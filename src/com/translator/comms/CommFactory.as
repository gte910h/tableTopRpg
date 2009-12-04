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
         * @param sprite A Sprite, in case anything needs an onEnterFrame for anythin
         * @return A new IComm
         */
        public static function MakeComm(sprite:Sprite):IComm
        {
            if (ExternalInterface.available)
            {
                return new WaveComm();
            }
            else
            {
                return new StubComm(sprite);
            }
        }
    }
}