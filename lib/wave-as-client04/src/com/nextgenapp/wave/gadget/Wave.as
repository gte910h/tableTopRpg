package com.nextgenapp.wave.gadget
{
    import flash.external.ExternalInterface;
    import flash.system.Security;

    import mx.core.Application;

    /**
     * Main starting point.
     *
     * @author sol wu
     */
    public class Wave
    {
        /** whether we have register callback for stateCallback */
        private static var stateCallbackConfigured:Boolean = false;
        /** whether we have register callback for participantCallback */
        private static var participantCallbackConfigured:Boolean = false;

        /** cache the stateCallback function  */
        private var stateCallback:Function = null;
        /** cache the participantCallback function */
        private var participantCallback:Function = null;
        /** application id from Application.application.id */
        private var appId:String = "";

        /**
         * @param	...domains — One or more strings or URLRequest objects that name the domains from which you want to allow access. You can specify the special domain "*" to allow access from all domains.
         */
        public function Wave(... domains)
        {
            if (domains.length == 0) {
                trace("allowDomain(\"*\")");
                flash.system.Security.allowDomain('*'); // you will want to change this to allow only certain domain.
            } else {
                trace("allowDomain("+domains+")");
                flash.system.Security.allowDomain(domains);;
            }

            this.appId = Application.application.id;
        }

        /**
         * call wave.isInWaveContainer() on js.
         */
        public function isInWaveContainer():Boolean {
            return ExternalInterface.call("wave.isInWaveContainer");
        }

        /**
         * Get the participant whose client renders this gadget.
         * @return the viewer (null if not known)
         */
        public function getViewer():WaveParticipant {
            // call getViewer() function, which will translate wave.Participant js object into generic object.
            var viewerObj:Object = ExternalInterface.call("nextgenapp.wave.gadget.getViewer");
            return WaveParticipant.unboxParticipant(viewerObj);
        }

        /**
         * Get host, participant who added this gadget to the blip.
         * Note that the host may no longer be in the participant list.
         * @return host (null if not known)
         */
        public function getHost():WaveParticipant {
            var hostObj:Object = ExternalInterface.call("nextgenapp.wave.gadget.getHost");
            return WaveParticipant.unboxParticipant(hostObj);
        }

        /**
         * Returns a list of participants on the Wave.
         * @return Participant list
         */
        public function getParticipants():Array {
            var objAr:Array = ExternalInterface.call("nextgenapp.wave.gadget.getParticipants");
            var partiAr:Array = [];
            for each (var obj:Object in objAr) {
                partiAr.push(WaveParticipant.unboxParticipant(obj));
            }
            return partiAr;
        }

        /**
         * Returns a Participant with the given id.
         * @param id	 The id of the participant to retrieve.
         * @return The participant with the given id.
         */
        public function getParticipantById(id:String):WaveParticipant {
            var obj:Object = ExternalInterface.call("nextgenapp.wave.gadget.getParticipantById", id);
            return WaveParticipant.unboxParticipant(obj);
        }

        /**
         * Returns the gadget state object.
         * @return 	 gadget state (null if not known)
         */
        public function getState():WaveState {
            var obj:Object = ExternalInterface.call("nextgenapp.wave.gadget.getState");
            return WaveState.unboxState(obj);
        }

        /**
         * Returns the playback state of the wave/wavelet/gadget.
         * @return whether the gadget should be in the playback state
         */
        public function isPlayback():Boolean {
            return ExternalInterface.call("wave.isPlayback");
        }

        /**
         * Sets the gadget state update callback.
         * If the state is already received from the container,
         * the callback is invoked immediately to report the current gadget state.
         * Only one callback can be defined.
         * Consecutive calls would remove the old callback and set the new one.
         * @param callback
         * @param opt_context	 the object that receives the callback
         */
        public function setStateCallback(callback:Function, opt_context:Object=null):void {
            stateCallback = callback;
            addStateCallback();
        }

        /**
         * if this is the first time this method is called, register the callback function.
         * since there is only one state object, we only to register it once.
         */
        private function addStateCallback():void {
            if (!stateCallbackConfigured) {
                ExternalInterface.addCallback("externalWaveStateCallback", externalWaveStateCallback);
                ExternalInterface.call("nextgenapp.wave.gadget.setStateCallback", appId);
                stateCallbackConfigured = true;
            }
        }

        /**
         * and stateCallback in javascript will call flashId.externalWaveStateCallback.
         */
        private function externalWaveStateCallback(...args):void {
            // translate the results from js to as object, then call
            var ws:WaveState = null;
            if (args.length > 0) {
                var stateObj:Object = args[0];
                ws = WaveState.unboxState(stateObj);
            }

            if (stateCallback != null) {
                stateCallback(ws);
            }
        }

        /**
         * Sets the participant update callback. If the participant information is already received, the callback is invoked immediately to report the current participant information. Only one callback can be defined. Consecutive calls would remove old callback and set the new one.
         *
         * @param callback
         * @param opt_context	 the object that receives the callback
         */
        public function setParticipantCallback(callback:Function, opt_context:Object=null):void {
            participantCallback = callback;
            addParticipantCallback();
        }

        /**
         * if this is the first time this method is called, register the callback function.
         * since there is only one participant callback object, it is
         */
        private function addParticipantCallback():void {
            if (!participantCallbackConfigured) {
                ExternalInterface.addCallback("externalWaveParticipantCallback", externalWaveParticipantCallback);
                ExternalInterface.call("nextgenapp.wave.gadget.setParticipantCallback", appId);
                participantCallbackConfigured = true;
            }
        }

        /**
         * and callback() in javascript will call flashId.externalWaveParticipantCallback.
         *
         * Since only one callback can be defined, it simplifies this method.
         */
        private function externalWaveParticipantCallback(...args):void {
            // translate the results from js to as object, then call
            var participants:Array = [];
            if (args.length > 0) {
                var participantObjs:Array = args[0];
                for each (var participantObj:Object in participantObjs) {
                    participants.push(WaveParticipant.unboxParticipant(participantObj));
                }
            }

            if (participantCallback != null) {
                participantCallback(participants);
            }
        }

        /**
         * Retrieves "gadget time" which is either the playback frame time in the playback mode or the current time otherwise.
         * @return The gadget time.
         */
        public function getTime():Number {
            return ExternalInterface.call("wave.getTime");
        }

        /**
         * this method is in State object on JS API.  However, since there is only one single state, and
         * we have to call wave.getState().submitDelta(), it is better to put this method here.
         *
         * WaveState.submitDelta() is deprecated.
         * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
         * @param delta	 Map of key-value pairs representing a delta of keys to update.
         */
        public function submitDelta(delta:Object):void {
            // there seems to be only one wave object.
            // so we should be able to call wave.getState().submitDelta() instead of keeping a reference
            // of state object at the javascript side.
            ExternalInterface.call("wave.getState().submitDelta", delta);
        }

    }
}