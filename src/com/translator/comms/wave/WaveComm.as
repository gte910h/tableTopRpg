package com.translator.comms.wave
{
    import com.nextgenapp.wave.gadget.Wave;
    import com.translator.comms.IComm;
    import com.translator.comms.ICommState;

    /**
     * Implementation of the IComm interface to actually interact with Google Wave
     */
    public class WaveComm implements IComm
    {
        /**
         * Our Wave object, set in the constructor
         */
        var mWave:Wave;

        /**
         * Constructor, takes a set of domains
         */
        public function WaveComm(... domains)
        {
            mWave = new Wave(domains);
        }

        /**
         * Returns the gadget state object.
         * @return 	 gadget state (null if not known)
         */
        public function GetState():ICommState
        {
            return new WaveCommState(this);
        }

        /**
         * Sets the gadget state update callback.
         * If the state is already received from the container,
         * the callback is invoked immediately to report the current gadget state.
         * Only one callback can be defined.
         * Consecutive calls would remove the old callback and set the new one.
         * @param callback
         */
        public function SetStateCallback(callback:Function):void
        {
            mWave.setStateCallback(callback);
        }

        /**
         * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
         * @param delta	 Map of key-value pairs representing a delta of keys to update.
         */
        public function SubmitDelta(delta:Object):void
        {
            mWave.submitDelta(delta);
        }
    }
}