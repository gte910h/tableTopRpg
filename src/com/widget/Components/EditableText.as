package com.widget.Components
{
    import com.translator.comms.CommEventModeChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import flash.events.Event;
    import mx.containers.Box;
    import mx.containers.Canvas;
    import mx.controls.Label;
    import mx.controls.TextInput;
    import mx.events.FlexEvent;

    /**
     * Class for a TextField that can be editable, or not, based on whether the IComm is currently in Edit Mode
     */
    public class EditableText extends Canvas
    {
        /**
         * Communication layer
         */
        private var mComms:IComm;

        /**
         * Getter to return the text in this EditableText field
         */
        public function get text():String
        {
            return mInput.text;
        }

        /**
         * Setter to set the text in this EditableText field
         */
        public function set text(value:String):void
        {
            mInput.text = value;
            mDisplay.text = value;
        }

        /**
         * Input field
         */
        private var mInput:TextInput;

        /**
         * Display field
         */
        private var mDisplay:Label;

        /**
         * Constructor
         * @param comms Communication layer
         */
        public function EditableText(comms:IComm)
        {
            mComms = comms;

            mDisplay = new Label();
            mDisplay.percentWidth = 100;
            mDisplay.percentHeight = 100;
            addChild(mDisplay);
            mInput = new TextInput();
            mInput.percentWidth = 100;
            mInput.percentHeight = 100;
            addChild(mInput);

            mInput.addEventListener(Event.CHANGE, _TextInputChanged);
            mComms.AddEventModeChange(_EventModeChange);

            _SetModeTo(mComms.GetMode());
        }

        /**
         * The Text Input field has changed - we need to update the Display text as well
         * @param e The event
         */
        private function _TextInputChanged(e:Event):void
        {
            mDisplay.text = mInput.text;
            dispatchEvent(new Event(Event.CHANGE));
        }

        /**
         * Event fired that the mode has changed
         * @param ev Event that fired
         */
        private function _EventModeChange(ev:CommEventModeChange):void
        {
            _SetModeTo(ev.Mode);
        }

        /**
         * Set to the given comm mode
         * @param mode New mode to set to
         */
        private function _SetModeTo(mode:String):void
        {
            switch (mode)
            {
                case CommMode.EDIT:
                    mInput.visible = true;
                    mDisplay.visible = false;
                    break;

                case CommMode.VIEW:
                    mInput.visible = false;
                    mDisplay.visible = true;
                    break;
            }
        }
    }
}