# Fontgen

Font rasterizer for Heaps based on Msdfgen. Primary target is automation of font rasterization with Signed Distance Field method.

## Usage
So far tool is built only with Hashlink VM and Windows, but with appropriate config should also work on Mac/Linux, as well as HXCPP/Eval/HLC.  
Command-line interface is currently limited to input config file and logger switches.  
Note that on Windows, HL should see the `msdfgen.dll` and `ammer_msdfgen.hdll`, so it should be either current working directory or in PATH.

### General usage and config file structure.
Run tool with: `hl fontgen.hl <input file> [switches]`  
Input file should contain a JSON object or array of objects describing font rasterization parameters.
```haxe
{
	"input": String,
	"inputs": Array<String>,
	"output": String,
	"mode": SDFMode,
	"dfSize": Int,
	"charset": Array<CharsetConf>,
  "options": Array<ProcessorOption>,
	"fontSize": Int,
	"padding": { "top": Int, "bottom": Int, "left": Int, "right": Int },
	"spacing": { "x": Int, "y": Int },
}
```
* `input` - path to TTF file relative to JSON file. Optional if `inputs` is present.
* `inputs` - An array of TTF files relative to JSON file. Can be used as fallback fonts in order of appearance. Optional if `input` is present.
* `output` - Path to output .fnt file relative to JSON file.
* `mode` - Describes mode in which glyphs are going to be generated. Possible values are: `msdf`, `sdf`, `psdf` and `raster`.
MSDF provides best accuracy by utilizing RGB channels, all others produce grayscale image.
* `dfSize` - Distance field range in pixels. Can be omitted for `raster` mode.
* `charset` - An array describing which characters should be rasterized in next priority:
  1. Try to find unicode block charset (or alias) described in `Charset.hx`
  2. If string points to a file, try to interpret it's contents.
    1. If file is a valid XML file, rasterizer will use characters present in all nodes that contain text. (Attributes and comments are ignored)
    2. Use contents of a file as a list of characters to rasterize.
  3. Use string as a list of characters to rasterize.
  
  Additionally, array nesting is supported.
* `fontSize` - desired font size in pixels.
* `padding` - optional and defaults to `0`. Describes extra padding for glyphs on the texture in pixels.
* `spacing` - optional and defaults to `1`. Describes spacing between glyphs on the texture in pixels.
* `options` - optional list of extra configuration flags. See below.

See [`test/config.json`](test/config.json) for example config.

### Switches

* `-info` - enables logging of processing progress.
* `-nowarnings` - disables logging of processing warnings.
* `-timings` - enables logging of processing timings for each step.
* `-printmissing` - enables printing of all characters that were not present in ttf files but were required by charsets.
* `-silent` - suppresses all logging.
* `-verbose` - enables all logging.
* `-help` - Prints [help](src/help.txt) file and exits.

### Processor pptions
All processor options can be used as switches to enable them on all configurations. For example `-fixwinding`

* `fixwinding` - Adds extra winding check for glyphs to ensure they are rendered properly. Is comparably slow and disabled by default.
* `allownonprint` - Enables rasterization of non-printing characters from range U+00 to U+1F plus U+7F (DEL). Disabled by default as to not produce warning about missing glyphs.

### .fnt file additions
Tool adds extra line at the end of `.fnt` file describing used SDF method that would allow decoder to determine parameters that are required to render the font.  
SDF descriptor presents itself as:
```
sdf mode=<mode> size=<dfSize>
```
It is put at the end of file, because some parsers depend on ordering of lines and may break if inserted between `info` and `chars` blocks.

## Compilation

TODO: More detailed
* Haxe Libraries:
  * [ammer](https://github.com/Aurel300/ammer/)
  * bin-packing (Haxelib version)
* Use MSVC in x86 mode, because ammer/hl don't like x64.
* Compile msdfgen in `native/msdfgen`  
Windows note: when using `cmake` it may fail at finding `freetype` lib. It's includes and .lib files are located in `native/msdfgen/freetype/` directory.
* Compile ammer library in `native`  
Mac/Linux note: Makefile is not valid, as it should also point at compiled `msdfgen.so/dylib` and `freetype.so/dylib`. Feel free to PR fixes, as I'm not using those OS ;)
* Run `build-hl.hxml` to compile hdll and the tool.  
Windows note: Make sure you are running in msvc envrionment, sicne ammer needs it to compile .hdll file.  
Ammer note: You probably will need to point at hashlink includes and lib files with `-D ammer.hl.hlInclude=<path-to-hashlink>/include -D ammer.hl.hlLibrary=<path-to-hashlink>`, see ammer lib for more details.
* Put `msdfgen.dll` from `native` and `ammer_msdfgen.hdll` from `native/hl` near `bin/fontgen.hl`
* You're good to go.

# License
* Source code is licensed under MIT
* `ammer`, `bin-packing` and `msdfgen` are under MIT
* Sample font files are licensed under SIL Open Font License, see [LICENSE](ttf/LICENSE/) folder for their respective license files.
* Msdfgen dependencies
  * `FreeType` - GPL2
  * `lodepng` - Zlib
  * `tinyxml` - Zlib

Welcome to licensing hell.