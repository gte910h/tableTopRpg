package com.widget.Components
{
    import com.translator.comms.CommEventModeChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import flash.events.Event;
    import mx.containers.Canvas;
    import mx.controls.Text;
    import mx.controls.TextInput;

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
        private var mDisplay:Text;

        public function EditableText(comms:IComm)
        {
            mComms = comms;

            mInput = new TextInput();
            addChild(mInput);
            mDisplay = new Text();
            addChild(mDisplay);

            addEventListener(Event.ADDED_TO_STAGE, _AddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, _RemovedFromStage);

            _SwitchModeTo(mComms.GetMode());
        }

        /**
         * This object has been added to the stage
         * @param e The event
         */
        private function _AddedToStage(e:Event):void
        {
            mInput.addEventListener(Event.CHANGE, _TextInputChanged);
            mComms.AddEventModeChange(_EventModeChange);
        }

        /**
         * This object has been removed from the stage
         * @param e The event
         */
        private function _RemovedFromStage(e:Event):void
        {
            mComms.RemoveEventModeChange(_EventModeChange);
            mInput.removeEventListener(Event.CHANGE, _TextInputChanged);
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
            _SwitchModeTo(ev.Mode);
        }

        /**
         * Switch to the given comm mode
         * @param mode New mode to switch to
         */
        private function _SwitchModeTo(mode:String):void
        {
            switch (mComms.GetMode())
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