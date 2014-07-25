// $Id: OntologySearchInterface.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ontology {
	import edu.isi.bmkeg.kefed.elements.IKefedNamedObject;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	/** Interface describing the search interface for ontology search
	 *  Web services.  This class operates by accepting requests to
	 *  list ontologies or search for terms.  The requests are processed
	 *  asynchronously and upon completion an event of the appropriate
	 *  type will be dispatched, containing the results.
	 * 
	 *  This is intended to be an abstract class that provides common
	 *  storage and some support routines for classes that implement
	 *  access to particular ontology repositories.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 */
	public class OntologySearchInterface extends EventDispatcher {
		
		/** Collection of ontology names that this Interface will
	 	 *  accept.  May be <code>null</code>, in which case all
	 	 *  ontologies will be accepted.  An empty collection will
	 	 *  accept no ontologies.
	 	 */
	 	 
		public static var allowedOntologyList:ArrayCollection = null;
		
		/** Perform a search for a term string and return a list of
		 *  ontology items that match.  The Kefed object is used to
		 *  pre-select already present terms from among those that
		 *  will be presented to the user in a dialog.  The search
		 *  terms will be included in an OntologySearchEvent of the
		 *  type OntologySearchEvent.FIND_ONTOLOGY_TERMS.
		 * 
		 * @param kefedObj The Kefed object for the ontology terms
		 * @param term The string to use for term search in the ontology
		 * @param exact If an exact match is required.  Otherwise, a substring suffices.
		 * @param prop If properties or relations are also considered.  Otherwise just classes.
		 */
		public function search(kefedObj:IKefedNamedObject, term:String, exact:Boolean, prop:Boolean):void {
			throw new Error("Internal error:\nOntologySearchInterface.search must be overridden in subclasses.");
		}
		
		/** List the ontologies that this particular service can search
		 *  over.  Results will be included in an OntologySearchEvent of
		 *  type OntologySearchEvent.LIST_ONTOLOGIES.   If listing ontologis
		 *  is not supported, then a search result of <code>null</code>
		 *  will be returned in the event.
		 */
		public function listOntologies():void {
			throw new Error("Internal error:\nOntologySearchInterface.listOntologies must be overridden in subclasses.");
		}
		
		
	}
}