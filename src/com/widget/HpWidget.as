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
    import mx.containers.Box;
    import mx.containers.ControlBar;
    import mx.containers.HBox;
    import mx.containers.Panel;
    import mx.containers.VBox;
    import mx.controls.Button;
    import mx.controls.Label;
    import mx.controls.LinkButton;
    import mx.controls.NumericStepper;
    import mx.controls.Spacer;
    import mx.controls.Text;
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
            var currentHp:Number = state.GetNumberValue(_GetCommKey(CURRENT_HP_KEY), 25);
            var maxHp:Number = state.GetNumberValue(_GetCommKey(MAX_HP_KEY), 25);

            mCurrentHpText.text = currentHp.toString();
            mMaxHpText.text = maxHp.toString();
            mTempHpText.text = state.GetNumberValue(_GetCommKey(TEMP_HP_KEY), 0).toString();
            mSurgesText.text = state.GetNumberValue(_GetCommKey(NUM_SURGES_KEY), 5).toString();
            mNameInput.text = state.GetStringValue(_GetCommKey(NAME_KEY), "John Smith");
            this.title = mNameInput.text;

            // Bloodied or not?
            if (currentHp <= Math.floor(maxHp * .5))
            {
                mCurrentHpText.setStyle("color", 0xc00000);
            }
            else
            {
                mCurrentHpText.setStyle("color", 0x000000);
            }

            var lastUpdate:String = state.GetStringValue(_GetCommKey(LAST_UPDATE_KEY), "");
            if ("" == lastUpdate)
            {
                trace("Hey wtf1");
                mLastUpdateText.text = "";
            }
            else
            {
                trace("Hey wtf2");
                mLastUpdateText.text = "Last update:\n" + lastUpdate;
            }

            trace("lastUpdate = " + lastUpdate);
            trace("mLastUpdateText.text = " + mLastUpdateText.text);
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
                sendObj[_GetCommKey(LAST_UPDATE_KEY)] = "";
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
            currentHpContainer.percentWidth = 34;
            currentHpContainer.addChild(_CreateLabel("Current HP"));
            mCurrentHpText = new EditableText(comms);
            mCurrentHpText.scaleX = 2;
            mCurrentHpText.scaleY = 2;
            mCurrentHpText.percentWidth = 100;
            currentHpContainer.addChild(mCurrentHpText);
            currentHpWrapper.addChild(currentHpContainer);

            mLastUpdateText = new Text();
            mLastUpdateText.percentWidth = 33;
            mLastUpdateText.enabled = false;
            currentHpWrapper.addChild(mLastUpdateText);
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

            mAdjustValue = new NumericStepper();
            mAdjustValue.maximum = 999;
            bar.addChild(mAdjustValue);

            var spacer:Spacer = new Spacer();
            spacer.percentWidth = 100;
            bar.addChild(spacer);

            var healButton:LinkButton = new LinkButton();
            healButton.setStyle("icon", mHealIcon);
            healButton.width = 20;
            healButton.addEventListener(MouseEvent.CLICK, _HealClicked);
            bar.addChild(healButton);

            var damageButton:LinkButton = new LinkButton();
            damageButton.setStyle("icon", mDamageIcon);
            damageButton.width = 20;
            damageButton.addEventListener(MouseEvent.CLICK, _DamageClicked);
            bar.addChild(damageButton);

            var tempHpButton:LinkButton = new LinkButton();
            tempHpButton.setStyle("icon", mTempHpIcon);
            tempHpButton.width = 20;
            tempHpButton.addEventListener(MouseEvent.CLICK, _TempHpClicked);
            bar.addChild(tempHpButton);

            var surgeButton:Button = new Button();
            surgeButton.width = 58;
            surgeButton.label = "Surge";
            surgeButton.addEventListener(MouseEvent.CLICK, _SurgeClicked);
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
            mNameInput.percentWidth = 100;
            bar.addChild(mNameInput);

            return bar;
        }

        /**
         * The user wants to heal
         * @param me Event
         */
        private function _HealClicked(me:MouseEvent):void
        {
            _AttemptHeal(false);
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
                var totalDamageTaken:Number = amount;

                // Damage for that amount.  Take off Temp Hp first
                var tempHp:Number = parseInt(mTempHpText.text);
                var currentHp:Number = parseInt(mCurrentHpText.text);

                var amountTakenFromTemp:Number = Math.min(amount, tempHp);
                tempHp -= amountTakenFromTemp;
                amount -= amountTakenFromTemp;
                currentHp -= amount;

                // Also cap at -maxHp just because
                var maxHp:Number = parseInt(mMaxHpText.text);
                currentHp = Math.max(currentHp, -maxHp);

                // Send that info over Comms
                var sendObj:Object = new Object();
                sendObj[_GetCommKey(CURRENT_HP_KEY)] = currentHp;
                sendObj[_GetCommKey(TEMP_HP_KEY)] = tempHp;
                sendObj[_GetCommKey(LAST_UPDATE_KEY)] = "Took " + totalDamageTaken + " damage";
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
                _AttemptHeal(true);
            }
        }

        /**
         * Attempt to healing event.  Will look at the current amount on mAdjustValue
         * @param surgeUsed Whether a surge was used
         */
        private function _AttemptHeal(surgeUsed:Boolean=false):void
        {
            var amount:Number = mAdjustValue.value;
            if (0 < amount)
            {
                // Heal for that amount.  Cannot go over max HP.
                // CurrentHp must start at 0 (if we're getting healed, it automatically becomes zero before the healing applies).
                var maxHp:Number = parseInt(mMaxHpText.text);
                var currentHp:Number = parseInt(mCurrentHpText.text);
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

                // Send that info over Comms
                var sendObj:Object = new Object();
                sendObj[_GetCommKey(CURRENT_HP_KEY)] = currentHp;
                sendObj[_GetCommKey(NUM_SURGES_KEY)] = surgesLeft;
                sendObj[_GetCommKey(LAST_UPDATE_KEY)] = (surgeUsed ? "Surged, gaining " : "Healed for ") + amount + (overHeal > 0 ? " (+" + overHeal + " over)" : "");
                mComms.SubmitDelta(sendObj);
            }
            mAdjustValue.value = 0;
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