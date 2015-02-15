package 
{
	import com.hurlant.crypto.symmetric.AESKey;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Fakhir
	 */
	[SWF(width = 480, height = 320)]
	public class Main extends Sprite 
	{
		private var key:String;
        private var ref:FileReference;
		
		private var lbl:TextField;
		private var lbl2:TextField;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			ref = new FileReference();
            ref.addEventListener(Event.SELECT, load);
            ref.browse();
			
			lbl = new TextField();
			lbl.x = 10;
			lbl.y = 20;
			lbl.width = 300;
			lbl.text = "Choose SWF to encrypt";
			addChild(lbl);
			
			lbl2 = new TextField();
			lbl2.x = 10;
			lbl2.y = 40;
			lbl2.width = 300;
			lbl2.text = "";
			addChild(lbl2);
			
			key = "www.delagames.com";
		}
		
		private function load(e:Event):void
        {
            ref.addEventListener(Event.COMPLETE, encrypt);
            ref.load();
        }
         
        private function encrypt(e:Event):void
        {
            var data:ByteArray = ref.data;
             
            var binKey:ByteArray = new ByteArray();
            binKey.writeUTF(key); //AESKey requires binary key
             
            var aes:AESKey = new AESKey(binKey);
            var bytesToEncrypt:int = (data.length & ~15); //make sure that it can be divided by 16, zero the last 4 bytes
            for (var i:int = 0; i < bytesToEncrypt; i += 16)
                aes.encrypt(data, i);
             
            new FileReference().save(data);
			
			//lbl2.text = "Done !!!";
        }
		
	}
	
}