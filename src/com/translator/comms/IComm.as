package com.translator.comms
{
    /**
     * ...
     * @author Colin C.
     */
    public interface IComm
    {
        /**
         * Returns the state object.
         * @return gadget state (null if not known)
         */
        function GetState():ICommState;

        /**
         * Sets the gadget state update callback.
         * If the state is already received from the container,
         * the callback is invoked immediately to report the current gadget state.
         * Only one callback can be defined.
         * Consecutive calls would remove the old callback and set the new one.
         * @param callback
         */
        function SetStateCallback(callback:Function):void;

        /**
         * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
         * @param delta Map of key-value pairs representing a delta of keys to update.
         */
        function SubmitDelta(delta:Object):void;
    }

}