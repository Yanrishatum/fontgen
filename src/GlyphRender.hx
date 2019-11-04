import sys.io.File;
import binpacking.Rect;
import format.ttf.Data;
import format.ttf.Reader;

class GlyphRender {
	
	public var file:String;
	var ttf:TTF;
	var glyphs:Map<Int, GlyphInfo>;
	var glyphMap:Map<Int, GlyphInfo>;
	public var kernings:Array<KerningPair>;
	public var unitsPerEm:Float;
	
	public var fontName:String;
	public var bold:Bool;
	public var italic:Bool;
	public var lineHeight:Float;
	public var baseLine:Float;
	public var fontHeight:Float;
	public var ascent:Float;
	public var descent:Float;
	
	public var renderGlyphs:Array<GlyphInfo>;
	
	public function new(path:String)
	{
		var fio = File.read(path);
		var reader = new Reader(fio);
		ttf = reader.read();
		fio.close();
		fontName = reader.fontName;
		file = path;
		glyphs = [];
		kernings = [];
		glyphMap = [];
		renderGlyphs = [];
		
		for (table in ttf.tables) {
			switch (table) {
				case THead(data):
					unitsPerEm = data.unitsPerEm;
					bold = (data.macStyle & 1) != 0;
					italic = (data.macStyle & 2) != 0;
				case THhea(data):
					// I'm not sure if it's correct way to calculate lineHeight and baseLine, but it kinda works.
					// By default both stb and libgdx use ascender and descender to calculate font size instead of unitsPerEm value.
					ascent = data.ascender;
					descent = data.descender;
					fontHeight = (data.ascender - data.descender);
					baseLine = ascent;
					lineHeight = (data.ascender - data.descender + data.lineGap);
				// case TMaxp(data):
				// case TLoca(data):
				case THmtx(metrics):
					var i = 0;
					while (i < metrics.length) {
						var g = getGlyph(i);
						var m = metrics[i++];
						if (m == null) continue;
						g.advance = m.advanceWidth;
					}
				case TCmap(subtables):
					for (subtable in subtables) {
						var theader:CmapHeader = null;
						var array:Array<GlyphIndex> = null;
						var charOffset = 0;
						switch (subtable) {
							case Cmap6(header, glyphIndexArray, off):
								theader = header;
								array = glyphIndexArray;
								charOffset = off;
							case Cmap0(header, glyphIndexArray),
								// Cmap2(header, glyphIndexArray, _, _),
								// Cmap10(header, glyphIndexArray, _, _),
									Cmap4(header, glyphIndexArray):
								theader = header;
								array = glyphIndexArray;
							// case CmapUnk({ format: 12, platformId: pid, offset: offset, language: 0, platformSpecificId: psid }, bytes):
								
							default: if (Main.warnings) Sys.println("[Warn] Unsupported CMAP: " + Std.string(subtable));
						}
						if (array != null && theader.platformId == 0) { // Ignore Windows/Mac platform IDs
							for (glyphIndex in array) {
								if (glyphIndex != null) {
									var g = getGlyph(glyphIndex.index);
									if (g.char == -1) {
										g.char = glyphIndex.charCode + charOffset;
									}
									glyphMap.set(g.char, g);
								}
							}
						}
					}
				case TGlyf(descriptions):
					var i = 0;
					while (i < descriptions.length) {
						var g = getGlyph(i);
						var d = descriptions[i++];
						if (d == null) continue;
						switch (d) {
							case TGlyphSimple(header, _), TGlyphComposite(header, _):
								g.xMin = header.xMin;
								g.xMax = header.xMax;
								g.yMin = header.yMin;
								g.yMax = header.yMax;
							case TGlyphNull:
								// ...
						}
					}
				case TKern(kerning):
					for (k in kerning) {
						switch (k) {
							case KernSub0(kerningPairs):
								for (pair in kerningPairs) {
									kernings.push(pair);
								}
							case KernSub1(array):
								// if (Main.warnings) Sys.println("[Warn] Unsupported kerning table");
						}
					}
				// case TOS2(data):
				// case TName(records):
				// 	for (record in records) {
				// 		if (record.platformId == 3) {
				// 			if (record.record != "") fontName = record.record;
				// 		}
				// 	}
				// case TUnkn(bytes):
				// 	trace(bytes.getString(0, 4));
				// case TPost(data):
				default:
			}
		}
		
	}
	
	public inline function toPixel(v:Float, scalar:Float):Float
	{
		return v / unitsPerEm * scalar;
	}
	
	public inline function toIPixel(v:Float, scalar:Float):Int
	{
		return Math.ceil(v / unitsPerEm * scalar);
	}
	
	public inline function toHPixel(v:Float, scalar:Float):Float
	{
		return v / fontHeight * scalar;
	}
	
	public inline function toHIPixel(v:Float, scalar:Float):Int
	{
		return Math.floor(v / fontHeight * scalar);
	}
	
	public function get(char:Int) {
		return glyphMap[char];
	}
	
	function getGlyph(index:Int)
	{
		var g = glyphs.get(index);
		if (g == null) {
			g = new GlyphInfo();
			g.renderer = this;
			glyphs.set(index, g);
		}
		return g;
	}
	
}

class GlyphInfo {
	
	public var char:Int;
	public var xMin:Float;
	public var xMax:Float;
	public var yMin:Float;
	public var yMax:Float;
	public var advance:Float;
	
	public var rect:Rect;
	public var renderer:GlyphRender;
	
	public var width(get, never):Float;
	public var height(get, never):Float;
	
	inline function get_width() return xMax - xMin;
	inline function get_height() return yMax - yMin;
	
	public function new() {
		char = -1;
	}
	
	public function toString() {
		return '{ $char : [$xMin, $xMax] [$yMin, $yMax] [$width, $height] }';
	}
	
}