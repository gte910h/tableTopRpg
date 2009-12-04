package com.translator.comms.wave
{
    import com.translator.comms.CommStateUtil;
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
         * Retrieve a value from the synchronized state.  It's typed as whatever
         * it was when you submitted it in the first place.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Default value if nonexistent.
         * @return Value for the specified key or the default if not found.
         */
        public function GetValue(key:String, defaultVal:*):*
        {
            if (null != mState)
            {
                var stateVal:String = mState.getStringValue(key);
                if (null != stateVal)
                {
                    return CommStateUtil.UnpackValue(stateVal);
                }
            }
            return defaultVal;
        }

        /**
         * Retrieve raw data given a key.  You should not be calling this unless you
         * really need to get at unsafe values as they were stored in data objects.
         * @param key Key of the value
         * @return Raw data
         */
        public function GetRawData(key:String):String
        {
            if (null != mState)
            {
                return mState.getStringValue(key);
            }
            return null;
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
            if (null != mState)
            {
                var packed:Object = CommStateUtil.PackObject(delta);
                for (var i:String in packed)
                {
                    if (packed[i] != mState.getStringValue(i))
                    {
                        return false;
                    }
                }
                return true;
            }
            return false;
        }
    }
}