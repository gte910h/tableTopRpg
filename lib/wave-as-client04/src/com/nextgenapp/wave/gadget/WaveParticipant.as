package com.nextgenapp.wave.gadget
{
	/**
	 * Participant class that describes participants on a wave.
	 * this is a model class.  
	 * 
	 * @author sol wu
	 */
	public class WaveParticipant
	{
		
		public var id:String;
		public var displayName:String;
		public var thumbnailUrl:String;
		
		public function WaveParticipant()
		{
		}
		
		/**
		 * Gets the unique identifier of this participant.
		 * @return The participant's id
		 */
		public function getId():String {
			return this.id;
		}

		/**
		 * get the display name of this participant.
		 * @return the participant's display name.
		 */
		public function getDisplayName():String {
			return this.displayName;
		}
		
		/**
		 * Gets the url of the thumbnail image for this participant.
		 * @return The participant's thumbnail image url.
		 */
		public function getThumbnailUrl():String {
			return this.thumbnailUrl;
		}

		
		/**
		 * translate the object returned by js to as object.
		 */ 
		public static function unboxParticipant(participantObj:Object):WaveParticipant {
			var participant:WaveParticipant = null;
			if (participantObj) {
				participant = new WaveParticipant();
				participant.id = participantObj.id_;
				participant.displayName = participantObj.displayName_;
				participant.thumbnailUrl = participantObj.thumbnailUrl_;
			}
			return participant;
		}
	}
}