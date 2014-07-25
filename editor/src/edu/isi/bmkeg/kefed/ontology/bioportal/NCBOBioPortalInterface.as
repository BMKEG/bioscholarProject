// $Id: NCBOBioPortalInterface.as 54 2011-07-06 22:57:37Z taruss2000@gmail.com $
//
//  $Date: 2011-07-06 15:57:37 -0700 (Wed, 06 Jul 2011) $
//  $Revision: 54 $
//
package edu.isi.bmkeg.kefed.ontology.bioportal
{

	import edu.isi.bmkeg.kefed.elements.IKefedNamedObject;
	import edu.isi.bmkeg.kefed.ontology.OntologySearchEvent;
	import edu.isi.bmkeg.kefed.ontology.OntologySearchInterface;
	import edu.isi.bmkeg.kefed.ontology.OntologyTermReference;
	
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ArrayUtil;
	
	public class NCBOBioPortalInterface extends OntologySearchInterface {
	
		/** API key for NCBO restful web services calls
		 */
		[Bindable]
		public var apikey:String = "af39dd48-ba3e-43a0-bf72-461030d945d8";

		private var baseUrl:String;
		private var ncboSearchService:HTTPService;
		private var ncboTermService:HTTPService;
		private var ncboListOntologiesService:HTTPService;
		
		private var searchResults:ArrayCollection = new ArrayCollection();

		
		private var term:XML = new XML();
		private var kefedObj:IKefedNamedObject;
		
		public function NCBOBioPortalInterface() {
						
			this.initNcboSearch();
			this.initNcboListOntologies();
				
		}

		/**
		 * ___________________________________________________________
		 * 
		 * Search 
		 * ___________________________________________________________
		 */

		private function initNcboSearch():void {

		 	ncboSearchService = new HTTPService();
		 	ncboSearchService.useProxy = true;
			ncboSearchService.destination="DefaultHTTP";
		 	ncboSearchService.resultFormat = "text";
			ncboSearchService.contentType = "application/javascript";
			ncboSearchService.method = "GET";
			ncboSearchService.addEventListener(ResultEvent.RESULT, ncboSearchResultEventHandler);
			ncboSearchService.addEventListener(FaultEvent.FAULT, faultEventHandler);
			
		}		


		override public function search(kefedObj:IKefedNamedObject, term:String, exact:Boolean, prop:Boolean):void {

			this.kefedObj = kefedObj;
			if (term == null) return;
			// Need to use escape characters for the URL

			var exactStr:String = (exact) ? "1" : "0";
			var propStr:String = (prop) ? "1" : "0";
		 	ncboSearchService.url = "http://rest.bioontology.org/bioportal/search/" 
		 			+ encodeURIComponent(term)
		 			+ "?isexactmatch=" + exactStr 
		 			+ "&includeproperties=" + propStr 
		 			+ "&apikey=" + apikey; 	 	
		 	CursorManager.setBusyCursor();
			ncboSearchService.send();
			
		}

		/** Takes the results from the web service query and puts them
		 *  into an array
		 *  Takes care to select any search results that are already 
		 *  present in the current Kefed object's onologyId field.
		 * 
		 * @param event The result event for the web service query
		 */
		private function ncboSearchResultEventHandler(event:ResultEvent):void {
		
			var xmlDoc:XMLDocument =  new XMLDocument(XML(event.result));	
			
		 	CursorManager.removeBusyCursor();
		 	
		 	var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
            var topXMLObject:Object = decoder.decodeXML(xmlDoc);
                
            var check:Object = topXMLObject.success.data;
            
            searchResults = new ArrayCollection();
            
            // Store a hash table of concept IDs so that we can
            // find those concepts that are already selected for
            // our variables.
            // NOTE:  This is currently done by just using the
            //  ontologyIdentifier field, which is not guaranteed
            //  unique across ontologies.  It should really be the
            //  combination of the ontology name and item id.
            var lookup:Object = new Object();
            for each (var i:Object in kefedObj.ontologyIds) {
            	// Backward compatibility.  Be prepared for just a string.
            	if (i is OntologyTermReference) {
            		lookup[i.ontologyIdentifier] = i;
            	} else {
            		lookup[i] = i;
            	}
            }
            
            if( check != null && check.page.numResultsTotal != "0" ) {
            	var returnedTermsObj:Object = check.page.contents.searchResultList.searchBean;
            	// We can only iterate over the returnedTermsObj if there is more than one.
            	// Otherwise we just get the fields of the object instead.
            	if (check.page.numResultsTotal == "1") {
            		if (allowedOntologyList == null || allowedOntologyList.contains(returnedTermsObj.ontologyId)) {
	    	        	searchResults.addItem(returnedTermsObj);
	    	        	if( lookup[returnedTermsObj.conceptId] != null ) {
	    	        		returnedTermsObj.selected = true;
	    	        	} else {
	    	        		returnedTermsObj.selected = false;
	    	        	}
	    	        }
            	} else {
 	           		for each (var j:Object in returnedTermsObj) {
	     				if (allowedOntologyList == null || allowedOntologyList.contains(j.ontologyId)) {
	    	        		searchResults.addItem(j);
	    	        		if( lookup[j.conceptId] != null ) {
	    	        			j.selected = true;
	    	        		} else {
	    	        			j.selected = false;
	    	        		}
	    	   			}
 	           		}
        	    }
            }
 
			var outputEvent:OntologySearchEvent = 
					new OntologySearchEvent(OntologySearchEvent.FIND_ONTOLOGY_TERMS, searchResults);
			dispatchEvent(outputEvent);
				
		}

		/**
		 * http://rest.bioontology.org/bioportal/ontologies?email=example@example.org
		 * ___________________________________________________________
		 * 
		 * NCBO's list of active ontologies
		 * ___________________________________________________________
		 */

		private function initNcboListOntologies():void {

		 	ncboListOntologiesService = new HTTPService();
		 	ncboListOntologiesService.useProxy = true;
			ncboListOntologiesService.destination = "DefaultHTTP";
		 	ncboListOntologiesService.resultFormat = "text";
			ncboListOntologiesService.contentType = "application/javascript";
			ncboListOntologiesService.method = "GET";
		 	ncboListOntologiesService.url = "http://rest.bioontology.org/bioportal/" + 
		 			"ontologies?apikey=" + apikey; 	 	
			
			ncboListOntologiesService.addEventListener(ResultEvent.RESULT, 
					ncboListOntologiesEventHandler);
			ncboListOntologiesService.addEventListener(FaultEvent.FAULT, 
					faultEventHandler);
		}		

		public function ncboListOntologies():void {
		 	CursorManager.setBusyCursor();
			ncboListOntologiesService.send();
		}

		private function ncboListOntologiesEventHandler(event:ResultEvent):void {
		 	CursorManager.removeBusyCursor();
		
			var xmlDoc:XMLDocument =  new XMLDocument(XML(event.result));	
		 	var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
            var topXMLObject:Object = decoder.decodeXML(xmlDoc);
            var check:Object = topXMLObject.success.data;
            
			var searchResults:ArrayCollection = new ArrayCollection();
			
			if (allowedOntologyList == null) {
			    allowedOntologyList = new ArrayCollection();
			} else {
				allowedOntologyList.removeAll();
			}
			
            if( check != null ) {
            	var returnedTermsObj:Object = check.list.ontologyBean;
            	// searchResults = ArrayCollection(returnedTermsObj);
            	
            	// HACK: Filter ontologies to use in Crux.
            	searchResults = new ArrayCollection();
            	for each (var term:Object in returnedTermsObj) {
//            		if (-1 != ArrayUtil.getItemIndex(term["abbreviation"], 
//            										 ["CHEBI", "CL", "DOID", "FIX", "FMA",
//            										  "GO", "IAO", "OBI", "OBO_REL", "PATO",
//            										  "PRO", "REX", "UO"
//													  /* , "BFO", "ECO", "HP" */
//													  ])) {
            			searchResults.addItem(term);
            			allowedOntologyList.addItem(term.ontologyId);
//            		}
            	}
            	
            	var dataSortField:SortField = new SortField();
            	dataSortField.name = "displayLabel";
				dataSortField.numeric = false;
				dataSortField.descending = false;
				dataSortField.caseInsensitive = true;
				
            	/* Create the Sort object and add the SortField object created earlier 
            	to the array of fields to sort on. */
            	var ontologyNameSort:Sort = new Sort();
           	    ontologyNameSort.fields = [dataSortField];

	            /* Set the ArrayCollection object's sort property to our custom sort, 
	            and refresh the ArrayCollection. */
	            searchResults.sort = ontologyNameSort;
	            searchResults.refresh();
  	
            }

			var outputEvent:OntologySearchEvent = 
					new OntologySearchEvent(OntologySearchEvent.LIST_ONTOLOGIES, searchResults);
			
			dispatchEvent(outputEvent);
		}
		
		/**
		 * view-source:http://rest.bioontology.org/bioportal/ontologies?email=example@example.org
		 * ___________________________________________________________
		 * 
		 * LOAD A SPECIFIC TERM ACCORDING TO MIREOT PRINCIPLES
		 * ___________________________________________________________
		 */
		 
		 
		
		/**
		 * ___________________________________________________________
		 * 
		 * GENERIC INTERNAL FUNCTIONS
		 * ___________________________________________________________
		 */

		private function faultEventHandler(event:FaultEvent):void {
			
			Alert.show(event.toString());
			
			CursorManager.removeBusyCursor();

			dispatchEvent(event); 			
		
		}

		public function cancel():void {
			this.ncboListOntologiesService.cancel();
			this.ncboSearchService.cancel();
			CursorManager.removeBusyCursor();

		}
	   
	}
}