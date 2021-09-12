#include <stdio.h>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include "msdfgen_lib.h"
#include "msdfgen/msdfgen.h"
#include "msdfgen/ext/import-svg.h"
#include "msdfgen/msdfgen-ext.h"
#include <ft2build.h>
#include <lodepng.h>
#include FT_FREETYPE_H
#include FT_OUTLINE_H
#include FT_TRUETYPE_TABLES_H
#include FT_SFNT_NAMES_H
#include FT_BITMAP_H

#ifdef __cplusplus
extern "C" {
#endif

using namespace msdfgen;

// Since we can't send structs/pointers to Haxe, store it locally and use slots for referencing.
struct FontSlot {
	FontHandle* font;
	FT_Face ft;
	double scale;
};

struct ShapeSlot {
	Shape* shape;
	double scale;
};

// Haxe struct for font metrics.
struct FontMetricsInternal {
	int ascent;
	int descent;
	int unitsPerEm;
	int baseLine;
	int lineHeight;
	int flags;
};

// Haxe struct for glyph metrics.
struct GlyphMetrics {
	int width;
	int height;
	int offsetX;
	int offsetY;
	int advanceX;
	int descent;
	int ccw;
};

FreetypeHandle* ft = NULL;
FT_Library ft_lib;
std::vector<FontSlot*> fonts;
std::vector<ShapeSlot*> shapes;

bool enforceR8 = false;
bool normalizeShapes = false;
Bitmap<byte, 4> atlasPixels;

LIB_EXPORT bool wrap_initializeFreetype() {
	ft = initializeFreetype();
	FT_Init_FreeType(&ft_lib);
	return ft != NULL;
}

LIB_EXPORT void wrap_deinitializeFreetype() {
	if ( ft != NULL ) {
		deinitializeFreetype(ft);
		FT_Done_FreeType(ft_lib);
	}
}


LIB_EXPORT int initFont(char* filename, unsigned char* metrics_data, int fontSize) {
	FontHandle* msdfHandle = loadFont(ft, filename);
	if (msdfHandle != NULL) {
		int index = fonts.size();
		struct FontSlot* slot = (FontSlot*)malloc(sizeof(FontSlot));
		slot->font = msdfHandle;
		
		FT_New_Face(ft_lib, filename, 0, &slot->ft);
		slot->scale = (double)fontSize / (double)slot->ft->units_per_EM * 64.;
		FT_Set_Pixel_Sizes(slot->ft, 0, fontSize);
		
		FontMetricsInternal* metrics = reinterpret_cast<FontMetricsInternal*>(metrics_data);
		metrics->ascent = slot->ft->ascender;
		metrics->descent = slot->ft->descender;
		metrics->unitsPerEm = slot->ft->units_per_EM;
		metrics->baseLine = (slot->ft->size->metrics.ascender + 32) >> 6;
		metrics->lineHeight = (slot->ft->size->metrics.height + 32) >> 6;
		TT_Header* header = (TT_Header*)FT_Get_Sfnt_Table(slot->ft, FT_SFNT_HEAD);
		metrics->flags = (int)header->Mac_Style | header->Flags << 16;
		
		fonts.push_back(slot);
		return index;
	}
	return -1;
}

// No single font unload, because there's no point.
LIB_EXPORT void unloadFonts() {
	std::vector<FontSlot*>::iterator it = fonts.begin();
	int size = fonts.size();
	while ( size-- > 0 ) {
		FontSlot* handle = *it++;
		destroyFont(handle->font);
		FT_Done_Face(handle->ft);
		free(handle);
	}
	fonts.clear();
}

LIB_EXPORT unsigned char* getFontName(int font, size_t *size) {
	FT_Face face = fonts[font]->ft;
	FT_SfntName name;
	int count = FT_Get_Sfnt_Name_Count(face);
	for (int i = 0; i < count; i++) {
		FT_Get_Sfnt_Name(face, i, &name);
		if (name.name_id == 4 && (name.platform_id == 3 || name.platform_id == 0) && name.language_id == 0x409) {
			unsigned char* data = (unsigned char*)malloc(name.string_len);
			*size = name.string_len;
			memcpy(data, name.string, name.string_len);
			return data;
		}
	}
	*size = 0;
	return nullptr;
}

LIB_EXPORT bool getGlyphMetrics(int font, int charcode, unsigned char* output) {
	FT_Face face = fonts[font]->ft;
	FT_UInt index = FT_Get_Char_Index(face, charcode);
	// In case we actually try to draw charcode 0.
	if (index == 0 && charcode != 0) return false;
	FT_Error err = FT_Load_Glyph(face, index, FT_LOAD_DEFAULT);
	if (err) return false;
	FT_GlyphSlot slot = face->glyph;
	GlyphMetrics* metrics = reinterpret_cast<GlyphMetrics*>(output);
	
	metrics->width = slot->bitmap.width;
	metrics->height = slot->bitmap.rows;
	metrics->offsetX = slot->bitmap_left;
	metrics->offsetY = slot->bitmap_top;
	metrics->advanceX = (slot->advance.x + 32) >> 6;
	metrics->descent = (slot->metrics.horiBearingY - slot->metrics.height) >> 6;
	metrics->ccw = FT_Outline_Get_Orientation(&slot->outline);
	// Slower alternative:
	// FT_BBox bbox;
	// FT_Outline_Get_CBox(&slot->outline, &bbox);
	// metrics->descent = bbox.yMin >> 6;
	return true;
}

LIB_EXPORT int getKerning(int font, int left, int right) {
	FT_Vector vec;
	FT_Face face = fonts[font]->ft;
	FT_Error err = FT_Get_Kerning(face, FT_Get_Char_Index(face, left), FT_Get_Char_Index(face, right), FT_KERNING_DEFAULT, &vec);
	if (err) return err;
	return (vec.x+32) >> 6;
}

LIB_EXPORT void beginAtlas(int atlasWidth, int atlasHeight, int defaultColor, bool _enforceR8) {
	atlasPixels = Bitmap<byte, 4>(atlasWidth, atlasHeight);
	enforceR8 = _enforceR8;
	const int max = atlasWidth * atlasHeight;
	unsigned int* pixels = (unsigned int*)(unsigned char*)atlasPixels;
	// Ensure empty memory
	memset(pixels, 0, max*sizeof(int));
	if (defaultColor != 0) {
		for (int i = 0; i < max; i++) {
			pixels[i] = defaultColor;
		}
	}
}

LIB_EXPORT void endAtlas(char* output) {
	const unsigned char* pixels = (const unsigned char*)atlasPixels;
	lodepng::encode(output, pixels, atlasPixels.width(), atlasPixels.height(), LCT_RGBA);
	// TODO: Optimization: Save in appropriate format - grayscale (SDF/PSDF), RGB (MSDF) and RGBA for raster.
}

void normalizeShape(Shape &shape) {
	if (normalizeShapes) {
		shape.normalize();
	} else {
		for (std::vector<msdfgen::Contour>::iterator contour = shape.contours.begin(); contour != shape.contours.end(); ++contour) {
			if (contour->edges.size() == 1) {
				contour->edges.clear();
			}
		}
	}
}

inline void copyGrayBitmapToAtlas(Bitmap<float, 1> sdf, int width, int height, int ox, int oy, bool ccw) {
		oy += height;
		if (ccw) {
			for (int y = height - 1; y >= 0; y--) {
				byte* it = atlasPixels(ox, oy - y);
				for (int x = 0; x < width; x++) {
					byte px = pixelFloatToByte(1.f - *sdf(x, y));
					*it++ = px;
					*it++ = px;
					*it++ = px;
					*it++ = 0xff;
				}
			}
		} else {
			for (int y = height - 1; y >= 0; y--) {
				byte* it = atlasPixels(ox, oy - y);
				for (int x = 0; x < width; x++) {
					byte px = pixelFloatToByte(*sdf(x, y));
					*it++ = px;
					*it++ = px;
					*it++ = px;
					*it++ = 0xff;
				}
			}
		}
}

inline void copyColorBitmapToAtlas(Bitmap<float, 3> msdf, int width, int height, int ox, int oy, bool ccw){
		oy += height;
		if (ccw) {
			for (int y = height - 1; y >= 0; y--) {
				byte* it = atlasPixels(ox, oy - y);
				for (int x = 0; x < width; x++) {
					*it++ = pixelFloatToByte(1.f - msdf(x, y)[0]);
					*it++ = pixelFloatToByte(1.f - msdf(x, y)[1]);
					*it++ = pixelFloatToByte(1.f - msdf(x, y)[2]);
					*it++ = 0xff;
				}
			}
		} else {
			for (int y = height - 1; y >= 0; y--) {
				byte* it = atlasPixels(ox, oy - y);
				for (int x = 0; x < width; x++) {
					*it++ = pixelFloatToByte(msdf(x, y)[0]);
					*it++ = pixelFloatToByte(msdf(x, y)[1]);
					*it++ = pixelFloatToByte(msdf(x, y)[2]);
					*it++ = 0xff;
				}
			}
		}

}

LIB_EXPORT bool generateSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty, bool ccw, double range) {
	if (width == 0 || height == 0) return true;
	
	Shape glyph;
	if (loadGlyph(glyph, fonts[slot]->font, charcode)) {
		normalizeShape(glyph);
		Bitmap<float, 1> sdf(width, height);
		double scale = fonts[slot]->scale;
		generateSDF(sdf, glyph, range / scale, scale, Vector2(tx/scale, ty/scale));
		copyGrayBitmapToAtlas(sdf, width, height, ox, oy, ccw);
		return true;
	}
	return false;
}

