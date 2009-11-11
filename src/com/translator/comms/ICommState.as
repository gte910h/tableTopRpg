package com.translator.comms
{
    public interface ICommState
    {
        /**
         * correspond to wave.State.get(key, opt_default)
         * Retrieve a value from the synchronized state.
         *
         * @param key  specified key to retrieve.
         * @param defaultVal Optional default value if nonexistent (optional).
         * @return Object for the specified key or null if not found.
         */
        function GetStringValue(key:String, defaultVal:String = null):String;

        /**
         * Retrieve the valid keys for the synchronized state.
         * @return set of keys
         */
        function GetKeys():Array;
    }
}