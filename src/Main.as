
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
import com.translator.comms.IComm;
import com.translator.comms.stub.StubComm;
import com.translator.comms.wave.WaveComm;

import flash.external.ExternalInterface;

//
//   This is already an implicit subclass of the container...you don't usually see them make a class here.
//
//


private var wave:IComm;
private var mGadget:UIComponent;

public function Startup():void
{
    mGadget = this;

    if (wave == null)
    {
        if (ExternalInterface.available)
        {
            wave = new WaveComm();
        }
        else
        {
            wave = new StubComm();
        }

    }
    wave.SetStateCallback(StateCallback);

}

private function Increment(evt:MouseEvent):void
{
    trace("Increment");
    var strCount:String = wave.GetState().GetStringValue("count");
    var numCount:Number = 0;
    if (strCount != null)
    {
        numCount = parseInt(strCount);
    }

    var delta:Object = { };
    delta.count = numCount+1;
    wave.SubmitDelta(delta);
}

private function StateCallback():void
{
    var strCount:String = wave.GetState().GetStringValue("count");
    var numCount:Number = 0;
    if (strCount != null)
    {
        numCount = parseInt(strCount);
    }
    txtDisplay.text = "Count is " + numCount;
}

