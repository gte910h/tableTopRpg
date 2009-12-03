package com.widget
{
    import com.translator.comms.CommEventModeChange;
    import com.translator.comms.CommEventStateChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import com.widget.Components.EditableText;
    import com.widget.Components.TextList;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import mx.containers.Box;
    import mx.containers.Canvas;
    import mx.containers.ControlBar;
    import mx.containers.HBox;
    import mx.containers.Panel;
    import mx.containers.VBox;
    import mx.controls.Button;
    import mx.controls.HRule;
    import mx.controls.Label;
    import mx.controls.LinkButton;
    import mx.controls.NumericStepper;
    import mx.controls.Spacer;
    import mx.controls.Text;
    import mx.controls.TextInput;
    import mx.controls.VRule;
    import mx.core.Container;
    import mx.core.ScrollPolicy;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;

    /**
     * Simple UI Widget to show HP, max HP, etc.
     */
    public class HpWidget extends Canvas
    {
        /**
         * Communication layer
         */
        private var mComms:IComm;

        /**
         * The panel that will hold all the HP data and character name
         */
        private var mHpContainerPanel:Panel;

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
         * Text for whatever update happened last
         */
        private var mLastUpdateText:Text;

        /**
         * Control bar across the bottom when in View mode
         */
        private var mBottomBarViewMode:Container;

        /**
         * Control bar across the bottom when in Edit mode
         */
        private var mBottomBarEditMode:Container;

        /**
         * The Text List showing status indicators
         */
        private var mStatusList:TextList;

        /**
         * A simple box for the user to input a number
         */
        private var mAdjustValue:NumericStepper;

        // Embedded icons for our Buttons
        [Embed(source="../../../img/plus.png")]
        private var mHealIcon:Class;
        [Embed(source="../../../img/minus.png")]
        private var mDamageIcon:Class;
        [Embed(source="../../../img/temporary.png")]
        private var mTempHpIcon:Class;

        // All the various keys we are going to use for our communication state
        private static const NAME_KEY:String = "name";
        private static const CURRENT_HP_KEY:String = "currentHp";
        private static const TEMP_HP_KEY:String = "tempHp";
        private static const MAX_HP_KEY:String = "maxHp";
        private static const NUM_SURGES_KEY:String = "numSurges";
        private static const LAST_UPDATE_KEY:String = "lastChange";
        private static const LAST_UPDATE_USER_KEY:String = "lastChangeUser";

        /**
         * Constructor
         * @param comms Communication layer
         */
        public function HpWidget(comms:IComm)
        {
            mComms = comms;

            // This prefix and instance stuff allows us to have multiple copies of this widget in 1 gadget
            mCommPrefix = "hp" + sInstances;
            sInstances++;


            // Alright, here's the layout.
            // The entire thing is an HBox.  The left side of that is a VBox
            // The top of the VBox is the HP info container.  The bottom of the VBox
            // has little control buttons.
            // The right side of the HBox is going to be status text and updates.


            var hBox:HBox = new HBox();
            hBox.setStyle("horizontalGap", 2);
            _AddObjectToContainer(this, hBox);

            var leftVBox:VBox = new VBox();
            leftVBox.setStyle("verticalGap", 0);
            _AddObjectToContainer(hBox, leftVBox, 70);

            mHpContainerPanel = new Panel();
            _AddObjectToContainer(mHpContainerPanel,  _SetupInfoArea(comms));
            _AddObjectToContainer(leftVBox, mHpContainerPanel);

            mBottomBarViewMode = _SetupBottomViewBar(comms);
            mBottomBarEditMode = _SetupBottomEditBar(comms);

            // These bottom bar things need to be on top of each other
            var bottomHBox:HBox = new HBox();
            bottomHBox.setStyle("horizontalGap", 0);
            var bottomCanvas:Canvas = new Canvas();
            _AddObjectToContainer(bottomCanvas, mBottomBarViewMode);
            _AddObjectToContainer(bottomCanvas, mBottomBarEditMode);
            _AddObjectToContainer(bottomHBox, bottomCanvas, 92); // Leaving some room for the edit button
            _AddObjectToContainer(leftVBox, bottomHBox);

            var rightVBox:VBox = new VBox();
            rightVBox.setStyle("verticalGap", 2);
            _AddObjectToContainer(hBox, rightVBox, 30);

            mStatusList = new TextList(comms);
            _AddObjectToContainer(rightVBox, mStatusList, 100, 63);

            mLastUpdateText = new Text();
            mLastUpdateText.setStyle("fontSize", 9);
            mLastUpdateText.setStyle("textAlign", "right");
            _AddObjectToContainer(rightVBox, mLastUpdateText, 100, 37);


            mComms.AddEventModeChange(_EventModeChange);
            mComms.AddEventStateChange(_EventStateChange);

            _SetModeTo(mComms.GetMode());
            _ApplyState(mComms.GetState());
        }

        /**
         * The state has changed or we're just starting out.  Apply the state to everything.
         */
        private function _ApplyState(state:ICommState):void
        {
            var currentHp:Number = state.GetNumberValue(_GetCommKey(CURRENT_HP_KEY), 25);
            var maxHp:Number = state.GetNumberValue(_GetCommKey(MAX_HP_KEY), 25);
            var tempHp:Number = state.GetNumberValue(_GetCommKey(TEMP_HP_KEY), 0);

            mCurrentHpText.text = currentHp.toString();
            mMaxHpText.text = maxHp.toString();
            mTempHpText.text = tempHp.toString();
            mSurgesText.text = state.GetNumberValue(_GetCommKey(NUM_SURGES_KEY), 5).toString();
            mNameInput.text = state.GetStringValue(_GetCommKey(NAME_KEY), "John Smith");
            mHpContainerPanel.title = mNameInput.text;

            // Change current HP color depending on status
            if (currentHp == maxHp)
            {
                mCurrentHpText.setStyle("color", 0x008000);
            }
            else if (currentHp <= Math.floor(maxHp * .5))
            {
                mCurrentHpText.setStyle("color", 0xc00000);
            }
            else
            {
                mCurrentHpText.setStyle("color", 0x000000);
            }

            // Has temp HP or not?
            if (0 < tempHp)
            {
                mTempHpText.setStyle("color", 0x00dddd);
            }
            else
            {
                mTempHpText.setStyle("color", 0x000000);
            }

            // Show a nice update of who changed what to do what
            var lastUpdate:String = state.GetStringValue(_GetCommKey(LAST_UPDATE_KEY), "");
            var lastUpdateUser:String = state.GetStringValue(_GetCommKey(LAST_UPDATE_USER_KEY), "");
            var fullUpdateText:String = lastUpdate;
            if ("" != lastUpdateUser)
            {
                fullUpdateText = lastUpdateUser + ":\n" + fullUpdateText;
            }
            mLastUpdateText.text = fullUpdateText;
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

            if (!mComms.GetState().IsSameState(sendObj))
            {
                // Something changed.  Let's reset the last state change and fire it off
                sendObj[_GetCommKey(LAST_UPDATE_KEY)] = "Edited";
                sendObj[_GetCommKey(LAST_UPDATE_USER_KEY)] = mComms.GetViewingUser().GetName();
                mComms.SubmitDelta(sendObj);
            }
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
            var maxHpContainer:Container = new HBox();4
            maxHpContainer.setStyle("horizontalGap", 0);
            mMaxHpText = new EditableText(comms);
            mMaxHpText.setStyle("textAlign", "right");
            maxHpContainer.addChild(_CreateLabel("Max", 30));
            _AddObjectToContainer(maxHpContainer, mMaxHpText, 70);

            var tempHpContainer:Container = new HBox();
            tempHpContainer.setStyle("horizontalGap", 0);
            mTempHpText = new EditableText(comms);
            mTempHpText.setStyle("textAlign", "right");
            tempHpContainer.addChild(_CreateLabel("Temp", 30));
            _AddObjectToContainer(tempHpContainer, mTempHpText, 70);

            var surgesContainer:Container = new HBox();
            surgesContainer.setStyle("horizontalGap", 0);
            mSurgesText = new EditableText(comms);
            mSurgesText.setStyle("textAlign", "right");
            surgesContainer.addChild(_CreateLabel("Surge", 30));
            _AddObjectToContainer(surgesContainer, mSurgesText, 70);

            var sideLayout:Container = new VBox();
            _AddObjectToContainer(sideLayout, maxHpContainer);
            sideLayout.addChild(_CreateHRule());
            _AddObjectToContainer(sideLayout, tempHpContainer);
            sideLayout.addChild(_CreateHRule());
            _AddObjectToContainer(sideLayout, surgesContainer);

            var currentHpContainer:Container = new VBox();
            currentHpContainer.percentWidth = 34;
            currentHpContainer.setStyle("verticalGap", 0);
            mCurrentHpText = new EditableText(comms);
            mCurrentHpText.setStyle("textAlign", "center");
            mCurrentHpText.setStyle("fontSize", 58);
            _AddObjectToContainer(currentHpContainer, mCurrentHpText);


            var hLayout:Container = new HBox();
            hLayout.setStyle("horizontalGap", 0);

            _AddObjectToContainer(hLayout, sideLayout, 38);
            hLayout.addChild(_CreateVRule());
            _AddObjectToContainer(hLayout, currentHpContainer, 62);

            return hLayout;
        }

        /**
         * Add an object to a particular container with the specified width and height percentages
         * @param container Container to add the object to
         * @param object Object to add to the container
         * @param percentWidth Percent of the container to take up
         * @param percentHeight Percent of the container to take up
         */
        private function _AddObjectToContainer(container:Container, object:UIComponent, percentWidth:Number = 100, percentHeight:Number = 100):void
        {
            object.percentWidth = percentWidth;
            object.percentHeight = percentHeight;
            container.addChild(object);
        }

        /**
         * Create a label with the given text
         * @param text Text to give the label
         * @return The label
         */
        private function _CreateLabel(text:String, percentWidth:Number=Number.NaN):Label
        {
            var label:Text = new Text();
            label.text = text;
            label.percentWidth = percentWidth;
            return label;
        }

        /**
         * Create a little horizontal divider thingy
         * @return The divider
         */
        private function _CreateHRule():HRule
        {
            var ruler:HRule = new HRule();
            ruler.percentWidth = 100;
            return ruler;
        }

        /**
         * Create a little vertical divider thingy
         * @return The divider
         */
        private function _CreateVRule():VRule
        {
            var ruler:VRule = new VRule();
            ruler.percentHeight = 100;
            return ruler;
        }

        /**
         * The View mode bottom bar is going to adjust youu HP and such
         */
        private function _SetupBottomViewBar(comms:IComm):Container
        {
            mAdjustValue = new NumericStepper();
            mAdjustValue.maximum = 99;
            mAdjustValue.width = 50;

            var healButton:LinkButton = new LinkButton();
            healButton.setStyle("icon", mHealIcon);
            healButton.width = 20;
            healButton.addEventListener(MouseEvent.CLICK, _HealClicked);

            var damageButton:LinkButton = new LinkButton();
            damageButton.setStyle("icon", mDamageIcon);
            damageButton.width = 20;
            damageButton.addEventListener(MouseEvent.CLICK, _DamageClicked);

            var tempHpButton:LinkButton = new LinkButton();
            tempHpButton.setStyle("icon", mTempHpIcon);
            tempHpButton.width = 20;
            tempHpButton.addEventListener(MouseEvent.CLICK, _TempHpClicked);

            var surgeButton:Button = new Button();
            surgeButton.width = 58;
            surgeButton.label = "Surge";
            surgeButton.addEventListener(MouseEvent.CLICK, _SurgeClicked);

            var bar:ControlBar = new ControlBar();
            bar.addChild(mAdjustValue);
            bar.addChild(healButton);
            bar.addChild(damageButton);
            bar.addChild(tempHpButton);
            bar.addChild(surgeButton);

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
            _AddObjectToContainer(bar, mNameInput);

            return bar;
        }

        /**
         * The user wants to heal
         * @param me Event
         */
        private function _HealClicked(me:MouseEvent):void
        {
            // Can only heal if we put in a number
            var amount:Number = mAdjustValue.value;
            if (0 < amount)
            {
                _PerformHeal(amount, false);
            }
            mAdjustValue.value = 0;
        }

        /**
         * The user wants to take damage.  Well I guess he probably doesn't actually want to take damage, but that's what he's doing.
         * @param me Event
         */
        private function _DamageClicked(me:MouseEvent):void
        {
            var amount:Number = mAdjustValue.value;
            if (0 < amount)
            {
                var maxHp:Number = parseInt(mMaxHpText.text);
                var bloodiedVal:Number = Math.floor(maxHp * .5);
                var previousHp:Number = parseInt(mCurrentHpText.text);

                var totalDamageTaken:Number = amount;

                // Damage for that amount.  Take off Temp Hp first
                var tempHp:Number = parseInt(mTempHpText.text);

                var amountTakenFromTemp:Number = Math.min(amount, tempHp);
                var currentHp:Number = previousHp;
                tempHp -= amountTakenFromTemp;
                amount -= amountTakenFromTemp;
                currentHp -= amount;

                // Also cap at -maxHp just because
                currentHp = Math.max(currentHp, -maxHp);


                // Send that info over Comms
                var sendObj:Object = new Object();
                sendObj[_GetCommKey(CURRENT_HP_KEY)] = currentHp;
                sendObj[_GetCommKey(TEMP_HP_KEY)] = tempHp;

                sendObj[_GetCommKey(LAST_UPDATE_KEY)] = "Took " + totalDamageTaken + " damage" + (previousHp > bloodiedVal && currentHp <= bloodiedVal ? " (bloodied)" : "");
                sendObj[_GetCommKey(LAST_UPDATE_USER_KEY)] = mComms.GetViewingUser().GetName();
                mComms.SubmitDelta(sendObj);
            }
            mAdjustValue.value = 0;
        }

        /**
         * The user wants to gain temporary Hp.
         * @param me Event
         */
        private function _TempHpClicked(me:MouseEvent):void
        {
            var amount:Number = mAdjustValue.value;
            if (0 < amount)
            {
                // Temp HP does not stack.  It just becomes the higher of what it was before and the new value
                var tempHp:Number = parseInt(mTempHpText.text);

                // Send a change over comms
                var sendObj:Object = new Object();
                sendObj[_GetCommKey(TEMP_HP_KEY)] = Math.max(amount, tempHp);
                sendObj[_GetCommKey(LAST_UPDATE_KEY)] = "Gained " + amount + " Temp HP" + (tempHp > amount ? " (ineffective)" : "");
                sendObj[_GetCommKey(LAST_UPDATE_USER_KEY)] = mComms.GetViewingUser().GetName();
                mComms.SubmitDelta(sendObj);
            }
            mAdjustValue.value = 0;
        }

        /**
         * The user wants to spend a surge
         * @param me Event
         */
        private function _SurgeClicked(me:MouseEvent):void
        {
            // Can only surge if we have a surge left
            if (0 < parseInt(mSurgesText.text))
            {
                _PerformHeal(mAdjustValue.value, true);
                mAdjustValue.value = 0;
            }
        }

        /**
         * Perform healing
         * @param surgeUsed Whether a surge was used
         */
        private function _PerformHeal(amount:Number, surgeUsed:Boolean=false):void
        {
            var initialHealAmount:Number = amount;
            var maxHp:Number = parseInt(mMaxHpText.text);
            var bloodiedVal:Number = Math.floor(maxHp * .5);
            var previousHp:Number = parseInt(mCurrentHpText.text);

            // Heal for that amount.  Cannot go over max HP.
            // CurrentHp must start at 0 (if we're getting healed, it automatically becomes zero before the healing applies).
            var currentHp:Number = previousHp;
            if (0 > currentHp)
            {
                currentHp = 0;
            }
            currentHp += amount;
            var overHeal:Number = 0;
            if (currentHp > maxHp)
            {
                overHeal = currentHp - maxHp;
                amount -= overHeal;
                currentHp = maxHp;
            }

            // If we used a surge, decrease by 1
            var surgesLeft:Number = parseInt(mSurgesText.text);
            if (surgeUsed)
            {
                surgesLeft -= 1;
            }

            var statusUpdate:String;
            if (0 == initialHealAmount && surgeUsed)
            {
                statusUpdate = "Spent a surge (no healing)";
            }
            else
            {
                statusUpdate = (surgeUsed ? "Surge" : "Healed") + " for " + amount;
                if (overHeal > 0)
                {
                    statusUpdate += " (+" + overHeal + " over)"
                }
                if (previousHp <= bloodiedVal && currentHp > bloodiedVal)
                {
                    statusUpdate += " (un-bloodied)";
                }
            }

            // Send that info over Comms
            var sendObj:Object = new Object();
            sendObj[_GetCommKey(CURRENT_HP_KEY)] = currentHp;
            sendObj[_GetCommKey(NUM_SURGES_KEY)] = surgesLeft;
            sendObj[_GetCommKey(LAST_UPDATE_KEY)] = statusUpdate;
            sendObj[_GetCommKey(LAST_UPDATE_USER_KEY)] = mComms.GetViewingUser().GetName();
            mComms.SubmitDelta(sendObj);
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
                    mLastUpdateText.visible = false;
                    break;

                case CommMode.VIEW:
                    mBottomBarViewMode.visible = true;
                    mBottomBarEditMode.visible = false;
                    mLastUpdateText.visible = true;
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