package com.translator.comms
{
    import flash.events.Event;

    /**
     * Event fired when a Comm's State changes (IE switching from Edit to View or back)
     */
    public class CommEventModeChange extends Event
    {
        /**
         * String to use when talking about the event
         */
        public static var MODE_CHANGE:String = "modeChange";

        /**
         * The new mode (from CommMod)
         */
        public var Mode:String;

        /**
         * Construct an event to fire off at people
         * @param mode New mode (from CommMod)
         * @param bubbles ?
         * @param cancelable ?
         */
        public function CommEventModeChange(mode:String, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            Mode = mode;
            super(MODE_CHANGE, bubbles, cancelable);
        }
    }
}