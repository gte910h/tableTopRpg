package
{
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import com.nextgenapp.wave.gadget.Wave;
    import mx.controls.Alert;
    import mx.controls.Button;

    [SWF(width='400', height='300', backgroundColor='#cccccc', framerate='12')]

    public class Main extends Sprite
    {
        private var wave:Wave;

        private var txtDisplay:TextField;
        private var btnIncrement:Button;

        public function Main():void
        {
            if (stage)
            {
                init();
            }
            else
            {
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
        }

        private function init(e:Event = null):void
        {
            trace("init running!");
            removeEventListener(Event.ADDED_TO_STAGE, init);

            txtDisplay = new TextField();
            txtDisplay.autoSize = "left";
            txtDisplay.text = "What the?";
            stage.addChild(txtDisplay);

            var tf:TextFormat = txtDisplay.getTextFormat();
            tf.size = 30;
            txtDisplay.setTextFormat(tf);

            btnIncrement = new Button();
            btnIncrement.addEventListener(MouseEvent.CLICK, increment);
            stage.addChild(btnIncrement);


            if (wave == null)
            {
                wave = new Wave();
                txtDisplay.text = "In wave container? " + wave.isInWaveContainer();
            }

            wave.setStateCallback(stateCallback);

        }

        private function increment():void
        {
            txtDisplay.text = "increment pressed.";
        }

        private function stateCallback(state:Object):void
        {
            txtDisplay.text = "State Callback Called!";
        }
    }
}