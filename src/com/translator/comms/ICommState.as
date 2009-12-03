package com.translator.comms
{
    public interface ICommState
    {
        /**
         * Retrieve a String value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return String for the specified key or the default if not found.
         */
        function GetStringValue(key:String, defaultVal:String = null):String;

        /**
         * Retrieve a Number value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return Number for the specified key or the default if not found.
         */
        function GetNumberValue(key:String, defaultVal:Number = -1):Number;

        /**
         * Retrieve an Array value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return Number for the specified key or the default if not found.
         */
        function GetArrayValue(key:String, defaultVal:Array = null):Array;

        /**
         * Retrieve the valid keys for the synchronized state.
         * @return set of keys
         */
        function GetKeys():Array;

        /**
         * Return whether the given state object is strictly contained within the current state object
         * @param delta Change we are considering applying
         * @return True if that change is already what we have and therefore we don't need to submit it
         */
        function IsSameState(delta:Object):Boolean;
    }
}