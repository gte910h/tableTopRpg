package com.translator.comms
{
    import adobe.utils.CustomActions;

    /**
     * Class for dealing with State objects
     */
    public class CommStateUtil
    {
        /**
         * We are going to track what "Version" of the Comms we're in.  The verison is the data
         * representation.  For example, version 0 (the default) contained Strings and Numbers,
         * both stored as Strings.  Version 1 will contain Strings and Numbers, stored as Strings
         * with attached type information so we can properly cast them later.  etc.  When the Util
         * starts up it will upgrade the state to latest.
         */
        private static const COMM_VERSION_KEY:String = "CommVersion";

        /**
         * If you change the data format, you must be updating the UnpackValue() and PackValue() functions.  But
         * we want to maintain backward compatibility.
         *
         * In order to maintain backward compatibility, also update this number.  Then demote the UnpackValue() function
         * to _UnpackValueV#() and return it in the _GetUnpackValueFunction() function for the old version number.  You
         * can scrap the old PackValue() function because we won't be packing any more old data.
         */
        private static const LATEST_VERSION:Number = 1;

        /**
         * Take an object with a bunch of typed values and convert it to a packed-up object
         * we can send over Comm.
         * @param input Incoming object
         * @return Object that is safe to send over Comm
         */
        public static function PackObject(input:Object):Object
        {
            if (null != input)
            {
                var packed:Object = new Object();
                for (var key:String in input)
                {
                    packed[key] = _PackValue(input[key]);
                }
                return packed;
            }
            return null;
        }

        /**
         * Take some input value and convert it into a Comm-safe string
         * @param input Input value
         * @return A string that can be sent over Comm
         */
        private static function _PackValue(input:*):String
        {
            if (input is Array)
            {
                var ret:String = "a[";
                var asArray:Array = (input as Array);
                var numItems:Number = asArray.length;

                for (var i:Number = 0 ; i < numItems ; ++i)
                {
                    ret += "|" + _PackValue(asArray[i]);
                }
                ret += "]";

                return ret;
            }
            else
            {
                var inputType:String = typeof(input)
                switch (inputType)
                {
                    case "string":
                    {
                        var asString:String = (input as String);

                        // Get rid of pipes and brackets.  Those are our Array dividers and we don't want them mucking things up.
                        asString = asString.split("|").join("-");
                        asString = asString.split("[").join("-");
                        asString = asString.split("]").join("-");
                        return ("s" + asString);
                    }

                    case "number":
                    {
                        var asNumber:Number = (input as Number);
                        if (Math.floor(asNumber) == asNumber)
                        {
                            return ("i" + asNumber.toString());
                        }
                        else
                        {
                            return ("f" + asNumber.toString());
                        }
                    }

                    case "booleanzzz":
                    {
                        var asBoolean:Boolean = (input as Boolean);
                        return "b" + input.toString();
                    }

                    default: throw ("Unable to Pack value of type \"" + inputType + "\"");
                }
            }
            return null;
        }

        /**
         * Take a Comm-safe string input and convert it back into a value we are interested in
         * @param input Input string coming from Comm
         * @return A properly typed value
         */
        public static function UnpackValue(input:String):*
        {
            var typeChar:String = input.charAt(0);
            var theRest:String = input.substr(1);
            switch (typeChar)
            {
                case "s":   return theRest;
                case "f":   return parseFloat(theRest);
                case "i":   return parseInt(theRest);
                case "b":   return Boolean(theRest);
                case "a":
                {
                    var arrayVals:String = theRest.substr(1, theRest.length - 2);
                    var ret:Array = new Array();
                    var nextItemIndex:Number = _FindNextArrayValueIndex(arrayVals, 0);
                    while (-1 != nextItemIndex)
                    {
                        var followingItemIndex:Number = _FindNextArrayValueIndex(arrayVals, nextItemIndex+1);

                        var thisItemString:String;
                        if (nextItemIndex != arrayVals.length)
                        {
                            if ( -1 == followingItemIndex)
                            {
                                thisItemString = arrayVals.substr(nextItemIndex+1, arrayVals.length-nextItemIndex-1);
                            }
                            else
                            {
                                thisItemString = arrayVals.substr(nextItemIndex+1, (followingItemIndex - nextItemIndex-1));
                            }

                            var thisItem:* = UnpackValue(thisItemString);
                            ret.push(thisItem);
                            nextItemIndex = followingItemIndex;
                        }
                        else
                        {
                            // We're actually in the middle of a recursion and at the end of TWO arrays.
                            // That's the only way I could find my way into this bit.
                            nextItemIndex = -1;
                        }
                    }
                    return ret;


                    break;
                }
                default: throw ("Unable to Unpack value with type \"" + typeChar + "\"");
            }
        }


        /**
         * * Incredibly complicted search function.  The point is: given a string and a start index,
         * find the start of the next item.  The next item is NOT necessarily where the next pipe
         * is, because we might currently be on an array, in which case the next item is AFTER the array.
         * So it's got some special sauce for bypassing arrays and getting us to the start of the next item
         * after the array
         * @param arrayString String that we expect to be the insides of an array
         * @param startIndex Where we should begin searching for the next item
         * @return
         */
        private static function _FindNextArrayValueIndex(arrayString:String, startIndex:Number):Number
        {
            var nextPipe:Number = arrayString.indexOf("|", startIndex);

            // Base case: no more values left at all
            if ( -1 == nextPipe)
            {
                return -1;
            }
            else
            {
                // See if we're currently on an array
                if (arrayString.charAt(startIndex) == "a")
                {
                    // We're on an array.  We need to slip ahead to the end of this array.
                    // Problem is, arrays can be inside other arrays and it can all get very complicated.
                    var arrayCount:Number = 0;
                    var endIndex:Number = startIndex;
                    do
                    {
                        var nextArrayStart:Number = arrayString.indexOf("[", endIndex);
                        var nextArrayEnd:Number = arrayString.indexOf("]", endIndex);

                        if (-1 == nextArrayStart)
                        {
                            // We're out of array starts.  That means this ender is the last one
                            arrayCount--;

                            if ( -1 != nextArrayEnd)
                            {
                                endIndex = nextArrayEnd+1;
                            }
                            else
                            {
                                // We must have been on the ].  Scoot over to get rid of it.
                                endIndex += 1;
                            }

                        }
                        else if ( -1 == nextArrayEnd)
                        {
                            // We're out of array ends.  That's impossible
                        }
                        else
                        {
                            // There is both a start and an end.  Keep going
                            if (nextArrayStart < nextArrayEnd)
                            {
                                // There's another array in here.  Delve in
                                arrayCount++;
                                endIndex = nextArrayStart+1;
                            }
                            else
                            {
                                // We have ended the array we were in
                                arrayCount--;
                                endIndex = nextArrayEnd+1;
                            }
                        }
                    }
                    while (0 < arrayCount);

                    return endIndex;
                }
                else
                {
                    // This isn't an array, skip ahead to the next value
                    return nextPipe;
                }
            }
        }

        /**
         * Ask the util to update to the latest state if necessary
         * @param comms Comms object to update
         * @param state The comm state
         * @return True if an update was necessary and has been sent, false if not
         */
        public static function UpdateVersionIfNecessary(comms:IComm, state:ICommState):Boolean
        {
            var version:Number = state.GetValue(COMM_VERSION_KEY, 0);
            if (version < LATEST_VERSION)
            {
                _UpgradeToLatest(comms, state, version);
                return true;
            }
            return false;
        }

        /**
         * We have detected that the state is out of date.  Let's upgrade it to the latest version
         * @param comms Comms object to update
         * @param state The comm state
         * @param oldVersion Previous version we were on
         */
        private static function _UpgradeToLatest(comms:IComm, state:ICommState, oldVersion:Number):void
        {
            // We'll need to extra all the values and make up a new object of the latest type
            var converted:Object = new Object();

            // What unpacking function should we use for the old version?
            var unpackFunction:Function = _GetUnpackValueFunction(oldVersion);

            // Convert every value in the state object
            var keys:Array = state.GetKeys();
            var numKeys:Number = keys.length;
            for (var i:Number = 0 ; i < numKeys ; ++i)
            {
                var key:String = keys[i];
                var rawValue:String = state.GetRawData(key);
                var unpackedValue:* = unpackFunction(rawValue);
                converted[key] = unpackedValue;
            }

            // We also, of course, want to upgrade to the latest version
            converted[COMM_VERSION_KEY] = LATEST_VERSION;

            // Submit the new state.  It will get repacked using the latest packing technique
            comms.SubmitDelta(converted);
        }

        /**
         * Return the correct function to unpack values of a given version
         * @param version Which version we're looking at
         * @return
         */
        private static function _GetUnpackValueFunction(version:Number):Function
        {
            switch (version)
            {
                case 0:     return _UnpackValueV0;
                default:    throw ("Not sure how to unpack values from version " + version);
            }
        }

        /**
         * Unpack a value, version 0
         * @param input Input string
         * @return Output value
         */
        private static function _UnpackValueV0(input:String):*
        {
            // It's either a Number or a String.  If it's a String, \
            // it's the raw input value.
            var asNumber:Number = (input as Number);
            if (isNaN(asNumber))
            {
                return input;
            }
            else
            {
                return asNumber;
            }
        }
    }
}