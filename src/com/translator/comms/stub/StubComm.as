package com.translator.comms.stub
{
    import com.translator.comms.BaseComm;
    import com.translator.comms.CommEventStateChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;

    public class StubComm extends BaseComm implements IComm
    {
        /**
         * The State object for this StubComm
         */
        private var mState:StubCommState;

        /**
         * Current mode of the Comm
         */
        private var mCurrentMode:String;

        /**
         * Stubbed out implementation of IComm, for when we're not actually in a Wave
         */
        public function StubComm()
        {
            super();
            mState = new StubCommState();
            mCurrentMode = CommMode.VIEW;
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
         * Returns the current mode
         * @return Current mode, from CommMode
         */
        public function GetMode():String
        {
            return mCurrentMode;
        }

        /**
         * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
         * @param delta	 Map of key-value pairs representing a delta of keys to update.
         */
        public function SubmitDelta(delta:Object):void
        {
            trace("StubComm::SubmitDelta");

            if (!mState.IsSameState(delta))
            {
                for (var i:String in delta)
                {
                    trace("[" + i + "] => " + delta[i]);
                    mState.SetValue(i, delta[i]);
                }
                _DispatchStateChange(mState);
            }
        }

        /**
         * Request that the mode be changed.  Asynchronous call, wait for events to determine if it happened for real
         * @param newMode New mode (from CommMode)
         */
        public function ChangeMode(newMode:String):void
        {
            if (newMode != mCurrentMode)
            {
                mCurrentMode = newMode;
                _DispatchModeChange(mCurrentMode);
            }
        }
    }
}