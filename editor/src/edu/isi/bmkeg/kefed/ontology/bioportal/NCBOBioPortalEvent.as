// $Id: NCBOBioPortalEvent.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ontology.bioportal
{

	import flash.events.Event;
	import mx.collections.ArrayCollection;
		
	public class NCBOBioPortalEvent extends Event
	{
		public static const NCBO_SEARCH:String = "ncbo-search";
		public static const NCBO_LIST_ONTOLOGIES:String = "ncbo-list-ontologies";
		public static const SET_ONTOLOGY_IDS:String = "set_ontology_ids";
		public static const ADD_ONTOLOGY_IDS:String = "add_ontology_ids";

		public var searchResults:ArrayCollection;
		
		public function NCBOBioPortalEvent(type:String, searchResults:ArrayCollection)
		{
			super(type);
			this.searchResults = searchResults;
		}
		
	}
	
}