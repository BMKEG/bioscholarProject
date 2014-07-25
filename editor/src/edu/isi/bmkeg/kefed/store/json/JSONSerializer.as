// $Id: JSONSerializer.as 50 2011-06-09 22:55:52Z taruss2000@gmail.com $
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
	import edu.isi.bmkeg.kefed.ui.TypeTemplateForm;
	import edu.isi.bmkeg.kefed.ui.kapit.DiagramMappings;
	import edu.isi.bmkeg.utils.DataUtil;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	/**  Implementation of a serialization protocol for KefedModels
	 *   and KefedExperiments for storage in the JSON framework.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-06-09 15:55:52 -0700 (Thu, 09 Jun 2011) $
	 * @version $Revision: 50 $
	 * 
	 */	
	public class JSONSerializer {
		
		private static var spriteIdMapping:Object = {"Controlled Variable Data": DiagramMappings.CONSTANT_SPRITE_ID,
													 "Independent Variable Data":DiagramMappings.PARAMETER_SPRITE_ID,
													 "Dependent Variable Data":  DiagramMappings.MEASUREMENT_SPRITE_ID};
		
		
		/****************************
		 * 
		 *  Serialization Support
		 * 
		 ****************************/
		 
	   /** Serialize some type of Kefed Object.  Will dynamically dispatch
	   *   on the type and return the appropriate string value.  Currently
	   *   supports KefedModel and KefedExperiment.
	   *
	   *  @param obj The object to serialize
	   *  @param includeId Flag for including the model id or not in the serialization
	   *  @return A serialized string representation of the object.
	   */
	   public static function serializeObject(obj:Object, includeId:Boolean=true):String {
	  	   if (obj is KefedExperiment) {
	  	   	  return serializeKefedExperiment(obj as KefedExperiment, includeId);
	  	   } else if (obj is KefedModel) {
	  	   	  return serializeKefedModel(obj as KefedModel, includeId);
	  	   } else {
	  	   	  trace("Unrecognized object type in serialization: ",obj);
	  	   	  return null;
	  	   }
	   }
		 
		 
		
		/** Serialize a kefed model for JSON/Persevere.
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
		
		/** Serialize a kefed experiment for JSON/Persevere.
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
			
			clone._type = "KefedModel";
			clone.kefedVersion = model.kefedVersion;
			clone.uid = model.uid;
        	if(includeId)
	        	clone.id = model.id;
	        //  Important:  The diagramXML field is of type XML which cannot be 
	        //  properly serialized.  It must be converted to be of type string 
			clone.diagramXML = (model.diagramXML == null) ? "" : model.diagramXML.toXMLString();
			clone.modelName = model.modelName;
			clone.description = model.description;
			clone.dateTime = model.dateTime;
			clone.type = model.type;
			clone.source = model.source;
			clone.citeKey = model.citeKey;
		
			clone.nodes = new Array(model.bNodes.length);
			for(var i:int=0; i<model.bNodes.length; i++) {
				clone.nodes[i] = convertKefedObjectToObject(model.bNodes[i] as KefedObject);
			}

			clone.edges = new Array(model.bEdges.length);
			for(i=0; i<model.bEdges.length; i++) {
				clone.edges[i] = copyEdge(model.bEdges[i] as KefedLink);
			}
			return clone;
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
			var o:Object = convertKefedModelToObject(experiment, includeId);
			o._type = "KefedExperiment";
			o.designUid = experiment.designUid;
			o.experimentData = convertKefedDataToObject(experiment.experimentData);
			return o;
		}
		
		/** Create a generic object clone of this experiment's data object.
		 *  The format of a data object is that it contains fields for each
		 *  of the MeasurementValue variables, keyed by their uid.  The value
		 *  of these keys is an ArrayCollection of data rows.  That ArrayCollection
		 *  needs to be changed in to Arrays for proper JSON serialization.
		 * 
		 *  @param dataObject A data object with measurement to data ArrayCollection items
		 *  @param A generic object with the ArrayCollections replaced by Arrays. 
		 */
		private static function convertKefedDataToObject(dataObject:Object):Object {
			var o:Object  = new Object();
			for (var key:String in dataObject) {
				o[key] = convertArrayCollectionToArray(dataObject[key], false);
			}
			return o;
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

			clone._type = "KefedObject";
			clone.type = obj.type;
			clone.spriteid = obj.spriteid;
			clone.did = obj.did;
			clone.nameValue = obj.nameValue;
			clone.uid = obj.uid;
			clone.compositions = obj.compositions;
			clone.master = obj.master;
			clone.notes = obj.notes;
			if (obj.isVariable()) {
				clone.valueType = convertValueTemplateToObject(obj.valueType);
			}

			// TODO: Get rid of this when updating is completed!
			if (obj.oldDataTable.length > 0) {
				trace(obj.nameValue,"still has dataTable items:",obj.oldDataTable.length);
			}
			clone.dataTable = convertArrayCollectionToArray(obj.oldDataTable, false);
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
			
			clone._type = "OntologyReference";
			clone.ontology = ref.ontology;
			clone.ontologyIdentifier = ref.ontologyIdentifier;
			clone.ontologyLocalName = ref.ontologyLocalName;
			clone.termURL = ref.termURL;
			clone.description = ref.description;
			
			return clone;		
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

			clone._type = (template is KefedFullValueTemplate) ? "KefedFullValueTemplate" : "KefedBaseValueTemplate";
			clone.nameValue = template.nameValue;
 			clone.valueTypeName = template.valueTypeName;
 			clone.termLookupFunction = template.termLookupFunction; 			
			clone.minimumValue = template.minimumValue;
			clone.maximumValue = template.maximumValue;
			clone.orderedValues = template.orderedValues;
		    clone.allowFreeValueInput = template.allowFreeValueInput;
			clone.allowFreeUnitInput = template.allowFreeUnitInput;
			clone.allowFreePatternInput = template.allowFreePatternInput;
			
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
			
			clone._type = "KefedFieldTemplate";
			clone.nameValue = template.nameValue;
			clone.uid = template.uid;
			clone.notes = template.notes;
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
        	edge._type = "KefedLink";
			edge.uid = sourceEdge.uid;
			if (sourceEdge.source) edge.start = (sourceEdge.source as KefedObject).uid;
			if (sourceEdge.target) edge.end = (sourceEdge.target as KefedObject).uid;
			return edge;
        }

		/****************************
		 * 
		 *  Deserialization Support
		 * 
		 ****************************/


		/** Takes a JSON  list encoding and returns a list of objects that
		 *  have been reconstituted from that list.  Used to return the
		 *  values that listModels and listData return.
		 * 
		 * @param s The string describing a list of objects
		 * @return An ArrayCollection of objects made from the list
		 * 
		 */
		public static function deserializeJsonList(s:String):ArrayCollection {
	        s = stripAdditionalJsonCoding(s);								
			var o:Object = JSON.decode(s);
 			var list:ArrayCollection = new ArrayCollection();
			for( var i:int=0; i<o.length; i++) {
				list.addItem(o[i]);			
			}
			return list;
		}

		/** Takes a string describing a JSON encoded generic object for a
		 *  KefedModel and converts it into a properly formed KefedModel
		 *  object by creating the proper types
		 * 
		 * @param str representation of the KefedModel as a JSON string
		 * @return the KefedModel built from this string, or null if no model is present.
		 * 
		 */
		public static function deserializeKefedModel(str:String):KefedModel {
			return deserializeKefedModelFromObject(stringToJsonObject(str));
		}

		/** Constructs a KefedModel object by copying over the fields from 
		 *  the Json object serialization.
		 * 
		 * @param o The generic object representation of the Kefed Model
		 * @return The corresponding KefedModel
		 */			
		public static function deserializeKefedModelFromObject(o:Object):KefedModel {
			if (o == null) {
				return null;
			} else {
		       	trace("Deserialize kefed model", o.modelName," id=" + o.id + " version=" + o.kefedVersion);
				var model:KefedModel = new KefedModel();
		       	var diagramXml:XML = new XML(o.diagramXML);
		       	DataUtil.updateXmlTagAttributes(diagramXml, "sprite", "spriteid", spriteIdMapping);
		       	DataUtil.updateXmlTagAttributes(diagramXml, "panel", "title", {"Default title":"Kefed Model"});
		       	DataUtil.updateXmlTagAttributes(diagramXml, "lane", "title", {"Default title":"Kefed Model"});
	 	
				var idStr:String = String(o.id);
				var idPos:int = idStr.indexOf("/");
				model.id = String(o.id).substr(idPos+1, idStr.length-idPos);
	       		model.diagramXML = diagramXml;
			
				model.modelName = o.modelName;
				model.description = o.description;
				model.dateTime = o.dateTime;
				model.source = o.source;
				model.citeKey = o.citeKey;
				model.type = o.type;
				model.uid = o.uid;
				
				var nDict:Dictionary = new Dictionary();   // Keep a UID -> KefedObject map.
				//
				// Add all the appropriate nodes and store them in the node dictionary.
				//
				if( o.nodes ) {						
					var nodeArray:Object = o.nodes;
					for(var i:int=0; i<nodeArray.length; i++) {
						var kObj:KefedObject = deserializeKefedObject(nodeArray[i]);
						nDict[kObj.uid] = kObj;
						model.addNode(kObj);
					}
				}
	
				// Add all the appropriate edges taking care to connect
				// the appropriate edge objects from their UIDs using
				// the node dictionary.
				if( o.edges ) {
					var linkArray:Object = o.edges;
					for(var k:int=0; k<linkArray.length; k++) {
						var lObj:Object = linkArray[k];
						
						var s:KefedObject = KefedObject(nDict[lObj.start]);
						var t:KefedObject = KefedObject(nDict[lObj.end]);
	
						var l:KefedLink = new KefedLink(lObj.uid, s, t);
											
						model.addEdge(l);
						if (s != null) s.addOutEdge(l);
						if (t != null) t.addInEdge(l);
					}
				}	
				return model;
			}	
        }
        
        
		/** Takes a string describing a JSON encoded generic object for a
		 *  KefedExperiment and converts it into a properly formed KefedExperiment
		 *  object by creating the proper types
		 * 
		 * @param str representation of the KefedExperiment as a JSON string
		 * @return the KefedExperiment built from this string
		 * 
		 */
		 public static function deserializeKefedExperiment(str:String):KefedExperiment {
		 	return deserializeKefedExperimentFromObject(stringToJsonObject(str));		 	
		 }
		 
		 /** Constructs a KefedExperiment and by copying over the fields from
		 *  a generic object representation of the KefedExperiment.
		 * 
		 * @param str representation of the KefedExperiment as a JSON string
		 * @return the KefedExperiment built from this string
		 * 
		 */
		public static function deserializeKefedExperimentFromObject(o:Object):KefedExperiment {
			// TODO: Update when we get real KefedExperiment objects
			if (o == null) {
				return null;
			} else {
				var model:KefedModel = deserializeKefedModelFromObject(o);
				var exp:KefedExperiment = new KefedExperiment(model, false);
				exp.id = model.id;
				exp.designUid = o.designUid;
				if (o.experimentData != null) {
				   exp.experimentData = deserializeExperimentalData(o.experimentData);
				} else {
				   updateStoredData(exp);
				}
				return exp;
			}
		}
		
		/** Converts a string representation of  son object into an Object
		 * after stripping some additional Persevere coding.
		 *
		 *  @param str The string encoding of the Json object
		 *  @return The Json object or null if none is present in the string
		 */
		 public static function stringToJsonObject (str:String):Object {
		 	 str = stripAdditionalJsonCoding(str);	        	
			
			var holder:Object = JSON.decode(str);
			if (holder.length == 0) { // No object in this string!
				return null;
			} else {
				return holder[0];
			}
		 }
        
        /** Strips some additional Json Coding that the Persevere system
         * adds to the returned values.  This additional coding will break
         * the Json parsing code.
         *
         * @param str The Json string serialization from Persevere
         * @return The cleaned up string with additional elements removed
         */
        public static function stripAdditionalJsonCoding( str:String ) : String {
			//
			// Either the system returns JSON string enclosed with "( ... )" or
			// within a block starting with "()&&[...]"
			// both of which breaks the JSON parse.
			//
			if( str.substr(0,4) == "{}&&" ) {					
				str = str.substr(4,str.length);
			} else if( str.substr(0,1) == "(" ) {
				str = str.substr(1,str.length-2);
			}		
			
			// HACK: Be careful to remove all instances of 'undefined' 
			// and replace them with 'null'. This breaks the JSON Parser.
			str = str.replace(/undefined/g,"null");
			
			return str;
		} 

        
        /** Deserialized a KefedObject from a generic object representation.
         * 
         * @param source The generic object from which the KefedObject gets deserialized.
         * @return the corresponding KefedObject
         * 
         */               
        private static function deserializeKefedObject(source:Object):KefedObject {
        	// trace("Deserialize kefed object, source=",source);
 			var n:KefedObject = new KefedObject(); 
			n.type =  source.type;
			// trace("source.spriteid => ", updateSpriteId(source.spriteid));
			n.spriteid = updateSpriteId(source.spriteid);
			n.did = source.did;
			n.nameValue = source.nameValue;
			n.uid = source.uid;
			n.compositions = source.compositions;
			n.master = source.master;
			n.notes = source.notes;
			// Update value types to new storage form.
			// TODO:  Is this really needed?  There aren't many.
			if (source.valueType != null) {
				if (source.valueType is String) {
					n.valueType.valueTypeName = updateValueType(source.valueType);
				} else if (source.valueType is Object) {
					n.valueType = deserializeKefedValueTemplate(source.valueType, true) as KefedFullValueTemplate;
				} else {
					Alert("Found odd valueType '" + source.valueType + "' on " + source);
					n.valueType.valueTypeName = source.valueType.toString();
				}
			}
		
			// Update the old style information in the dataTable to be
			// the newer style.  This involves
			//  (a) For Parameter types, moving the values into allowedValues
			//  (b) For Measurement types, moving the values into the experiment
			//      data form, but that must be performed at the KefedExperiment level.
			if( source.dataTable ) {						
				var aObj:Object = source.dataTable;
				if (n.spriteid == DiagramMappings.PARAMETER_SPRITE_ID) {
					if (aObj.length > 0) {
						n.valueType.allowFreeValueInput = false; // TODO: Is this correct?
						for(var i:int=0; i<aObj.length; i++) {
							if (!n.valueType.allowedValues.contains(source.dataTable[i].value)) {
								n.valueType.allowedValues.addItem(source.dataTable[i].value);
							}
						}
					}
				} else {
					// TODO:  Eventually eliminate this.
					// Preserve the table for now for other items.
					for(var j:int=0; j<aObj.length; j++) {
						n.oldDataTable.addItem(source.dataTable[j]);
					}
				}
			}

			if( source.ontologyIds) {						
				var bObj:Object = source.ontologyIds;
				for(j=0; j<bObj.length; j++) {
					var r:OntologyTermReference = deserializeOntologyReference(source.ontologyIds[j]);
					if (r != null) {
						n.ontologyIds.addItem(r);
					}
				}
			}
			return n;
        }
        
        /** Deserialized a Kefed Value Template from a generic object representation.
         * 
         * @param source The generic object from which the value template gets deserialized.
         * @param isFull Flag to choose between KefedFullValueTemplate or KefedBaseValueTemplate
         * @return the corresponding value template
         * 
         */
         private static function deserializeKefedValueTemplate(source:Object, isFull:Boolean):KefedBaseValueTemplate {
         	// trace("Deserialize value template, source=",source);
         	var i:int;
         	var temp:Object;
         	var template:KefedBaseValueTemplate = (isFull) ? new KefedFullValueTemplate() : new KefedBaseValueTemplate();
        	template.nameValue = source.nameValue;
        	template.valueTypeName = updateValueType(source.valueTypeName);
 			template.termLookupFunction = (source.termLookupFunction) ? source.termLookupFunction : "";
        	template.minimumValue = source.minimumValue;
			template.maximumValue = source.maximumValue;
			template.orderedValues = Boolean(source.orderedValues);
			template.allowFreeValueInput = Boolean(source.allowFreeValueInput);
			template.allowFreeUnitInput = Boolean(source.allowFreeUnitInput);
			template.allowFreePatternInput = (source.allowFreePatternInput) ? false : Boolean(source.allowFreeUnitInput);
			
			if (source.allowedValues) {
				temp = source.allowedValues;
				for(i=0; i<temp.length; i++) {
					template.allowedValues.addItem(temp[i]);
				}
			}
			if (source.allowedUnits) {
				temp = source.allowedUnits;
				for(i=0; i<temp.length; i++) {
					template.allowedUnits.addItem(temp[i]);
				}
			}
			if (source.allowedPatterns) {
				temp = source.allowedPatterns;
				for(i=0; i<temp.length; i++) {
					template.allowedPatterns.addItem(temp[i]);
				}
			}
			if (source.multipleSlotFields) {
				temp = source.multipleSlotFields;
				for(i=0; i<temp.length; i++) {	
					var f:KefedFieldTemplate = deserializeKefedFieldTemplate(temp[i]);
					(template as KefedFullValueTemplate).multipleSlotFields.addItem(f);
				}
			}
			return template;
         }
         
        /** Handle updates to the names of variable types.  This might
         *   not be a change.
         * 
         *  @param sourceType The value type from the input
         *  @return The updated value type.
         */
         private static function updateValueType(sourceType:String):String {
         	var targetType:String = TypeTemplateForm.typeUpdateMap[sourceType];
         	if (targetType == null) {
         		targetType = sourceType; // No mapping, keep as is.
         	}
         	return targetType;
         }
         
        /** Deserialize an OntologyReference from a generic object representation.
         * 
         * @param source The generic object from which the OntologyReference gets deserialized.
         * @return the corresponding OntologyReference
         * 
         */
         private static function deserializeOntologyReference(source:Object):OntologyTermReference {
         	// trace("Deserialize ontology reference, source=",source);
          	if (source is String) {
         		// Or should we drop it because it doesn't have enough info and return null?
         		// return new OntologyReference("", source, "");
         		return null; 
         	} else if (source is Number) {
         		// This can occur when the original ontologyId was a numeric value, for
         		// example from SNOMED ids.
         		// Or should we drop it because it doesn't have enough info and return null?
         		// return new OntologyReference("", source.toString(), "");
         		return null; 
         	} else if (source is Object) {
         		var ref:OntologyTermReference = new OntologyTermReference(source.ontology,
         									 							  source.ontologyIdentifier,
         									 							  source.ontologyLocalName);
         		if (source.termURL) ref.termURL = source.termURL;
         		if (source.description) ref.description = source.description;
         		return ref;
         	} else {  // We shouldn't really get here.
         		// Or should we treat this as a string value and use that as
         		// the ontologyIdentifier? 
         		return null;
         	}
         }
         
       /** Deserialize a KefedFieldTemplate from a generic object representation.
         * 
         * @param source The generic object from which the KefedFieldTemplate gets deserialized.
         * @return the corresponding KefedFieldTemplate
         * 
         */
         private static function deserializeKefedFieldTemplate(source:Object):KefedFieldTemplate {
         	var f:KefedFieldTemplate = new KefedFieldTemplate();
         	f.nameValue = source.nameValue;
         	f.notes = source.notes;
         	if (source.uid != null) f.uid = source.uid;
         	f.valueType = deserializeKefedValueTemplate(source.valueType, false);
         	if (source.ontologyIds) {
     			var temp:Object = source.ontologyIds;
				for(var j:int=0; j<temp.length; j++) {
					var r:OntologyTermReference = deserializeOntologyReference(temp[j]);
					if (r != null) {
						f.ontologyIds.addItem(r);
					}
				}    		
         	}
 			return f;
 		}
         
        /** Deserialize a data table item from a generic object representation.
         *  Currently data table items are generic objects, so this is the identity function
         * 
         * @param source The generic object from which the data table item gets deserialized.
         * @return the corresponding data table item
         */         
        private static function deserializeDataTableItem(source:Object):Object {
        	return source;
        }
        
        /** Deserialize an experimental data item from a generic object representation.
         *  Experimental data is stored as a generic object with an Array of values.
         *  The arrays need to be changed into ArrayCollections instead.
         * 
         * @param source The generic object from which the experimental data item gets deserialized.
         * @return the corresponding experimental data item
         */         
        private static function deserializeExperimentalData(source:Object):Object {
        	var data:Object = new Object();
        	for (var key:String in source) {
        		var a:Array = source[key] as Array;
        		data[key] = new ArrayCollection(source[key] as Array);
        	}
        	return data;
        }
        
        /** Function to update sprite Ids for backward compatibilty with already
        *   stored items
        */
        private static function updateSpriteId(sourceId:String):String {
       	   if (spriteIdMapping.hasOwnProperty(sourceId)) {
       	   	return spriteIdMapping[sourceId];
       	   } else {
       	   	return sourceId;
       	   }
       }
       
        /** Function to update stored data elements in a KefedExperiment from the
        *   old form in which they are in a dataTable for each variable into the
        *   new, unified form where there is a central object that holds all of
        *   the items.
        */
        private static function updateStoredData(exp:KefedExperiment):void {
        	for each (var v:KefedObject in exp.getMeasurements()) {
        		var vName:String = v.nameValue;
        		var vUid:String = v.uid;
        		if (v.oldDataTable.length != 0) {
        			exp.experimentData[vUid] = new ArrayCollection();
        			for each (var entry:Object in v.oldDataTable) {
        				var o:Object = new Object();
        				for (var key:String in entry) {
							if (key == "value") {
								o[vUid] = entry[key];
								if (!v.valueType.allowedValues.contains(entry[key])) {
									v.valueType.allowedValues.addItem(entry[key]);
								}
							} else {
								var dependOn:KefedObject = exp.getKefedObjectFromName(key);
								if (dependOn != null) o[dependOn.uid] = entry[key];
							}
        				}
        				ArrayCollection(exp.experimentData[vUid]).addItem(o);
        			}
        		}
        	}
        }

	}
}
