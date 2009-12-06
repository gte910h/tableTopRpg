package com.translator.comms.stub
{
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
         * Sprite on which we will set on onEnterFrame for async stuff
         */
        private var mSprite:Sprite;

        /**
         * Stubbed out implementation of IComm, for when we're not actually in a Wave
         * @param callWhenReady Function to call when ready
         * @param sprite For an onEnterFrame
         */
        public function StubComm(callWhenReady:Function, sprite:Sprite)
        {
            super(callWhenReady);

            mSprite = sprite;

            var fakedInitialState:Object = null; // For testing
            mState = new StubCommState(fakedInitialState);
            mCurrentMode = CommMode.VIEW;

            if (!CommStateUtil.UpdateVersionIfNecessary(this, mState))
            {
                _DispatchReady();
            }
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
                var packed:Object = CommStateUtil.PackObject(delta);

                for (var i:String in packed)
                {
                    var newValue:String = packed[i];
                    trace("[" + i + "] => " + newValue);
                    mState.SetValue(i, newValue);
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
         * Called after we change state so we can delay dispatching change events
         * @param ev Event
         */
        private function _OnEnterFrame(ev:Event):void
        {
            _ClearOnEnterFrame();
            _DispatchStateChange(mState);
            _DispatchReady();
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

        /**
         * Get the user who is viewing this Comm
         * @return The viewing user
         */
        public function GetViewingUser():IUser
        {
            return new StubUser("<your longish name here>");
        }

        /**
         * Get the user who originally started this gadget
         * @return The host user
         */
        public function GetHostUser():IUser
        {
            return new StubUser("<your longish name here>");
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