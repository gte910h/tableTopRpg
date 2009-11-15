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
    import mx.containers.HBox;
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
         * Healing surges field
         */
        private var mSurgesText:EditableText;

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
        private static const NUM_SURGES_KEY:String = "numSurges";

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
            mSurgesText.text = state.GetNumberValue(_GetCommKey(NUM_SURGES_KEY), 5).toString();
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
            var numSurges:Number = _ParseAndValidateNumber(mSurgesText.text, 5, 0);

            sendObj[_GetCommKey(MAX_HP_KEY)] = maxHp;
            sendObj[_GetCommKey(CURRENT_HP_KEY)] = currentHp;
            sendObj[_GetCommKey(TEMP_HP_KEY)] = tempHp;
            sendObj[_GetCommKey(NUM_SURGES_KEY)] = numSurges;

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
            var vLayout:Container = new VBox();
            vLayout.percentWidth = 100;
            vLayout.percentHeight = 70;

            // Doing a bunch of shenanigans simply becuase I cannot figure out how "Center" works.
            var currentHpWrapper:Container = new HBox();
            currentHpWrapper.percentWidth = 100;

            var spacer1:Spacer = new Spacer();
            spacer1.percentWidth = 33;
            currentHpWrapper.addChild(spacer1);

            var currentHpContainer:Container = new VBox();
            currentHpContainer.percentWidth = 33;
            currentHpContainer.addChild(_CreateLabel("Current HP"));
            mCurrentHpText = new EditableText(comms);
            mCurrentHpText.scaleX = 2;
            mCurrentHpText.scaleY = 2;
            mCurrentHpText.percentWidth = 100;
            currentHpContainer.addChild(mCurrentHpText);
            currentHpWrapper.addChild(currentHpContainer);

            var spacer2:Spacer = new Spacer();
            spacer2.percentWidth = 33;
            currentHpWrapper.addChild(spacer2);
            vLayout.addChild(currentHpWrapper);

            var hLayout:Container = new HBox();
            hLayout.percentWidth = 100;

            var maxHpContainer:Container = new VBox();
            maxHpContainer.percentWidth = 33;
            maxHpContainer.addChild(_CreateLabel("Max HP"));
            mMaxHpText = new EditableText(comms);
            mMaxHpText.percentWidth = 100;
            maxHpContainer.addChild(mMaxHpText);
            hLayout.addChild(maxHpContainer);

            var tempHpContainer:Container = new VBox();
            tempHpContainer.percentWidth = 34;
            tempHpContainer.addChild(_CreateLabel("Temp HP"));
            mTempHpText = new EditableText(comms);
            mTempHpText.percentWidth = 100;
            tempHpContainer.addChild(mTempHpText);
            hLayout.addChild(tempHpContainer);

            var surgesContainer:Container = new VBox();
            surgesContainer.percentWidth = 33;
            surgesContainer.addChild(_CreateLabel("Surges"));
            mSurgesText = new EditableText(comms);
            mSurgesText.percentWidth = 100;
            surgesContainer.addChild(mSurgesText);
            hLayout.addChild(surgesContainer);

            vLayout.addChild(hLayout);
            return vLayout;
        }

        /**
         * Create a label with the given text
         * @param text Text to give the label
         * @return The label
         */
        private function _CreateLabel(text:String):Label
        {
            var label:Label = new Label();
            label.text = text;
            return label;
        }

        /**
         * The View mode bottom bar is going to adjust youu HP and such
         */
        private function _SetupBottomViewBar(comms:IComm):Container
        {
            var bar:ControlBar = new ControlBar();
            bar.addChild(_CreateLabel("Adjust"));

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
            bar.addChild(_CreateLabel("Name"));

            mNameInput = new TextInput();
            mNameInput.percentWidth = 100;
            bar.addChild(mNameInput);

            return bar;
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

            // If the new mode is View mode, we should submit the updates we have pending
            if (CommMode.VIEW == ev.Mode)
            {
                _SendStateUpdate();
            }
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