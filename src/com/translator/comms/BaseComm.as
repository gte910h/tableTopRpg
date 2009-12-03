package com.translator.comms
{
    import flash.events.EventDispatcher;
    /**
     * Simple base class for Comms
     */
    public class BaseComm
    {
        // Some special keys we'll use when working with Arrays
        private static const ARRAY_DELIMITER:String  = "\t";
        private static const ARRAY_NUMBER_TAG:String = "n";
        private static const ARRAY_STRING_TAG:String = "s";

        /**
         * Making use of AS3's Event system
         */
        private var mEventDispatcher:EventDispatcher;

        /**
         * Constructor
         */
        public function BaseComm()
        {
            mEventDispatcher = new EventDispatcher();
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

        // TODO move to comm util
        /**
         * Take any value and make sure it's a string that can be passed over the network
         * @param value Some value
         * @return A string for that value
         */
        protected function _GetSafeString(value:*):String
        {
            if (value is Array)
            {
                return _ConvertArrayToString(value);
            }
            else
            {
                var type:String = typeof(value);
                switch (type)
                {
                    case "string":
                        return String(value);

                    case "number":
                        return Number(value).toString();

                    default:
                        throw ("Unusable type \"" + type + "\" submitted to Comms");
                }
            }
            return undefined;
        }

        /**
         * Take an array and convert into a string we can send over comms safely
         */
        private function _ConvertArrayToString(val:Array):String
        {
            var numItems:Number = val.length;
            for (var i:Number = 0 ; i < numItems ; ++i)
            {
                // Let's prepend some keys
                var type:String = typeof(val[i]);
                switch (type)
                {
                    case "string":
                        val[i] = ARRAY_STRING_TAG + val[i];
                        break;

                    case "number":
                        val[i] = ARRAY_NUMBER_TAG + Number(val[i]).toString();
                        break;

                    default:
                        throw ("Unusable type \"" + type + "\" submitted as part of an Array to Comms");
                }
            }

            var compiledString:String = val.join(ARRAY_DELIMITER);
            return compiledString;
        }
    }
}