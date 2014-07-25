// $Id: KefedDiagramView.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.elements
{

	import com.kapit.diagram.view.DiagramView;
	import com.kapit.diagram.IDiagramElement;
	
	public class KefedDiagramView extends DiagramView
	{

		public override function notifyElementMoved(arg0:IDiagramElement):void
		{
			super.notifyElementMoved(arg0);
		}

		public override function notifyElementCreated(arg0:IDiagramElement):void
		{
			super.notifyElementCreated(arg0);			
		}

	}

}