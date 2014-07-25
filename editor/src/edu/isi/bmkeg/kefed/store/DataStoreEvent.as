// $Id: DataStoreEvent.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.store
{
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	import edu.isi.bmkeg.kefed.elements.KefedExperiment;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	
	/** Events dispatched as part of the action of a
	 *  data store.  These are dispatched by the data store
	 *  implementations as asynchronous operations complete.
	 *  The return values of operations are returned as the values
	 *  of the fields of this event, for those events where that
	 *  makes sense.  Otherwise these fields have null as their value.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */
	public class DataStoreEvent extends Event
	{
		/**
		 *  Constants used for event types in this class. 
		 */		
		public static const DELETE:String = "delete";
		public static const LIST:String = "list";
		public static const INSERT:String = "insert";
		public static const SAVE:String = "save";
    	public static const RETRIEVE:String = "retrieve";
    	public static const ERROR:String = "error";
    	
  	  	/** The KefedExperiment that is returned as a result of a LOAD
    	 *  operation.  Null otherwise. 
    	 */
    	public var experiment:KefedExperiment = null;

   		/** The collection of experiments that is returned as a result of a LIST
    	 *  operation.  Null otherwise.   The collection will contain objects
    	 *  of type ??? [Probably whatever we use as our shorthand experiment
    	 *  descriptor.]
    	 */
 		public var experimentList:ArrayCollection = null;
    	
		/** Create a new DataStoreEvent and set the experiment and experimentList
		 *  fields.  This will be used in response to list or load actions
		 *  and provide the means to get the return values.
		 * 
		 * @param type The type of event from the set of constants for this class
		 * @param experiment The KefedExperiment retrieve by load (optional)
		 * @param experimentList List of KefedExperiments in reponse to list (optional)
		 * 
		 */
		public function DataStoreEvent(type:String, experiment:KefedExperiment=null, experimentList:ArrayCollection=null) {
			super(type);
			this.experiment = experiment;
			this.experimentList = experimentList;	
		}

	}
}