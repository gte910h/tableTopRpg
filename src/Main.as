
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import com.nextgenapp.wave.gadget.Wave;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
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
import tilemap;
private var wave:IComm;

private var mLoader:Loader;

private var the_map:tilemap;

public function Startup():void
{
    mLoader = new Loader();

    //
    //   XXXXXXXXXXXXXXXXX
    //   X...............X
    //   X...............X
    //   X...............X
    //   XXXXXXXXXXXXXXXXX
    //
    var asciimap:String = "XXXXXXXXXXXXXXXXX\nX...............X\nX...............X\nX...............X\nXXXXXXXXXXXXXXXXX";

    
    the_map = new tilemap(asciimap);
    if (wave == null)
    {
        if (ExternalInterface.available)
        {
            trace("Constructing a WaveComm");
            wave = new WaveComm();
        }
        else
        {
            trace("Constructing a StubComm");
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

private function SelectImage(evt:Event):void
{
    var delta:Object = new Object();
    delta.bgImage = txtImage.text;
    wave.SubmitDelta(delta);
}

private function LoadImageIfNecessary(strImage:String):void
{
    trace("LoadImageIfNecessary");

    if (strImage != image1.source)
    {
        image1.addEventListener(Event.COMPLETE, ImageLoadComplete);
        image1.load(strImage);
    }
}

private function ImageLoadComplete(event:Event):void
{
    trace("ImageLoadComplete");
    image1.removeEventListener(Event.COMPLETE, ImageLoadComplete);

    width = image1.contentWidth;
    height = image1.contentHeight;
}

private function StateCallback():void
{
    var strCount:String = wave.GetState().GetStringValue("count");
    var numCount:Number = 0;
    if (strCount != null)
    {
        numCount = parseInt(strCount);
    }

    var strImage:String = wave.GetState().GetStringValue("bgImage");
    LoadImageIfNecessary(strImage);
}

