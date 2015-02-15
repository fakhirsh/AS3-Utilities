package  
{
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author fakhir
	 */
	public class AdManager 
	{
		static private var _ads:FGLAds;
		static public var _adsDone:Boolean;
		
		public function AdManager() 
		{
		
			
		}
		
		static public function Init(stage:Stage):void
		{
			_ads = new FGLAds(stage, "FGL-20027918");
			_ads.addEventListener(FGLAds.EVT_API_READY, showStartupAd);
			_ads.addEventListener(FGLAds.EVT_AD_LOADING_ERROR, AdsDone);
			_ads.addEventListener(FGLAds.EVT_NETWORKING_ERROR, AdsDone);
			
			_adsDone = false;
		}
		
		static private function AdsDone(e:Event):void {
            // removing listeners
            _ads.removeEventListener(FGLAds.EVT_AD_CLOSED, AdsDone);
            _ads.removeEventListener(FGLAds.EVT_AD_LOADING_ERROR, AdsDone);
            
			// start the game
            _adsDone = true;
        }
		
		static private function showStartupAd(e:Event):void
		{
			_ads.showAdPopup();
			_ads.addEventListener(FGLAds.EVT_AD_CLOSED, AdsDone);
		}
		
		static public function ApiLoaded():Boolean
		{
			return FGLAds.apiLoaded;
		}
		
	}

}