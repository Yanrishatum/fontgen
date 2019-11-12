package msdfgen;

import ammer.Library;
import haxe.io.Bytes;
import ammer.ffi.*;

class Msdfgen extends Library<"msdfgen_lib"> {
	
	@:ammer.native("wrap_initializeFreetype")
	public static function initializeFreetype():Bool;
	
	@:ammer.native("wrap_deinitializeFreetype")
	public static function deinitializeFreetype():Void;
	
	public static function setParameters(dfRange:Float, fontSize:Int):Void;
	public static function initFont(filename:String, metrics:NoSize<Bytes>):Int;
	public static function unloadFonts():Void;
	public static function getGlyphMetrics(font:Int, charcode:Int, output:NoSize<Bytes>):Bool;
	public static function getKerning(font:Int, left:Int, right:Int):Int;
	public static function getFontName(font:Int, len:SizeOfReturn):Bytes;

	public static function beginAtlas(width:Int, height:Int, defaultAlpha:Int):Void;
	public static function endAtlas(output:String):Void;
	
	public static function generateSDFGlyph(slot:Int, charcode:Int, width:Int, height:Int, x:Int, y:Int, tx:Float, ty:Float, ccw:Bool):Bool;
	public static function generatePSDFGlyph(slot:Int, charcode:Int, width:Int, height:Int, x:Int, y:Int, tx:Float, ty:Float, ccw:Bool):Bool;
	public static function generateMSDFGlyph(slot:Int, charcode:Int, width:Int, height:Int, x:Int, y:Int, tx:Float, ty:Float, ccw:Bool):Bool;
	public static function rasterizeGlyph(slot:Int, charcode:Int, width:Int, height:Int, x:Int, y:Int):Bool;
}