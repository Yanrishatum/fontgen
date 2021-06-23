import binpacking.SkylinePacker;
import binpacking.SimplifiedMaxRectsPacker;
import binpacking.ShelfPacker;
import binpacking.NaiveShelfPacker;
import binpacking.GuillotinePacker;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import haxe.io.Path;
import binpacking.MaxRectsPacker;
import GlyphRender;
import DataTypes;
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
	
	public static var globalNonprint:Bool = false;
	public static var globalr8:Bool = false;
	
	static function main() {
		
		var configs = readInput();
		
		inline function ts() return haxe.Timer.stamp();
		inline function timeStr(ts:Float) return Std.string(Math.round(ts * 1000)) + "ms";
		
		var start = ts();
		Msdfgen.initializeFreetype();
		
		for (config in configs) {
			
			var rasterMode = config.mode == Raster;

			if (info) {
				Sys.println("[Info] Rendering mode: " + config.mode);
				Sys.println("[Info] Font size: " + config.fontSize);
				if (!rasterMode) Sys.println("[Info] SDF size: " + config.dfSize);
				Sys.println("[Info] Output format: text .fnt");
			}
			
			var stamp = ts();
			var renderers:Array<GlyphRender> = [];
			for ( inp in config.inputs ) {
				if (info) Sys.println("[Info] TTF: " + inp);
				renderers.push(new GlyphRender(inp, config));
			}
			var ttfParse = ts();
			if (timings) Sys.println("[Timing] Parsed ttf: " + timeStr(ttfParse - stamp));
			
			var rasterR8:Bool = globalr8 || config.options.indexOf("r8raster") != -1;
			// Find all corresponding glyphs to render.
			var missing:Array<Int> = [];
			var glyphs:Array<GlyphInfo> = [];
			var inserted:Array<Int> = [];
			var skipNonprint:Bool = config.options.indexOf("allownonprint") == -1 && !globalNonprint;
			var charsets = Charset.parse(config.charset);
			var countMissing = charsets.indexOf(Charset.EVERYTHING) == -1;
			for ( cset in Charset.parse(config.charset) ) {
				for (char in cset) {
					if (skipNonprint && Charset.NONPRINTING.contains(char)) continue;
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
					if (countMissing && !found) missing.push(char);
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
			if (timings) Sys.println("[Timing] Glyph lookup: " + timeStr(charsetProcess - ttfParse));
			
			
			packGlyphs(config.packer, glyphs, config.spacing.x, config.spacing.y);
			
			var glyphPacking = ts();
			if (info) Sys.println('[Info] Atlas size: ${atlasWidth}x${atlasHeight}');
			if (timings) Sys.println("[Timing] Glyph packing: " + timeStr(glyphPacking - charsetProcess));
			
			Msdfgen.beginAtlas(atlasWidth, atlasHeight, (rasterMode && !rasterR8) ? 0x00ffffff : 0xff000000, rasterR8);

			for (renderer in renderers) {
				if (renderer.renderGlyphs.length == 0) continue;
				if (info)
					Sys.println("[Info] Started rendering glyphs from " + renderer.file);
				renderer.renderToAtlas();
			}
			
			var pngPath = Path.withExtension(config.output, "png");
			Msdfgen.endAtlas(pngPath);
			var glyphRendering = ts();
			if (info) Sys.println("[Info] Writing PNG file to " + pngPath);
			if (timings) Sys.println("[Timing] Glyph rendering: " + timeStr(glyphRendering - glyphPacking));
			
			// TODO: Optimize: Start building file right away.
			var file = new FntFile(config, renderers[0]);
			
			file.texture = Path.withoutDirectory(pngPath);
			file.textureWidth = atlasWidth;
			file.textureHeight = atlasHeight;
			
			for (g in glyphs) {
				file.chars.push({
					id: g.char,
					x: Std.int(g.rect.x),
					y: Std.int(g.rect.y),
					w: g.width ,
					h: g.height ,
					xa: g.advance,
					xo: g.xOffset,
					yo: (file.base - g.yOffset),
				});
			}
			
			final len = inserted.length;
			for (i in 0...len) {
				var left = glyphs[i];
				var slot = left.renderer.slot;
				for (j in (i+1)...len) {
					var right = glyphs[j];
					if (right.renderer.slot == slot) {
						var kern = Msdfgen.getKerning(slot, left.char, right.char);
						if (kern != 0) {
							file.kernings.push({ first: left.char, second: right.char, amount: kern });
						}
						kern = Msdfgen.getKerning(slot, right.char, left.char);
						if (kern != 0) {
							file.kernings.push({ first: right.char, second: left.char, amount: kern });
						}
					}
				}
			}
			
			Msdfgen.unloadFonts();
			File.saveContent(Path.withExtension(config.output, "fnt"), file.writeString());
			
			var ttfGen = ts();
			if (timings) {
				Sys.println("[Timing] FNT generation: " + timeStr(ttfGen - glyphRendering));
				Sys.println("[Timing] Total config processing time: " + timeStr(ttfGen - stamp));
			}
			
		}
		
		Msdfgen.deinitializeFreetype();
		if (timings && configs.length > 1) {
			Sys.println("[Timing] Total work time: " + timeStr(ts() - start));
		}
	}
	
	static function packGlyphs(config:PackerConfig, glyphs:Array<GlyphInfo>, extendWidth:Int, extendHeight:Int) {
		var inverse = config.sort.charCodeAt(0) == '-'.code;
		var sortAlgo = switch (inverse ? config.sort.substr(1) : config.sort) {
			case "width": widthSort;
			case "area": areaSort;
			case "perimeter": perimeterSort;
			case "id", "char": idSort;
			default: heightSort;
		}
		glyphs.sort(sortAlgo);
		if (inverse) glyphs.reverse();
		
		var insert:(w:Int, h:Int)->binpacking.Rect;
		switch (config.algorithm) {
			case "guillotine":
				var p = new GuillotinePacker(config.width, config.height);
				insert = p.insert.bind(_, _, false, BestLongSideFit, MaximizeArea);
			case "naive-shelf":
				var p = new NaiveShelfPacker(config.width, config.height);
				insert = p.insert;
			case "shelf":
				var p = new ShelfPacker(config.width, config.height, config.useWasteMap == null ? true : config.useWasteMap);
				var names = ShelfChoiceHeuristic.getConstructors();
				var heur = if (names.indexOf(config.heuristic) != -1) ShelfChoiceHeuristic.createByName(config.heuristic);
					else ShelfChoiceHeuristic.BestArea;
				insert = p.insert.bind(_, _, heur);
			case "simple-max-rect":
				var p = new SimplifiedMaxRectsPacker(config.width, config.height);
				insert = p.insert;
			case "skyline": 
				var p = new SkylinePacker(config.width, config.height, true); // Does not expect usage without waste map.
				var names = LevelChoiceHeuristic.getConstructors();
				var heur = if (names.indexOf(config.heuristic) != -1) LevelChoiceHeuristic.createByName(config.heuristic);
					else LevelChoiceHeuristic.MinWasteFit;
				insert = p.insert.bind(_, _, heur);
			default:
				var p = new MaxRectsPacker(config.width, config.height, false);
				var names = FreeRectChoiceHeuristic.getConstructors();
				var heur = if (names.indexOf(config.heuristic) != -1) FreeRectChoiceHeuristic.createByName(config.heuristic);
					else FreeRectChoiceHeuristic.BestLongSideFit;
				insert = p.insert.bind(_, _, heur);
		}
		
		var xMax = 0;
		var yMax = 0;
		for (g in glyphs) {
			var rect = g.rect = insert(g.width + extendWidth, g.height + extendHeight);
			var tmp = Std.int(rect.x + rect.width);
			if (tmp > xMax) xMax = tmp;
			tmp = Std.int(rect.y + rect.height);
			if (tmp > yMax) yMax = tmp;
		}
		if (config.exact) {
			atlasWidth = config.width;
			atlasHeight = config.height;
		} else if (config.pot) {
			atlasWidth = toPOT(xMax);
			atlasHeight = toPOT(yMax);
		} else {
			atlasWidth = xMax;
			atlasHeight = yMax;
		}
	}
	
	static function toPOT(v:Int):Int {
		// https://graphics.stanford.edu/~seander/bithacks.html#RoundUpPowerOf2
		v--;
		v |= v >> 1;
		v |= v >> 2;
		v |= v >> 4;
		v |= v >> 8;
		v |= v >> 16;
		return v + 1;
	}
	
	static function readInput():Array<GenConfig> {
		var args = Sys.args();
		if (args.length == 0) printHelp();
		var flags = args.filter( (a) -> a.charCodeAt(0) == '-'.code );
		args = args.filter( (a) -> a.charCodeAt(0) != '-'.code );
		var stdinConfig:Bool = false;
		
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
				case "-allownonprint":
					globalNonprint = true;
				case "-r8raster":
					globalr8 = true;
				case "-help":
					printHelp();
				case "-stdin":
					stdinConfig = true;
			}
		}
		if (stdinConfig) {
			var data = Sys.stdin().readAll().toString();
			return jsonConfig(data);
		}
		var baseDir = Sys.getCwd();
		for (arg in args) {
			if (FileSystem.exists(arg)) {
				if (Path.isAbsolute(arg)) Sys.setCwd(Path.directory(arg));
				else {
					var dir = Path.directory(arg);
					if (dir == "") Sys.setCwd(baseDir);
					else Sys.setCwd(Path.join([baseDir, dir]));
				}
				return jsonConfig(File.getContent(arg));
			}
			// TODO: CLI
		}
		printHelp();
		return null;
	}
	
	static function printHelp() {
		#if (hlc || cpp)
		final exe = Sys.systemName() == "Windows" ? "fontgen.exe" : "fontgen";
		#elseif hl
		final exe = "hl fontgen.hl";
		#else
		final exe = "{haxe eval here}";
		#end
		Sys.println(StringTools.replace(haxe.Resource.getString("help"), "{{exe}}", exe));
		Sys.exit(0);
	}
	
	static function jsonConfig(inp:String):Array<GenConfig> {
		var cfg:Dynamic = Json.parse(inp);
		if (Std.is(cfg, Array)) {
			var arr:Array<GenConfig> = cfg;
			for (conf in arr) {
				fillTemplate(conf);
				fillDefaults(conf);
			}
			return arr;
		} else {
			return [fillDefaults(cfg)];
		}
	}

	static function fillTemplate(cfg:GenConfig) {
		if (cfg.template == null)
			return;
		if (!FileSystem.exists(cfg.template)) {
			Sys.println('[Warn] template ${cfg.template} not found');
			return;
		}
		var template = Json.parse (File.getContent(cfg.template));
		for (key in Reflect.fields(template)) {
			if (!Reflect.hasField(cfg, key)) {
				Reflect.setField(cfg, key, Reflect.field(template, key));
			}
		}
	}
	
	static function fillDefaults(cfg:GenConfig):GenConfig {
		if ( cfg.mode == null ) cfg.mode = MSDF;
		else {
			cfg.mode = (cfg.mode:String).toLowerCase();
			cfg.mode.validate();
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
		if ( cfg.options == null ) cfg.options = [];
		else {
			for (i in 0...cfg.options.length) {
				cfg.options[i] = cfg.options[i].toLowerCase();
			}
		}
		if ( cfg.output == null ) throw "Output to FNT file should be specified!";
		if ( cfg.charset == null || cfg.charset.length == 0 ) cfg.charset = ["everything"];
		if ( cfg.dfSize == null ) cfg.dfSize = 6;
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
		
		if (cfg.packer == null) {
			cfg.packer = {
				size: null,
				width: 4096,
				height: 4096,
				pot: false,
				exact: false,
				sort: "-height",
				algorithm: "max-rect",
				heuristic: null,
				useWasteMap: true,
			};
		} else {
			if (cfg.packer.size != null) {
				cfg.packer.width = cfg.packer.height = cfg.packer.size;
			} else {
				if (cfg.packer.width == null) cfg.packer.width = 4096;
				if (cfg.packer.height == null) cfg.packer.height = 4096;
				if (cfg.packer.sort == null) cfg.packer.sort = "-height";
				else cfg.packer.sort = cfg.packer.sort.toLowerCase();
				if (cfg.packer.algorithm == null) cfg.packer.algorithm = "max-rect";
				else cfg.packer.algorithm = cfg.packer.algorithm.toLowerCase();
			}
		}
		
		return cfg;
	}
	
	static function widthSort(a:GlyphInfo, b:GlyphInfo):Int
	{
		return Math.round(a.width - b.width);
	}
	
	static function heightSort(a:GlyphInfo, b:GlyphInfo):Int
	{
		return Math.round(a.height - b.height);
	}
	
	static function areaSort(a:GlyphInfo, b:GlyphInfo):Int
	{
		return Math.round((a.width * a.height) - (b.width * b.height));
	}
	
	static function perimeterSort(a:GlyphInfo, b:GlyphInfo):Int
	{
		return Math.round((a.width + a.height) - (b.width + b.height));
	}
	
	static function idSort(a:GlyphInfo, b:GlyphInfo):Int
	{
		return a.char - b.char;
	}
	
}