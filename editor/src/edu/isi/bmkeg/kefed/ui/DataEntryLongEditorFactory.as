// $Id: DataEntryLongEditorFactory.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui
{
	import edu.isi.bmkeg.kefed.elements.KefedBaseValueTemplate;
	
	import mx.controls.TextArea;
	import mx.core.ClassFactory;

	public class DataEntryLongEditorFactory extends ClassFactory
	{
	
		private var _template:KefedBaseValueTemplate;
				
		public function DataEntryLongEditorFactory(vTemplate:KefedBaseValueTemplate) {
			super(TextArea);
			this._template = vTemplate;
		}
		
		override public function newInstance():* {
			var ed:TextArea = super.newInstance();
			ed.editable = true;
			// TODO: Add some validation for ranges and unit expressions
			return ed;
		}
		
	}

}