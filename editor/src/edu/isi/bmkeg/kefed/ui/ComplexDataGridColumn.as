package edu.isi.bmkeg.kefed.ui
{
	import mx.controls.dataGridClasses.DataGridColumn;

	public class ComplexDataGridColumn extends DataGridColumn
	{
		public function ComplexDataGridColumn(columnName:String=null)
		{
			super(columnName);
		}
		
    /**
     *  Returns a String that the item renderer displays as the datatip for the given data object,
     *  taking into account complex data field accesses.
     *
     *  @param data Object to be rendered.
     *  @return Displayable String based on the data.
     */
    override public function itemToDataTip(data:Object):String  {
    	if ( !hasComplexFieldName ) 
            data = data[dataField];
        else 
            data = deriveComplexColumnData( data );
    	return super.itemToDataTip(data);
      }

		
	}
}