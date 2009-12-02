package com.widget.Components
{
    import com.translator.comms.IComm;
    import mx.containers.Canvas;
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
         * Constructor
         * @param comms Communication object
         */
        public function TextList(comms:IComm)
        {
            mComms = comms;

        }
    }
}