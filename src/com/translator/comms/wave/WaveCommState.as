package com.translator.comms.wave
{
    import com.translator.comms.ICommState;
    import com.nextgenapp.wave.gadget.WaveState;

    /**
     * Implementation of the ICommState interface to actually interact with Google Wave
     */
    public class WaveCommState implements ICommState
    {
        /**
         * The WaveState object, set in the constructor
         */
        private var mState:WaveState;

        /**
         * Constructor
         */
        public function WaveCommState(state:WaveState=null)
        {
            mState = state;
        }


        /**
         * Retrieve a String value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return String for the specified key or null if not found.
         */
        public function GetStringValue(key:String, defaultVal:String = null):String
        {
            if (null != mState)
            {
                return mState.getStringValue(key, defaultVal);
            }
            return defaultVal;
        }

        /**
         * Retrieve a Number value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return Number for the specified key or -1 if not found.
         */
        public function GetNumberValue(key:String, defaultVal:Number = -1):Number
        {
            return parseInt(GetStringValue(key, defaultVal.toString()));
        }

        /**
         * Retrieve the valid keys for the synchronized state.
         * @return set of keys
         */
        public function GetKeys():Array
        {
            if (null != mState)
            {
                return mState.getKeys();
            }
            return [];
        }

        /**
         * Return whether the given state object is strictly contained within the current state object
         * @param delta Change we are considering applying
         * @return True if that change is already what we have and therefore we don't need to submit it
         */
        public function IsSameState(delta:Object):Boolean
        {
            for (var i:String in delta)
            {
                if (String(delta[i]) != mState.getStringValue(i))
                {
                    return false;
                }
            }
            return true;
        }
    }
}