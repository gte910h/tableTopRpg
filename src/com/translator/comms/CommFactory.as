package com.translator.comms
{
    import com.translator.comms.IComm;
    import com.translator.comms.stub.StubComm;
    import com.translator.comms.wave.WaveComm;
    import flash.external.ExternalInterface;

    /**
     * Simple factory to create an IComm for you
     */
    public class CommFactory
    {
        public static function MakeComm():IComm
        {
            if (ExternalInterface.available)
            {
                return new WaveComm();
            }
            else
            {
                return new StubComm();
            }
        }
    }
}