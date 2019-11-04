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
LIB_EXPORT bool wrap_loadFont(char* filename);
LIB_EXPORT void wrap_unloadFont();
LIB_EXPORT void beginAtlas(int atlasWidth, int atlasHeight);
LIB_EXPORT void setParameters(double dfRange, double _scale);
LIB_EXPORT void endAtlas(char* output);
LIB_EXPORT bool generateSDFGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty);
LIB_EXPORT bool generatePSDFGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty);
LIB_EXPORT bool generateMSDFGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty);
LIB_EXPORT bool rasterizeGlyph(int charcode, int width, int height, int ox, int oy, double tx, double ty);

// LIB_EXPORT bool wrap_initializeFreetype();
// LIB_EXPORT void wrap_deinitializeFreetype();
  
#ifdef __cplusplus
}
#endif