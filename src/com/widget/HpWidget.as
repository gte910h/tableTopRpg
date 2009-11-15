package com.widget
{
    import com.translator.comms.IComm;
    import com.widget.Components.EditableText;
    import mx.containers.Canvas;
    import mx.controls.Text;
    import mx.controls.TextInput;
    import mx.core.UIComponent;
    import mx.controls.Label;

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
         * Constructor
         * @param comms Communication layer
         */
        public function HpWidget(comms:IComm)
        {
            mComms = comms;

            mHpText = new EditableText(comms);
            mHpText.scaleX = 2;
            mHpText.scaleY = 2;
            mHpText.width = 30;
            mHpText.text = "20";
            addChild(mHpText);

            mMaxHpText = new EditableText(comms);
            mMaxHpText.y = 50;
            mMaxHpText.width = 30;
            mMaxHpText.text = "20";
            addChild(mMaxHpText);

            mTempHpText = new EditableText(comms);
            mTempHpText.y = 80;
            mTempHpText.width = 30;
            mTempHpText.text = "0";
            addChild(mTempHpText);
        }
    }
}