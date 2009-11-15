package com.widget
{
    import com.translator.comms.CommEventModeChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import com.widget.Components.EditableText;
    import flash.events.Event;
    import mx.containers.Canvas;
    import mx.containers.ControlBar;
    import mx.containers.Panel;
    import mx.containers.VBox;
    import mx.controls.Button;
    import mx.controls.Label;
    import mx.controls.NumericStepper;
    import mx.controls.Spacer;
    import mx.events.FlexEvent;

    /**
     * Simple UI Widget to show HP, max HP, etc.
     */
    public class HpWidget extends Panel
    {
        /**
         * Communication layer
         */
        private var mComms:IComm;

        /**
         * Max HP text field
         */
        private var mMaxHpText:EditableText;

        /**
         * Max HP text field
         */
        private var mHpText:EditableText;

        /**
         * Temp HP text field
         */
        private var mTempHpText:EditableText;

        /**
         * Control bar across the bottom
         */
        private var mBottomBar:ControlBar;

        /**
         * Constructor
         * @param comms Communication layer
         */
        public function HpWidget(comms:IComm)
        {
            mComms = comms;

            title = "HP Tracker";

            mHpText = new EditableText(comms);
            mHpText.scaleX = 2;
            mHpText.scaleY = 2;
            mHpText.width = 30;
            mHpText.text = "20";

            mMaxHpText = new EditableText(comms);
            mMaxHpText.width = 30;
            mMaxHpText.text = "20";

            mTempHpText = new EditableText(comms);
            mTempHpText.width = 30;
            mTempHpText.text = "0";


            mBottomBar = new ControlBar();
            var adjustLabel:Label = new Label();
            adjustLabel.text = "Adjust HP:";
            mBottomBar.addChild(adjustLabel);
            mBottomBar.addChild(new NumericStepper());
            var spacer:Spacer = new Spacer();
            spacer.percentWidth = 100;
            mBottomBar.addChild(spacer);
            mBottomBar.addChild(new Button());

            var vLayout:VBox = new VBox();
            vLayout.addChild(mHpText);
            vLayout.addChild(mMaxHpText);
            vLayout.addChild(mTempHpText);

            vLayout.percentWidth = 80;

            addChild(vLayout);
            addChild(mBottomBar);

            addEventListener(FlexEvent.CREATION_COMPLETE, _CreationComplete);
        }

        /**
         * This Flex obejct has been created properly
         * @param e Event
         */
        private function _CreationComplete(e:Event):void
        {
            _SwitchModeTo(mComms.GetMode());
            mComms.AddEventModeChange(_EventModeChange);
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
            switch (mode)
            {
                case CommMode.EDIT:
                    mBottomBar.visible = false;
                    break;

                case CommMode.VIEW:
                    mBottomBar.visible = true;
                    break;
            }
        }
    }
}