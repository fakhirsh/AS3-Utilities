package 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author Fakhir
	 */
	[Frame(factoryClass = "Preloader")]
	[SWF(width="640", height="400", backgroundColor="#ffffff")]
	public class Main extends Sprite 
	{

		[Embed(source = "../assets/PixelFlight_Encrypted.swf", mimeType = "application/octet-stream")]
		private var SourceEncryptedSWF:Class;
		
		private var _decryptionWorker:DecryptionWorker;
		private var _mainToBack:MessageChannel;
		private var _backToMain:MessageChannel;
		private var _worker:Worker; 
		
		private var _swfBinaryData:ByteArray;
		private var _totalSize:int;
		private var _bytesLoaded:int;
		private var _decryptionComplete:Boolean;
		
		
///////////////////////////////////////////////////////////////////////////////

		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//Main thread
			if (Worker.current.isPrimordial) {
				addEventListener(Event.ENTER_FRAME, OnEnterFrame);
				_decryptionComplete = false;
				stage.frameRate = 30;
				InitUI();
				initWorker();
			} 
			//If not the main thread, we're the worker
			else {
				stage.frameRate = 2;
				_decryptionWorker = new DecryptionWorker(SourceEncryptedSWF, "www.delagames.com");
			}

		}
		
		private function OnEnterFrame(e:Event):void 
		{
			if(_decryptionComplete)
			{
				if(AdManager.ApiLoaded())
				{
					if(AdManager._adsDone)
					{
						LoadGame();
					}
				}
				else
				{
					LoadGame();
				}
				
			}
		}
		
		private function LoadGame():void 
		{
			removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			var loader:Loader = new Loader();
			addChild(loader);
			loader.loadBytes(_swfBinaryData, new LoaderContext(false, new ApplicationDomain()));
		}
		
		private function initWorker():void {
			//Create worker from the main swf 
			_worker = WorkerDomain.current.createWorker(loaderInfo.bytes);
			
			//Create message channel TO the worker
			_mainToBack = Worker.current.createMessageChannel(_worker);
			
			//Create message channel FROM the worker, add a listener.
			_backToMain = _worker.createMessageChannel(Worker.current);
			_backToMain.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain, false, 0, true);
			
			//Now that we have our two channels, inject them into the worker as shared properties.
			//This way, the worker can see them on the other side.
			_worker.setSharedProperty("backToMain", _backToMain);
			_worker.setSharedProperty("mainToBack", _mainToBack);
			
			_worker.setSharedProperty("swfBinaryData", _swfBinaryData);
			
			_worker.start();
		}
		
		protected function onBackToMain(event:Event):void {
			var msg:String = _backToMain.receive();
			if(msg == "TOTAL_SIZE")
			{
				_totalSize = _backToMain.receive();
			}
			else if(msg == "CURRENT_PROGRESS")
			{
				_bytesLoaded = _backToMain.receive();
				
				var percent:int = 40 + _bytesLoaded / _totalSize * 60;
				if (percent > 41)
				{
					ProgressBar.SetProgress(percent);
				}
			}
			else if(msg == "DECRYPTION_COMPLETE"){
				_swfBinaryData = _backToMain.receive();
				_swfBinaryData.position = 0;
				_decryptionComplete = true; 
				ProgressBar.SetProgress(100);
			}
			trace(msg);
		}
				
		protected function InitUI():void {

		}
		
		protected function GetKey():String
		{
			var domain:String = this.root.loaderInfo.url.split("/")[2];
			var key:String = "INVALID_STRING";
			
			if (domain == "")
			{
				key = "www.planetMars.com.pk_834783#&&39874382749082348977#*";
			}
			else {
				if(domain.indexOf("www.") == -1)
				{
					key = "www." + domain;
				}
				else
				{
					key = domain;
				}	
			}
			
			return key;
		}
	}

}