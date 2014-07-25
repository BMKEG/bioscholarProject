// $Id: DataEntryRelativeRegionFactory.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui
{
	import edu.isi.bmkeg.kefed.elements.KefedBaseValueTemplate;
	
	import mx.containers.BoxDirection;
	import mx.core.ClassFactory;

	public class DataEntryRelativeRegionFactory extends ClassFactory	{
	
		private var _template:KefedBaseValueTemplate;
				
		public function DataEntryRelativeRegionFactory(vTemplate:KefedBaseValueTemplate) {
			super(RelativeRegionEditor);
			this._template = vTemplate;
		}
		
		override public function newInstance():* {
			var ed:RelativeRegionEditor = super.newInstance();
			var tempData:Array = new Array();
			// Is this copying really needed?
			for each (var v:String in _template.allowedValues) { 
				tempData.push(v);
			}
			// Currently allowedRelations is fixed.
			ed.direction = BoxDirection.VERTICAL;
			ed.allowOtherRegions = _template.allowFreeValueInput;
			ed.allowedRegions = _template.allowedValues;		
			return ed;
		}
		
	}

}