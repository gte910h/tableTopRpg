package com.translator.comms
{
    public interface ICommState
    {
        /**
         * Retrieve a value from the synchronized state.  It's typed as whatever
         * it was when you submitted it in the first place.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Default value if nonexistent.
         * @return Value for the specified key or the default if not found.
         */
        function GetValue(key:String, defaultVal:*):*;

        /**
         * Retrieve the valid keys for the synchronized state.
         * @return set of keys
         */
        function GetKeys():Array;

        /**
         * Retrieve raw data given a key.  You should not be calling this unless you
         * really need to get at unsafe values as they were stored in data objects.
         * @param key Key of the value
         * @return Raw data
         */
        function GetRawData(key:String):String;

        /**
         * Return whether the given state object is strictly contained within the current state object
         * @param delta Change we are considering applying
         * @return True if that change is already what we have and therefore we don't need to submit it
         */
        function IsSameState(delta:Object):Boolean;
    }
}