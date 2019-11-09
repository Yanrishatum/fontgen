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
		
		if (!Res.loader.exists("msdf.fnt")) {
			Sys.setCwd("bin");
			var result = Sys.command("hl", ["fontgen.hl", "-verbose", "../test/config.json"]);
			trace(result);
			Sys.setCwd("..");
		}
		
		var f = new Flow(s2d);
		f.layout = Vertical;
		f.verticalSpacing = 2;
		f.setPosition(10, 10);
		f.maxWidth = s2d.width - 20;
		
		var ctrl = new Flow(f);
		f.horizontalSpacing = 2;
		
		var txts:Array<Text> = [];
		new Text(hxd.res.DefaultFont.get(), ctrl).text = "SDF Smoothing: ";
		var slider = new h2d.Slider(200, 10, ctrl);
		slider.minValue = 0;
		slider.maxValue = 1;
		slider.value = 4 / 24;
		slider.onChange = function() {
			for (txt in txts) {
				@:privateAccess {
					if (txt.sdfShader != null) {
						txt.sdfShader.smoothing = slider.value;
					}
				}
			}
		}
		
		function makeText(label:String, fnt:Font)
		{
			var txt = new MetricText(fnt, f);
			txts.push(txt);
			txt.letterSpacing = 0;
			txt.smooth = true;
			txt.text = label + ": 0123456789 `~!@#$%^&*_+=-()[]{}<>:;,.'\"\\|/?
THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG
the quick brown fox jumps over the lazy dog
in-place glyphs: конкретные глифы txt: あいうえおかき xml: �□";
		}
		makeText("MSDF", Res.load("msdf.fnt").to(hxd.res.BitmapFont).toSdfFont(24, SDFChannel.MultiChannel, 0.5, 4/24));
		makeText("SDF", Res.load("sdf.fnt").to(hxd.res.BitmapFont).toSdfFont(24, SDFChannel.Red, 0.5, 4/24));
		makeText("PSDF", Res.load("psdf.fnt").to(hxd.res.BitmapFont).toSdfFont(24, SDFChannel.Red, 0.5, 4/24));
		makeText("Raster", Res.load("raster.fnt").to(hxd.res.BitmapFont).toFont());
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