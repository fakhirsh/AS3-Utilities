package  
{
	import flash.display.*;
	
	/**
	 * ...
	 * @author fakhir
	 */
	public class ProgressBar extends Sprite
	{
		private static var _bar:Sprite;
		private static var _container:Sprite;
		
		private static var _instance:ProgressBar;
		
		public function ProgressBar() 
		{
		}
		
		static public function Init(container:Sprite):void
		{
			_container = container;
			
			[Embed(source = "../assets/preloader/progressbar_outline.png")] var ProgressBarOutlineGFX:Class;
			var barBGBitmap:Bitmap = new ProgressBarOutlineGFX();
			barBGBitmap.x = -barBGBitmap.width / 2;
			barBGBitmap.y = -barBGBitmap.height / 2;
			var barBG:Sprite = new Sprite();
			barBG.addChild(barBGBitmap);
			barBG.x = _container.stage.width / 2;
			barBG.y = _container.stage.height - 30;
			_container.addChild(barBG);
			
			[Embed(source = "../assets/preloader/progressbar.png")] var ProgressBarGFX:Class;
			var barBitmap:Bitmap = new ProgressBarGFX();
			//barBitmap.x = -barBitmap.width / 2;
			barBitmap.y = -barBitmap.height / 2;
			_bar = new Sprite();
			_bar.addChild(barBitmap);
			_bar.x = _container.stage.width / 2 -barBitmap.width / 2;
			_bar.y = _container.stage.height - 29;
			_bar.scaleX = 0.0;
			_container.addChild(_bar);
		}
		
		static public function SetProgress(percent:int):void
		{
			_bar.scaleX = (percent / 100.0);
		}
		
	}

}