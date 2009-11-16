// This is already an implicit subclass of the container...you don't usually see them make a class here.

import com.translator.comms.CommEventStateChange;
import com.translator.comms.IComm;
import com.translator.comms.CommFactory;
import com.translator.comms.stub.StubComm;
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
    hpWidget.percentHeight = 80; // Accounting for the View/Edit button
    addChild(hpWidget);

    // Allow us to change modes
    var modeChangeButton:ModeChangeButton = new ModeChangeButton(mComms);
    modeChangeButton.x = width - modeChangeButton.width;
    modeChangeButton.y = 0;
    addChild(modeChangeButton);
}