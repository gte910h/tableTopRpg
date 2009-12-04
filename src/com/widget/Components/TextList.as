package com.widget.Components
{
    import com.translator.comms.CommEventModeChange;
    import com.translator.comms.CommEventStateChange;
    import com.translator.comms.CommMode;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import mx.containers.Canvas;
    import mx.containers.HBox;
    import mx.containers.VBox;
    import mx.controls.Button;
    import mx.controls.HRule;
    import mx.controls.LinkButton;
    import mx.controls.Spacer;
    import mx.controls.Text;
    import mx.controls.TextInput;
    import mx.core.Container;
    import mx.core.ScrollPolicy;
    import mx.core.UIComponent;

    /**
     * Class for a list of text that can have items added to it and removed from it
     */
    public class TextList extends Canvas
    {
        /**
         * Key we will use for communicating the whole list
         */
        private static const LIST_TEXT_KEY:String = "text";

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
         * Object of all the list items we are displaying.  Contains the following:
         *   Container      - Container housing the whole thing
         *   RemoveButton   - The "remove" button
         *   Text           - The text assocaited with this item
         *   TextBox        - The Text object housing the actual text string
         */
        private var mListItems:/*Object*/Array;

        /**
         * All the text inside those fields (mirrored Array alongside with mListFields)
         */
        private var mListText:/*String*/Array;

        /**
         * The actual list itself
         */
        private var mList:Container;

        /**
         * Field used to add new entries
         */
        private var mInputText:TextInput;

        /**
         * Container housing the input text stuff
         */
        private var mInputTextContainer:Container;

        /**
         * Container housing the List stuff
         */
        private var mListContainer:Container;

        // Image for adding new items
        [Embed(source="../../../../img/add.png")]
        private var mAddIcon:Class;

        // Image for removing items
        [Embed(source="../../../../img/cancel.png")]
        private var mRemoveIcon:Class;

        /**
         * Constructor
         * @param comms Communication object
         */
        public function TextList(comms:IComm)
        {
            mComms = comms;

            // This prefix and instance stuff allows us to have multiple copies of this widget in 1 gadget
            mCommPrefix = "tl" + sInstances;
            sInstances++;

            mListItems = new Array();

            _SetupComponents();

            mComms.AddEventModeChange(_EventModeChange);
            mComms.AddEventStateChange(_EventStateChange);
            _ApplyState(mComms.GetState());
        }

        private function _SetupComponents():void
        {
            var listBox:VBox = new VBox();
            listBox.percentHeight = 100;
            listBox.percentWidth = 85;
            listBox.setStyle("verticalGap", 0);

            listBox.setStyle("borderStyle", "solid");
            listBox.setStyle("backgroundColor", "white");

            var listBoxCanvas:Canvas = new Canvas();
            listBoxCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
            listBoxCanvas.percentHeight = 80;
            listBoxCanvas.percentWidth = 100;
            listBoxCanvas.addChild(listBox);

            var vBox:VBox = new VBox();
            vBox.percentHeight = 100;
            vBox.percentWidth = 100;
            vBox.addChild(listBoxCanvas);

            var addTextBox:TextInput = new TextInput();
            addTextBox.percentWidth = 85;
            addTextBox.percentHeight = 100;
            addTextBox.setStyle("fontSize", 9);

            var addButton:LinkButton = new LinkButton();
            addButton.setStyle("icon", mAddIcon);
            addButton.width = 16;
            addButton.height = 16;

            var addButtonVBox:VBox = new VBox();
            addButtonVBox.setStyle("verticalGap", 0);
            var spacer:Spacer = new Spacer();
            spacer.height = 2;
            addButtonVBox.addChild(spacer);
            addButtonVBox.addChild(addButton);

            var addHBox:HBox = new HBox();
            addHBox.setStyle("horizontalGap", 0);
            addHBox.percentWidth = 100;
            addHBox.percentHeight = 20;
            addHBox.addChild(addTextBox);
            addHBox.addChild(addButtonVBox);

            vBox.addChild(addHBox);

            this.addChild(vBox);


            // Set up the local variables of all the above mumbo jumbo so we can come back and reference that stuff later
            mInputTextContainer = addHBox;
            mInputText = addTextBox;
            mListContainer = listBoxCanvas;
            mList = listBox;

            // Add any listeners we care about
            addButton.addEventListener(MouseEvent.CLICK, _AddButtonClick);
            addTextBox.addEventListener(KeyboardEvent.KEY_DOWN, _AddKeyPressed);
        }

        /**
         * Create a new list item to add to our list of fields.  Returns an object with the following:
         *   Container      - Container housing the whole thing
         *   RemoveButton   - The "remove" button
         *   Text           - The text assocaited with this item
         *   TextBox        - The Text object housing the actual text string
         */
        private function _CreateNewListItem(text:String):Object
        {
            var fieldVBox:VBox = new VBox();
            fieldVBox.percentWidth = 100;
            fieldVBox.setStyle("verticalGap", 0);

            var fieldHBox:HBox = new HBox();
            fieldHBox.percentWidth = 100;
            fieldHBox.setStyle("horizontalGap", 0);

            fieldVBox.addChild(fieldHBox);

            var removeButton:LinkButton = new LinkButton();
            removeButton.setStyle("icon", mRemoveIcon);
            removeButton.width = 16;
            fieldHBox.addChild(removeButton);
            removeButton.addEventListener(MouseEvent.CLICK, _RemoveButtonClick);

            var field:Text = new Text();
            field.percentWidth = 100;
            field.text = text;
            field.setStyle("fontSize", 9);
            fieldHBox.addChild(field);

            var hRule:HRule = new HRule();
            hRule.percentWidth = 100;
            fieldVBox.addChild(hRule);



            var retObject:Object = {
                Container : fieldVBox,
                RemoveButton : removeButton,
                TextBox : field,
                Text : text
            };
            return retObject;
        }

        /**
         * Add whatever text is in the Add box to the list
         */
        private function _AddCurrentText():void
        {
            var text:String = mInputText.text;
            if ("" != text)
            {
                _AddText(text);
            }
            mInputText.text = "";
        }

        /**
         * Add the given text to our tracking
         * @param text The new text
         */
        private function _AddText(text:String):void
        {
            var newListItem:Object = _CreateNewListItem(text);
            mListItems.push(newListItem);
            mList.addChild(newListItem.Container);
        }

        /**
         * The Add button was clicked
         * @param ev Click event
         */
        private function _AddButtonClick(ev:MouseEvent):void
        {
            _AddCurrentText();
        }

        /**
         * A key was pressed while on the Input Text thingy
         * @param ev The keyboard event
         */
        private function _AddKeyPressed(ev:KeyboardEvent):void
        {
            // 13 is enter
            if (13 == ev.keyCode)
            {
                _AddCurrentText();
            }
        }

        /**
         * A remove button was clicked
         * @param ev Event for the removal click
         */
        private function _RemoveButtonClick(ev:MouseEvent):void
        {
            // We don't need that event listener anymore
            var button:Button = Button(ev.target);

            // Find the index of the list item we're talking about here
            var numItems:Number = mListItems.length;
            for (var i:Number = 0 ; i < numItems ; ++i)
            {
                if (mListItems[i].RemoveButton == button)
                {
                    break;
                }
            }

            // Eject the item from the list data and the list container
            _RemoveItemAt(i);
        }

        /**
         * Remove the item at the given index
         * @param index Index to remove
         */
        private function _RemoveItemAt(index:Number):void
        {
            mListItems[index].RemoveButton.removeEventListener(MouseEvent.CLICK, _RemoveButtonClick);
            mListItems.splice(index, 1);
            mList.removeChildAt(index);
        }

        /**
         * Send new values for everything through the Comms layer
         */
        private function _SendStateUpdate():void
        {
            var textList:Array = new Array();
            var numItems:Number = mListItems.length;
            for (var i:Number = 0 ; i < numItems ; ++i)
            {
                textList[i] = mListItems[i].Text;
            }

            var delta:Object = new Object();
            delta[_GetCommKey(LIST_TEXT_KEY)] = textList;
            mComms.SubmitDelta(delta);
        }

        /**
         * The state has changed or we're just starting out.  Apply the state to everything.
         */
        private function _ApplyState(state:ICommState):void
        {
            var i:Number;
            var numItems:Number = mListItems.length;
            for (i = numItems-1 ; i >= 0  ; --i)
            {
                _RemoveItemAt(i);
            }

            var newItems:Array = state.GetValue(_GetCommKey(LIST_TEXT_KEY), []);
            var numNewItems:Number = newItems.length;
            for (i = 0 ; i < numNewItems ; ++i)
            {
                _AddText(newItems[i]);
            }

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
            // I hate you, ActionScript.
            var i:Number;
            var li:Object;
            var numItems:Number = mListItems.length;

            switch (mode)
            {
                case CommMode.EDIT:
                {
                    // Edit mode: Has an Add text box, List moves up to account for it, Remove buttons exist
                    mInputTextContainer.includeInLayout = true;
                    mInputTextContainer.visible = true;
                    mListContainer.height = height - mInputTextContainer.height - 6;

                    for (i = 0 ; i < numItems ; ++i)
                    {
                        li = mListItems[i];
                        li.RemoveButton.visible = true;
                        li.RemoveButton.includeInLayout = true;
                    }
                    break;
                }

                case CommMode.VIEW:
                {
                    // View mode: no Add text box, List takes up full height, Remove buttons go away
                    mInputTextContainer.includeInLayout = false;
                    mInputTextContainer.visible = false;
                    mListContainer.percentHeight = 100;

                    for (i = 0 ; i < numItems ; ++i)
                    {
                        li = mListItems[i];
                        li.RemoveButton.visible = false;
                        li.RemoveButton.includeInLayout = false;
                    }
                    break;
                }
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