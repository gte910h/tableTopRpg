package com.translator.comms
{
    import adobe.utils.CustomActions;

    /**
     * Class for dealing with State objects
     */
    public class CommStateUtil
    {
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

                    case "boolean":
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
                case "b":   return "true" == theRest;
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
         * @return The start of the next item (often a pipe, but could be the end of an array or something)
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
         * @return True if an update was necessary and has been sent, false if not and everything is peachy
         */
        public static function UpdateVersionIfNecessary(comms:IComm, state:ICommState):Boolean
        {
            // TODO Get some sort of version updating working
            return false;
        }
    }
}