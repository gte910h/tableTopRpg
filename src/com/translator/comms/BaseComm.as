package com.translator.comms
{
    import flash.events.EventDispatcher;
    /**
     * Simple base class for Comms
     */
    public class BaseComm
    {
        /**
         * Making use of AS3's Event system
         */
        private var mEventDispatcher:EventDispatcher;

        /**
         * Listeners waiting for the Comm to be ready.  Set in the constructor
         */
        private var mReadyListener:Function;


        /**
         * Constructor
         * @param callWhenReady Function to call when ready
         */
        public function BaseComm(callWhenReady:Function)
        {
            mEventDispatcher = new EventDispatcher();
            mReadyListener = callWhenReady;
        }

        /**
         * Adds a callback for when the state is changed.
         * @param callback Will be passed an object of type CommEventStateChange
         */
        public function AddEventStateChange(callback:Function):void
        {
            mEventDispatcher.addEventListener(CommEventStateChange.STATE_CHANGE, callback);
        }

        /**
         * Removes a callback for when the state is changed.
         * @param callback Callback to remove
         */
        public function RemoveEventStateChange(callback:Function):void
        {
            mEventDispatcher.removeEventListener(CommEventStateChange.STATE_CHANGE, callback);
        }

        /**
         * Dispatch a state change event
         * @param newState Newly changed state
         */
        protected function _DispatchStateChange(newState:ICommState):void
        {
            mEventDispatcher.dispatchEvent(new CommEventStateChange(newState));
        }

        /**
         * Adds a callback for when the Mode is changed
         * @param callback Will be passed an object of type CommEventModeChange
         */
        public function AddEventModeChange(callback:Function):void
        {
            mEventDispatcher.addEventListener(CommEventModeChange.MODE_CHANGE, callback);
        }

        /**
         * Removes a callback for when the Mode is changed.
         * @param callback Callback to remove
         */
        public function RemoveEventModeChange(callback:Function):void
        {
            mEventDispatcher.removeEventListener(CommEventModeChange.MODE_CHANGE, callback);
        }

        /**
         * Dispatch a mode change event
         * @param newMode Newly changed mode
         */
        protected function _DispatchModeChange(newMode:String):void
        {
            mEventDispatcher.dispatchEvent(new CommEventModeChange(newMode));
        }

        /**
         * Dispatch a call (not actually an event) to all listeners waiting to
         * see if the Comms is ready to go.
         */
        protected function _DispatchReady():void
        {
            if (null != mReadyListener)
            {
                var temp:Function = mReadyListener;
                mReadyListener = null;
                temp(this);
            }
        }
    }
}