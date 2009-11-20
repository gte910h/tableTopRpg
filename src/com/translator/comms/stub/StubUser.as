package com.translator.comms.stub
{
    import com.translator.comms.IUser;

    /**
     * Stub implementation of the IUser interface
     */
    public class StubUser implements IUser
    {
        /**
         * The user's name
         */
        private var mUserName:String;

        /**
         * Constructor
         * @param userName User's name
         */
        public function StubUser(userName:String)
        {
            mUserName = userName;
        }

        /**
         * Get the name of this user
         * @return The user's name.
         */
        public function GetName():String
        {
            return mUserName;
        }
    }

}