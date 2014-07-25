// $Id: OntologyReference.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//

package edu.isi.bmkeg.kefed.ontology
{
	/** Class that holds references to an ontology term.  We store
	 *  the name of the ontology, the identifier of the term in that
	 *  ontology and a local name, which is the human-readable name
	 *  for the term.
	 */
	public class OntologyReference {
		public var ontology:String;
		public var ontologyIdentifier:String;
		public var ontologyLocalName:String;
		
		/** Create a new OntologyReference
		 * 
		 * @param ont The ontology name
		 * @param id The term ID in the ontology
		 * @param name A human-readable string name.  [Optional]
		 */
		public function OntologyReference(ont:String, id:String, name:String)
		{
			ontology = ont;
			ontologyIdentifier = id;
			ontologyLocalName = name;			
		}
		
		public function toString():String {
			return ontology + ":" + ontologyLocalName;
		}
		
		/** Test function to find if this term is a match
		 *  for the parameter.
		 * 
		 *  A bit tricky because it will accept either another
		 *  OntologyReference object or a String.  Ontology references
		 *  match if all fields match.  A string will be matched against
		 *  the ontologyIdentifier field.  This aids backward compatibility.
		 * 
		 * @param obj The object to match against
		 */
		public function matches(obj:Object):Boolean {
			if (obj is OntologyReference) {
				var other:OntologyReference = OntologyReference(obj);
				return other.ontologyIdentifier == this.ontologyIdentifier
				       && other.ontology == this.ontology
				       && other.ontologyLocalName == this.ontologyLocalName;
			} else if (obj is String) {
				return obj == this.ontologyIdentifier;
			} else {
				return false;
			}
		}

	}
}