package com.translator.comms
{
    import flash.events.Event;

    /**
     * Event fired when a Comm's State changes (IE data has arrived)
     */
    public class CommEventStateChange extends Event
    {
        /**
         * String to use when talking about the event
         */
        public static var STATE_CHANGE:String = "stateChange";

        /**
         * The new state
         */
        public var State:ICommState;

        /**
         * Construct an event to fire off at people
         * @param mode New state
         * @param bubbles ?
         * @param cancelable ?
         */
        public function CommEventStateChange(commState:ICommState, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            State = commState;
            super(STATE_CHANGE, bubbles, cancelable);
        }
    }
}