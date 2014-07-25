// $Id: PersevereModelStore.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.store.persevere
{
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	import edu.isi.bmkeg.kefed.store.IModelStore;
	import edu.isi.bmkeg.kefed.store.ModelStoreEvent;
	import edu.isi.bmkeg.kefed.store.json.JSONSerializer;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	/** Model store that saves KefedModel to an underlying Persevere
	 *  object store.  This serializes the model to a generic object
	 *  representation, which is then de-serialized for reading.
	 * 
	 *  Uses asynchronous transactions, which means that users
	 *  will need to register appropriate event listeners to get
	 *  the results of any operations.  The events signalled will be
	 *  of type ModelStoreEvent.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */
	public class PersevereModelStore extends EventDispatcher implements IModelStore
	{
		private var serviceUrl:String;
		
		private var listService:HTTPService;
		private var retrieveService:HTTPService;
		private var insertService:HTTPService;
		private var saveService:HTTPService;
		private var deleteService:HTTPService;
		// private var copyService:HTTPService;
		
		/**
		 * Create a new PersevereModelStore object, with the store
		 * using a URL relative to the given base URL.  There must 
		 * be a persevere data store that is present as a web service
		 * at the listed URL.  This needs to be the complete URL
		 * including the type name.  The type name identifies the class
		 * in the persevere store such as "KefedModel"
		 * 
		 * @param baseUrl The URL for the persevere model store server including the type.
		 * 
		 */		
		public function PersevereModelStore(url:String)
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

		/** List the models that are present in the store.  Returns
		 *  after starting the load and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.LIST when loading is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 */
		public function listModels():void {
			listService.url = serviceUrl + encodeURIComponent("[?type='template']")
										 + encodeURIComponent("[={uid:uid,modelName:modelName,source:source,dateTime:dateTime}]");
			listService.send();
		}
		
		private function listResultEventHandler(event:ResultEvent):void {
			var s:String = String(listService.lastResult);	
			var modelList:ArrayCollection = JSONSerializer.deserializeJsonList(s);
			dispatchEvent(new ModelStoreEvent(ModelStoreEvent.LIST, null, modelList));			
		}
		
		/** Load the model that matches the given UID.  Returns
		 *  after starting the load and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.LOAD when loading is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the model to load
		 * 
		 */
		public function retrieveModel(uid:String):void {
			retrieveService.url = serviceUrl + encodeURIComponent("[?uid='" + uid + "']");
			retrieveService.send();
		}
		
		private function loadResultEventHandler(event:ResultEvent):void {
			var str:String = String(retrieveService.lastResult);
			var model:KefedModel = JSONSerializer.deserializeKefedModel(str);
			dispatchEvent(new ModelStoreEvent(ModelStoreEvent.RETRIEVE, model, null));						
		}
		
		/** Insert the model.  Assumes that this model does not already
		 *  exist in the store.   Returns after starting the insertion
		 *  and dispatches a ModelStoreEvent  with type 
		 *  ModelStoreEvent.INSERT when loading is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param model The model to save to the store
		 * 
		 */
		public function insertModel(model:KefedModel):void {
			insertService.url = serviceUrl;
			insertService.request = JSONSerializer.serializeKefedModel(model, false);
			insertService.send();
		}
		
		private function insertResultEventHandler(event:ResultEvent):void {
			// We could do this to get the model and then add it to the event, 
			// but will all stores be able to handle it?
			var str:String = String(insertService.lastResult);
			str = "[" + str.substring(1,str.length-1) + "]"; // Hack for parser.
			var model:KefedModel = JSONSerializer.deserializeKefedModel(str);
			dispatchEvent(new ModelStoreEvent(ModelStoreEvent.INSERT, model, null));	
		}		
		
		/** Save the model.  Assumes that there is already a model
		 *  present that will be replaced.   Returns after starting
		 *  the save and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.SAVE when loading is complete.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param model The model to save to the store
		 * 
		 */
		public function saveModel(model:KefedModel):void {
			saveService.url = serviceUrl + encodeURIComponent(model.id);
			saveService.request = JSONSerializer.serializeKefedModel(model, true);
			saveService.send();
		}
		
		private function saveResultEventHandler(event:ResultEvent):void {
			dispatchEvent(new ModelStoreEvent(ModelStoreEvent.SAVE));	
		}
		
		/** Delete the model that matches the given UID.  Returns
		 *  immediately and dispatches a ModelStoreEvent
		 *  with type ModelStoreEvent.DELETE upon successful completion.
		 *  Otherwise dispatches a ModelStoreEvent.ERROR event.
		 * 
		 * @param uid The UID of the model to delete
		 * 
		 */
		public function deleteModel(uid:String):void {
			deleteService.url = serviceUrl + encodeURIComponent("[?uid='" + uid + "']");
			deleteService.send();
		}
		
		private function deleteResultEventHandler(event:ResultEvent):void {
			dispatchEvent(new ModelStoreEvent(ModelStoreEvent.DELETE));						
		}

		// TODO: Make this dispatch a ModelStoreEvent.ERROR event?
		private function faultEventHandler(event:FaultEvent):void {
			dispatchEvent(event); 			
		} 		
	}
}