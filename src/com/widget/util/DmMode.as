package com.widget.util
{
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;

    /**
     * Constants relating to Dm Mode
     */
    public class DmMode
    {
        /**
         * Key for whether DM Mode should be on or off.
         */
        private static const DM_MODE_KEY:String = "DmMode";

        /**
         * Return whether DM mode is currently On.  If it's not set, will return false
         * @param commState Current state
         * @return Whether DM mode has been turned on
         */
        public static function IsDmModeOn(commState:ICommState):Boolean
        {
            return commState.GetValue(DM_MODE_KEY, false);
        }

        /**
         * Return whether DM mode has even been specified
         * @param commState Current state
         * @return Whether DM mode has been specified or not
         */
        public static function IsDmModeSpecified(commState:ICommState):Boolean
        {
            return (null != commState.GetValue(DM_MODE_KEY, null));
        }

        /**
         * Turn on or off DM Mode
         * @param comm Communication layer
         * @param dmModeOn True if you want DM mode to be on
         */
        public static function SetDmMode(comm:IComm, dmModeOn:Boolean):void
        {
            var delta:Object = new Object();
            delta[DM_MODE_KEY] = dmModeOn;
            comm.SubmitDelta(delta);
        }
    }
}