package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Fakhir
	 */
	[SWF(width = 480, height = 320)]
	public class Main extends Sprite 
	{
		private var lbl:TextField;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			lbl = new TextField();
			lbl.x = 10;
			lbl.y = 20;
			lbl.width = 400;
			addChild(lbl);
			
			var domain:String = this.root.loaderInfo.url.split("/")[2];
			if (domain == "")
			{
				lbl.text = "Domain: Local";
			}
			else {
				if(domain.indexOf("www.") == -1)
				{
					lbl.text = "Domain: www." + domain;	
				}
				else
				{
					lbl.text = "Domain: " + domain;
				}
			}	
			
		}
	}
	
}