// $Id: DataEntryComboFactory.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui
{
	import edu.isi.bmkeg.kefed.elements.KefedBaseValueTemplate;
	
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.core.ClassFactory;

	public class DataEntryComboFactory extends ClassFactory	{
	
		private var _template:KefedBaseValueTemplate;
				
		public function DataEntryComboFactory(vTemplate:KefedBaseValueTemplate) {
			super(DataGridComboBox);
			this._template = vTemplate;
		}
		
		override public function newInstance():* {
			var cb:ComboBox = super.newInstance();
			var tempData:Array = new Array();
			// Is this copying really needed?
			for each (var v:String in _template.allowedValues) { 
				tempData.push(v);
			}
			cb.height = 20;
			cb.editable = _template.allowFreeValueInput;
			cb.dataProvider = tempData;
			cb.itemRenderer = new ClassFactory(Label);
			return cb;
		}
		
	}

}