package com.translator.comms
{
    /**
     * Enumeration class defining all the Modes a Comm can be in
     */
    public class CommMode
    {
        /**
         * View mode.  In Wave, this means the user can only see the Blip and can't change it much.
         */
        public static const VIEW:String = "view";

        /**
         * Edit mode.  In Wave, this means the user is messing around with the Blip
         */
        public static const EDIT:String = "edit";
    }
}