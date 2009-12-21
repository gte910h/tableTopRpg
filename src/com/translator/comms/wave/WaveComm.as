package com.translator.comms.wave
{
    import com.nextgenapp.wave.gadget.Wave;
    import com.nextgenapp.wave.gadget.WaveState;
    import com.translator.comms.BaseComm;
    import com.translator.comms.CommEventStateChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.CommStateUtil;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import com.translator.comms.IUser;
    import flash.display.Sprite;
    import flash.events.Event;
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
         * Sprite on which we will set on onEnterFrame for async stuff
         */
        private var mSprite:Sprite

        /**
         * TEMP faked "Mode" of the Wave from CommMode.  We don't currently have real mode
         * control through wave-as-client lib, so I'm just making a slapdash version.
         */
        private var mTempWaveMode:String = null;
        private static const WAVE_MODE_KEY:String = "TempWaveMode";

        /**
         * Object we are waiting to submit
         */
        private var mPendingSubmit:Object;

        /**
         * Constructor, takes a set of domains
         * @param callWhenReady Function to call when ready
         * @param sprite For an onEnterFrame
         */
        public function WaveComm(callWhenReady:Function, sprite:Sprite)
        {
            super(callWhenReady);

            mSprite = sprite;

            mPendingSubmit = new Object();
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
            var shouldSubmit:Boolean = true;
            if (null != mWaveState)
            {
                if (mWaveState.IsSameState(delta))
                {
                    shouldSubmit = false;
                }
            }

            if (shouldSubmit)
            {
                var packed:Object = CommStateUtil.PackObject(delta);
                for (var i:String in packed)
                {
                    mPendingSubmit[i] = packed[i];
                }
                _SetOnEnterFrame();
            }
        }

        /**
         * Set an onEnterFrame for dispatching state
         */
        private function _SetOnEnterFrame():void
        {
            _ClearOnEnterFrame();
            mSprite.addEventListener(Event.ENTER_FRAME, _OnEnterFrame);
        }

        /**
         * Clear the onEnterFrame for dispatching state
         */
        private function _ClearOnEnterFrame():void
        {
            mSprite.removeEventListener(Event.ENTER_FRAME, _OnEnterFrame);
        }

        /**
         * Called after we change state so we can gather a bunch of state changes at once and submit them all in 1 batch
         * @param ev Event
         */
        private function _OnEnterFrame(ev:Event):void
        {
            _ClearOnEnterFrame();
            var delta:Object = mPendingSubmit;
            mPendingSubmit = new Object();

            // Before we send off any data, let's also pack our own Mode along with.
            // This would normally be done through a normal Submit, but Mode is not really
            // supposed to be stored in here anyway.  We're just tacking it on because currently
            // the library we are using can't access the Wave mode.
            var modeDelta:Object = { WAVE_MODE_KEY : mTempWaveMode };
            modeDelta = CommStateUtil.PackObject(modeDelta);
            delta[WAVE_MODE_KEY] = modeDelta[WAVE_MODE_KEY];

            mWave.submitDelta(delta);
        }

        /**
         * The state has changed
         */
        private function _StateCallback(ws:WaveState):void
        {
            var newState:WaveCommState = new WaveCommState(ws);

            if (!CommStateUtil.UpdateVersionIfNecessary(this, newState))
            {
                // Don't actually store state until we are sure it's been upgraded to latest
                mWaveState = newState;

                // WaveComm ITSELF is also storing mode info about the mode it's in.
                // Not dispatching an event here because it messes with the StateChange event stuff
                // This is technically wrong as far as state usually goes, but the problem is if
                // you try to submit state in response to the Mode changing you're going to be
                // very disappointed.  This will get fixed, in theory, when the lib actually does
                // modes rather than me having to do it.
                if (null == mTempWaveMode)
                {
                    var waveMode:String = mWaveState.GetValue(WAVE_MODE_KEY, CommMode.EDIT);
                    if (null != waveMode)
                    {
                        mTempWaveMode = waveMode;
                    }
                }

                // Tell everyone about the state change
                _DispatchStateChange(mWaveState);

                // Tell everything that we're ready to go
                _DispatchReady();
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

        /**
         * Get the user who originally started this gadget
         * @return The host user
         */
        public function GetHostUser():IUser
        {
            return new WaveUser(mWave.getHost());
        }

        /**
         * Return whether the Viewer and the Host are the same user
         * @return
         */
        public function IsViewerHost():Boolean
        {
            return (GetHostUser().IsSameAs(GetViewingUser()));
        }
    }
}