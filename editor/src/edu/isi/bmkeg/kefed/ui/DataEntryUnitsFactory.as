// $Id: DataEntryUnitsFactory.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui
{
	import edu.isi.bmkeg.kefed.elements.KefedBaseValueTemplate;
	
	import mx.controls.ComboBox;
	import mx.core.ClassFactory;

	public class DataEntryUnitsFactory extends ClassFactory	{
	
		private var _template:KefedBaseValueTemplate;
				
		public function DataEntryUnitsFactory(vTemplate:KefedBaseValueTemplate) {
			super(UnitEditor);
			this._template = vTemplate;
		}
		
		override public function newInstance():* {
			var ed:UnitEditor = super.newInstance();
			var tempData:Array = new Array();
			// Is this copying really needed?
			for each (var v:String in _template.allowedUnits) { 
				tempData.push(v);
			}
			ed.allowOtherUnits = _template.allowFreeUnitInput;
			ed.allowedUnits = _template.allowedUnits;
			ed.data	
			return ed;
		}
		
		private function unitsDataTipFunction(data:Object):String {
        	return data.value + " " + data.units;
        }
		
	}

}