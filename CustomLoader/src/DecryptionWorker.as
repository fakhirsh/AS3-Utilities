package  
{
	import com.hurlant.crypto.symmetric.AESKey;
	import flash.display.*;
	import flash.system.*;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author fakhir
	 */
	public class DecryptionWorker extends Sprite 
	{
		private var _mainToBack:MessageChannel;
		private var _backToMain:MessageChannel;
		
		private var _totalSize:int;
		private var _bytesLoaded:int;
		
		public function DecryptionWorker(EncryptedSWFFileClass:Class, key:String)
		{
			var _worker:Worker = Worker.current;
			
			//Listen on mainToBack for Decrypt events
			_mainToBack = _worker.getSharedProperty("mainToBack");
			_backToMain = _worker.getSharedProperty("backToMain");
		
            
			var _swfBinaryData:ByteArray = new EncryptedSWFFileClass();
			
            var binKey:ByteArray = new ByteArray();
            binKey.writeUTF(key); //AESKey requires binary key
             
            var aes:AESKey = new AESKey(binKey);
            var bytesToDecrypt:int = (_swfBinaryData.length & ~15); //make sure that it can be divided by 16, zero the last 4 bytes
            
			_backToMain.send("TOTAL_SIZE");
			_backToMain.send(bytesToDecrypt);
					
			for (var i:int = 0; i < bytesToDecrypt; i += 16){
                aes.decrypt(_swfBinaryData, i);
				if(i%2048 == 0)
				{
					//CURRENT_PROGRESS
					_backToMain.send("CURRENT_PROGRESS");
					_backToMain.send(i);
				}
			}
			
			_backToMain.send("DECRYPTION_COMPLETE");
			_backToMain.send(_swfBinaryData);
			
			//var loader:Loader = new Loader();
            //addChild(loader);
            //loader.loadBytes(_swfBinaryData, new LoaderContext(false, new ApplicationDomain()));
			
			
		}
		
			
	}

}