package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Fakhir
	 */
	[SWF(width=480,height=320)]
	
	public class Main extends Sprite
	{
		private var ref:FileReference;
		private var lbl1:TextField;
		private var lbl2:TextField;
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			ref = new FileReference();
            ref.addEventListener(Event.SELECT, load);
            ref.browse([new FileFilter("SWF Files", "*.swf")]);
			
			lbl1 = new TextField();
			lbl1.x = 10;
			lbl1.y = 20;
			lbl1.text = "";
			lbl1.width = 200;
			
			lbl2 = new TextField();
			lbl2.x = 10;
			lbl2.y = 40;
			lbl2.text = "";
			lbl2.width = 200;
			
			addChild(lbl1);
			addChild(lbl2);
		}
	
		private function load(e:Event):void
        {
            ref.addEventListener(Event.COMPLETE, processSWF);
            ref.load();
        }
         
        private function processSWF(e:Event):void
        {
            var swf:ByteArray;
            switch(ref.data.readMultiByte(3, "us-ascii"))
            {
                case "CWS":
					lbl1.text = "Decompressing SWF"
                    swf = decompress(ref.data);
                    break;
                case "FWS":
					lbl2.text = "Compressing SWF"
                    swf = compress(ref.data);
                    break;
                default:
                    throw Error("Not SWF...");
                    break;
            }
             
            new FileReference().save(swf);
        }
         
        private function compress(data:ByteArray):ByteArray
       {
            var header:ByteArray = new ByteArray();
            var decompressed:ByteArray = new ByteArray();
            var compressed:ByteArray = new ByteArray();
             
            header.writeBytes(data, 3, 5); //read the header, excluding the signature
            decompressed.writeBytes(data, 8); //read the rest
            
            decompressed.compress();
            
            compressed.writeMultiByte("CWS", "us-ascii"); //mark as compressed
            compressed.writeBytes(header);
            compressed.writeBytes(decompressed);
             
            return compressed;
        }
         
        private function decompress(data:ByteArray):ByteArray
        {
            var header:ByteArray = new ByteArray();
            var compressed:ByteArray = new ByteArray();
            var decompressed:ByteArray = new ByteArray();
             
            header.writeBytes(data, 3, 5); //read the uncompressed header, excluding the signature
            compressed.writeBytes(data, 8); //read the rest, compressed
             
            compressed.uncompress();
             
            decompressed.writeMultiByte("FWS", "us-ascii"); //mark as uncompressed
            decompressed.writeBytes(header); //write the header back
            decompressed.writeBytes(compressed); //write the now uncompressed content
             
            return decompressed;
        }
	}

}