package com.widget.Components
{
    import com.translator.comms.IComm;
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
            mCommPrefix = "hp" + sInstances;
            sInstances++;

            mListItems = new Array();

            _SetupComponents();

            /*
            listBox.addChild(_CreateNewField("-2 to all defenses (Elan)"));
            listBox.addChild(_CreateNewField("Cursed by Sangria"));
            listBox.addChild(_CreateNewField("W W W W W W W W "));
            listBox.addChild(_CreateNewField("WW W W W W W W W "));
            listBox.addChild(_CreateNewField("What's up, doc?"));
            listBox.addChild(_CreateNewField("Hey there, people!"));
            listBox.addChild(_CreateNewField("Some text here."));
            */
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
                var newListItem:Object = _CreateNewListItem(text);
                mListItems.push(newListItem);
                mList.addChild(newListItem.Container);
            }
            mInputText.text = "";
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
            button.removeEventListener(MouseEvent.CLICK, _RemoveButtonClick);

            // Find the index of the list item we're talking about here
            var numItems:Number = mListItems.length;
            for (var i:Number = 0 ; i < numItems ; ++i)
            {
                if (mListItems[i].RemoveButton == button)
                {
                    break;
                }
            }

            // Ejet the item from the list data and the list container
            mListItems.splice(i, 1);
            mList.removeChildAt(i);
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