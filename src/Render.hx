import binpacking.Rect;
interface Render {
	public var file:String;
	public var renderGlyphs:Array<GlyphInfo>;
	public function get(char:Int):GlyphInfo;
    
	public function renderToAtlas():Void;
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