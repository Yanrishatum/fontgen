import h2d.Bitmap;
import h2d.Tile;
import h2d.RenderContext;
import h2d.Flow;
import h2d.Text;
import h2d.Font;
import hxd.res.BitmapFont;
import hxd.Res;

class TestMain extends hxd.App {
	
	static function main()
	{
		hxd.Res.initLocal();
		new TestMain();
	}
	
	override function init()
	{
		super.init();
		Sys.setCwd("bin");
		var result = Sys.command("hl", ["fontgen.hl", "-verbose", "../test/config.json"]);
		trace(result);
		Sys.setCwd("..");
		var f = new Flow(s2d);
		f.layout = Vertical;
		
		function makeText(label:String, fnt:Font)
		{
			var txt = new MetricText(fnt, f);
			txt.letterSpacing = 0;
			txt.text = label + ": A quick brown fox jumps over the lazy dog. 0123456789";
		}
		makeText("MSDF", Res.load("msdf.fnt").to(hxd.res.BitmapFont).toSdfFont(24, SDFChannel.MultiChannel, 0.5, 4/24));
		makeText("SDF", Res.load("sdf.fnt").to(hxd.res.BitmapFont).toSdfFont(24, SDFChannel.Red, 0.5, 4/24));
		makeText("PSDF", Res.load("psdf.fnt").to(hxd.res.BitmapFont).toSdfFont(24, SDFChannel.Red, 0.5, 4/24));
		makeText("Raster", Res.load("raster.fnt").to(hxd.res.BitmapFont).toFont());
		
		// new Text("MSDF font\n");
	}
	
}

class MetricText extends Text {
	
	var t:Bitmap;
	var h:Bitmap;
	
	override function draw(ctx:RenderContext)
	{
		if (t == null)
		{
			t = new Bitmap(Tile.fromColor(0xff0000), this);
			t.y = font.baseLine;
			t.scaleX = textWidth;
			h = new Bitmap(Tile.fromColor(0xff00), this);
			h.y = font.lineHeight;
			h.scaleX = textWidth;
		}
		if (hxd.Key.isReleased(hxd.Key.SPACE))
		{
			t.visible = !t.visible;
			h.alpha = t.visible ? 1 : 0;
		}
		super.draw(ctx);
	}
	
}