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
        public function WaveCommState(state:WaveState)
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
            return mState.getStringValue(key, defaultVal);
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
            return mState.getKeys();
        }
    }
}