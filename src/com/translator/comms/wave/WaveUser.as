package com.translator.comms.wave
{
    import com.nextgenapp.wave.gadget.WaveParticipant;
    import com.translator.comms.IUser;

    /**
     * Wave-based implementation of IUser
     */
    public class WaveUser implements IUser
    {
        /**
         * The actual WaveParticipant class
         */
        private var mParticipant:WaveParticipant;

        /**
         * Constructor
         * @param participant Wave participant this will represent
         */
        public function WaveUser(participant:WaveParticipant)
        {
            mParticipant = participant;
        }

        /**
         * Get the name of this user
         * @return The user's name.
         */
        public function GetName():String
        {
            return mParticipant.getDisplayName();
        }
    }

}