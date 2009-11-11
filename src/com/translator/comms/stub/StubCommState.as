package com.translator.comms.stub
{
    import com.translator.comms.ICommState;

    /**
     * Stubbed out implementation of ICommState, for when we're not actually in a Wave
     */
    public class StubCommState implements ICommState
    {
        /**
         * <key,value> map to store the data.  State is basically a data structure of key/value map.
         */
        private var mStateMap:Object = new Object();

        /**
         * correspond to wave.State.get(key, opt_default)
         * Retrieve a value from the synchronized state.
         *
         * @param key  specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return Object for the specified key or null if not found.
         */
        public function GetStringValue(key:String, defaultVal:String = null):String
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
    }
}