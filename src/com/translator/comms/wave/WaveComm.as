package com.translator.comms.wave
{
    import com.nextgenapp.wave.gadget.Wave;
    import com.nextgenapp.wave.gadget.WaveState;
    import com.translator.comms.BaseComm;
    import com.translator.comms.CommEventStateChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import com.translator.comms.IUser;
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
        private var mTempWaveMode:String = null;
        private static const WAVE_MODE_KEY:String = "TempWaveMode";

        /**
         * Constructor, takes a set of domains
         */
        public function WaveComm()
        {
            super();

            mWaveState = new WaveCommState();

            mWave = new Wave();
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
         * @param delta Map of key-value pairs representing a delta of keys to update.
         */
        public function SubmitDelta(delta:Object):void
        {
            /*
             * Something's busted, not sure what
            var shouldSubmit:Boolean = true;
            if (null != mWaveState)
            {
                if (mWaveState.IsSameState(delta))
                {
                    shouldSubmit = false;
                }
            }

            if (shouldSubmit)
            */
            {
                mWave.submitDelta(delta);
            }
        }

        /**
         * The state has changed
         */
        private function _StateCallback(ws:WaveState):void
        {
            mWaveState = new WaveCommState(ws);

            _DispatchStateChange(mWaveState);

            // WaveComm ITSELF is also storing mode info about the mode it's in.
            // Not dispatching an event here because it messes with the StateChange event stuff
            // This is technically wrong as far as state usually goes, but the problem is if
            // you try to submit state in response to the Mode changing you're going to be
            // very disappointed.  This will get fixed, in theory, when the lib actually does
            // modes rather than me having to do it.
            if (null == mTempWaveMode)
            {
                var waveMode:String = mWaveState.GetStringValue(WAVE_MODE_KEY, CommMode.EDIT);
                if (null != waveMode)
                {
                    mTempWaveMode = waveMode;
                }
            }
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

                // Save that off for next time
                var modeChange:Object = new Object();
                modeChange[WAVE_MODE_KEY] = newMode;
                SubmitDelta(modeChange);
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

        /**
         * Get the user who is viewing this Comm
         * @return The viewing user
         */
        public function GetViewingUser():IUser
        {
            return new WaveUser(mWave.getViewer());
        }
    }
}