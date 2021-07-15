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

LIB_EXPORT int initFont(char* filename, unsigned char* metrics_data, int fontSize);
LIB_EXPORT void unloadFonts();
LIB_EXPORT bool getGlyphMetrics(int font, int charcode, unsigned char* output);
LIB_EXPORT int getKerning(int font, int left, int right);
LIB_EXPORT unsigned char* getFontName(int font, size_t* size);

LIB_EXPORT void beginAtlas(int atlasWidth, int atlasHeight, int defaultColor, bool _enforceR8);
LIB_EXPORT void endAtlas(char* output);

LIB_EXPORT bool generateSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty, bool ccw, double range);
LIB_EXPORT bool generatePSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty, bool ccw, double range);
LIB_EXPORT bool generateMSDFGlyph(int slot, int charcode, int width, int height, int ox, int oy, double tx, double ty, bool ccw, double range);
LIB_EXPORT bool rasterizeGlyph(int slot, int charcode, int width, int height, int ox, int oy);

LIB_EXPORT int initSvgShape(const char *path, int fontSize, double scale);
LIB_EXPORT bool generateSDFPath(int slot, double width, double height,  int ox, int oy, double tx, double ty, double range, double scale);

#ifdef __cplusplus
}
#endif