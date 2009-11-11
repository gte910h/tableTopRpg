
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import com.nextgenapp.wave.gadget.Wave;
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.Text;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;

   
//
//   This is already an implicit subclass of the container...you don't usually see them make a class here.
//
//

	
	
        public const DO_WAVE:Boolean = true;

        private var wave:Wave;
        private var mGadget:UIComponent;

//        private var txtDisplay:Text;
  //      private var btnIncrement:Button;

        public function Startup():void
        {
            mGadget = this;
            if (DO_WAVE)
            {
                if (wave == null)
                {
                    wave = new Wave();
                    txtDisplay.text = "In wave container? " + wave.isInWaveContainer();
                }
                wave.setStateCallback(stateCallback);
            }

        }

        private function buttonCreationComplete(evt:FlexEvent):void
        {
            btnIncrement.addEventListener(MouseEvent.CLICK, increment);
        }

        private function increment(evt:MouseEvent):void
        {
			if (!wave) 
			{
				Alert.show("Wave does not exist");
				return;
			}
			
            var strCount:String = wave.getState().getStringValue("count");
            var numCount:Number = 0;
            if (strCount != null)
            {
                numCount = parseInt(strCount);
            }

            var delta:Object = { };
            delta.count = numCount+1;
            wave.submitDelta(delta);
        }

        private function stateCallback(state:Object):void
        {
            var strCount:String = wave.getState().getStringValue("count");
            var numCount:Number = 0;
            if (strCount != null)
            {
                numCount = parseInt(strCount);
            }
            txtDisplay.text = "Count is " + numCount;
        }
    
