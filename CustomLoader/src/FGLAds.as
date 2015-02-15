package
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
		
	/**
	 * <p>The FGLAds object is used to show ads! It's very simple.</p> 
	 * 
	 * <ul>
	 * <li> Copy <a href="http://flashgamedistribution.com/fglads/FGLAds.as">the FGLAds actionscript file</a> into your project. </li>
	 * <li> Call the constructor and pass it the stage and your game ID. You can find your FGL Ads ID on the FGD or FGL website.</li>	  
	 * <li> Add an event listener for the EVT_API_READY event. This fires when 
	 * everything's ready to go. It should take less than a second.</li> 
	 * <li> In the event handler, call FGLAds.api.showAdPopup(). By default, 
	 * it will show a 300x250 ad popup in the center of the game. The user 
	 * can close it after 3s.</li> 
	 * </ul>
	 * 
	 * <p><b>Example:</b></p>
	 * <p><code><pre>
	 * function myInitFunction():void {
	 *     FGLAds(stage, "FGL-EXAMPLE");
	 *     FGLAds.api.addEventListener(EVT_API_READY, onAdsReady);
	 * }
	 * 
	 * function onAdsReady(e:Event):void {
	 *     FGLAds.api.showAdPopup();
	 * }
	 * </pre></code></p>
	 * 
	 * <p>That's it for now. We'll have more ad formats and more ways to load them soon!</p>
	 * 
	 */
	public class FGLAds extends Sprite
	{
		public static const version:String = "01";
		
		//singleton var
		/**@private*/protected static var _instance:FGLAds;
		
		//status vars
		private var _status:String = "Loading";
		private var _loaded:Boolean = false;
		private var _stageWidth:Number = 550;
		private var _stageHeight:Number = 400;
		private var _inUse:Boolean = false;
		
		//swf loading vars
		private var _referer:String = "";
		private var _loader:Loader = new Loader();
		private var _context:LoaderContext = new LoaderContext(true);
		
		//live URL
		private var _request:URLRequest = new URLRequest("http://ads.fgl.com/swf/FGLAds." + version + ".swf");
		
		//event handlers
		private var _evt_NetworkingError:Function = null;
		private var _evt_ApiReady:Function = null;
		private var _evt_AdLoaded:Function = null;
		private var _evt_AdShown:Function = null;
		private var _evt_AdClicked:Function = null;
		private var _evt_AdClosed:Function = null;
		private var _evt_AdLoadingError:Function = null;
		
		//event types
		public static const EVT_NETWORKING_ERROR:String = "networking_error";
		public static const EVT_API_READY:String = "api_ready";
		public static const EVT_AD_LOADED:String = "ad_loaded";
		public static const EVT_AD_SHOWN:String = "ad_shown";
		public static const EVT_AD_CLOSED:String = "ad_closed";
		public static const EVT_AD_CLICKED:String = "ad_clicked";
		public static const EVT_AD_LOADING_ERROR:String = "ad_loading_error";
		
		//ad formats
		public static const FORMAT_300x250:String = "300x250";
		public static const FORMAT_90x90:String = "90x90";
		
		//display objects
		private var _fglAds:Object;
		private var _stage:Stage;
		
		/**
		 * FGLAds constructor.<br />
		 * Important Note: You must only create one instance of the FGLAds object in your project.
		 * If you try to create a second instance, it will not initiate properly and a message will be
		 * logged to the output console (trace())
		 * 
		 * @param parent It is imperative that the parent object that you pass to the FGLAds constructor
		 * is either Sprite, MovieClip or Stage.
		 * @param gameID The game's ID, as issued on the FGL or FGD website.
		 */
		
		public function FGLAds(parent:*, gameID:String):void
		{
			if(_instance == null) {
				_instance = this;
			} else {
				trace("FGLAds: Instance Error: The FGLAds class is a singleton and should only be constructed once. Use FGLAds.api to access it after it has been constructed.");
				return;
			}
			
			_storedGameID = gameID;
			
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			_context.applicationDomain = ApplicationDomain.currentDomain;
			
			//download client library
			_status = "Downloading";
			try {
				_loader.load(_request, _context);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadingError);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadingComplete);
			} catch(e:Error) {
				_status = "Failed";
				trace("FGLAds: SecurityError: cannot load client library");
				_loader = null;
			}
			
			addEventListener(Event.ADDED_TO_STAGE, setupStage);
			if(parent is Sprite || parent is MovieClip || parent is Stage)
			{
				parent.addChild(this);
			} else {
				trace("FGLAds: Incompatible parent!");
			}				
		}
		
		/**
		 * The api variable allows you to access your instance of FGL Ads from anywhere in your code.<br />
		 * After constructing the FGLAds object, one of the easiest ways of accessing the API functionality
		 * is by using FGLAds.api.
		 * 
		 * You can access all of the functions that you need by using FGLAds.api, and because it
		 * is static, it can be accessed anywhere from within your code.
		 * 
		 * You MUST initiate one instance of the FGLAds class using the code provided from the website
		 * before trying to access this api variable. If the FGLAds object has not been initiated then
		 * this variable will return null.
		 */		
		public static function get api():FGLAds	{
			if(_instance == null) {
				trace("FGL Ads: Instance Error: Attempted to get instance before construction.");
				return null;
			}
			return _instance;
		}
		
		/**
		 * Displays an ad popup that appears over the current swf and lowers the lights.
		 * @param format the format of the ad to request, use one of the FORMAT_ constants.
		 * @param delay how long before they can close the ad
		 * @param timeout how long before the ad closes itself
		 */
		
		public function showAdPopup(format:String = FGLAds.FORMAT_300x250, delay:Number = 3000, timeout:Number = 0):void {
			if(_loaded == false) return;
			_fglAds.showAdPopup(format, delay, timeout);
		}
		
		/**
		 * The status variable allows you to determine the current
		 * status of the API. This can be any of the following:
		 * <ul>
		 * <li>Loading</li>
		 * <li>Downloading</li>
		 * <li>Ready</li>
		 * <li>Failed</li>
		 * </ul>
		 */
		public function get status():String {
			return _status;
		}		
		
		/**
		 * Returns true if the API has been initialised by the constructor. If this returns false, you need to
		 * call new FGLAds(stage) - passing the stage or root displayobject in. 
		 */
		public static function get apiLoaded():Boolean {
			return _instance != null;
		}
		
		/**
		 * Disable the API. This will stop FGLAds from processing any requests. Use enable() to re-enable the API.
		 */
		public function disable():void {
			if(_status == "Ready"){
				_status = "Disabled";
				_loaded = false;
			}
		}		
		
		/**
		 * Re-enables the API if it's been disabled using the disable() function.
		 */
		public function enable():void {
			if(_status == "Disabled"){
				_status = "Ready";
				_loaded = true;
			}
		}
		
		// Event handling...
		
		/** @private */ public function set onNetworkingError(func:Function):void { _evt_NetworkingError = func; }
		/** @private */ public function get onNetworkingError():Function {return _evt_NetworkingError;}
		private function e_onNetworkingError(e:Event):void {
			if(_evt_NetworkingError != null) _evt_NetworkingError();
			dispatchEvent(e);
		}
		
		/** @private */ public function set onApiReady(func:Function):void { _evt_ApiReady = func; }
		/** @private */ public function get onApiReady():Function {return _evt_ApiReady;}
		private function e_onApiReady(e:Event):void {
			if(_evt_ApiReady != null) _evt_ApiReady();
			dispatchEvent(e);
		}
		
		/** @private */ public function set onAdLoaded(func:Function):void { _evt_AdLoaded = func; }
		/** @private */ public function get onAdLoaded():Function {return _evt_AdLoaded;}
		private function e_onAdLoaded(e:Event):void {
			if(_evt_AdLoaded != null) _evt_AdLoaded();
			dispatchEvent(e);
		}
		/** @private */ public function set onAdShown(func:Function):void { _evt_AdShown = func; }
		/** @private */ public function get onAdShown():Function {return _evt_AdShown;}
		private function e_onAdShown(e:Event):void {
			if(_evt_AdShown != null) _evt_AdShown();
			dispatchEvent(e);
		}
		/** @private */ public function set onAdClicked(func:Function):void { _evt_AdClicked = func; }
		/** @private */ public function get onAdClicked():Function {return _evt_AdClicked;}
		private function e_onAdClicked(e:Event):void {
			if(_evt_AdClicked != null) _evt_AdClicked();
			dispatchEvent(e);
		}
		/** @private */ public function set onAdClosed(func:Function):void { _evt_AdClosed = func; }
		/** @private */ public function get onAdClosed():Function {return _evt_AdClosed;}
		private function e_onAdClosed(e:Event):void {
			if(_evt_AdClosed != null) _evt_AdClosed();
			dispatchEvent(e);
		}
		
		/** @private */ public function set onAdLoadingError(func:Function):void { _evt_AdLoadingError = func; }
		/** @private */ public function get onAdLoadingError():Function {return _evt_AdLoadingError;}
		private function e_onAdLoadingError(e:Event):void {
			if(_evt_AdLoadingError != null) _evt_AdLoadingError();
			dispatchEvent(e);
		}
		
		
		/* Internal Functions */
		private function resizeStage(e:Event):void {
			if(_loaded == false) return;
			_stageWidth = _stage.stageWidth;
			_stageHeight = _stage.stageHeight;
			_fglAds.componentWidth = _stageWidth;
			_fglAds.componentHeight = _stageHeight;
		}
		
		private function setupStage(e:Event):void {
			if(stage == null) return;
			_stage = stage;
			_stage.addEventListener(Event.RESIZE, resizeStage);
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;
			if(root != null) {
				_referer = root.loaderInfo.loaderURL;
			}
			if(_loaded){
				_fglAds.componentWidth = _stageWidth;
				_fglAds.componentHeight = _stageHeight;
				_stage.addChild(_fglAds as Sprite);
			}
		}
		
		private function onLoadingComplete(e:Event):void {
			_status = "Ready";
			_loaded = true;
			_fglAds = _loader.content as Object;
			_fglAds.componentWidth = _stageWidth;
			_fglAds.componentHeight = _stageHeight;
			
			_fglAds.addEventListener(EVT_NETWORKING_ERROR, e_onNetworkingError);
			_fglAds.addEventListener(EVT_API_READY, e_onApiReady);
			_fglAds.addEventListener(EVT_AD_LOADED, e_onAdLoaded);
			_fglAds.addEventListener(EVT_AD_SHOWN, e_onAdShown);
			_fglAds.addEventListener(EVT_AD_CLICKED, e_onAdClicked);
			_fglAds.addEventListener(EVT_AD_CLOSED, e_onAdClosed);
			_fglAds.addEventListener(EVT_AD_LOADING_ERROR, e_onAdLoadingError);
			
			if(_stage != null){
				_stage.addChild(_fglAds as Sprite);
			}
			
			if(root != null){
				_referer = root.loaderInfo.loaderURL
			}
			
			_fglAds.init(_stage, _referer, _storedGameID);
		}
		
		private function onLoadingError(e:IOErrorEvent):void {
			_loaded = false;
			_status = "Failed";
			trace("Failed to load FGL Ads");				
		}
		
		private var _storedGameID:String = "";
	}
}