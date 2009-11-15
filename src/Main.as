//   This is already an implicit subclass of the container...you don't usually see them make a class here.

import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Text;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import com.translator.comms.IComm;
import com.translator.comms.CommFactory;

/**
 * Communication layer we'll be using to store state and such things
 */
private var mComms:IComm;

private var mLoader:Loader;

private var mMap:TileMap;

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


    mMap = new TileMap(asciimap);

    if (mComms == null)
    {
        mComms = CommFactory.MakeComm();
    }
    mComms.SetStateCallback(StateCallback);
}

private function Increment(evt:MouseEvent):void
{
    trace("Increment");
    var strCount:String = mComms.GetState().GetStringValue("count");
    var numCount:Number = 0;
    if (strCount != null)
    {
        numCount = parseInt(strCount);
    }

    var delta:Object = { };
    delta.count = numCount+1;
    mComms.SubmitDelta(delta);
}

private function SelectImage(evt:Event):void
{
    var delta:Object = new Object();
    delta.bgImage = txtImage.text;
    mComms.SubmitDelta(delta);
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
    var strCount:String = mComms.GetState().GetStringValue("count");
    var numCount:Number = 0;
    if (strCount != null)
    {
        numCount = parseInt(strCount);
    }

    var strImage:String = mComms.GetState().GetStringValue("bgImage");
    LoadImageIfNecessary(strImage);
}

