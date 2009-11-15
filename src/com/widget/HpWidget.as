package com.widget
{
    import com.translator.comms.CommEventModeChange;
    import com.translator.comms.CommEventStateChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import com.widget.Components.EditableText;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import mx.accessibility.ButtonAccImpl;
    import mx.containers.Box;
    import mx.containers.ControlBar;
    import mx.containers.Panel;
    import mx.containers.VBox;
    import mx.controls.Button;
    import mx.controls.Label;
    import mx.controls.NumericStepper;
    import mx.controls.Spacer;
    import mx.controls.TextInput;
    import mx.core.Container;
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
         * Prefix we will send to every comm message.  This is to avoid conflicts
         * with any other widgets
         */
        private var mCommPrefix:String;

        /**
         * Count of the number of instances of this object
         */
        private static var sInstances:Number = 0;

        /**
         * Max HP text field
         */
        private var mMaxHpText:EditableText;

        /**
         * Max HP text field
         */
        private var mCurrentHpText:EditableText;

        /**
         * Temp HP text field
         */
        private var mTempHpText:EditableText;

        /**
         * Text input field for Name
         */
        private var mNameInput:TextInput;

        /**
         * Control bar across the bottom when in View mode
         */
        private var mBottomBarViewMode:Container;

        /**
         * Control bar across the bottom when in Edit mode
         */
        private var mBottomBarEditMode:Container;

        // All the various keys we are going to use for our communication state
        private static const NAME_KEY:String = "name";
        private static const CURRENT_HP_KEY:String = "currentHp";
        private static const TEMP_HP_KEY:String = "tempHp";
        private static const MAX_HP_KEY:String = "maxHp";

        /**
         * Constructor
         * @param comms Communication layer
         */
        public function HpWidget(comms:IComm)
        {
            mComms = comms;
            mCommPrefix = "hp" + sInstances;
            sInstances++;

            var topLayout:Container = _SetupInfoArea(comms);
            addChild(topLayout);

            mBottomBarViewMode = _SetupBottomViewBar(comms);
            mBottomBarEditMode = _SetupBottomEditBar(comms);

            // We want both the Bottom Bar and the View bar to be on top of each other.
            // To do this, we say that the first one should not be included in the layout
            // code.  It will still go in the next slot, but will not "take up space".
            mBottomBarViewMode.includeInLayout = false;
            addChild(mBottomBarViewMode);
            addChild(mBottomBarEditMode);

            mComms.AddEventModeChange(_EventModeChange);
            mComms.AddEventStateChange(_EventStateChange);

            addEventListener(FlexEvent.UPDATE_COMPLETE, _UpdateComplete);
            _ApplyState(mComms.GetState());
        }

        /**
         * The state has changed or we're just starting out.  Apply the state to everything.
         */
        private function _ApplyState(state:ICommState):void
        {
            mCurrentHpText.text = state.GetNumberValue(_GetCommKey(CURRENT_HP_KEY), 25).toString();
            mMaxHpText.text = state.GetNumberValue(_GetCommKey(MAX_HP_KEY), 25).toString();
            mTempHpText.text = state.GetNumberValue(_GetCommKey(TEMP_HP_KEY), 0).toString();
            mNameInput.text = state.GetStringValue(_GetCommKey(NAME_KEY), "John Smith");
            this.title = mNameInput.text;
        }

        /**
         * Send new values for everything through the Comms layer
         */
        private function _SendStateUpdate():void
        {
            var sendObj:Object = new Object();
            sendObj[_GetCommKey(NAME_KEY)] = mNameInput.text;

            var maxHp:Number = _ParseAndValidateNumber(mMaxHpText.text, 25, 1);
            var currentHp:Number = _ParseAndValidateNumber(mCurrentHpText.text, 25, -maxHp, maxHp);
            var tempHp:Number = _ParseAndValidateNumber(mTempHpText.text, 0, 0);

            sendObj[_GetCommKey(MAX_HP_KEY)] = maxHp;
            sendObj[_GetCommKey(CURRENT_HP_KEY)] = currentHp;
            sendObj[_GetCommKey(TEMP_HP_KEY)] = tempHp;

            mComms.SubmitDelta(sendObj);
        }

        /**
         * Parse a number and return an appropiately validated number in range
         * @param numString Number string to parse
         * @param defaultVal Value in case the numString is not actually a Number
         * @param min Minimum value it could possibly be
         * @param max Maximum value it could possibly be
         * @return
         */
        private function _ParseAndValidateNumber(numString:String, defaultVal:Number, min:Number = Number.NEGATIVE_INFINITY, max:Number = Number.POSITIVE_INFINITY):Number
        {
            var asNumber:Number = parseInt(numString);
            if (isNaN(asNumber))
            {
                asNumber = defaultVal;
            }

            if (asNumber < min)
            {
                asNumber = min;
            }
            else if (asNumber > max)
            {
                asNumber = max;
            }
            return asNumber;
        }

        /**
         * Set up the area that will show all the actual information
         */
        private function _SetupInfoArea(comms:IComm):Container
        {
            mCurrentHpText = new EditableText(comms);
            mCurrentHpText.scaleX = 2;
            mCurrentHpText.scaleY = 2;
            mCurrentHpText.percentWidth = 100;
            mCurrentHpText.text = "20";

            mMaxHpText = new EditableText(comms);
            mMaxHpText.percentWidth = 100;
            mMaxHpText.text = "20";

            mTempHpText = new EditableText(comms);
            mTempHpText.percentWidth = 100;
            mTempHpText.text = "0";

            var vLayout:VBox = new VBox();
            vLayout.addChild(mCurrentHpText);
            vLayout.addChild(mMaxHpText);
            vLayout.addChild(mTempHpText);
            vLayout.percentWidth = 80;
            vLayout.percentHeight = 70;
            return vLayout;
        }

        /**
         * The View mode bottom bar is going to adjust youu HP and such
         */
        private function _SetupBottomViewBar(comms:IComm):Container
        {
            var bar:ControlBar = new ControlBar();
            var adjustLabel:Label = new Label();
            adjustLabel.text = "Adjust:";
            bar.addChild(adjustLabel);

            bar.addChild(new NumericStepper());

            var spacer:Spacer = new Spacer();
            spacer.percentWidth = 100;
            bar.addChild(spacer);

            var healButton:Button = new Button();
            healButton.label = "+";
            bar.addChild(healButton);

            var damageButton:Button = new Button();
            damageButton.label = "-";
            bar.addChild(damageButton);

            var tempHpButton:Button = new Button();
            tempHpButton.label = "T";
            bar.addChild(tempHpButton);

            return bar;
        }

        /**
         * The edit mode bottom bar will just let you adjust your character's name
         */
        private function _SetupBottomEditBar(comms:IComm):Container
        {
            var bar:ControlBar = new ControlBar();
            var nameLabel:Label = new Label();
            nameLabel.text = "Name:";
            bar.addChild(nameLabel);

            mNameInput = new TextInput();
            mNameInput.text = "John Smith";
            mNameInput.percentWidth = 100;
            bar.addChild(mNameInput);

            var spacer:Spacer = new Spacer();
            spacer.percentWidth = 5;
            bar.addChild(spacer);

            var submit:Button = new Button();
            submit.label = "Update";
            submit.addEventListener(MouseEvent.CLICK, _UpdateClicked);
            bar.addChild(submit);

            return bar;
        }

        /**
         * User pressed the "Update" button when in Edit mode
         * @param e Event
         */
        private function _UpdateClicked(e:MouseEvent):void
        {
            _SendStateUpdate();

            // When the user clicks update we can safely assume we are done with View mode.
            mComms.ChangeMode(CommMode.VIEW);
        }

        /**
         * This Flex obejct has been updated
         * @param e Event
         */
        private function _UpdateComplete(e:Event):void
        {
            _SetModeTo(mComms.GetMode());
        }

        /**
         * Event fired that the mode has changed
         * @param ev Event that fired
         */
        private function _EventModeChange(ev:CommEventModeChange):void
        {
            _SetModeTo(ev.Mode);

            _ApplyState(mComms.GetState());
        }

        /**
         * The comms state has changed
         */
        private function _EventStateChange(event:CommEventStateChange):void
        {
            _ApplyState(event.State);
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
                    mBottomBarViewMode.visible = false;
                    mBottomBarEditMode.visible = true;
                    break;

                case CommMode.VIEW:
                    mBottomBarViewMode.visible = true;
                    mBottomBarEditMode.visible = false;
                    break;
            }
        }

        /**
         * Return an appropraite key we should send to or get from Comms
         * @param startingKey
         * @return The key we should actually use to communicate
         */
        private function _GetCommKey(startingKey:String):String
        {
            return mCommPrefix + startingKey;
        }
    }
}