// $Id: KefedExperiment.as 50 2011-06-09 22:55:52Z taruss2000@gmail.com $

package edu.isi.bmkeg.kefed.elements
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	/** Class for Kefed Experiment objects.
	 *  TODO: Make this be more than a placeholder or renaming of KefedModel.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-06-09 15:55:52 -0700 (Thu, 09 Jun 2011) $
	 * @version $Revision: 50 $
	 * 
	 */	
	[Bindable]
	public class KefedExperiment extends KefedModel
	{
		/** UID of the design upon which this experiment is
		 *  based.  Used to keep all of the same experiments
		 *  together.
		 */
		public var designUid:String = null;
		
		/** Reference for the experimental data.  This should be a citation
		 *  to a particular published source for experimental data that
		 *  comes from a publication.  It should be an internal reference
		 *  for raw data from an experiment series.
		 */
//		public var reference:String = null;
		
		/** Case id for this specific data set.  This is used to distinguish
		 *  between different experiments that come from the same reference.
		 */
//		public var caseId:String = null;
		
		/** Holds experiment data as an Object hash from the uid
		 *  of the measurement variable to an array of objects
		 *  representing that data.  Each of those data objects
		 *  will in turn be an Object with a hash for the value
		 *  of the measurement variable itself, as well as all of
		 *  the other variables that it depends on.  All will be
		 *  indexed by uid hashes.
		 * 
		 *  Table values will be indexed by field uid.  Others
		 *  just by the plain top-level uid.
		 */
		public var experimentData:Object = new Object();
		
		/** Create a new KefedExperiment based on a model.
		 *  Currently copies over all the fields in model
		 *  to the current item, unless derived is true,
		 *  in which case this is creating an experiment
		 *  from a model, so it copies differently.
		 * 
		 * @param model The model to create the experiment from.
		 * @param derived If this is to be a derived experiment.
		 */
		public function KefedExperiment(model:KefedModel=null, derived:Boolean=false) {
			super();
			if (model != null) {
				// Copy over the fields.  But there doesn't seem to be
				// any other way to accomplish building this experiment as
				// a copy of the model since casting doesn't work.
				if (derived) {
					this.type = model.modelName;
				} else {
					this.modelName = model.modelName;
					this.type = model.type;
					this.source = model.source;
					this.citeKey = model.citeKey;
					this.uid = model.uid;
				}
				
				this.diagramXML = model.diagramXML;
				this.directedEdges = model.directedEdges;

				for(var i:int=0; i<model.bNodes.length; i++) {
						this.addNode(model.bNodes[i]);
					}
				for(i=0; i<model.bEdges.length; i++) {
						this.addEdge(model.bEdges[i]);
					}
				this.root = model.root;
				this.tree = model.tree;
				this.treeEdgeWeight = model.treeEdgeWeight;
				this.treePolicy = model.treePolicy;
			}
		}

		
		/** Returns an object suitable for holding the data values for the experimental Data.
		 *  This uses a format that is compatible with the dataGrid representation format.
         *  **** PROVISIONAL ****  Will need to change, along with the DataGrid
         *                         when we change the underlying data representation!
         *  Initially, just create an object with sub-objects for table variables.
         * 
         *  If a previousValue input is supplied, then the values for that previous input
         *  will be used as the initial values of the newly created data object.
         * 
         * @param depV The dependent variable to create a data object for.
         * @param previousValue The value object for the previous input of this object. May be null.
         * @return A suitable data object
         */
        public function buildDependentVariableDataObject(measureV:KefedObject, previousValue:Object):Object {
         	// Go back through graph and build pathways from all constant and parameter 
        	// variables and the current measurement variable.
        	// 
        	// TODO: Should this also pick up controlled variables and show
        	//       them in context?
        	var dataObject:Object = new Object();
        	var variable:KefedObject;
        	var oldValue:Object;

         	var dependOnsArray:ArrayCollection = this.getDependOnsForMeasurement(measureV);
			
			// Make entry for independent variables
        	for(var i:int=0; i<dependOnsArray.length; i++) {
 				variable = dependOnsArray[i] as KefedObject;
 				oldValue = (previousValue == null) ? null : previousValue[variable.uid];
        		dataObject[variable.uid] = buildDataObjectForVariableType(variable.valueType,
        																  oldValue);
        	}
 
        	// Now handle the Dependent variable structure as well.
        	oldValue = (previousValue == null) ? null : previousValue[measureV.uid];
        	dataObject[measureV.uid] = buildDataObjectForVariableType(measureV.valueType,
        														      oldValue);
			return dataObject;
         }

		
		
		 /** Return an appropriate object for storing data about just this
          *  variable.  This will be a simple object for simple variables
          *  and an object with appropriate substructure for Table variables.
          *  The data value will be appropriately initialized.  For certain
          *  fields with "mandatory" values, this will set a value.  Otherwise
          *  no value will be set.
          * 
          * @param vType The type description of the variable
          * @param previous The previous value of the variable.  May be null.
          * @return a suitable data object, properly initialized
          */
         public static function buildDataObjectForVariableType (vType:KefedBaseValueTemplate, previous:Object):Object {
         	var dataObject:Object = null;
         	if (vType.valueTypeName == "Table") {
         		dataObject = new Object();
         		for each (var field:KefedFieldTemplate in (vType as KefedFullValueTemplate).multipleSlotFields) {
         			var previousFieldValue:Object = (previous == null) ? null : previous[field.uid];
         			dataObject[field.uid] = buildDataObjectForVariableType(field.valueType,
         																   previousFieldValue);
         		}
         	} else { // Simple variable value
         		if (previous != null) {
         			if (previous is Array) { // An array we need to copy
         				dataObject = (previous as Array).slice();
         			} else if (ObjectUtil.isSimple(previous)) {  // Simple data
         				dataObject = previous;
         			} else if (previous is ObjectProxy) {
         				dataObject = ObjectUtil.copy((previous as ObjectProxy).valueOf());
         			} else { // An object that we need to copy
         			  dataObject = ObjectUtil.copy(previous);
         			}
         		} else if (vType.valueTypeName == "True/False") {
         			dataObject = false;
         		} else if (vType.valueTypeName == "Decimal with units") {
         			dataObject = new Object();
         			dataObject.value = "";
         			if (vType.allowedUnits.length > 0) {
         				dataObject.units = vType.allowedUnits[0];
         			} else {
         				dataObject.units = "";
         			}
         		}  else if (vType.valueTypeName == "Region") {
         			dataObject = new Object();
         			dataObject.relation = "part-of";
         			dataObject.regions = new Array();
         		} else if (vType.allowedValues.length > 0 && !vType.allowFreeValueInput) {
         			dataObject = vType.allowedValues[0];
         		}
         	}
         	return dataObject;
         }
 
	
		/** Update the UID of this model.
		 *  Do not update the model, since it hasn't changed.
		 *  NOTE: This does change the TOP-LEVEL model uid,
		 *        which is less than ideal, but until we change
		 *        the storage method, it will have to be done this way.
		 *  TODO: Change the model to be a reference to the model and 
		 *        not keep this as a subclass.
		 * 
		 * @return the old UID
		 */
		override public function updateUID():String { 
			var oldId:String = this.uid;
			this.uid = UIDUtil.createUID();
			return oldId;
		}
	
	}
}