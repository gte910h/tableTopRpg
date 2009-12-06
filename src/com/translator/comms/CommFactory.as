package com.translator.comms
{
    import com.translator.comms.IComm;
    import com.translator.comms.stub.StubComm;
    import com.translator.comms.wave.WaveComm;
    import flash.display.Sprite;
    import flash.external.ExternalInterface;

    /**
     * Simple factory to create an IComm for you
     */
    public class CommFactory
    {
        /**
         * Create a Comm
         * @param sprite A Sprite, in case anything needs an onEnterFrame for anything
         * @param callWhenReady Function to call when the comms are ready to go.  Will pass the comms.
         * @return A new IComm
         */
        public static function MakeComm(sprite:Sprite, callWhenReady:Function):void
        {
            if (ExternalInterface.available)
            {
                new WaveComm(callWhenReady, sprite);
            }
            else
            {
                new StubComm(callWhenReady, sprite);
            }
        }
    }
}