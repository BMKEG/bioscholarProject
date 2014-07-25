// $Id: KefedPersevereInterface.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.elements
{
	
	import edu.isi.bmkeg.kefed.store.json.JSONSerializer;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.managers.CursorManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Deprecated]
	public class KefedPersevereInterface extends EventDispatcher {

		private var serviceUrl:String;
		
		private var listPersvr:HTTPService;
		private var loadPersvr:HTTPService;
		private var copyPersvr:HTTPService;
		private var deletePersvr:HTTPService;
		private var insertPersvr:HTTPService;
		private var savePersvr:HTTPService;
		
		private var jsonEncoding:String;
		private var modelList:ArrayCollection;

		public function KefedPersevereInterface(baseUrl:String) {
			if( baseUrl.charAt(baseUrl.length-1) != "/" ) {
				baseUrl += "/";
			}
			this.serviceUrl = baseUrl + "persevere/KefedModel";
		
			listPersvr = initPersvr("GET", listResultEventHandler, faultEventHandler);
			loadPersvr = initPersvr("GET", loadResultEventHandler, faultEventHandler);
			copyPersvr = initPersvr("GET", copyResultEventHandler, faultEventHandler);
			deletePersvr = initPersvr("DELETE", deleteResultEventHandler, faultEventHandler);
			insertPersvr = initPersvr("POST", insertResultEventHandler, faultEventHandler);
			insertPersvr.url = baseUrl + "persevere/KefedModel";
			savePersvr = initPersvr("PUT", saveResultEventHandler, faultEventHandler);
		}
		
		private function initPersvr(method:String, resultHandler:Function, faultHandler:Function):HTTPService {
			var persvr:HTTPService = new HTTPService();
			
			persvr.useProxy = true;
		 	persvr.resultFormat = "text";
			persvr.contentType = "application/javascript";
			persvr.method = method;
			persvr.addEventListener(ResultEvent.RESULT, resultHandler);
			persvr.addEventListener(FaultEvent.FAULT, faultHandler);
			
			return persvr;
		}
		
		private function invokeServiceOnUid (uid:String, service:HTTPService):void {
			//	Need to use escape characters for the URL
			//	"/persevere/KefedModel[?uid='" + uid + "']"
			service.url = serviceUrl + "persevere/KefedModel" + 
			 			encodeURIComponent("[?uid='" + uid + "']");
			
			CursorManager.setBusyCursor();

			service.send();
		}

		/**
		 * ___________________________________________________________
		 * 
		 * LIST KEFED MODELS 
		 * ___________________________________________________________
		 */

		public function listKefedModels():void {

			// Need to use escape characters for the URL
			// persevere/KefedModel[={uid:uid,modelName:modelName,dateTime:dateTime}]
		 	listPersvr.url = serviceUrl + 
		 			encodeURIComponent("[={uid:uid,modelName:modelName,dateTime:dateTime}]");
		 	CursorManager.setBusyCursor();
			this.listPersvr.send();
		}

		public function listKefedModelsFromQuery(conditions:ArrayCollection):void {

		 	var conditionsStr:String = this.getUriEncodedConditionString(conditions);
		 			
			// Need to use escape characters for the URL
		 	listPersvr.url = serviceUrl +
		 			conditionsStr +  
		 			encodeURIComponent("[={uid:uid,modelName:modelName,source:source,type:type,dateTime:dateTime}]");
		 	
			this.listPersvr.send();
			
		}


		private function listResultEventHandler(event:ResultEvent):void {
		
			var s:String = String(listPersvr.lastResult);	
				
			var modelList:ArrayCollection = JSONSerializer.deserializeJsonList(s);

		 	CursorManager.removeBusyCursor();
			
			var e:KefedPersevereEvent = new KefedPersevereEvent(
					KefedPersevereEvent.LIST, null, modelList
					);
			
			dispatchEvent(e);
			
		}
		
		/**
		 * ___________________________________________________________
		 * 
		 * LOAD A KEFED MODEL 
		 * ___________________________________________________________
		 */

		public function loadKefedModelFromUid(uid:String):void {
			invokeServiceOnUid(uid, loadPersvr);
		}

		public function loadKefedModelFromQuery(conditions:ArrayCollection, uid:String):void {
			
			conditions.addItem("uid='" + uid + "'");
			var conditionStr:String = this.getUriEncodedConditionString(conditions);
			
			//	Need to use escape characters for the URL
			//	"/persevere/KefedModel[[?uid=" + uid + "]"
			loadPersvr.url = serviceUrl + 
						conditionStr;
			
			this.loadPersvr.send();
		
		}


		private function loadResultEventHandler(event:ResultEvent):void {
		
			var str:String = String(loadPersvr.lastResult);
			
			var model:KefedModel = JSONSerializer.deserializeKefedModel(str);

        	CursorManager.removeBusyCursor();
			
			var e:KefedPersevereEvent = new KefedPersevereEvent(KefedPersevereEvent.LOAD, model, null);
			
			dispatchEvent(e);						
		
		}
		
		/**
		 * ___________________________________________________________
		 * 
		 * COPY A KEFED MODEL 
		 * ___________________________________________________________
		 */
		 
		 public function copyKefedModelFromUid(uid:String):void {
			invokeServiceOnUid(uid, copyPersvr);
		}


		private function copyResultEventHandler(event:ResultEvent):void {
		
			var str:String = String(copyPersvr.lastResult);
			var original:KefedModel = JSONSerializer.deserializeKefedModel(str);
			var model:KefedModel = original.clone();
			model.modelName = model.modelName + " copy";
			insertModel(model);
		}
		
		/**
		 * ___________________________________________________________
		 * 
		 * DELETE A KEFED MODEL
		 * ___________________________________________________________
		 */

		public function deleteKefedModel(uid:String):void {
			invokeServiceOnUid(uid, deletePersvr);
		}
		 
		private function deleteResultEventHandler(event:ResultEvent):void {
		
			CursorManager.removeBusyCursor();

			var e:KefedPersevereEvent = new KefedPersevereEvent(KefedPersevereEvent.DELETE, null, null);
			
			dispatchEvent(e);						
							
		}
		
		/**
		 * ___________________________________________________________
		 * 
		 * INSERT A KEFED MODEL
		 * ___________________________________________________________
		 */


		public function insertModel(model:KefedModel):void {
			
			var s:String = JSONSerializer.serializeKefedModel(model, false);
			insertPersvr.request = s;
	 		CursorManager.setBusyCursor();
			insertPersvr.send();
		}
		
		public function insertExperiment(exp:KefedExperiment):void {
			
			var s:String = JSONSerializer.serializeKefedExperiment(exp, false);
			insertPersvr.request = s;
	 		CursorManager.setBusyCursor();
			insertPersvr.send();
		}

		private function insertResultEventHandler(event:ResultEvent):void {
			
			CursorManager.removeBusyCursor();
			var e:KefedPersevereEvent = new KefedPersevereEvent(KefedPersevereEvent.INSERT, null, null);
			dispatchEvent(e);	
			
		}

		/**
		 * ___________________________________________________________
		 * 
		 * SAVE A KEFED MODEL
		 * ___________________________________________________________
		 */

		public function saveModel(model:KefedModel):void {
			
			model.updateTime();
			savePersvr.url = serviceUrl + "persevere/KefedModel/" + encodeURIComponent(model.id);
			savePersvr.request = JSONSerializer.serializeKefedModel(model);
		 	CursorManager.setBusyCursor();
			savePersvr.send();
			
		}
		
		public function saveExperiment(exp:KefedExperiment):void {
			
			exp.updateTime();
			savePersvr.url = serviceUrl + "persevere/KefedModel/" + encodeURIComponent(exp.id);
			savePersvr.request = JSONSerializer.serializeKefedExperiment(exp);
		 	CursorManager.setBusyCursor();
			savePersvr.send();
			
		}

		private function saveResultEventHandler(event:ResultEvent):void {
			
		 	CursorManager.removeBusyCursor();

			var e:KefedPersevereEvent = new KefedPersevereEvent(KefedPersevereEvent.SAVE, null, null);
			
			dispatchEvent(e);	
			
		}
		
		/**
		 * ___________________________________________________________
		 * 
		 * GENERIC INTERNAL FUNCTIONS
		 * ___________________________________________________________
		 */

		private function StringReplaceAll( source:String, find:String, replacement:String ) : String {
    		    		
    		return source.split(find).join(replacement);
    			
		}

		private function faultEventHandler(event:FaultEvent):void {
			
			CursorManager.removeBusyCursor();

			dispatchEvent(event); 			
		
		} 

		private function getUriEncodedConditionString(conditions:ArrayCollection):String {
			
			var conditionsStr:String = ""; 
			
			for(var i:int=0; i<conditions.length; i++) { 
				if(i>0)
					conditionsStr += " & ";
				conditionsStr += conditions.getItemAt(i);
			}
			
			if( conditionsStr.length > 0 ) 
				conditionsStr = "[?" + conditionsStr + "]"; 

			return encodeURIComponent(conditionsStr);
			
		}  
         
 		public function cancel():void {
			this.deletePersvr.cancel();
			this.listPersvr.cancel();
			this.loadPersvr.cancel();
			this.insertPersvr.cancel();
		}
	   
	}
}