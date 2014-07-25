// $Id: PersevereDataStore.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.store.persevere
{
	import edu.isi.bmkeg.kefed.elements.KefedExperiment;
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	import edu.isi.bmkeg.kefed.store.DataStoreEvent;
	import edu.isi.bmkeg.kefed.store.IDataStore;
	import edu.isi.bmkeg.kefed.store.json.JSONSerializer;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	/** Data store that saves KefedExperiment to an underlying Persevere
	 *  object store.  This serializes the Experiment to a generic object
	 *  representation, which is then de-serialized for reading.
	 * 
	 *  Uses asynchronous transactions, which means that users
	 *  will need to register appropriate event listeners to get
	 *  the results of any operations.  The events signalled will be
	 *  of type DataStoreEvent.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */	
	 public class PersevereDataStore extends EventDispatcher implements IDataStore {
		private var serviceUrl:String;
		
		private var listService:HTTPService;
		private var retrieveService:HTTPService;
		private var insertService:HTTPService;
		private var saveService:HTTPService;
		private var deleteService:HTTPService;
		// private var copyService:HTTPService;
		
		
		/**
		 * Create a new PersevereDataStore object, with the store
		 * using a URL relative to the given base URL.  There must 
		 * be a persevere data store that is present as a web service
		 * at the listed URL.  This needs to be the complete URL
 		 * including the type name.  The type name identifies the class
 		 * in the persevere store, for example "KefedExperiment"
		 * 
		 * @param url The URL for the persevere data store server including the type name.
		 */		
		 public function PersevereDataStore(url:String)
		{
			if( url.charAt(url.length-1) != "/" ) {
				url += "/";
			}
			this.serviceUrl = url;
			
			listService = PersevereStoreUtil.initService("GET", listResultEventHandler, faultEventHandler);
			retrieveService = PersevereStoreUtil.initService("GET", loadResultEventHandler, faultEventHandler);
			insertService = PersevereStoreUtil.initService("POST", insertResultEventHandler, faultEventHandler);
			saveService = PersevereStoreUtil.initService("PUT", saveResultEventHandler, faultEventHandler);
			deleteService = PersevereStoreUtil.initService("DELETE", deleteResultEventHandler, faultEventHandler);
			// copyService = PersevereStoreUtil.initService("GET", copyResultEventHandler, faultEventHandler);
		}


		/** List the Experiment data that are present in the store.  Returns
		 *  after starting the load and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.LIST when loading is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 */
		 public function listData():void {
			listService.url = serviceUrl + encodeURIComponent("[?type<'template'|type>'template'|type=undef]")
										 + encodeURIComponent("[={uid:uid,modelName:modelName,source:source,type:type,dateTime:dateTime}]");
			listService.send();
		}
		
		private function listResultEventHandler(event:ResultEvent):void {
			var s:String = String(listService.lastResult);	
			var experimentList:ArrayCollection = JSONSerializer.deserializeJsonList(s);
			dispatchEvent(new DataStoreEvent(DataStoreEvent.LIST, null, experimentList));			
		}

		/** List the experiments that are present in the store and
		 *  which are realizations of the given model.  Returns
		 *  after starting the load and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.LIST when loading is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 *  @param model The model whose corresponding data items are returned
		 */		
		public function listDataForModel(model:KefedModel):void	{
		}
		
		/** Retrieve the experiment that matches the given UID.  Returns
		 *  after starting the retrieval and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.RETRIEVE when loading is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the experiment to load
		 * 
		 */		
		public function retrieveData(uid:String):void {
			retrieveService.url = serviceUrl + encodeURIComponent("[?uid='" + uid + "']");
			retrieveService.send();
		}
		
		private function loadResultEventHandler(event:ResultEvent):void {
			var str:String = String(retrieveService.lastResult);
			var experiment:KefedExperiment = JSONSerializer.deserializeKefedExperiment(str);
			dispatchEvent(new DataStoreEvent(DataStoreEvent.RETRIEVE, experiment, null));						
		}
		
		/** Insert the experiment.  Assumes that the experiment doesn't
		 *  exist in the store.  Returns after starting the insertion and
		 *  dispatches a DataStoreEvent with type DataStoreEvent.INSERT
		 *  when insertion is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param experiment The experiment to save to the store
		 * 
		 */
		 public function insertData(experiment:KefedExperiment):void {
			experiment.updateTime();
			insertService.url = serviceUrl;
			insertService.request = JSONSerializer.serializeKefedExperiment(experiment, false);
			insertService.send();
		}
		
		private function insertResultEventHandler(event:ResultEvent):void {
			// We could do this to get the experiment and then add it to the event, 
			// but will all stores be able to handle it?
			// var str:String = String(retrieveService.lastResult);
			// var experiment:KefedExperiment = PersevereStoreUtil.deserializeKefedExperiment(str);
			dispatchEvent(new DataStoreEvent(DataStoreEvent.INSERT, null, null));	
		}		
		
		
		/** Save the experiment.  Assumes that the experiment already
		 *  exists in the store.  Returns after starting the save and
		 *  dispatches a DataStoreEvent with type DataStoreEvent.SAVE
		 *  when saving is complete.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param experiment The experiment to save to the store
		 * 
		 */
		public function saveData(experiment:KefedExperiment):void {
			experiment.updateTime();
			saveService.url = serviceUrl + encodeURIComponent(experiment.id);
			saveService.request = JSONSerializer.serializeKefedExperiment(experiment);
			saveService.send();
		}
		
		private function saveResultEventHandler(event:ResultEvent):void {
			dispatchEvent(new DataStoreEvent(DataStoreEvent.SAVE));	
		}
		
		
		/** Delete the experiment that matches the given UID.  Returns
		 *  immediately and dispatches a DataStoreEvent
		 *  with type DataStoreEvent.DELETE upon successful completion.
		 *  Otherwise dispatches a DataStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the experiment to delete
		 * 
		 */
		public function deleteData(uid:String):void	{
			deleteService.url = serviceUrl + encodeURIComponent("[?uid='" + uid + "']");
			deleteService.send();
		}
		
		private function deleteResultEventHandler(event:ResultEvent):void {
			dispatchEvent(new DataStoreEvent(DataStoreEvent.DELETE));						
		}

		private function faultEventHandler(event:FaultEvent):void {
			dispatchEvent(event); 			
		} 		
		
		
	}
}