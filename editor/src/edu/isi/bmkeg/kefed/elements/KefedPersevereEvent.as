// $Id: KefedPersevereEvent.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.elements
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	[Deprecated]
	public class KefedPersevereEvent extends Event
	{
		public static const SEARCH:String = "search";
		public static const DELETE:String = "delete";
		public static const LIST:String = "list";
		public static const SAVE:String = "save";
		public static const INSERT:String = "insert";
    	public static const LOAD:String = "load";
    	public static const ERROR:String = "error";
		
		public var model:KefedModel;
		public var modelList:ArrayCollection;
		
		public function KefedPersevereEvent(type:String, model:KefedModel, modelList:ArrayCollection)
		{
			super(type);
			this.model = model;
			this.modelList = modelList;
		}
		
	}
}