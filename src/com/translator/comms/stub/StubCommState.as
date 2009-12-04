package com.translator.comms.stub
{
    import com.translator.comms.CommStateUtil;
    import com.translator.comms.ICommState;

    /**
     * Stubbed out implementation of ICommState, for when we're not actually in a Wave
     */
    public class StubCommState implements ICommState
    {
        /**
         * <key,value> map to store the data.  State is basically a data structure of key/value map.
         */
        private var mStateMap:Object;

        /**
         * Constructor
         * @param fakedInitialStateMap Optional initial state map to fake there already being data in the system
         */
        public function StubCommState(fakedInitialStateMap:Object=null):void
        {
            if (null != fakedInitialStateMap)
            {
                mStateMap = fakedInitialStateMap;
            }
            else
            {
                mStateMap = new Object();
            }
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
            var stateVal:String = mStateMap[key];
            if (null != stateVal)
            {
                return CommStateUtil.UnpackValue(stateVal);
            }
            else
            {
                return defaultVal;
            }
        }

        /**
         * Retrieve raw data given a key.  You should not be calling this unless you
         * really need to get at unsafe values as they were stored in data objects.
         * @param key Key of the value
         * @return Raw data
         */
        public function GetRawData(key:String):String
        {
            return mStateMap[key];
        }

        /**
         * Retrieve the valid keys for the synchronized state.
         * @return set of keys
         */
        public function GetKeys():Array
        {
            var ret:Array = new Array();
            for (var i:String in mStateMap)
            {
                ret.push(i);
            }
            return ret;
        }

        /**
         * Set a state value on this object
         * @param key The key
         * @param value New value for that key
         */
        public function SetValue(key:String, value:String):void
        {
            mStateMap[key] = value;
        }

        /**
         * Return whether the given state object is strictly contained within the current state object
         * @param delta Change we are considering applying
         * @return True if that change is already what we have and therefore we don't need to submit it
         */
        public function IsSameState(delta:Object):Boolean
        {
            var packed:Object = CommStateUtil.PackObject(delta);
            for (var i:String in packed)
            {
                if (packed[i] != mStateMap[i])
                {
                    return false;
                }
            }
            return true;
        }
    }
}