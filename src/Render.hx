import GlyphRender.GlyphInfo;

interface Render {
	public var file:String;
	public var renderGlyphs:Array<GlyphInfo>;
	public function get(char:Int):GlyphInfo;
    
	public function renderToAtlas():Void;
}