﻿package com.widget
{
    import com.translator.comms.CommEventModeChange;
    import com.translator.comms.IComm;
    import com.translator.comms.CommMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import mx.containers.Canvas;
    import mx.controls.Image;
    import mx.controls.LinkButton;

    /**
     * Button to switch between Edit and View modes
     */
    public class ModeChangeButton extends LinkButton
    {
        /**
         * Communication layer
         */
        private var mComms:IComm;

        [Embed(source="../../../img/wrench.png")]
        private var mEditIcon:Class;
        [Embed(source = "../../../img/magnifier.png")]
        private var mViewIcon:Class;

        /**
         * Constructor
         * @param comms Communication layer
         */
        public function ModeChangeButton(comms:IComm)
        {
            mComms = comms;

            addEventListener(Event.ADDED_TO_STAGE, _AddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, _RemovedFromStage);

            width = 20;
            height = 20;

            _SwitchModeTo(mComms.GetMode());
        }

        /**
         * Override what happens when this is clicked
         */
        protected override function clickHandler(event:MouseEvent):void
        {
            var newMode:String = CommMode.VIEW;
            switch (mComms.GetMode())
            {
                case CommMode.EDIT:     newMode = CommMode.VIEW;        break;
                case CommMode.VIEW:     newMode = CommMode.EDIT;        break;
            }
            mComms.ChangeMode(newMode);

            super.clickHandler(event);
        }

        /**
         * This object has been added to the stage
         * @param e The event
         */
        private function _AddedToStage(e:Event):void
        {
            mComms.AddEventModeChange(_EventModeChange);
        }

        /**
         * This object has been removed from the stage
         * @param e The event
         */
        private function _RemovedFromStage(e:Event):void
        {
            mComms.RemoveEventModeChange(_EventModeChange);
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
                    this.setStyle("icon", mViewIcon);
                    break;

                case CommMode.VIEW:
                    this.setStyle("icon", mEditIcon);
                    break;
            }
        }
    }
}