LIB_EXPORT bool generatePSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty, bool ccw, double range) {
	if (width == 0 || height == 0) return true;
	
	Shape glyph;
	if (loadGlyph(glyph, fonts[slot]->font, charcode)) {
		normalizeShape(glyph);
		Bitmap<float, 1> sdf(width, height);
		double scale = fonts[slot]->scale;
		generatePseudoSDF(sdf, glyph, range / scale, scale, Vector2(tx/scale, ty/scale));
		copyGrayBitmapToAtlas(sdf, width, height, ox, oy, ccw);
		return true;
	}
	return false;
}

LIB_EXPORT bool generateMSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty, bool ccw, double range) {
	if (width == 0 || height == 0) return true;
	Shape glyph;
	if (loadGlyph(glyph, fonts[slot]->font, charcode)) {
		normalizeShape(glyph);
		edgeColoringSimple(glyph, 3, 0);
		Bitmap<float, 3> msdf(width, height);
		double scale = fonts[slot]->scale;
		generateMSDF(msdf, glyph, range / scale, scale, Vector2(tx/scale, ty/scale));
		copyColorBitmapToAtlas(msdf, width, height, ox, oy, ccw);
		return true;
	}
	return false;
}

LIB_EXPORT bool rasterizeGlyph(int slot, int charcode, int width, int height, int ox, int oy) {
	if (width == 0 || height == 0) return true;
	
	FT_Error err = FT_Load_Char(fonts[slot]->ft, charcode, FT_LOAD_RENDER);
	if (err) return false;
	FT_Bitmap* bitmap = &fonts[slot]->ft->glyph->bitmap;
	int multiplier = 1;
	switch (bitmap->pixel_mode) {
		case FT_PIXEL_MODE_MONO:
			FT_Bitmap grayBtm;
			FT_Bitmap_Init(&grayBtm);
			FT_Bitmap_Convert(ft_lib, bitmap, &grayBtm, 1);
			bitmap = &grayBtm;
			multiplier = 0xff;
			// fall trough
		case FT_PIXEL_MODE_GRAY:
			if (enforceR8) {
				for (int y = 0; y < height; y++) {
					byte* it = atlasPixels(ox, oy + y);
					for (int x = 0; x < width; x++) {
						unsigned char px = bitmap->buffer[(y) * bitmap->width + x] * multiplier;
						*it++ = px;
						*it++ = px;
						*it++ = px;
						*it++ = 0xff;
					}
				}
			} else {
				for (int y = 0; y < height; y++) {
					byte* it = atlasPixels(ox, oy + y);
					for (int x = 0; x < width; x++) {
						unsigned char px = bitmap->buffer[(y) * bitmap->width + x] * multiplier;
						*it++ = 0xff;
						*it++ = 0xff;
						*it++ = 0xff;
						*it++ = px;
					}
				}
			}
			
			if (bitmap->pixel_mode == FT_PIXEL_MODE_MONO) {
				FT_Bitmap_Done(ft_lib, &grayBtm);
			}
			return true;
			break;
		default:
			std::cout << "[Error] Unsupported pixel mode: " << (int)bitmap->pixel_mode << "\n";
			// TODO: Other pixel modes
			return false;
	}
}

 LIB_EXPORT char* getBounds(int slot){
 		Shape* shape = shapes[slot]->shape;
 		Shape::Bounds b =  shape->getBounds();
 		std::stringstream str;
 		str << "{\"l\":" << b.l << ", \"r\":"  << b.r << ", \"t\":" << b.t << ", \"b\":" << b.b << "}";
 		return &(str.str()[0]);
 }

