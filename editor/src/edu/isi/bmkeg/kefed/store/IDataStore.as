// $Id: IDataStore.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.store
{
	import edu.isi.bmkeg.kefed.elements.KefedExperiment;
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	
	import flash.events.IEventDispatcher;
	
	/** Interface for Kefed data store implementations.  These
	 *  will use asynchronous transactions, which means that users
	 *  will need to register appropriate event listeners to get
	 *  the results of any operations.  The events signalled will be
	 *  of type DataStoreEvent.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */
	public interface IDataStore extends IEventDispatcher
	{
		/** List the experiments that are present in the store.  Returns
		 *  after starting the load and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.LIST when loading is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 */
		function listData():void;
		
		/** List the experiments that are present in the store and
		 *  which are realizations of the given model.  Returns
		 *  after starting the load and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.LIST when loading is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 *  @param model The model whose corresponding data items are returned
		 */
		function listDataForModel(model:KefedModel):void;
		
		/** Retrieve the experiment that matches the given UID.  Returns
		 *  after starting the retrieval and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.RETRIEVE when loading is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the experiment to load
		 * 
		 */
		function retrieveData(uid:String):void;
		
		/** Insert the experiment.  Assumes that the experiment doesn't
		 *  exist in the store.  Returns after starting the insertion and
		 *  dispatches a DataStoreEvent with type DataStoreEvent.INSERT
		 *  when insertion is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param experiment The experiment to save to the store
		 * 
		 */
		function insertData(experiment:KefedExperiment):void;
		
		/** Save the experiment.  Assumes that the experiment already
		 *  exists in the store.  Returns after starting the save and
		 *  dispatches a DataStoreEvent with type DataStoreEvent.SAVE
		 *  when saving is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param experiment The experiment to save to the store
		 * 
		 */
		function saveData(experiment:KefedExperiment):void;
		
		/** Delete the experiment that matches the given UID.  Returns
		 *  immediately and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.DELETE upon successful completion.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the experiment to delete
		 * 
		 */
		function deleteData(uid:String):void;
		
	}
}