package;

import DataTypes.SdfMode;
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
	var mode:SdfMode;

	public function new() {}

	public function reg(char:Int, svgfile:String, path = "", sdfMode) {
		var gi = new GlyphInfo();
		this.mode = sdfMode;
		gi.char = char;
		renderGlyphs.push(gi);
		glyphMap.set(char, gi);
		var pathDef = loadSvg(svgfile, path);
		var slotIndex = Msdfgen.initSvgShape(pathDef, 24, 1);
		var bounds = MsdfgenUtils.getBounds(slotIndex);

		gi.width = Math.ceil(bounds.r - bounds.l + dfRange);
		gi.height = Math.ceil(bounds.t - bounds.b + dfRange);

		gi.xOffset = 0; // - Math.floor(bounds.l - dfRange/2);
		gi.yOffset = -Math.ceil(bounds.b - bounds.t - dfRange / 2);
		gi.advance = Math.ceil(bounds.r - bounds.l);

		var descr = {
			filename: svgfile,
			pathName: path,
			slot: slotIndex,
			bounds: bounds
		};
		svgDescrs.set(char, descr);
		return gi;
	}

	static function loadSvg(file, pathName) {
		function findPath(xml:Xml, name) {
			var access = new Access(xml);
			for (node in access.elements) {
				if (node.name == "path") {
					if (pathName == "" || (node.has.id && node.att.id == pathName))
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
		inline function canvasX(g:GlyphInfo) return Std.int(g.rect.x) ;
		inline function canvasY(g:GlyphInfo) return Std.int(g.rect.y);
		inline function translateX(g:GlyphInfo, d:SvgDescr) return  dfRange/2 - d.bounds.l - 0.5 ;
		inline function translateY(g:GlyphInfo, d:SvgDescr) return dfRange/2 - d.bounds.b + 0.5;

		switch (mode) {
			case MSDF:
				for (g in renderGlyphs) {
					var descr = svgDescrs.get(g.char);
					if (g.width != 0 && g.height != 0)
						Msdfgen.generateMSDFPath(descr.slot, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g, descr), translateY(g, descr),
							dfRange, 1);
				}
			case SDF:
				for (g in renderGlyphs) {
					var descr = svgDescrs.get(g.char);
					if (g.width != 0 && g.height != 0)
						Msdfgen.generateSDFPath(descr.slot, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g, descr), translateY(g, descr),
							dfRange, 1);
				}
			case PSDF:
				for (g in renderGlyphs) {
					var descr = svgDescrs.get(g.char);
					if (g.width != 0 && g.height != 0)
						Msdfgen.generatePSDFPath(descr.slot, glyphWidth(g), glyphHeight(g), canvasX(g), canvasY(g), translateX(g, descr), translateY(g, descr),
							dfRange, 1);
				}
			case Raster:
				throw "SVG rasterizing is not implemened.";
		}
	}
}

typedef SvgDescr = {
	filename:String,
	?pathName:String,
	bounds:Bounds,
	slot:Int
}
