package com.translator.comms
{
    /**
     * Interface to wrap Wave's Participant system
     */
    public interface IUser
    {
        /**
         * Get the name of this user
         * @return The user's name.
         */
         function GetName():String;
    }
}