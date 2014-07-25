package edu.isi.bmkeg.kefed.elements
{
	import mx.collections.ArrayCollection;
	
	/** Interface for KefedObjects that support a name, notes  and ontology terms.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 *
	 */
	[Bindable]
	public interface IKefedNamedObject
	{
		function get nameValue ():String;

		function set nameValue (newName:String):void;
		
		function get ontologyIds ():ArrayCollection;
		
		// Do we want this to be set-able?
		// Perhaps we just need to be able to mutate the underlying Collection.
		function set ontologyIds (newIds:ArrayCollection):void;
	}
}