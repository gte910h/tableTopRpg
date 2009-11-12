package com.translator.comms.stub
{
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import flash.display.Sprite;
    import flash.events.Event;

    public class StubComm implements IComm
    {
        /**
         * The State object for this StubComm
         */
        private var mState:StubCommState = new StubCommState();

        /**
         * Function called when state changes
         */
        private var mStateCallback:Function;

        /**
         * Stubbed out implementation of IComm, for when we're not actually in a Wave
         */
        public function StubComm()
        {
        }

        /**
         * Returns the gadget state object.
         * @return 	 gadget state (null if not known)
         */
        public function GetState():ICommState
        {
            return mState;
        }

        /**
         * Sets the gadget state update callback.
         * If the state is already received from the container,
         * the callback is invoked immediately to report the current gadget state.
         * Only one callback can be defined.
         * Consecutive calls would remove the old callback and set the new one.
         * @param callback
         */
        public function SetStateCallback(callback:Function):void
        {
            trace("StubComm::SetStateCallback");
            mStateCallback = callback;
            mStateCallback();
        }

        /**
         * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
         * @param delta	 Map of key-value pairs representing a delta of keys to update.
         */
        public function SubmitDelta(delta:Object):void
        {
            trace("StubComm::SubmitDelta");
            for (var i:String in delta)
            {
                trace("[" + i + "] => " + delta[i]);
                mState.SetValue(i, delta[i]);
            }
            mStateCallback();
        }


    }

}