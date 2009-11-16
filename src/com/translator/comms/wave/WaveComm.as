package com.translator.comms.wave
{
    import com.nextgenapp.wave.gadget.Wave;
    import com.nextgenapp.wave.gadget.WaveState;
    import com.translator.comms.BaseComm;
    import com.translator.comms.CommEventStateChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import flash.events.EventDispatcher;

    /**
     * Implementation of the IComm interface to actually interact with Google Wave
     */
    public class WaveComm extends BaseComm implements IComm
    {
        /**
         * Our Wave object, set in the constructor
         */
        private var mWave:Wave;

        /**
         * Latest state object we heard about
         */
        private var mWaveState:WaveCommState;

        /**
         * TEMP faked "Mode" of the Wave from CommMode.  We don't currently have real mode
         * control through wave-as-client lib, so I'm just making a slapdash version.
         */
        private var mTempWaveMode:String;

        /**
         * Constructor, takes a set of domains
         */
        public function WaveComm(... domains)
        {
            mEventDispatcher = new EventDispatcher();

            // TODO figure out how to REAL Mode information.
            mTempWaveMode = CommMode.EDIT;
            mWaveState = new WaveCommState();

            mWave = new Wave(domains);
            mWave.setStateCallback(_StateCallback);
        }

        /**
         * Returns the gadget state object.
         * @return 	 gadget state (null if not known)
         */
        public function GetState():ICommState
        {
            return mWaveState;
        }

        /**
         * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
         * @param delta	 Map of key-value pairs representing a delta of keys to update.
         */
        public function SubmitDelta(delta:Object):void
        {
            mWave.submitDelta(delta);
        }

        /**
         * The state has changed
         * @param state New state
         */
        private function _StateCallback(state:WaveState):void
        {
            mWaveState = new WaveCommState(state);
            _DispatchStateChange(mWaveState);
        }

        /**
         * Request that the mode be changed.  Asynchronous call, wait for events to determine if it happened for real
         * @param newMode New mode (from CommMode)
         */
        public function ChangeMode(newMode:String):void
        {
            // TODO implement correctly
            if (newMode != mTempWaveMode)
            {
                mTempWaveMode = newMode;
                _DispatchModeChange(mTempWaveMode);
            }
        }

        /**
         * Returns the current mode
         * @return Current mode, from CommMode
         */
        public function GetMode():String
        {
            // TODO implement correctly
            return mTempWaveMode;
        }
    }
}