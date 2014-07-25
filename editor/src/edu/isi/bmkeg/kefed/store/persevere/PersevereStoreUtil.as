// $Id: PersevereStoreUtil.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.store.persevere {
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	/**  Collection of static utility routines that are used by the different
	 *   Persevere-based store implementations.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */	
	public class PersevereStoreUtil {
		/**  Initializes an HTTPService of the particular type and adds the
		 *   event handlers.  Sets the proper fields in the service for
		 *   operation via a proxy.
		 * 
		 * @param method
		 * @param resultHandler
		 * @param faultHandler
		 * @return The HTTP Service for the given type.
		 * 
		 */		
		internal static function initService(method:String, resultHandler:Function, faultHandler:Function):HTTPService {
			var persvr:HTTPService = new HTTPService();
			
			persvr.useProxy = true;
			persvr.resultFormat = "text";
			persvr.contentType = "application/javascript";
			persvr.method = method;
			persvr.addEventListener(ResultEvent.RESULT, resultHandler);
			persvr.addEventListener(FaultEvent.FAULT, faultHandler);
				
			return persvr;
		}
	}
}