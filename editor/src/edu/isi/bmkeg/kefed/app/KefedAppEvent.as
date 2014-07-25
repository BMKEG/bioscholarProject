// $Id: KefedAppEvent.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.app {
	
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	
	import flash.events.Event;

	public class KefedAppEvent extends Event {
		
		public static const EDIT_DESIGN:String = "edit-design";
		public static const CANCEL_DESIGN_EDIT:String = "cancel-edit-design";
		public static const SAVE_DESIGN_EDIT:String = "save-edit-design";
		public static const DONE_EDIT_DESIGN:String = "done-edit-design";
		public static const EDIT_DATA:String = "edit-data";
		public static const CANCEL_DATA_EDIT:String = "cancel-edit-data";
		public static const SAVE_DATA_EDIT:String = "save-edit-data";
		public static const DONE_EDIT_DATA:String = "done-edit-data";
		
		public static const ONTOLOGY_LIST_LOADED:String = "ontology-list-loaded";

		public var activeModel:KefedModel;
				
		public function KefedAppEvent(type:String, activeModel:KefedModel) {
			super(type);
			this.activeModel = activeModel;
		}

	}
}