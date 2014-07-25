// $Id: KefedAppEventDispatcher.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.app
{
	import flash.events.EventDispatcher;
	import edu.isi.bmkeg.kefed.elements.KefedModel;

	public class KefedAppEventDispatcher extends EventDispatcher {

		public function KefedAppEventDispatcher() {}
	
		public function dispatchBioScholarEvent(event:String, model:KefedModel=null):void {
			
			var e:KefedAppEvent = new KefedAppEvent(event, model);
			
			dispatchEvent(e);	
						
		}

	}

}