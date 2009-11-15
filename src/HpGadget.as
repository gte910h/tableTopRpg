// This is already an implicit subclass of the container...you don't usually see them make a class here.

import com.translator.comms.IComm;
import com.translator.comms.CommFactory;

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
    mComms.SetStateCallback(_StateCallback);
}

/**
 * Called when Comms state changes
 */
private function _StateCallback():void
{
    trace("Hello, Comm!");
}
