package edu.isi.bmkeg.kefed.store.json {
	import com.adobe.serialization.json.JSON;
	
	import edu.isi.bmkeg.kefed.elements.KefedBaseValueTemplate;
	import edu.isi.bmkeg.kefed.elements.KefedExperiment;
	import edu.isi.bmkeg.kefed.elements.KefedFieldTemplate;
	import edu.isi.bmkeg.kefed.elements.KefedFullValueTemplate;
	import edu.isi.bmkeg.kefed.elements.KefedLink;
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	import edu.isi.bmkeg.kefed.elements.KefedObject;
	import edu.isi.bmkeg.kefed.ontology.OntologyTermReference;
	
	import mx.collections.ArrayCollection;
	
	public class YogoSerializer
	{
		private static  var typeMap:Object = {"True/False"     : "DataMapper::Types::Boolean", 
   										      "Integer"        : "Integer",
											  "Decimal"        : "Float",
 										      "Term"           : "DataMapper::Types::Text", 
 										      "Text"           : "DataMapper::Types::Text", 
 										      "Text List"      : "DataMapper::Types::Text", 
 										      "Long Text"      : "DataMapper::Types::Text", 
   											  "Date"           : "Date",
 										      "Time"           : "Time",
 										      "DateTime"       : "DateTime",
 											  "File"           : "DataMapper::Types::YogoFile",
 										      "Image"          : "DataMapper::Types::YogoImage",
 										      // Other items
 										      "Decimal with units" : "Float",
 										      "Region"     		: "DataMapper::Types::Text",
 										      // Older versions
 										      "number"         : "Float",
											  "number with units" : "Float",
											  "true or false"  : "DataMapper::Types::Boolean",
											  "string"         : "DataMapper::Types::Text"};

		 			
 		/** Maps a KefedEditor human-readable type name to a Yogo
 		 *  data type.  If no such mapping exists, then the original
 		 *  type will be returned.
 		 * 
 		 *  @param kefedType The Kefed type to map
 		 *  @return The corresponding Yogo type		
 		 */							    
 		public static function mapTypeToYogo (type:String):String {
 			var yogoType:String = typeMap[type];
 			if (yogoType == null) {
 				return type;
 			} else {
 				return yogoType;
 			}
 		}
			
		/****************************
		 * 
		 *  Serialization Support
		 * 
		 ****************************/
		
		/** Serialize a kefed model for Yogo/JSON
		 *  Copy the fields to be saved into a new generic object
		 *  because that is what the storage mechanism knows how to
		 *  store.  It doesn't handle specialized objects.
		 * 
		 *  Then serialize the new object and return it.
		 *  The ID field is an optional include.  It should be omitted 
		 *  when a new model is inserted or a copy is being made.
		 *  Then Persevr will create a new model id.
		 * 
		 * @param model The model to serialize
		 * @param includeId Flag for including the model id or not in the serialization
		 * @return a serialized string representation of the model.
		 * 
		 */		
		public static function serializeKefedModel(model:KefedModel, includeId:Boolean=true):String {
			var o:Object = convertKefedModelToObject(model, includeId);
			var s:String = JSON.encode(o);
			return s;
		}
		
		/** Serialize a kefed experiment for Yogo/JSON
		 *  Copy the fields to be saved into a new generic object
		 *  because that is what the storage mechanism knows how to
		 *  store.  It doesn't handle specialized objects.
		 * 
		 *  Then serialize the new object and return it.
		 *  The ID field is an optional include.  It should be omitted 
		 *  when a new experiment is inserted or a copy is being made.
		 *  Then Persevr will create a new model id.
		 * 
		 * @param experiment The experiment to serialize
		 * @param includeId Flag for including the model id or not in the serialization
		 * @return a serialized string representation of the experiment.
		 * 
		 */		
		public static function serializeKefedExperiment(model:KefedExperiment, includeId:Boolean=true):String {
			var o:Object = convertKefedExperimentToObject(model, includeId);
			var s:String = JSON.encode(o);
			return s;
		}
		
		
		/** Convert one of the Kefed types to a generic object.  We dispatch on 
		 *  the type here to simulate a dynamic method dispatch.  This could be
		 *  handled by methods on the objects, but that leaks the special needs
		 *  of this conversion to support serialization into the general Kefed
		 *  model code, so this seems like the lesser of two evils.
		 * 
		 * @param obj The object to convert.
		 * @return The converted generic object
		 */
		 private static function convertToObject(obj:Object):Object {
		 	// Note that obj is really a specialization of Object
		 	// and needs to be turned into a generic object.
		 	if (obj is KefedModel) {
		 		return convertKefedModelToObject(obj as KefedModel, true);
		 	} else if (obj is KefedExperiment) {
		 		return convertKefedExperimentToObject(obj as KefedExperiment, true);
		 	} else if (obj is KefedObject) {
		 		return convertKefedObjectToObject(obj as KefedObject);
		 	} else if (obj is OntologyTermReference) {
		 		return convertOntologyReferenceToObject(obj as OntologyTermReference);
		 	} else if (obj is KefedBaseValueTemplate) {
		 		return convertValueTemplateToObject(obj as KefedBaseValueTemplate);
		 	} else if (obj is KefedFieldTemplate) {
		 		return convertFieldTemplateToObject(obj as KefedFieldTemplate);
		 	} else {
		 		trace("Got object we don't have a converter for: ", obj);
		 		return obj;
		 	}
		 }
			
		/** Create a generic object clone of this model, using
		 *  a deep copying strategy, whereby substructure is also
		 *  converted.  A flag controls whether to include the ID as
		 *  well.  Not including the ID is used to create a new copy
		 *  of this model rather than a true clone.  The copy is used
		 *  when a new or copy of a model is desired.
		 * 
		 * @param model The model to convert to a generic object
		 * @param includeId Flag to indicate if the id should be included.
  		 * @return Generic object clone of this model
		 * 
		 */
		private static function convertKefedModelToObject(model:KefedModel,
														 includeId:Boolean):Object {
			var clone:Object = new Object();
			var elements:Object;
			var item:Object;
			
			clone.kefedVersion = model.kefedVersion;
			clone.uid = model.uid;
        	if(includeId)
	        	clone.id = model.id;
			clone.modelName = model.modelName;
			clone.description = model.description;
			clone.dateTime = model.dateTime;
			clone.type = model.type;
			clone.source = model.source;
			
			var nodes:Object = new Object();
			clone.nodes = nodes;
			// Collect the nodes into separate classes.
			
			// For Measurements, collect the items they depend on.
			var measurements:ArrayCollection = model.getMeasurements();
			var serializedMeasurements:Object = collectKefedObjectsIntoObject(measurements);
			for (var i:int = 0; i < measurements.length; i++) {
				var mVar:KefedObject = measurements[i];
				var dependOns:ArrayCollection = model.getConstantsForMeasurement(mVar);
				dependOns.addAll(model.getParametersForMeasurement(mVar));
				var dependOnsArray:Array = new Array(dependOns.length);
				for (var j:int = 0; j < dependOns.length; j++) {
					dependOnsArray[j] = dependOns[j].uid;
				}
				var o:Object = serializedMeasurements[mVar.uid];
				o["dependsOn"] = dependOnsArray;
			}
			
			nodes.constants = collectKefedObjectsIntoObject(model.getConstants());
			nodes.parameters = collectKefedObjectsIntoObject(model.getParameters());
			nodes.measurements = serializedMeasurements;
			nodes.objects = collectKefedObjectsIntoObject(model.getExperimentalObjects());
			nodes.actions = collectKefedObjectsIntoObject(model.getActivities());
			nodes.forks = collectKefedObjectsIntoObject(model.getForks());
			nodes.branches = collectKefedObjectsIntoObject(model.getBranches());

			clone.edges = new Array(model.bEdges.length);
			for(var k:int=0; k<model.bEdges.length; k++) {
				clone.edges[k] = copyEdge(model.bEdges[k] as KefedLink);
			}
			return clone;
		}
		
		/** Collect clones of the KefedObjects into an object with each clone
		 *  indexed by its uid.
		 * 
		 *  @param kefedObjects A collection of KefedObjects from a design
		 *  @return A new object containing clones of the KefedObjects
		 */
		private static function collectKefedObjectsIntoObject (kefedObjects:ArrayCollection):Object {
			var elements:Object = new Object();
			for each (var item:KefedObject in kefedObjects) {
				elements[item.uid] = convertKefedObjectToObject(item as KefedObject);
			}
			return elements;
		}
		
				
		/** Create a generic object clone of this experiment, using
		 *  a deep copying strategy, whereby substructure is also
		 *  converted.  A flag controls whether to include the ID as
		 *  well.  Not including the ID is used to create a new copy
		 *  of this experiment rather than a true clone.  The copy is used
		 *  when a new or copy of a experiment is desired.
		 * 
		 * @param experiment The experiment to convert to a generic object
		 * @param includeId Flag to indicate if the id should be included.
  		 * @return Generic object clone of this experiment
		 * 
		 */
		private static function convertKefedExperimentToObject(experiment:KefedExperiment,
														 	   includeId:Boolean):Object {
			// TODO: Update this when we have a different data structure for
			//       the experiment objects
			return convertKefedModelToObject(experiment, includeId);
		}
		
		/** Create a generic object clone of this kefedObject.
		 *  Copy all of the relevant fields into a new, generic object.
		 * 
		 * @param The KefedObject to convert.
		 * @return The generic clone.
		 * 
		 */		
		private static function convertKefedObjectToObject (obj:KefedObject):Object {
			var clone:Object = new Object();

			clone.label = obj.nameValue;
			clone.uid = obj.uid;
			if (obj.isVariable()) {
				clone.schema = convertValueTemplateToSchema(obj.valueType);
			}

			// clone.dataTable = convertArrayCollectionToArray(obj.oldDataTable, false);
			clone.ontologyIds = convertArrayCollectionToArray(obj.ontologyIds, true);
			return clone;
		}	
			
		/** Create a generic object clone of OntologyReference.
		 *  Copy all of the relevant fields into a new, generic object.
		 * 
		 * @param ref The OntologyReference to convert.
		 * @return The generic clone.
		 * 
		 */		
		 private static function convertOntologyReferenceToObject(ref:OntologyTermReference):Object {
			var clone:Object = new Object();
			
			clone.ontology = ref.ontology;
			clone.ontologyIdentifier = ref.ontologyIdentifier;
			clone.ontologyLocalName = ref.ontologyLocalName;
			
			return clone;		
		}
		
		/** Create a schema object from a base or full value template.
		 * 
		 * @param template The value template to convert
		 * @return The generic clone.
		 * 
		 */
		private static function convertValueTemplateToSchema(template:KefedBaseValueTemplate):Object {
			var schema:Object = new Object();
			// If this is a table, do the expansion only for each subtype.  The main table
			// structure is handled in-line.  Otherwise, include the 
			// ValueTemplate values at top level.
			if (template.valueTypeName == "table") {
				var properties:Object = new Object();
				schema.id = (template as KefedFullValueTemplate).uid;
				for each (var item:KefedFieldTemplate in (template as KefedFullValueTemplate).multipleSlotFields) {
					var field:Object = new Object();
					field.label = item.nameValue;
					field.schema = convertValueTemplateToSchema(item.valueType);
					field.ontologyIds = convertArrayCollectionToArray(item.ontologyIds, true);;
					properties[item.nameValue] = field;
				}
				schema.type = properties;
			} else {
				schema.type = mapTypeToYogo(template.valueTypeName);
				schema.valueType = convertValueTemplateToObject(template);
			}
			return schema;		
		}

		/** Create a generic object clone of a base or full value template.
		 *  Copy all of the relevant fields into a new, generic object.
		 * 
		 * @param template The value template to convert
		 * @return The generic clone.
		 * 
		 */		
		private static function convertValueTemplateToObject(template:KefedBaseValueTemplate):Object {
			var clone:Object = new Object();

			clone.nameValue = template.nameValue;
 			clone.valueTypeName = template.valueTypeName;
 			clone.termLookupFunction = template.termLookupFunction;
			clone.minimumValue = template.minimumValue;
			clone.maximumValue = template.maximumValue;
			clone.orderedValues = template.orderedValues;
		    clone.allowFreeValueInput = Boolean(template.allowFreeValueInput);
			clone.allowFreeUnitInput = Boolean(template.allowFreeUnitInput);
			clone.allowFreeUnitInput = Boolean(template.allowFreeUnitInput);
			
			clone.allowedValues = convertArrayCollectionToArray(template.allowedValues, false);
			clone.allowedUnits = convertArrayCollectionToArray(template.allowedUnits, false);
			clone.allowedPatterns = convertArrayCollectionToArray(template.allowedPatterns, false);
			if (template is KefedFullValueTemplate) {
		 	    clone.multipleSlotFields = convertArrayCollectionToArray((template as KefedFullValueTemplate).multipleSlotFields, true);
			 }	
		 	return clone;
		 }
		 
		/** Create a generic object clone of a field template object.
		 *  Copy all of the relevant fields into a new, generic object.
		 * 
		 * @param template The value template to convert
		 * @return The generic clone.
		 * 
		 */		 
		 private static function convertFieldTemplateToObject(template:KefedFieldTemplate):Object {
			var clone:Object = new Object();
			clone.nameValue = template.nameValue;
			clone.valueType = convertValueTemplateToObject(template.valueType);
			clone.ontologyIds = convertArrayCollectionToArray(template.ontologyIds, true);
			return clone;
		}
		
		/** Convert the array collection into a new array.
		 * 
		 * @param source ArrayCollection of objects
		 * @param cloneContents flag to control cloning of array contents.
		 * @return Array of OntologyId objects
		 * 
		 */
		 private static function convertArrayCollectionToArray (source:ArrayCollection,
		 										  	    convertContents:Boolean):Array {
			var clones:Array = new Array(source.length);
			var i:int;
			if (convertContents) {
				for(i=0; i<source.length; i++) {
					clones[i] = convertToObject(source[i]);
				}
			} else {
				for(i=0; i<source.length; i++) {
					clones[i] = source[i];
				}
			}
			return clones;
		}	
				
		/**  Copy an edge object into a new generic object.
         * 
         * @param sourceEdge The edge to copy
         * @return A generic object copy of sourceEdge
         * 
         */        
        private static function copyEdge (sourceEdge:KefedLink):Object {
        	var edge:Object = new Object();
			edge.uid = sourceEdge.uid;
			if (sourceEdge.source) edge.start = (sourceEdge.source as KefedObject).uid;
			if (sourceEdge.target) edge.end = (sourceEdge.target as KefedObject).uid;
			return edge;
        }
        
        
		/** Takes a JSON  list encoding and returns a list of objects that
		 *  have been reconstituted from that list.  Used to return the
		 *  values that listModels and listData return.
		 * 
		 * @param s The string describing a list of objects
		 * @return An ArrayCollection of objects made from the list
		 * 
		 */
		public static function deserializeJsonList(s:String):ArrayCollection {
	        s = JSONSerializer.stripAdditionalJsonCoding(s);								
			var o:Object = JSON.decode(s);
 			var list:ArrayCollection = new ArrayCollection();
			for( var i:int=0; i<o.length; i++) {
				list.addItem(o[i]);			
			}
			return list;
		}
		
		/** Takes a string describing a JSON encoded generic object for a
		 *  KefedModel and converts it into a shell of a KefedModel
		 *  object by handling only the top-level identifying information.
		 *  This is not a full-fledged KefedModel, since not all of the
		 *  needed information is saved in the schema.
		 * 
		 *  But some information, such as the persevere id and uid are
		 *  needed, and other meta-data is returned to make this more
		 *  readable.
		 * 
		 * @param str representation of the KefedModel as a JSON string
		 * @return limited KefedModel built from this string
		 * 
		 */
		public static function deserializeKefedModel(str:String):KefedModel {
			str = JSONSerializer.stripAdditionalJsonCoding(str);	        	
			
			var holder:Object = JSON.decode(str);
			if (holder.length == 0) { // No model in this string!
				return null;
			}
			var o:Object = holder[0];
         	trace("Deserialize yogo schema ", o.modelName ," source=",o);
			
			var model:KefedModel = new KefedModel();

			var idStr:String = String(o.id);
			var idPos:int = idStr.indexOf("/");
			model.id = String(o.id).substr(idPos+1, idStr.length-idPos);

			model.modelName = o.modelName;
			model.description = o.description;
			model.dateTime = o.dateTime;
			model.source = o.source;
			model.uid = o.uid;
			return model;
        }

	}
}