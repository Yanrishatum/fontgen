#include <stdio.h>
#include <iostream>
#include "msdfgen_lib.h"
#include "msdfgen/msdfgen.h"
#include "msdfgen/msdfgen-ext.h"

#ifdef __cplusplus
extern "C" {
#endif

using namespace msdfgen;

FreetypeHandle* ft = NULL;
FontHandle* font = NULL;
double range = 4.0;
double scale = 1.0;
Bitmap<float, 3> atlasPixels;

LIB_EXPORT bool wrap_initializeFreetype() {
	ft = initializeFreetype();
	return ft != NULL;
}

LIB_EXPORT void wrap_deinitializeFreetype() {
	deinitializeFreetype(ft);
}

LIB_EXPORT bool wrap_loadFont(char* filename) {
	font = loadFont(ft, filename);
	return font != NULL;
}

LIB_EXPORT void wrap_unloadFont() {
	destroyFont(font);
	font = NULL;
}

LIB_EXPORT void beginAtlas(int atlasWidth, int atlasHeight) {
	atlasPixels = Bitmap<float, 3>(atlasWidth, atlasHeight);
}

LIB_EXPORT void setParameters(double dfRange, double _scale) {
	scale = _scale;
	range = dfRange / _scale;
}

LIB_EXPORT void endAtlas(char* output) {
	savePng(atlasPixels, output);
}

LIB_EXPORT bool generateSDFGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty) {
	Shape glyph;
	if (loadGlyph(glyph, font, charcode)) {
		glyph.normalize();
		Bitmap<float, 1> sdf(width, height);
		generateSDF(sdf, glyph, range, scale, Vector2(tx, ty));
		oy = atlasPixels.height() - height - oy;
		for (int y = 0; y < height; y++) {
			float* it = atlasPixels(ox, oy + y);
			for (int x = 0; x < width; x++) {
				float px = *sdf(x, y);
				*it++ = px;
				*it++ = px;
				*it++ = px;
			}
		}
		return true;
	}
	return false;
}

LIB_EXPORT bool generatePSDFGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty) {
	Shape glyph;
	if (loadGlyph(glyph, font, charcode)) {
		glyph.normalize();
		Bitmap<float, 1> sdf(width, height);
		generatePseudoSDF(sdf, glyph, range, scale, Vector2(tx, ty));
		oy = atlasPixels.height() - height - oy;
		for (int y = 0; y < height; y++) {
			float* it = atlasPixels(ox, oy + y);
			for (int x = 0; x < width; x++) {
				float px = *sdf(x, y);
				*it++ = px;
				*it++ = px;
				*it++ = px;
			}
		}
		return true;
	}
	return false;
}

LIB_EXPORT bool generateMSDFGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty) {
	Shape glyph;
	if (loadGlyph(glyph, font, charcode)) {
		glyph.normalize();
		edgeColoringSimple(glyph, 3, 0);
		Bitmap<float, 3> msdf(width, height);
		generateMSDF(msdf, glyph, range, scale, Vector2(tx, ty));
		
		oy = atlasPixels.height() - height - oy;
		for (int y = 0; y < height; y++) {
			memcpy( atlasPixels(ox, oy + y), msdf(0, y), width * 3 * sizeof(float));
		}
		
		return true;
	}
	return false;
}

LIB_EXPORT bool rasterizeGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty) {
	Shape glyph;
	if (loadGlyph(glyph, font, charcode)) {
		glyph.normalize();
		edgeColoringSimple(glyph, 3, 0);
		int dfSize = 6;
		Bitmap<float, 3> msdf(width+dfSize, height+dfSize);
		generateMSDF(msdf, glyph, dfSize / scale, scale, Vector2(tx+(dfSize>>1), ty+(dfSize>>1)));
		Bitmap<float, 1> raster(width, height);
		renderSDF(raster, msdf, dfSize);
		
		oy = atlasPixels.height() - height - oy;
		for (int y = 0; y < height; y++) {
			float* it = atlasPixels(ox, oy + y);
			for (int x = 0; x < width; x++) {
				float px = *raster(x, y);
				*it++ = px;
				*it++ = px;
				*it++ = px;
			}
		}
		
		return true;
	}
	return false;
}

#ifdef __cplusplus
}
#endif
