// $Id: KefedLinkProxy.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui.kapit
{
	import com.kapit.diagram.IDiagramElement;
	import com.kapit.diagram.model.ILinkProxy;
	import com.kapit.diagram.view.DiagramLink;
	import com.kapit.diagram.view.DiagramView;
	
	import edu.isi.bmkeg.kefed.elements.KefedLink;
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	import edu.isi.bmkeg.kefed.elements.KefedObject;
	
	import mx.utils.UIDUtil;

	public class KefedLinkProxy implements ILinkProxy
	{
		public static var _graph:KefedModel = null;
				
		protected var _view:DiagramView;

		public function KefedLinkProxy(view:DiagramView)
		{
			_view = view;
		}		

		public function createDataObject(el:IDiagramElement):String
		{
			
			var type:String = el.getTagName();
			
			var l:DiagramLink = DiagramLink(el);
			var sourceid:String = DiagramLink(el).sourceobject.dataobjectid;
			var targetid:String = DiagramLink(el).targetobject.dataobjectid;
						
			var source:KefedObject = _graph.getKefedObjectFromUID(sourceid);
			var target:KefedObject = _graph.getKefedObjectFromUID(targetid);
						
			var uid:String = UIDUtil.createUID();
			var link:KefedLink = new KefedLink(uid, source, target, true);

			if (_graph) {
				source.addOutEdge(link);
				target.addInEdge(link);
				_graph.addEdge(link);
			}
			
			return uid;
			
		}
		
		public function scopeChanged(link:DiagramLink, oldscope:String):void
		{
		}
		
		public function removeDataObject(el:IDiagramElement):void
		{
			try {	
				var link:KefedLink = _graph.getKefedLinkFromDiagramElement(el);
				if (link) _graph.removeEdge(link);
			} catch(e:Error) {
				trace(e.message);
			}

		}
		
		public function propertyModified(el:IDiagramElement, propname:String, propvalue:Object, shapeid:String):void
		{
		}
		
		public function dataObjectPropertyModified(uid:String, propname:String, propvalue:Object):void
		{
		}
		
		public function dataObjectRemoved(uid:String):void
		{
		}
		
		public function dataObjectLoaded(el:IDiagramElement):void
		{
		}
		
		public function acceptPropertyModification(el:IDiagramElement,propname:String,propvalue:Object,shapeid:String):Boolean
		{
			return true;
		}

		public function acceptRemoveObject(el:IDiagramElement):Boolean
		{
			return true;
		}
				
	}
}