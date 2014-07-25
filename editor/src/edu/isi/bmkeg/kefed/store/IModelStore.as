// $Id: IModelStore.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.store
{
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	
	import flash.events.IEventDispatcher;
	
	/** Interface for Kefed model store implementations.  These
	 *  will use asynchronous transactions, which means that users
	 *  will need to register appropriate event listeners to get
	 *  the results of any operations.  The events signalled will be
	 *  of type ModelStoreEvent.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */
	public interface IModelStore extends IEventDispatcher
	{
		/** List the models that are present in the store.  Returns
		 *  after starting the load and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.LIST when loading is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 */
		function listModels():void;
		
		/** Retrieve the model that matches the given UID.  Returns
		 *  after starting the load and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.LOAD when loading is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the model to load
		 * 
		 */
		function retrieveModel(uid:String):void;
		
				
		/** Insert the model.  Assumes that this model does not already
		 *  exist in the store.   Returns after starting the insertion
		 *  and dispatches a ModelStoreEvent  with type 
		 *  ModelStoreEvent.INSERT when loading is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param model The model to save to the store
		 * 
		 */
		function insertModel(model:KefedModel):void;
		
		/** Save the model.  Assumes that there is already a model
		 *  present that will be replaced.   Returns after starting
		 *  the save and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.SAVE when saving is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param model The model to save to the store
		 * 
		 */
		function saveModel(model:KefedModel):void;
		
		/** Delete the model that matches the given UID.  Returns
		 *  immediately and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.DELETE upon successful completion.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the model to delete
		 * 
		 */
		function deleteModel(uid:String):void;
		
	}
}