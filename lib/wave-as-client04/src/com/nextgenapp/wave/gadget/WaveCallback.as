package com.nextgenapp.wave.gadget
{
	/**
	 * wrapper for callback function. 
	 * 
	 * @author sol wu
	 */
	public class WaveCallback
	{
		private var callback:Function;
		private var opt_context:Object;
		
		/**
		 * 
		 * @param callback  function(Array.<*>, ?Object=)  or null
		 * @opt_context  If context is specified, the method will be called back in the context of that object (optional). 
		 */
		public function WaveCallback(callback:Function, opt_context:Object=null)
		{
			this.callback = callback;
			this.opt_context = opt_context;
		}
		
		/**
		 * Invokes the callback method with any arguments passed in.
		 */
		public function invoke(...var_args):void {
			if (opt_context) {
				// todo: check var_args passing
				callback.apply(opt_context, var_args);
			} else {
				callback(var_args);
			}
		}

	}
}