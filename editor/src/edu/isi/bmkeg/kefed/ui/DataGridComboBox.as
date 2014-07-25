// $Id: DataGridComboBox.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui {
	import mx.controls.ComboBox;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.ListData;
	import mx.events.FlexEvent;

	/** Extended version of the ComboBox control that can handle
	 *  nested data items with a nested accessor using dot notation.
	 *  Also fixes a problem where editable combo boxes would lose
	 *  the display of an edited value that isn't in the list of
	 *  valid values.
	 * 
	 *  This provides better compatibility with the DataGrid
	 *  objects that know how to do that.
	 *  
	 *  Fix the set data method to support dotted notation for
	 *  field names in a way that allows nested objects.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 */
	[Bindable]
	public class DataGridComboBox extends ComboBox
	{
		/** Need our own copy because the variable in the
		 *  parent is marked "private", so we can't get at
		 *  it to fix things.
		 */
		private var _data:Object;
		
		public function DataGridComboBox()
		{
			super();
		}
		
		/** A copy of the super class's set data value, with the
		 *  change of access to support getting values from nested
		 *  objects via dot notation in dataField or labelField
		 *  values of the ListData structure.
		 */
	    [Bindable("dataChange")]
		override public function set data(value:Object):void
	    {
	        var newSelectedItem:* = value;
	        var _listData:BaseListData = this.listData;
	        _data = value;
	
	        if (_listData) { // Embedded in a DataGrid, List, Tree, etc.
	        	if (_listData is DataGridListData) {
	            	newSelectedItem = getNestedValue(_data, DataGridListData(_listData).dataField);
	        	 } else if (_listData is ListData && ListData(_listData).labelField in _data) {
	            	newSelectedItem = getNestedValue(_data, ListData(_listData).labelField);
	         	} // TODO: Extend for Tree as well.
	         }
	
	        if (newSelectedItem !== undefined /* && !selectedItemSet */)
	        {
	            selectedItem = newSelectedItem;
	            /* selectedItemSet = false; */
	        }
	
	        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
	    }
	    
	    
   	    override public function get data():Object
    	{
   			return _data;
   		}
		

	    
	    /** Set the selectedItem of this ComboBox.  Contains a fix for
	    *   when the selected item is actually free text.  This needs
	    *   to keep that text and not clear the input box.
	    */
	    [Bindable("change")]
	    [Bindable("collectionChange")]
	    [Bindable("valueCommit")]
        override public function set selectedItem(data:Object):void {
   		 	super.selectedItem = data;
			// For editable combo boxes, we need to make sure that the
 			// text box is also set correctly for display.  This is done
 			// by making sure that the proper value is set in the text field.
 			// This must be done each time, since when this component is reused
 			// in a List or DataGrid, there may be garbage left over in "text".
 			// NOTE: This could also be done for non-editable comboboxes as well,
 			//       but it doesn't really need to be, so we omit it for efficiency.
   		 	if (editable) {
   		 		var dataLabel:String = "";
   		 		if (data) {
   		 			dataLabel = itemToLabel(data);
   		 		}
   		 		if (text != dataLabel) {
   		 			text = dataLabel;
   		 		}
   		 	}
 	    }
	    
		/** Follows a chain of fieldNames separated by "." characters.
		 *
		 * @param obj The object to operate on
		 * @param fieldName The fieldname to use for access
		 * @return The end value from following the chain
		 */
		private function getNestedValue(obj:*, fieldName:String):* {
			var dotIndex:int = fieldName.indexOf(".");
			if (obj == null || obj == undefined) {
				return obj;
			} else if (dotIndex == -1) {
				return obj[fieldName];
			} else {
				var first:String = fieldName.substring(0,dotIndex);
				var rest:String  = fieldName.substring(dotIndex+1);
				return getNestedValue(obj[first], rest);
			}
		}
		
	}
}