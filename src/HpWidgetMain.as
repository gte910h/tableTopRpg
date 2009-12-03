// This is already an implicit subclass of the container...you don't usually see them make a class here.

import com.translator.comms.CommEventStateChange;
import com.translator.comms.IComm;
import com.translator.comms.CommFactory;
import com.translator.comms.ICommState;
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

    var hpWidget:HpWidget = new HpWidget(mComms);
    hpWidget.percentWidth = 100;
    hpWidget.percentHeight = 100;
    addChild(hpWidget);

    // Allow us to change modes
    var modeChangeButton:ModeChangeButton = new ModeChangeButton(mComms);
    modeChangeButton.x = 220;
    modeChangeButton.y = 135;
    addChild(modeChangeButton);
}