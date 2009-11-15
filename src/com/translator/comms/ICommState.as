package com.translator.comms
{
    public interface ICommState
    {
        /**
         * Retrieve a String value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return String for the specified key or null if not found.
         */
        function GetStringValue(key:String, defaultVal:String = null):String;

        /**
         * Retrieve a Number value from the synchronized state.
         *
         * @param key specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return Number for the specified key or -1 if not found.
         */
        function GetNumberValue(key:String, defaultVal:Number = -1):Number;

        /**
         * Retrieve the valid keys for the synchronized state.
         * @return set of keys
         */
        function GetKeys():Array;
    }
}