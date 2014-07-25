// $Id: StructuredEditorComponent.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui {
	import mx.containers.Box;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListBase;
	import mx.controls.listClasses.ListData;
	import mx.core.IDataRenderer;
	import mx.events.FlexEvent;
	import mx.utils.ObjectProxy;

	/** UI Container base class for editing structured information.
	 *
	 *  This is an abstract class for handling the editing of structured
	 *  information.  It defines a single method for updating the structured
	 *  data that needs to be overridden in subclasses.  This is meant to be
	 *  used as in in-line ItemRenderer and editor for lists and DataGrids.
	 * 
	 *  Provides methods for setting the data and listData fields
	 *  needed for in-line renderers and editors.  The purpose of 
	 *  this class is to provide for editors of structured (i.e., 
	 *  Object-valued data fields in lists and datagrids.
	 * 
	 *  This may later be extended to Tree controls as well.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 */
	public class StructuredEditorComponent extends Box implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer
	{
		/** Storage for implementing the listdata object interface
		 */
		protected var _listData:BaseListData;
		
		/** Storage for implmenting the data object interface.
		 */
		protected var _data:Object;
		
		/** Storage for the currently edited item.
		 */
		[Bindable]
		public  var dataItem:ObjectProxy;
		
		
		public function StructuredEditorComponent ()
		{
			super();
		}
		
 	   // Make the listData property bindable.
    	[Bindable("dataChange")]
 		/** Return the listData information.
  		  */
  	 	 public function get listData():BaseListData {
    	  return _listData;
     	}
    
 	    /** Set the listData field.
 	     *
 	     */
	    public function set listData(value:BaseListData):void {
	      _listData = value;
	    }
		
		/** 
  	     * @return The data object.
  	     * 
  	     */
  	    override public function get data():Object
    	{
   			return _data;
   		}
   	
		/** Sets the data value and then updates the internal 
		 *  localData to be the appropriate object from the
		 *  larger data object when used in lists or data grids.
		 */
		override public function set data(value:Object):void
	    {
	        _data = value;
	        var targetObject:Object;
	
	        if (_listData && _listData is DataGridListData)
	            targetObject = getNestedValue(_data, DataGridListData(_listData).dataField);
	        else if (_listData is ListData && ListData(_listData).labelField in _data)
	            targetObject = getNestedValue(_data, ListData(_listData).labelField);
	        else
	            targetObject = _data;
	
			dataItem = (targetObject is ObjectProxy) ? targetObject as ObjectProxy : new ObjectProxy(targetObject);
	        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
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