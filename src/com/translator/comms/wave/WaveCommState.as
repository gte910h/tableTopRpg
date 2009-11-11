package com.translator.comms.wave
{
    import com.nextgenapp.wave.gadget.Wave;
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

        public function WaveCommState(wave:Wave)
        {
            mState = wave.getState();
        }


        /**
         * correspond to wave.State.get(key, opt_default)
         * Retrieve a value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param opt_default Optional default value if nonexistent (optional).
         * @return Object for the specified key or null if not found.
         */
        public function GetStringValue(key:String, opt_default:String = null):String
        {
            return mState.getStringValue(key, opt_default);
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