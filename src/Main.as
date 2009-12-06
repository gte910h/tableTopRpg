//   This is already an implicit subclass of the container...you don't usually see them make a class here.

import com.translator.comms.CommEventStateChange;
import com.translator.comms.ICommState;
import com.widget.ModeChangeButton;
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
import flash.external.ExternalInterface;
//import com.widget.ModeChangeButton;

/**
 * Communication layer we'll be using to store state and such things
 */
private var mComms:IComm;

private var mLoader:Loader;

private var mMap:TileMap;

public function Startup():void
{
    CommFactory.MakeComm(this, _CommsReady);
}

private function _CommsReady(comms:IComm):void
{
    mComms = comms;
    mLoader = new Loader();

    //
    //   XXXXXXXXXXXXXXXXX
    //   X...............X
    //   X...............X
    //   X...............X
    //   XXXXXXXXXXXXXXXXX
    //
    var asciimap:String = "XXXXXXXXXXXXXXXXX\nX...............X\nX...............X\nX...............X\nXXXXXXXXXXXXXXXXX";


    mMap = new TileMap();
    addChild(mMap);
    mMap.x = 0;
    mMap.y = 0;
    mMap.width = 300;
    mMap.height = 300;
    mMap.SetMap(asciimap);


    mComms.AddEventStateChange(_StateCallback);

    // Allow us to change modes
    var modeChangeButton:ModeChangeButton = new ModeChangeButton(mComms);
    modeChangeButton.x = width - modeChangeButton.width;
    modeChangeButton.y = height - modeChangeButton.height;
    addChild(modeChangeButton);
}

private function _Increment(evt:MouseEvent):void
{
    trace("Increment");
    var strCount:String = mComms.GetState().GetValue("count", -1);
    var numCount:Number = 0;
    if (strCount != null)
    {
        numCount = parseInt(strCount);
    }

    var delta:Object = { };
    delta.count = numCount+1;
    mComms.SubmitDelta(delta);
}

/*
private function _SelectImage(evt:Event):void
{
    var delta:Object = new Object();
    delta.bgImage = txtImage.text;
    mComms.SubmitDelta(delta);
}

private function _LoadImageIfNecessary(strImage:String):void
{
    trace("_LoadImageIfNecessary");

    if (strImage != image1.source)
    {
        image1.addEventListener(Event.COMPLETE, _ImageLoadComplete);
        image1.load(strImage);
    }
}

private function _ImageLoadComplete(event:Event):void
{
    trace("_ImageLoadComplete");
    image1.removeEventListener(Event.COMPLETE, _ImageLoadComplete);

    width = image1.contentWidth;
    height = image1.contentHeight;
}
*/

private function _StateCallback(stateEvent:CommEventStateChange):void
{
    _StateChanged(stateEvent.State);
}

private function _StateChanged(newState:ICommState):void
{
    /*
    var strCount:String = newState.GetStringValue("count");

    var numCount:Number = 0;
    if (strCount != null)
    {
        numCount = parseInt(strCount);
    }

    var strImage:String = newState.GetStringValue("bgImage");
    _LoadImageIfNecessary(strImage);
    */
}

