package edu.isi.bmkeg.kefed.elements
{
	import mx.collections.ArrayCollection;
	
	/** Interface for KefedObjects that support a notes.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 *
	 */
	[Bindable]
	public interface IKefedAnnotatedObject
	{
		function get notes ():String;

		function set notes (newNotes:String):void;
	}
}
