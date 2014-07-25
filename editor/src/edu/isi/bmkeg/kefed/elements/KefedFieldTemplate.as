// $Id: KefedFieldTemplate.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//

package edu.isi.bmkeg.kefed.elements
{
	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;
	
	/**  Description of a field element for a multi-slot Kefed Variable
	 *   Value.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 *   NOTE: There is a need to also update 
	 *   KefedPersevereInterface.deserializeKefedObject
	 *   for structural changes here.
	 * 
	 */
	[Bindable]
	public class KefedFieldTemplate implements IKefedNamedObject, IKefedAnnotatedObject
	{
		private var _nameValue:String;
		private var _ontologyIds:ArrayCollection = new ArrayCollection();
		private var _notes:String;

		public var uid:String = UIDUtil.createUID();
		public var valueType:KefedBaseValueTemplate = new KefedBaseValueTemplate();
		
		public function get nameValue ():String {
			return _nameValue;
		}

		public function set nameValue (newName:String):void {
			_nameValue = newName;
		}
		
		public function get ontologyIds ():ArrayCollection {
			return _ontologyIds;
		}

		public function set ontologyIds (newIds:ArrayCollection):void {
			_ontologyIds = newIds;
		}
		
		public function get notes ():String {
			return _notes;
		}

		public function set notes (newNotes:String):void {
			_notes = newNotes;
		}		
				 
		/** Update the UID of this object, and recursively update the
		 *   UID of any fields.
		 */
		 public function updateUID():void {
		 	uid = UIDUtil.createUID();
		 }

	}
}