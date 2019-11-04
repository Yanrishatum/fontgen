package msdfgen;

import ammer.Library;
import haxe.io.Bytes;
import ammer.ffi.*;

class Msdfgen extends Library<"msdfgen"> {
	
	@:ammer.native("wrap_initializeFreetype")
	public static function initializeFreetype():Bool;
	
	@:ammer.native("wrap_deinitializeFreetype")
	public static function deinitializeFreetype():Void;
	
	@:ammer.native("wrap_loadFont")
	public static function loadFont(fname:String):Bool;
	@:ammer.native("wrap_unloadFont")
	public static function unloadFont():Void;
	
	public static function beginAtlas(width:Int, height:Int):Void;
	public static function setParameters(dfRange:Float, scale:Float):Void;
	public static function endAtlas(output:String):Void;
	
	public static function generateSDFGlyph(charcode:Int, width:Int, height:Int, x:Int, y:Int, tx:Float, ty:Float):Bool;
	public static function generatePSDFGlyph(charcode:Int, width:Int, height:Int, x:Int, y:Int, tx:Float, ty:Float):Bool;
	public static function generateMSDFGlyph(charcode:Int, width:Int, height:Int, x:Int, y:Int, tx:Float, ty:Float):Bool;
	public static function rasterizeGlyph(charcode:Int, width:Int, height:Int, x:Int, y:Int, tx:Float, ty:Float):Bool;
}