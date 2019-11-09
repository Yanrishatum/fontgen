#include <stdio.h>
#include <cstdlib>
#include <iostream>
#include "msdfgen_lib.h"
#include "msdfgen/msdfgen.h"
#include "msdfgen/msdfgen-ext.h"
#include <ft2build.h>
#include <lodepng.h>
#include FT_FREETYPE_H
#include FT_OUTLINE_H
#include FT_TRUETYPE_TABLES_H
#include FT_SFNT_NAMES_H

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

// Haxe struct for font metrics.
struct FontMetrics {
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
};

FreetypeHandle* ft = NULL;
FT_Library ft_lib;
std::vector<FontSlot*> fonts;

int fontSize = 24;
double range = 4.0;
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

LIB_EXPORT void setParameters(double dfRange, int _fontSize) {
	range = dfRange;
	fontSize = _fontSize;
}

LIB_EXPORT int initFont(char* filename, unsigned char* metrics_data) {
	FontHandle* msdfHandle = loadFont(ft, filename);
	if (msdfHandle != NULL) {
		int index = fonts.size();
		struct FontSlot* slot = (FontSlot*)malloc(sizeof(FontSlot));
		slot->font = msdfHandle;
		
		FT_New_Face(ft_lib, filename, 0, &slot->ft);
		slot->scale = (double)fontSize / (double)slot->ft->units_per_EM * 64.;
		FT_Set_Pixel_Sizes(slot->ft, 0, fontSize);
		
		FontMetrics* metrics = reinterpret_cast<FontMetrics*>(metrics_data);
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

LIB_EXPORT void beginAtlas(int atlasWidth, int atlasHeight, int defaultAlpha) {
	atlasPixels = Bitmap<byte, 4>(atlasWidth, atlasHeight);
	const int max = atlasWidth * atlasHeight * 4;
	unsigned char* pixels = (unsigned char*)atlasPixels;
	memset(pixels, 0, max); // Because for some reason there's garbage in allocated memory?
	if (defaultAlpha != 0) {
		char alpha = (char)defaultAlpha;
		for (int i = 3; i < max; i += 4) {
			pixels[i] = alpha;
		}
	}
}

LIB_EXPORT void endAtlas(char* output) {
	const unsigned char* pixels = (const unsigned char*)atlasPixels;
	lodepng::encode(output, pixels, atlasPixels.width(), atlasPixels.height(), LCT_RGBA);
	// TODO: Optimization: Save in appropriate format - grayscale (SDF/PSDF), RGB (MSDF) and RGBA for raster.
}

LIB_EXPORT bool generateSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty) {
	if (width == 0 || height == 0) return true;
	
	Shape glyph;
	if (loadGlyph(glyph, fonts[slot]->font, charcode)) {
		glyph.normalize();
		Bitmap<float, 1> sdf(width, height);
		double scale = fonts[slot]->scale;
		generateSDF(sdf, glyph, range / scale, scale, Vector2(tx/scale, ty/scale));
		oy += height;
		for (int y = height - 1; y >= 0; y--) {
			byte* it = atlasPixels(ox, oy - y);
			for (int x = 0; x < width; x++) {
				float px = pixelFloatToByte(*sdf(x, y));
				*it++ = px;
				*it++ = px;
				*it++ = px;
				*it++ = 0xff;
			}
		}
		return true;
	}
	return false;
}

LIB_EXPORT bool generatePSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty) {
	if (width == 0 || height == 0) return true;
	
	Shape glyph;
	if (loadGlyph(glyph, fonts[slot]->font, charcode)) {
		glyph.normalize();
		Bitmap<float, 1> sdf(width, height);
		double scale = fonts[slot]->scale;
		generatePseudoSDF(sdf, glyph, range / scale, scale, Vector2(tx/scale, ty/scale));
		oy += height;
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
		return true;
	}
	return false;
}

LIB_EXPORT bool generateMSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty) {
	if (width == 0 || height == 0) return true;
	Shape glyph;
	if (loadGlyph(glyph, fonts[slot]->font, charcode)) {
		glyph.normalize();
		edgeColoringSimple(glyph, 3, 0);
		Bitmap<float, 3> msdf(width, height);
		double scale = fonts[slot]->scale;
		generateMSDF(msdf, glyph, range / scale, scale, Vector2(tx/scale, ty/scale));
		oy += height;
		for (int y = height - 1; y >= 0; y--) {
			byte* it = atlasPixels(ox, oy - y);
			for (int x = 0; x < width; x++) {
				*it++ = pixelFloatToByte(msdf(x, y)[0]);
				*it++ = pixelFloatToByte(msdf(x, y)[1]);
				*it++ = pixelFloatToByte(msdf(x, y)[2]);
				*it++ = 0xff;
			}
		}
		
		return true;
	}
	return false;
}

LIB_EXPORT bool rasterizeGlyph(int slot, int charcode, int width, int height, int ox, int oy) {
	if (width == 0 || height == 0) return true;
	
	FT_Error err = FT_Load_Char(fonts[slot]->ft, charcode, FT_LOAD_RENDER);
	if (err) return false;
	FT_Bitmap* bitmap = &fonts[slot]->ft->glyph->bitmap;
	switch (bitmap->pixel_mode) {
		case FT_PIXEL_MODE_GRAY:
			for (int y = 0; y < height; y++) {
				byte* it = atlasPixels(ox, oy + y);
				for (int x = 0; x < width; x++) {
					float px = bitmap->buffer[(y) * bitmap->width + x];
					*it++ = 0xff;
					*it++ = 0xff;
					*it++ = 0xff;
					*it++ = px;
				}
			}
			
			return true;
			break;
		default:
			// TODO: Other pixel modes
			return false;
	}
}

#ifdef __cplusplus
}
#endif