LIB_EXPORT int initSvgShape(const char *path, int fontSize, double scale){
		Shape* shape = new Shape;
		buildShapeFromSvgPath(*shape, path, fontSize*1.4);
		bool autoFrame = true;
		Vector2 translate;
		bool scaleSpecified = false;
		Shape::Bounds bounds = { };
		shape->normalize();
        shape->inverseYAxis = true;

		bounds = shape->getBounds();
		int index = shapes.size();
		struct ShapeSlot* slot = (ShapeSlot*)malloc(sizeof(ShapeSlot));
		slot->scale = scale;
		slot->shape = shape;
		shapes.push_back(slot);

		Shape* shaper = shapes[index]->shape;
		Shape::Bounds b =  shaper->getBounds();

		return index;
}
LIB_EXPORT bool generateSDFPath( int slotId, double width, double height,  int ox, int oy, double tx, double ty, double range, double _scale) {
		ShapeSlot* slot = shapes[slotId];
		Bitmap<float, 1> sdf(width, height);
		Shape* shape = slot->shape;
		generateSDF(sdf, *shape, range , Vector2(slot->scale, slot->scale), Vector2(tx, ty));
		copyGrayBitmapToAtlas(sdf, width, height, ox, oy, false);
		return true;
}

LIB_EXPORT bool generateMSDFPath( int slotId, double width, double height,  int ox, int oy, double tx, double ty, double range, double _scale) {
		ShapeSlot* slot = shapes[slotId];
		Bitmap<float, 3> sdf(width, height);
		Shape* shape = slot->shape;
		edgeColoringSimple(*shape, 3, 0);
		generateMSDF(sdf, *shape, range , Vector2(slot->scale, slot->scale), Vector2(tx, ty));
		copyColorBitmapToAtlas(sdf, width, height, ox, oy, false);
		return true;
}

LIB_EXPORT bool generatePSDFPath( int slotId, double width, double height,  int ox, int oy, double tx, double ty, double range, double _scale) {
		ShapeSlot* slot = shapes[slotId];
		Bitmap<float, 1> sdf(width, height);
		Shape* shape = slot->shape;
		generatePseudoSDF(sdf, *shape, range , Vector2(slot->scale, slot->scale), Vector2(tx, ty));
		copyGrayBitmapToAtlas(sdf, width, height, ox, oy, false);
		return true;
}

#ifdef __cplusplus
}
#endif
