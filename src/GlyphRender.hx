import haxe.io.Bytes;
import msdfgen.StructAlias;
import msdfgen.Msdfgen;
import binpacking.Rect;
import DataTypes;

class GlyphRender {
	
	static var METRICS:FontMetrics = new FontMetrics();
	static var GLYPH:GlyphMetrics = new GlyphMetrics();
	
	public var file:String;
	/** Internal slot index **/
	public var slot:Int;
	
	public var fontName:String;
	public var unitsPerEm:Int;
	public var bold:Bool;
	public var italic:Bool;
	public var lineHeight:Int;
	public var baseLine:Int;
	public var fontHeight:Int;
	public var ascent:Int;
	public var descent:Int;
	var mode:SdfMode;
	var dfRange:Int;
	var extendWidth:Int;
	var extendHeight:Int;
	var config:GenConfig;
	var glyphMap:Map<Int, GlyphInfo>;
	public var renderGlyphs:Array<GlyphInfo>;
	
	public function new(path:String, config:GenConfig)
	{
		file = path;
		
		var m = METRICS;
		slot = Msdfgen.initFont(path, m, config.fontSize);
		this.ascent = m.ascent;
		this.descent = m.descent;
		this.baseLine = m.baseLine;
		this.unitsPerEm = m.unitsPerEm;
		this.lineHeight = m.lineHeight;
		this.fontHeight = m.lineHeight;
		this.bold = (m.flags & 1) != 0;
		this.italic = (m.flags & 2) != 0;
		this.config = config;
		this.mode = config.mode;
		this.dfRange = (mode==Raster)? 0 : config.dfSize;
		this.extendWidth = config.padding.left + config.padding.right + dfRange;
		this.extendHeight = config.padding.top + config.padding.bottom + dfRange;
		var nameBytes:Bytes = Msdfgen.getFontName(slot);
		fontName = "";
		if (nameBytes.length != 0) {
			var i = 0;
			while (i < nameBytes.length) {
				fontName += String.fromCharCode(nameBytes.get(i) << 8 | nameBytes.get(i+1));
				i += 2;
			}
		}
		
		glyphMap = [];
		renderGlyphs = [];
	}
	
	public function get(char:Int) {
		var g = glyphMap.get(char);
		if (g == null) {
			var paddingLeft = config.padding.left;
			var paddingTop = config.padding.top;
			g = new GlyphInfo();
			g.renderer = this;
			glyphMap.set(char, g);
			var m = GLYPH;
			if (Msdfgen.getGlyphMetrics(slot, char, m)) {
				g.char = char;
				g.width = m.width + extendWidth;
				g.height = m.height+ extendHeight;
				g.xOffset = m.offsetX- paddingLeft - Math.ceil(dfRange/2);
				g.yOffset = m.offsetY + paddingTop + Math.ceil(dfRange/2);
				g.advance = m.advanceX;
				g.descent = m.descent;
				g.isCCW = m.ccw;
			}
		}
		return g.char == -1 ? null : g;
	}
	
}

class GlyphInfo {
	
	public var char:Int;
	public var width:Int;
	public var height:Int;
	public var xOffset:Int;
	public var yOffset:Int;
	public var descent:Float;
	public var advance:Int;
	public var isCCW:Bool;
	
	public var rect:Rect;
	public var renderer:GlyphRender;
	
	public function new() {
		char = -1;
	}
	
	public function toString() {
		return '{ $char : size: [$width x $height] off: [$xOffset, $yOffset] adv: $advance }';
	}
	
}