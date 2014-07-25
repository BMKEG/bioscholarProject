// $Id: ModelStoreEvent.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.store
{
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	
	/** Events dispatched as part of the action of a
	 *  model store.  These are dispatched by the model store
	 *  implementations as asynchronous operations complete.
	 *  The return values of operations are returned as the values
	 *  of the fields of this event, for those events where that
	 *  makes sense.  Otherwise these fields have null as their value.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */
	public class ModelStoreEvent extends Event
	{
		/**
		 *  Constants used for event types in this class. 
		 */		
		public static const DELETE:String = "delete";
		public static const LIST:String = "list";
		public static const SAVE:String = "save";
    	public static const RETRIEVE:String = "retrieve";
    	public static const INSERT:String = "insert";
    	public static const ERROR:String = "error";
    	
    	/** The KefedModel that is returned as a result of a RETRIEVE
    	 *  operation.  Null otherwise. 
    	 */
    	public var model:KefedModel = null;


   		/** The collection of models that is returned as a result of a LIST
    	 *  operation.  Null otherwise.   The collection will contain objects
    	 *  of type ??? [Probably whatever we use as our shorthand model
    	 *  descriptor.]
    	 */
 		public var modelList:ArrayCollection = null;
		
		/** Create a new ModelStoreEvent and set the model and modelList
		 *  fields.  This will be used in response to list or load actions
		 *  and provide the means to get the return values.
		 * 
		 * @param type The type of event from the set of constants for this class
		 * @param model The KefedModel retrieve by load (optional)
		 * @param modelList List of KefedModels in reponse to list (optional)
		 * 
		 */
		public function ModelStoreEvent(type:String, model:KefedModel=null, modelList:ArrayCollection=null) {
			super(type);
			this.model = model;
			this.modelList = modelList;	
		}

	}
}