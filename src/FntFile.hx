class FntFile {
	
	// Info
	public var face:String;
	public var size:Int;
	public var bold:Bool;
	public var italic:Bool;
	public var paddingUp:Int;
	public var paddingDown:Int;
	public var paddingLeft:Int;
	public var paddingRight:Int;
	public var spacingX:Int = 0;
	public var spacingY:Int = 0;
	public var outline:Int;
	public var dfSize:Int;
	public var dfMode:String;
	
	// Common
	public var lineHeight:Int;
	public var base:Int;
	public var texture:String;
	public var textureWidth:Int;
	public var textureHeight:Int;
	// public var isMono:Bool;
	
	public var chars:Array<{ id:Int, x:Int, y:Int, w:Int, h:Int, xo:Int, yo:Int, xa:Int }> = [];
	
	public var kernings:Array<{ first:Int, second:Int, amount:Int }> = [];
	
	public function new() {}
	
	public function writeString():String
	{
		var lines = [
			'info face="$face" size=$size bold=${bold?'1':'0'} italic=${italic?'1':'0'} charset=""' +
			' unicode=1 stretchH=100 smooth=1 aa=1 padding=$paddingUp,$paddingRight,$paddingDown,$paddingLeft' +
			' spacing=$spacingX,$spacingY outline=0',
			'common lineHeight=$lineHeight base=$base scaleW=$textureWidth scaleH=$textureHeight pages=1 packed=0 alphaChnl=0 redChnl=4 greenChnl=4 blueChnl=4',
			'page id=0 file="$texture"',
			'chars count=${chars.length}'
		];
		for (char in chars) {
			lines.push('char id=${char.id} x=${char.x} y=${char.y} width=${char.w} height=${char.h} xoffset=${char.xo} yoffset=${char.yo} xadvance=${char.xa} page=0 chnl=15');
		}
		lines.push('kernings count=${kernings.length}');
		for (kern in kernings) {
			lines.push('kerning first=${kern.first} second=${kern.second} amount=${kern.amount}');
		}
		lines.push('sdf mode=$dfMode size=$dfSize');
		return lines.join("\r\n");
	}
	
}