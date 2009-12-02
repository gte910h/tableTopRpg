package com.widget.Components
{
    import com.translator.comms.IComm;
    import mx.containers.Canvas;
    import mx.containers.VBox;
    import mx.controls.Text;
    import mx.controls.TextInput;
    import mx.core.ScrollPolicy;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;

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
         * All the fields we are displaying
         */
        private var mListFields:Array;

        /**
         * Constructor
         * @param comms Communication object
         */
        public function TextList(comms:IComm)
        {
            mComms = comms;

            //this.setStyle("borderStyle", "solid");
            //this.setStyle("backgroundColor", "white");

            this.horizontalScrollPolicy = ScrollPolicy.OFF;

            var vBox:VBox = new VBox();
            vBox.percentHeight = 100;
            vBox.percentWidth = 95;
            vBox.setStyle("verticalGap", 0);

            /*
            vBox.addChild(_CreateNewField("-2 to all defenses (Elan)"));
            vBox.addChild(_CreateNewField("Cursed by Sangria"));
            vBox.addChild(_CreateNewField("W W W W W W W W W W W W"));
            vBox.addChild(_CreateNewField("WW W W W W W W W W W W W"));
            vBox.addChild(_CreateNewField("What's up, doc?"));
            vBox.addChild(_CreateNewField("Hey there, people!"));
            vBox.addChild(_CreateNewField("Some text here."));
            */

            this.addChild(vBox);
        }

        private function _CreateNewField(text:String):UIComponent
        {
            var field:Text = new Text();
            field.percentWidth = 90;
            field.text = "- " + text;
            field.setStyle("fontSize", 9);
            return field;
        }
    }
}