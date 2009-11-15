// This is already an implicit subclass of the container...you don't usually see them make a class here.

import com.translator.comms.CommEventStateChange;
import com.translator.comms.IComm;
import com.translator.comms.CommFactory;
import com.widget.HpWidget;
import com.widget.ModeChangeButton;
import flash.text.TextField;
import flash.external.ExternalInterface;


import flash.display.Sprite;

/**
 * Communication layer we'll be using to store state and such things
 */
private var mComms:IComm;

/**
 * Startup function.  Called when the SWF loads.
 */
public function Startup():void
{
    mComms = CommFactory.MakeComm();
    addChild(new HpWidget(mComms));

    // Local debug mode - add a ModeChangeButton
    if (!ExternalInterface.available)
    {
        var modeChangeButton:ModeChangeButton = new ModeChangeButton(mComms);
        modeChangeButton.x = 500;
        modeChangeButton.y = 250;
        addChild(modeChangeButton);
    }
}