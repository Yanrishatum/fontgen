import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import haxe.io.Path;
import binpacking.MaxRectsPacker;
import GlyphRender;
import haxe.io.Bytes;
import format.ttf.Reader;
import msdfgen.Msdfgen;

class Main {
	static inline var SIZE:Int = 4096;
	
	static var atlasWidth : Int;
	static var atlasHeight : Int;
	
	public static var verbose:Bool = false;
	public static var warnings:Bool = true;
	public static var info:Bool = false;
	public static var timings:Bool = false;
	public static var printMissing:Bool = false;
	
	static function main() {
		
		var configs = readInput();
		
		inline function ts() return haxe.Timer.stamp();
		
		var start = ts();
		Msdfgen.initializeFreetype();
		
		for (config in configs) {
			
			if (info) {
				Sys.println("[Info] Rendering mode: " + config.mode);
				Sys.println("[Info] Font size: " + config.fontSize);
				Sys.println("[Info] SDF size: " + config.dfSize);
				Sys.println("[Info] Output format: text .fnt");
			}
			
			var stamp = ts();
			var renderers:Array<GlyphRender> = [];
			for ( inp in config.inputs ) {
				if (info) Sys.println("[Info] TTF: " + inp);
				renderers.push(new GlyphRender(inp));
			}
			var ttfParse = ts();
			if (timings) Sys.println("[Timing] Parsed ttf: " + (ttfParse - stamp));
			
			// Find all corresponding glyphs to render.
			var missing:Array<Int> = [];
			var glyphs:Array<GlyphInfo> = [];
			var inserted:Array<Int> = [];
			for ( cset in Charset.parse(config.charset) ) {
				for (char in cset) {
					if (inserted.indexOf(char) != -1) continue; // Already rendering with another charset.
					var found = false;
					for (renderer in renderers) {
						var glyph = renderer.get(char);
						if (glyph == null) continue;
						glyphs.push(glyph);
						renderer.renderGlyphs.push(glyph);
						found = true;
						inserted.push(char);
						break;
					}
					if (!found) missing.push(char);
				}
			}
			
			var charsetProcess = ts();
			if ((warnings || printMissing) && missing.length != 0) {
				Sys.println('[Warn] Could not locate ${missing.length} glyphs!');
				if (printMissing) {
					Sys.print(missing[0] + ": " + String.fromCharCode(missing[0]));
					var i = 1, l = missing.length;
					while (i < l) {
						var char = missing[i++];
						Sys.print(", " + char + ": " + String.fromCharCode(char));
					}
					Sys.print("\n");
				}
			}
			if (info) Sys.println('[Info] Rendering ${inserted.length} glyphs');
			if (timings) Sys.println("[Timing] Glyph lookup: " + (charsetProcess - ttfParse));
			
			// var dfSize = (config.dfSize + 1) >> 1 << 1;
			var dfSize = config.dfSize;
			var halfDF = (dfSize * .5);
			var fontSize = config.fontSize;
			
			var extendWidth = config.padding.left + config.padding.right + dfSize + config.spacing.x;
			var extendHeight = config.padding.top + config.padding.bottom + dfSize + config.spacing.y;
			
			packGlyphs(glyphs, fontSize, extendWidth, extendHeight);
			// glyphs.sort(glyphSort)
			
			var glyphPacking = ts();
			if (info) Sys.println('[Info] Atlas size: ${atlasWidth}x${atlasHeight}');
			if (timings) Sys.println("[Timing] Glyph packing: " + (glyphPacking - charsetProcess));
			
			Msdfgen.beginAtlas(atlasWidth, atlasHeight);
			var paddingLeft = config.padding.left;
			var paddingTop = config.padding.top;
			var paddingBottom = config.padding.bottom;
			
			for (renderer in renderers) {
				if (renderer.renderGlyphs.length == 0) continue;
				Msdfgen.loadFont(renderer.file);
				Msdfgen.setParameters(dfSize, fontSize / (renderer.unitsPerEm / 64));
				if (info)
					Sys.println("[Info] Started rendering glyphs from " + renderer.file);
				
				
				inline function adjustRect(g:GlyphInfo) {
					g.rect.width -= config.spacing.x;
					g.rect.height -= config.spacing.y;
				}
				inline function glyphWidth(g:GlyphInfo) return Std.int(g.rect.width);
				inline function glyphHeight(g:GlyphInfo) return Std.int(g.rect.height);
				inline function canvasX(g:GlyphInfo) return Std.int(g.rect.x);
				inline function canvasY(g:GlyphInfo) return Std.int(g.rect.y);
				inline function translateX(g:GlyphInfo) return Math.ffloor(halfDF - renderer.toHPixel(g.xMin, fontSize)) + paddingLeft;
				inline function translateY(g:GlyphInfo) return Math.ffloor(halfDF + 1e-10 - renderer.toHPixel(g.yMin, fontSize)) + paddingBottom; // renderer.toHPixel(g.yMin, fontSize)
				
				switch (config.mode) {
					case "msdf":
						for (g in renderer.renderGlyphs) {
							adjustRect(g);
							Msdfgen.generateMSDFGlyph(g.char, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g), translateY(g));
						}
					case "sdf":
						for (g in renderer.renderGlyphs) {
							adjustRect(g);
							Msdfgen.generateSDFGlyph(g.char, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g), translateY(g));
						}
					case "psdf":
						for (g in renderer.renderGlyphs) {
							adjustRect(g);
							Msdfgen.generatePSDFGlyph(g.char, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g), translateY(g));
						}
					case "raster":
						for (g in renderer.renderGlyphs) {
							adjustRect(g);
							Msdfgen.rasterizeGlyph(g.char, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g), translateY(g));
						}
				}
				Msdfgen.unloadFont();
			}
			var pngPath = Path.withExtension(config.output, "png");
			Msdfgen.endAtlas(pngPath);
			var glyphRendering = ts();
			if (info)
				Sys.println("[Info] Writing PNG file to " + pngPath);
			if (timings) Sys.println("[Timing] Glyph rendering: " + (glyphRendering - glyphPacking));
			
			var file = new FntFile();
			var base = renderers[0];
			file.face = base.fontName;
			file.bold = base.bold;
			file.italic = base.italic;
			file.size = Math.ceil(fontSize);
			file.dfSize = dfSize;
			file.dfMode = config.mode;
			file.paddingRight = config.padding.right;
			file.paddingDown = config.padding.bottom;
			file.paddingLeft = config.padding.left;
			file.paddingUp = config.padding.top;
			file.spacingX = 0;
			file.spacingY = 0;
			file.texture = Path.withoutDirectory(pngPath);
			file.textureWidth = atlasWidth;
			file.textureHeight = atlasHeight;
			file.outline = 0;
			file.base = Math.ceil((base.baseLine / base.fontHeight) * fontSize);
			file.lineHeight = Math.ceil((base.lineHeight / base.fontHeight) * fontSize);
			
			for (g in glyphs) {
				file.chars.push({
					id: g.char,
					x: Std.int(g.rect.x),
					y: Std.int(g.rect.y),
					w: Std.int(g.rect.width),
					h: Std.int(g.rect.height),
					xa: Math.ceil((g.advance / g.renderer.unitsPerEm) * fontSize),
					xo: Math.ceil(-config.padding.left - halfDF + (g.xMin / g.renderer.fontHeight) * fontSize),
					yo: Math.ceil(-config.padding.top - halfDF + file.base - g.renderer.toPixel(g.yMax - (0.5 / fontSize * g.renderer.unitsPerEm), fontSize)),
				});
			}
			
			for (kern in base.kernings) {
				if (inserted.indexOf(kern.left) != -1 && inserted.indexOf(kern.right) != -1) {
					file.kernings.push({ first: kern.left, second: kern.right, amount: Math.round((kern.value / base.fontHeight) * fontSize) });
				}
			}
			
			File.saveContent(config.output, file.writeString());
			
			
			var ttfGen = ts();
			if (timings) {
				Sys.println("[Timing] FNT generation: " + (ttfGen - glyphRendering));
				Sys.println("[Timing] Total config processing time: " + (ttfGen - stamp));
			}
			
		}
		
		Msdfgen.deinitializeFreetype();
		if (timings && configs.length > 1) {
			Sys.println("[Timing] Total work time: " + (ts() - start));
		}
	}
	
	static function packGlyphs(glyphs:Array<GlyphInfo>, fontSize:Float, extendWidth:Int, extendHeight:Int) {
		
		glyphs.sort(glyphSort);
		
		var packer = new MaxRectsPacker(SIZE, SIZE, false);
		var xMax = 0;
		var yMax = 0;
		for (g in glyphs) {
			var render = g.renderer;
			var rect = g.rect = packer.insert(render.toIPixel(g.width, fontSize) + extendWidth, render.toIPixel(g.height, fontSize) + extendHeight, BestShortSideFit);
			var tmp = Std.int(rect.x + rect.width);
			if (tmp > xMax) xMax = tmp;
			tmp = Std.int(rect.y + rect.height);
			if (tmp > yMax) yMax = tmp;
		}
		atlasWidth = xMax;
		atlasHeight = yMax;
	}
	
	static function readInput():Array<GenConfig> {
		var args = Sys.args();
		var flags = args.filter( (a) -> a.charCodeAt(0) == '-'.code );
		args = args.filter( (a) -> a.charCodeAt(0) != '-'.code );
		
		for (arg in flags) {
			switch (arg.toLowerCase()) {
				case "-verbose":
					verbose = true;
					warnings = true;
					info = true;
					timings = true;
					printMissing = true;
				case "-nowarnings":
					warnings = false;
				case "-info":
					info = true;
				case "-timings":
					timings = true;
				case "-printmissing":
					printMissing = true;
				case "-silent":
					verbose = false;
					warnings = false;
					info = false;
					timings = false;
					printMissing = false;
				case "-guessorder":
					// TODO: Fix winding.
			}
		}
		for (arg in args) {
			if (FileSystem.exists(arg)) {
				Sys.setCwd(Path.directory(arg));
				return jsonConfig(File.getContent(arg));
			}
			// TODO: CLI
		}
		return [];
	}
	
	static function jsonConfig(inp:String):Array<GenConfig> {
		var cfg:Dynamic = Json.parse(inp);
		if (Std.is(cfg, Array)) {
			var arr:Array<GenConfig> = cfg;
			for (conf in arr) {
				fillDefaults(conf);
			}
			return arr;
		} else {
			return [fillDefaults(cfg)];
		}
	}
	
	static function fillDefaults(cfg:GenConfig):GenConfig {
		if ( cfg.mode == null ) cfg.mode = "msdf";
		else {
			cfg.mode = cfg.mode.toLowerCase();
			switch ( cfg.mode ) {
				case "msdf", "sdf", "psdf", "raster":
				default: throw "Invalid render mode, allowed values are 'msdf', 'sdf', 'psdf' or 'raster'";
			}
		}
		if ( cfg.fontSize == null ) throw "Font size should be specified!";
		if ( cfg.inputs == null ) {
			if ( cfg.input == null || !FileSystem.exists(cfg.input) ) throw "Path to TTF file should be specified!";
			cfg.inputs = [cfg.input];
		} else {
			if ( cfg.input != null ) cfg.inputs.unshift(cfg.input);
			for ( inp in cfg.inputs ) {
				if (!FileSystem.exists(inp)) throw "Input file does not exists: " + inp;
			}
		}
		if ( cfg.output == null ) throw "Output to FNT file should be specified!";
		if ( cfg.charset == null ) cfg.charset = ["ansi"];
		if ( cfg.dfSize == null ) cfg.dfSize = cfg.mode == "raster" ? 0 : 6;
		if ( cfg.padding == null ) cfg.padding = { top: 0, bottom: 0, left: 0, right: 0 };
		else {
			if ( cfg.padding.top == null ) cfg.padding.top = 0;
			if ( cfg.padding.bottom == null ) cfg.padding.bottom = 0;
			if ( cfg.padding.left == null ) cfg.padding.left = 0;
			if ( cfg.padding.right == null ) cfg.padding.right = 0;
		}
		if ( cfg.spacing == null ) cfg.spacing = { x: 1, y: 1 };
		else {
			if ( cfg.spacing.x == null) cfg.spacing.x = 0;
			if ( cfg.spacing.y == null) cfg.spacing.y = 0;
		}
		return cfg;
	}
	
	static function glyphSort(a:GlyphInfo, b:GlyphInfo):Int
	{
		return Math.round(a.height - b.height);
	}
	
}

typedef GenConfig = {
	var input:String; // path to ttf
	var inputs:Array<String>;
	var output:String; // path to output .fnt
	var charset:Array<Dynamic>; // Charset info
	var fontSize:Null<Float>;
	var padding: { top: Null<Int>, bottom: Null<Int>, left: Null<Int>, right: Null<Int> };
	var spacing: { x:Null<Int>, y:Null<Int> };
	var dfSize:Null<Int>;
	var mode:String; // Generator mode
};