# Fontgen

Font rasterizer for Heaps based on Msdfgen. Primary target is automation of font rasterization with Signed Distance Field method.

## Usage
So far tool is built only with Hashlink VM and Windows, but with appropriate config should also work on Mac/Linux, as well as HXCPP/Eval/HLC.  
Command-line interface is currently limited to input config file and logger switches.  
Note that on Windows, HL should see the `msdfgen.dll` and `ammer_msdfgen.hdll`, so it should be either current working directory or in PATH.  
Warning: Some image viewers do not follow PNG specification properly and show some rasterized images as pure white.
This is an issue with particular decoder and file itself is correct. Known affected viewers: XNView, FastStone Image Viewer.

## Warning
Make sure you use 32-bit Hashlink.

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
  "packer": {
    "size": Int,
    "width": Int,
    "height": Int,
    "pot": Bool,
    "exact": Bool,
    "sort": String,
    "algorithm": String,
    "heuristic": String,
    "useWasteMap": String
  },
  "template":String
}
```
* `input` - path to TTF file relative to JSON file. Optional if `inputs` is present.
* `inputs` - An array of TTF files relative to JSON file. Can be used as fallback fonts in order of appearance. Optional if `input` is present.
* `svgInput` - Description for generating font with glyphs created from svg shapes. See [SVG input description format](#SVG-input-description-format) for details.
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
* `template` - optional file name of config containing "default" values which would be inherited if not defined in main config.

#### Packer configuration
Optional packer configuration allows to fine-tune atlas creation.
* `size` - Shortcut to set both `width` and `height` with same value. Default max atlas size is 4096x4096
* `width` - Maximum output atlas width in pixels. Note that it does not ensure atlas would be of specified size.
* `height` - Maximum output atlas height in pixels.
* `pot` - Output image will be power-of-two in dimensions. Note that this operation can override maximum size
(for example 122 max size can output 128px image), and packing of content happens within boundaries of define sizes, not power-of-two boundaries. Default: false
* `exact` - Ensures that output image is always of specified size. Default: false
* `sort` - Sets sorting function for glyphs prior packing. Prefixing name with `-` would reverse sort results.  
Available values: `width`, `height`, `area`, `perimeter` and `char`. Defaults to `-height`.  
* `algorithm` - Allows to select packing algorithm. Available values presented below. Defaults to `max-rect`
  * `guillotine` - Uses Guillotine algorithm. Currently not configurable and uses `BestLongSideFit` and `MaximizeArea` heuristics.
  * `naive-shelf` - Uses naive Shelf algorithm.
  * `shelf` - Uses Shelf algorithm. Default Heuristic is `BestArea`. Allows usage of waste map.
  * `simple-max-rect` - Uses simplified Max Rects algorithm.
  * `skyline` - Uses Skyline algorithm. Default Heuristic is `MinWasteFit`.
  * `max-rect` - Uses Max Rects algorithm. Default Heuristic is `BestLongSideFit`.
* `heuristic` - Specifies exact heuristic to use for some algorithms. **Case-sensitive.**
  * `shelf` - Dictates which shelf to choose:
    * `Next` - Always add the new rectangle to the last open shelf
    * `First` - Test each rectangle against each shelf in turn and pack it to the first where it fits
    * `BestArea` - Choose the shelf with smallest remaining shelf area
    * `WorstArea` - Choose the shelf with the largest remaining shelf area
    * `BestHeight` - Choose the smallest shelf (height-wise) where the rectangle fits
    * `BestWidth` - Choose the shelf that has the least remaining horizontal shelf space available after packing
    * `WorstWidth` - Choose the shelf that will have most remainining horizontal shelf space available after packing
  * `skyline` - Dictates prefered insertion location:
    * `BottomLeft`
    * `MinWasteFit`
  * `max-rect` - Dictates which rects is preferred when inserting:
    * `BestShortSideFit`
    * `BestLongSideFit`
    * `BestAreaFit`
    * `BottomLeftRule`
    * `ContactPointRule`
* `useWasteMap` - Enables or disables usage of waste maps for some algorithms.

See [`test/config.json`](test/config.json) for example config.

### Switches

* `-info` - enables logging of processing progress.
* `-nowarnings` - disables logging of processing warnings.
* `-timings` - enables logging of processing timings for each step.
* `-printmissing` - enables printing of all characters that were not present in ttf files but were required by charsets.
* `-silent` - suppresses all logging.
* `-verbose` - enables all logging.
* `-help` - Prints [help](src/help.txt) file and exits.
* `-stdin` - Allows to pass json config via stdin. Note that current working directory will be considered as a root path for font lookup.
* `-sharedatlas` - Enables shared texture for all configs. Spacing settings and textrue filename will be taken from the first config.

### Processor options
All processor options can be used as switches to enable them on all configurations. For example `-allownonprint`

* `allownonprint` - Enables rasterization of non-printing characters from range U+00 to U+1F plus U+7F (DEL). Disabled by default as to not produce warning about missing glyphs.
* `r8raster` - Forces greyscale rasterization without usage of alpha when using `raster` mode.

### .fnt file additions
Tool adds extra line at the end of `.fnt` file describing used SDF method that would allow decoder to determine parameters that are required to render the font.  
SDF descriptor presents itself as:
```
sdf mode=<mode> size=<dfSize>
```
It is put at the end of file, because some parsers depend on ordering of lines and may break if inserted between `info` and `chars` blocks.

### SVG input description format
Value of `svgInput` parameter should be an object with pairs where key is a character and value is a description of where to get shape for this character appearance.
Description contains name of svg file and (optional) `id` attribute of path node in svg file. If you edit svg file with Inkscape, you can assign `id` attribute in "XML Editor" panel available trough "edit" menu. One character can be generated from single path node only. Clockwise/counterclockwise direction defines if the path would be hole or fill. Example:
`{"s":"drawing.svg:star", "d":"drawing.svg:donut", "a":"drawing.svg:a"}`

## Compilation

TODO: More detailed
* Under windows it is possible to use build scripts with following prerequisites:
  
  * `build-msdfgen.cmd` compiles msdfgen and uses freetype dependency from vcpkg, so vcpkg should be installed as well as freetype package. And `%vcpkg_path%` env var should point to vcpkg location.
  * `build-msdfgen_lib.cmd` and `compile-hlc.bat` call `vcvars` to raise VS environment so there should be such cmd/bat file available through %path%. In my case it looks like `call "%path_to_VS%\VC\Auxiliary\Build\vcvars32.bat" `.
  * `%HLPATH%` should point to Hashlink installation.
* Haxe Libraries:
  * [ammer](https://github.com/Aurel300/ammer/)
  * bin-packing (Haxelib version)
* Use MSVC in x86 mode, because ammer/hl don't like x64.
* Compile msdfgen in `native/msdfgen`  
Windows note: when using `cmake` it may fail at finding `freetype` lib. It's includes and .lib files are located in `native/msdfgen/freetype/` directory.
* Compile ammer library in `native`
* Run `build-hl.hxml` to compile hdll and the tool.
Windows note: Make sure you are running in msvc envrionment, sicne ammer needs it to compile .hdll file.
Ammer note: You probably will need to point at hashlink includes and lib files with `-D ammer.hl.hlInclude=<path-to-hashlink>/include -D ammer.hl.hlLibrary=<path-to-hashlink>`, see ammer lib for more details.
* Put `msdfgen.dll` from `native` and `ammer_msdfgen.hdll` from `native/hl` near `bin/fontgen.hl`
* You're good to go.

### MacOS
- setup ammer using git. Known working commit - `b922a96`
- clone repo recursively, or run `git submodule init && git submodule update` after cloning the repo
- run `build-msdfgen.sh`. This should build all the object file needed and the dylib needed
- run `haxe build-hl.hxml` to compile hdll
- copy `native/libmsdfgen_lib.dylib` to `./bin/`
- run `hl fontgen.hl` from the bin folder and it should work


# License
* Source code is licensed under MIT
* `ammer`, `bin-packing` and `msdfgen` are under MIT
* Sample font files are licensed under SIL Open Font License, see [LICENSE](ttf/LICENSE/) folder for their respective license files.
* Msdfgen dependencies
  * `FreeType` - GPL2
  * `lodepng` - Zlib
  * `tinyxml` - Zlib

Welcome to licensing hell.