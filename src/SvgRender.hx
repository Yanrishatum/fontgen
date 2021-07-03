package;

import Render;
import msdfgen.Msdfgen;
import sys.io.File;
import haxe.xml.Parser;

class SvgRender implements Render {
	public var file:String;
	public var renderGlyphs:Array<GlyphInfo> = [];
	var dfRange = 5.;
	var glyphMap:Map<Int, GlyphInfo> = new Map();
	public function new() {
	}

	public function reg(char:Int) {
		var gi = new GlyphInfo();
		gi.char = char;
		gi.width = 64 + 10;
		gi.height = 64 + 10;
        renderGlyphs.push(gi);
        glyphMap.set(char, gi);
	}

	static function loadSvg() {
		var svg:Xml = Parser.parse(File.getContent("drawing2.svg"));
		// var svg:Xml = Parser.parse(File.getContent("blob.svg"));
		var paths = svg.elementsNamed("svg").next().elementsNamed("g").next().elementsNamed("path").next().get("d");
		Sys.println(paths.toString());
		return paths.toString();
	}

	public function get(char:Int):GlyphInfo {
        return glyphMap.get(char);
    }

	public function renderToAtlas():Void {
        inline function glyphWidth(g:GlyphInfo) return g.width;
		inline function glyphHeight(g:GlyphInfo) return g.height;
		inline function canvasX(g:GlyphInfo) return Std.int(g.rect.x);
		inline function canvasY(g:GlyphInfo) return Std.int(g.rect.y);
		inline function translateX(g:GlyphInfo) return  - (0.5 - g.xOffset) +dfRange / 2  ;
		inline function translateY(g:GlyphInfo) return dfRange/2 ;// Math.floor(halfDF) + 0.5 - g.descent + paddingBottom;
		for (g in renderGlyphs) {
			if (g.width != 0 && g.height != 0)
				Msdfgen.generateSDFPath(loadSvg(), glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g), translateY(g), dfRange, 1);
		}
	}
}