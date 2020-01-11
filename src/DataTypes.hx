enum abstract SdfMode(String) from String to String {
	
	var SDF = "sdf";
	var PSDF = "psdf";
	var MSDF = "msdf";
	var Raster = "raster";
	
	public inline function validate() {
		if (this != SDF && this != PSDF && this != MSDF && this != Raster)
			throw "Invalid render mode, allowed values are 'msdf', 'sdf', 'psdf' or 'raster'";
	}
	
}

typedef GenConfig = {
	var input:String; // path to ttf
	var inputs:Array<String>;
	var output:String; // path to output .fnt
	var charset:Array<Dynamic>; // Charset info
	var fontSize:Null<Int>;
	var options:Array<String>;
	var padding: { top: Null<Int>, bottom: Null<Int>, left: Null<Int>, right: Null<Int> };
	var spacing: { x:Null<Int>, y:Null<Int> };
	// TODO: Margin
	var dfSize:Null<Int>;
	var mode:SdfMode; // Generator mode
	var packer:PackerConfig;
};

typedef PackerConfig = {
	var size:Null<Int>;
	var width:Null<Int>;
	var height:Null<Int>;
	var pot:Bool;
	var exact:Bool;
	var sort:String;
	var algorithm:String;
	var heuristic:String;
	var useWasteMap:Null<Bool>;
}