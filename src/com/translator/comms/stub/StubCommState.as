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
         * Retrieve a String value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return String for the specified key or null if not found.
         */
        public function GetStringValue(key:String, defaultVal:String = null):String
        {
            return mStateMap[key] ? mStateMap[key] : defaultVal;
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
            return mStateMap[key] ? mStateMap[key] : defaultVal;
        }

        /**
         * Retrieve an Array value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return Number for the specified key or the default if not found.
         */
        public function GetArrayValue(key:String, defaultVal:Array = null):Array
        {
            return mStateMap[key] ? _GetArrayFromString(mStateMap[key]) : defaultVal;
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
            for (var i:String in delta)
            {
                if (String(delta[i]) != String(mStateMap[i]))
                {
                    return false;
                }
            }
            return true;
        }




        // TODO this is all messed up
        /**
         * Return an array given a string that went through
         * @param in
         * @return
         */
        private function _GetArrayFromString(input:String):Array
        {
            var ret:Array = input.split("\t");
            var numItems:Number = ret.length;
            for (var i:Number = 0 ; i < numItems ; ++i)
            {
                // Pull out those keys we prepended
                var sub:String = ret[i].substr(1);
                switch(ret[i].charAt(0))
                {
                    case "n":
                        ret[i] = Number(sub)
                        break;

                    case "s":
                        ret[i] = sub;
                }
            }
            return ret;
        }
    }
}