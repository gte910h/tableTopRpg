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

         /**
          * Return whether this user is the same as another user
          * @param another The other user
          * @return True if they are the same, false if not
          */
         function IsSameAs(another:IUser):Boolean;
    }
}