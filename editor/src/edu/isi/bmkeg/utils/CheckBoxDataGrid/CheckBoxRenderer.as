// $Id: CheckBoxRenderer.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.utils.CheckBoxDataGrid
{
import flash.display.DisplayObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import mx.controls.CheckBox;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.ListBase;

/** 
 *  The Renderer.
 */
public class CheckBoxRenderer extends CheckBox
{

	public function CheckBoxRenderer()
	{
		focusEnabled = false;
	}

	override public function set data(value:Object):void
	{
		super.data = value;
		invalidateProperties();
	}
	
	override protected function commitProperties():void
	{
		super.commitProperties();
		if (owner is ListBase)
			selected = ListBase(owner).isItemSelected(data);
	}

	/* eat keyboard events, the underlying list will handle them */
	override protected function keyDownHandler(event:KeyboardEvent):void
	{
	}

	/* eat keyboard events, the underlying list will handle them */
	override protected function keyUpHandler(event:KeyboardEvent):void
	{
	}

	/* eat mouse events, the underlying list will handle them */
	override protected function clickHandler(event:MouseEvent):void
	{
	}

	/* center the checkbox if we're in a datagrid */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		if (listData is DataGridListData)
		{
			var n:int = numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var c:DisplayObject = getChildAt(i);
				if (!(c is TextField))
				{
					c.x = (w - c.width) / 2;
					c.y = 0;
				}
			}
		}
	}

}

}