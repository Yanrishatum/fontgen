package;

import haxe.xml.Access;
import Render;
import msdfgen.Msdfgen;
import sys.io.File;
import haxe.xml.Parser;

class SvgRender implements Render {
	public var file:String;
	public var renderGlyphs:Array<GlyphInfo> = [];
	var dfRange = 5.;
	var glyphMap:Map<Int, GlyphInfo> = new Map();
	var svgDescrs:Map<Int, SvgDescr> = new Map();
	public function new() {
	}

	public function reg(char:Int, svgfile:String, path = "") {
		var gi = new GlyphInfo();
		gi.char = char;
		gi.width = 64 + 10;
		gi.height = 64 + 10;
        renderGlyphs.push(gi);
        glyphMap.set(char, gi);
		svgDescrs.set(char, {filename:svgfile, pathName: path});
		return gi;
	}

	static function loadSvg(file, pathName) {
		function findPath(xml:Xml, name) {
			var access = new Access(xml);
			for (node in access.elements) {
				if (node.name == "path") {
					if (pathName=="" || (node.has.id && node.att.id == pathName))
						return node.x;
				} else if (node.name == "g")
					return findPath(node.x, name);
			}
			return null;
		}

		var svg:Xml = Parser.parse(File.getContent(file));
		var root = svg.elementsNamed("svg").next();
		var path:Xml = findPath(root, pathName);
		if (path == null || !path.exists("d")) {
			trace('cant find path with name $pathName in file $file');
			return null;
		}
		return path.get("d").toString();
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
			var descr = svgDescrs.get(g.char);
			var pathDef = loadSvg(descr.filename, descr.pathName);
			if (g.width != 0 && g.height != 0)
				Msdfgen.generateSDFPath(pathDef, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g), translateY(g), dfRange, 1);
		}
	}
}
typedef SvgDescr = {
	filename:String,
	?pathName:String
}