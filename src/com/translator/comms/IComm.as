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
         * Returns the current mode
         * @return Current mode, from CommMode
         */
        function GetMode():String;

        /**
         * Adds a callback for when the state is changed.
         * @param callback Will be passed an object of type CommEventStateChange
         */
        function AddEventStateChange(callback:Function):void;

        /**
         * Removes a callback for when the state is changed.
         * @param callback Callback to remove
         */
        function RemoveEventStateChange(callback:Function):void;

        /**
         * Adds a callback for when the Mode is changed
         * @param callback Will be passed an object of type CommEventModeChange
         */
        function AddEventModeChange(callback:Function):void;

        /**
         * Removes a callback for when the Mode is changed.
         * @param callback Callback to remove
         */
        function RemoveEventModeChange(callback:Function):void;

        /**
         * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
         * @param delta Map of key-value pairs representing a delta of keys to update.
         */
        function SubmitDelta(delta:Object):void;

        /**
         * Request that the mode be changed.  Asynchronous call, wait for events to determine if it happened for real
         * @param newMode New mode (from CommMode)
         */
        function ChangeMode(newMode:String):void;

        /**
         * Get the user who is viewing this Comm
         * @return The viewing user
         */
        function GetViewingUser():IUser;

        /**
         * Get the user who originally started this gadget
         * @return The host user
         */
        function GetHostUser():IUser;

        /**
         * Return whether the Viewer and the Host are the same user
         * @return
         */
        function IsViewerHost():Boolean;
    }
}