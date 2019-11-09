#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
	#define LIB_EXPORT __declspec(dllexport)
#else
	#define LIB_EXPORT
#endif

LIB_EXPORT bool wrap_initializeFreetype();
LIB_EXPORT void wrap_deinitializeFreetype();

LIB_EXPORT void setParameters(double dfRange, int fontSize, bool fixWinding);
LIB_EXPORT int initFont(char* filename, unsigned char* metrics_data);
LIB_EXPORT void unloadFonts();
LIB_EXPORT bool getGlyphMetrics(int font, int charcode, unsigned char* output);
LIB_EXPORT int getKerning(int font, int left, int right);
LIB_EXPORT unsigned char* getFontName(int font, size_t* size);

LIB_EXPORT void beginAtlas(int atlasWidth, int atlasHeight, int defaultAlpha);
LIB_EXPORT void endAtlas(char* output);

LIB_EXPORT bool generateSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty);
LIB_EXPORT bool generatePSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty);
LIB_EXPORT bool generateMSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty);
LIB_EXPORT bool rasterizeGlyph(int slot, int charcode, int width, int height, int ox, int oy);

#ifdef __cplusplus
}
#endif