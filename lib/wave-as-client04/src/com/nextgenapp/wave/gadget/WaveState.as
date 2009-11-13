package com.nextgenapp.wave.gadget
{
	import flash.external.ExternalInterface;
	
	/**
	 * State class for managing the gadget state.
	 * 
	 * @author sol wu
	 */
	public class WaveState
	{
		/** 
		 * <key,value> map to store the data.  State is basically a data structure of key/value map.
		 */
		private var map:Object = {};
		
		public function WaveState()
		{
		}
		
		/**
		 * correspond to wave.State.get(key, opt_default)
		 * Retrieve a value from the synchronized state. As of now, get always returns a string. This will change at some point to return whatever was set.
		 * 
		 * @param key  specified key to retrieve.
		 * @param opt_default Optional default value if nonexistent (optional).
		 * @return Object for the specified key or null if not found.
		 */ 
		public function getStringValue(key:String, opt_default:String=null):String {
			if (map[key]) {
				return map[key];
			} else {
				return opt_default;
			}
		}
		
		/**
		 * Retrieve the valid keys for the synchronized state.
		 * @return set of keys
		 */
		public function getKeys():Array {
			var keys:Array = [];
			for (var key:String in map) {
				keys.push(key);
			}
			return keys;
		}
		
		/**
		 * This method is deprecated and will be removed in the future.  Please use Wave.submitDelta() instead.  
		 * @deprecated
		 * 
		 * Updates the state delta. This is an asynchronous call that will update the state and not take effect immediately. Creating any key with a null value will attempt to delete the key.
		 * @param delta	 Map of key-value pairs representing a delta of keys to update.
		 */
		public function submitDelta(delta:Object):void {
			trace("WARNING: WaveState.submitDelta() is DEPRECATED.  Please use Wave.submitDelta() instead.");
			// there seems to be only one wave object.  
			// so we should be able to call wave.getState().submitDelta() instead of keeping a reference 
			// of state object at the javascript side.
			ExternalInterface.call("wave.getState().submitDelta", delta);
		}

		/**
		 * Pretty prints the current state object. Note this is a debug method only.
		 * note: this does not necessarily print the same string as the javascript toString() function.
		 * @return The stringified state
		 */
		public function toString():String {
			var str:String = "";
			for (var key:Object in map) {
				str += (key + "=" + map[key] + ", ");
			}
			return str;
		}
		
		/**
		 * translate the object returned by js to as object.
		 */
		public static function unboxState(stateObj:Object):WaveState {
			var waveState:WaveState = null;
			if (stateObj) {
				waveState = new WaveState();
				for (var propName:Object in stateObj) {
					waveState.map[propName] = stateObj[propName];
				}
			}
			return waveState;
		}
		
	}
}