// $Id: DataEntryCheckBoxFactory.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui
{
	import edu.isi.bmkeg.kefed.elements.KefedBaseValueTemplate;
	
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;

	public class DataEntryCheckBoxFactory extends ClassFactory
	{
	
		private var _template:KefedBaseValueTemplate;
				
		public function DataEntryCheckBoxFactory(vTemplate:KefedBaseValueTemplate) {
			super(CheckBox);
			this._template = vTemplate;
		}
		
		override public function newInstance():* {
			var ed:CheckBox = super.newInstance();
			return ed;
		}
		
	}

}