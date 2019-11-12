package msdfgen;

import haxe.io.Bytes;

// Bytes mapper for data transfer between C and Haxe.
abstract FontMetrics(Bytes) from Bytes to Bytes {
	
	public static inline var SIZE:Int = 6 * 4;
	
	public inline function new()
		this = Bytes.alloc(SIZE);
	
	public var ascent(get, never):Int;
	public var descent(get, never):Int;
	public var unitsPerEm(get, never):Int;
	public var baseLine(get, never):Int;
	public var lineHeight(get, never):Int;
	public var flags(get, never):Int;
	inline function get_ascent() return this.getInt32(0);
	inline function get_descent() return this.getInt32(4);
	inline function get_unitsPerEm() return this.getInt32(8);
	inline function get_baseLine() return this.getInt32(12);
	inline function get_lineHeight() return this.getInt32(16);
	inline function get_flags() return this.getInt32(20);
	
}

abstract GlyphMetrics(Bytes) from Bytes to Bytes {
	
	public static inline var SIZE:Int = 7 * 4;
	
	public inline function new()
		this = Bytes.alloc(SIZE);
	
	public var width(get, never):Int;
	public var height(get, never):Int;
	public var offsetX(get, never):Int;
	public var offsetY(get, never):Int;
	public var advanceX(get, never):Int;
	public var descent(get, never):Int;
	public var ccw(get, never):Bool;
	
	inline function get_width() return this.getInt32(0);
	inline function get_height() return this.getInt32(4);
	inline function get_offsetX() return this.getInt32(8);
	inline function get_offsetY() return this.getInt32(12);
	inline function get_advanceX() return this.getInt32(16);
	inline function get_descent() return this.getInt32(20);
	inline function get_ccw() return this.getInt32(24) != 0;
}