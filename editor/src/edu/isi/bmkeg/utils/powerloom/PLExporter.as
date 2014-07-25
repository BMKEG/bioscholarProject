// $Id: PLExporter.as 50 2011-06-09 22:55:52Z taruss2000@gmail.com $
//
//  $Date: 2011-06-09 15:55:52 -0700 (Thu, 09 Jun 2011) $
//  $Revision: 50 $
//

package edu.isi.bmkeg.utils.powerloom
{
	import edu.isi.bmkeg.kefed.elements.KefedBaseValueTemplate;
	import edu.isi.bmkeg.kefed.elements.KefedExperiment;
	import edu.isi.bmkeg.kefed.elements.KefedFieldTemplate;
	import edu.isi.bmkeg.kefed.elements.KefedModel;
	import edu.isi.bmkeg.kefed.elements.KefedObject;
	import edu.isi.bmkeg.kefed.ontology.OntologyTermReference;
	
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	

	/** Functions to export Kefed designs and experimental
	 *  data in a PowerLoom format.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-06-09 15:55:52 -0700 (Thu, 09 Jun 2011) $
	 * @version $Revision: 50 $
	 */
	public class PLExporter
	{
		
		private static var plRelationMap:Object = {"equivalent"     : "=",
		                                       	   "part-of"        : "/PART/PROPER-PART-OF",
											   	   "overlaps"       : "/PART/OVERLAPS",
											   	   "non-overlapping": "/PART/DISCRETE"};

       private static var _vCounter:int = 0;  // Counter for generated variable instances
       
       /** Resets the temporary variable name counter.  Can be
        * called whenever the number should be reset.  Typically
        * this will be at the start of the main entry points to 
        * the exporter functions.
        */
       private static function resetValueCounter():void {
        	_vCounter = 0;
       }
       
       /** Generate a temporary variable name for PowerLoom
       *   using the standard "$" syntax.
       * 
       * @param root The root string for the variable name
       * @return The temporary variable name
       */        
       private static function genVariableName(root:String="value"):String {
        	return "$" + root + "-" + _vCounter++;
       }

	  /** Generates a PowerLoom name from the given string.
       *
       * @param name The general name.
       * @return A PowerLoom legal name for the object.
       */
       public static function powerLoomName(name:String):String {
       	  var trimmedName:String = StringUtil.trim(name);
       	  var plName:String = "|" + trimmedName.replace(/\|/g,"_") + "|";
       	  return plName;
       }
       
      /** Generates a PowerLoom string form from the given string
       *  with proper escaping.
       *
       * @param str The string.
       * @return A PowerLoom legal string form for the input string.
       */
       public static function powerLoomString(str:String):String {
       	  var trimmedString:String = StringUtil.trim(str);
       	  var plString:String = "\"" + trimmedString.replace(/\"/g,"\\\"") + "\"";
       	  return plString;
       }
       
       /** Generates a PowerLoom units value string, if enough information
       *   is present in the object denoting units and dimensions
       * 
       *  @param unitsObject The object denoting units and dimensions
       *  @return A PowerLoom string or null if not enough info present.
       */
       private static function powerLoomUnits(unitsObject:Object):String {
       	  var value:String = unitsObject.value;
       	  var units:String = unitsObject.units;
       	  if (value && units) {
       	  	value = StringUtil.trim(value);
       	  	var unitString:String = powerLoomString(units);
       	  	var nvalue:Number = Number(value);
       	  	if (isNaN(nvalue)) { // units can be the empty string
       	  		return null;
       	  	} else {
       	  		return "(/UNIT-KB/UNITS " + nvalue + " " + unitString + ")";
       	  	}
       	  } else {
       	  	return null;
       	  }
       }
       
       /** Generates a PowerLoom term name.  If lookup function exists and
       * is non-null, then use that to lookup the name from a string argument.
       * Otherwise create a PowerLoom name from the term itself.
       * 
       * @param value The name of the term or term identifying string
       * @param lookupFunctionName The name of a PowerLoom function to look up the term.
       */
       private static function powerLoomTermForm (value:String,
       							 				 lookupFunctionName:String):String {
       	  if (lookupFunctionName && StringUtil.trim(lookupFunctionName) != "") {
       	  	return "(" + powerLoomName(lookupFunctionName) + " " + powerLoomString(value) + ")";
       	  } else {
       	  	return powerLoomName(value);
       	  }
       }
       
       
       /** Generates a PowerLoom region assertion string.  The region
       * is created as an anonymous object with a relation to some
       * reference regions. The reference regions can either be named 
       * directly by the regions field of the regionObject, or they can 
       * use that name via a PowerLoom lookup function to find the instance.
       * 
       * If lookupName is null, then the region should be the individual name
       * itself.  Otherwise, the lookupName will be applied as a PowerLoom 
       * function to a string value of the region name.
       * 
       *  @param indent  The indent string for each line. Should include newline.
       *  @param regionInstanceName The name of the region object in the PL assertion.
       *  @param unitsObject The object denoting units and dimensions
       *  @param lookupName Function name to use for instance lookup.  May be null.
       *  @return A PowerLoom string or null if not enough info present.
       */
       private static function powerLoomRegionForm (indent:String,
       										   		  regionInstanceName:String,
       												  regionObject:Object,
       												  lookupName:String):String {
       		var result:String = "";
            var plRelation:String = plRelationMap[regionObject.relation];
           	result += indent + "(/PART/GEOMETRIC-REGION " + regionInstanceName + ")"
           	for each (var regionName:String in regionObject.regions) {
           		var referenceRegion:String = (lookupName && lookupName != "") ?
           									 "(" + lookupName + " " + powerLoomString(regionName) + ")" : 
           									 powerLoomName(regionName);
           	    result += indent + "(" + plRelation + " " 
           	    				       + regionInstanceName + " "
           	    				       + powerLoomTermForm(regionName, lookupName) + ")";
           	}
           	return result;
       }
        		   	      
       /** Generates the value expression for a structured value.
        *   This would be a Region or units & dimensions value.
        * 
        * @param indent The indent string for each line. Should include newline.
        * @param valueName The name of the value object in the PL assertion.
        * @param variableType The type description for this value.
        * @param value The particular value of this object.
        * @return A PowerLoom assertion string for the value object itself.
        *         Could be multiple PL forms.
        */
         private static function structuredValueForm(indent:String,
                               						valueName:String,
                               						variableType:KefedBaseValueTemplate,
                               						value:Object):String {
           if (!value || value == "") {
           	return null;
           } else if (variableType.valueTypeName == "Region") {
				return powerLoomRegionForm(indent, valueName, value, "brain-region-for");
           } else {
           		return null;
           }
       }
       
       /** Returns a value expression if the input value can be represented
       *   as a simple PowerLoom value expression.  Otherwise null is returned
       *   and the value is a structured value expression instead.
       * 
       * @param value The value to be converted.
       * @return A string expression for value, or null if it is not simple.
       */
       private static function simpleValueExpression(value:Object, valueType:KefedBaseValueTemplate):String {
           if (!value || value == "") {
           	return null;
           } else if (ObjectUtil.isSimple(value)) {  // Literal expressions
	    		if (valueType.valueTypeName == "Decimal" 
	    			|| valueType.valueTypeName == "Integer") {
	    			return value.toString();
	    		} else if (valueType.valueTypeName == "True/False") {
	    			return value.toString().toUpperCase();
	       		} else if (valueType.valueTypeName == "Term") {
	       			return powerLoomTermForm(value.toString(), valueType.termLookupFunction);
	    		} else { // Wrap with string quotes.
	    			return powerLoomString(value.toString());
	    		}
	    	} else if (valueType.valueTypeName == "Decimal with units") {
	    		return powerLoomUnits(value);
	    	} else {
	    		return null;
	    	}
       }

       /** Generate the value string for the appropriate variable value.
        *  Creates and structures an appropriate value object to use
        *  for the value.  The PowerLoom relation should be one of
        * 
        * @param indent The indent string for each line.  Should include newline.
        * @param datumName The name of the datum object in the PL assertion.
        * @param variable The variable object for this value.
        * @param value The particular value of this object.
        * @param includeComments Flag for generating comments with human readable names
        * @return A PowerLoom assertion string for the value.  Could be multiple PL forms.
        */
	    private static function generateVariableValueForm(indent:String, 
	    										   		  datumName:String,
	    										  		  variable:KefedObject,
	    										 	 	  value:*,
	    										 	 	  includeComments:Boolean):String {
	    	var result:String = "";
	    	var plRelation:String = (variable.isMeasurement()) ? "datum-measurement-value" : "datum-context-value";
	    	var variableName:String = variable.uid;
	    	var valueName:String;
	    	var valueExpression:String;
	    	var subindent:String = indent + "     ";
			if (variable.valueType.valueTypeName == "Table") {
				valueName = genVariableName("value");	    		
	    		for each (var field:KefedFieldTemplate in variable.valueType.multipleSlotFields) {
	    			var fieldName:String = field.uid;
	    			var fieldValue:* = value[field.uid];
	    			valueExpression = simpleValueExpression(fieldValue, field.valueType);
	    			if (valueExpression) {
	    				result += subindent + "(" + fieldName + " " + valueName + " " + valueExpression + ")";
	    				if (includeComments) result += "  ; " + field.nameValue;
	    			} else {
	    				var fieldValueName:String = genVariableName("field");
		    			valueExpression = structuredValueForm(subindent, fieldValueName, field.valueType, fieldValue);
		    			if (valueExpression) {
		    				result += valueExpression;
		    				result += subindent + "(" + fieldName + " " + valueName + " " + fieldValueName + ")";
	    					if (includeComments) result += "  ; " + field.nameValue;
		    			} else {
		    				result += subindent + "  ;; No value for datum " + datumName 
	    					  	   + " of variable " + variable.uid + "." + field.uid;
		    			}
	    			}
		    	}
		    	result += indent + "(" + plRelation + " " + datumName + " " + variableName + " " + valueName + ")";
		    	if (includeComments) result += "  ; " + variable.nameValue;
	    	} else {
	    		valueExpression = simpleValueExpression(value, variable.valueType);
	    		if (valueExpression) {
	    			result += indent + "(" + plRelation + " " + datumName + " " + variableName + " " + valueExpression + ")  ; " + variable.nameValue;
	    		} else {
	    			valueName = genVariableName("value");
	    			valueExpression = structuredValueForm(subindent, valueName, variable.valueType, value);
	    			if (valueExpression) {
	    				result += valueExpression;
	    				result += indent + "(" + plRelation + " " + datumName + " " + variableName + " " + valueName + ")"
	    				if (includeComments) result += "  ; " + variable.nameValue;
	    			} else {
	    				result += subindent + "  ;; No value for datum " + datumName + " of variable " + variable.uid + " (" + variable.nameValue + ")";
	    			}
	    		}
	    	}				  	
	    	return result;
	    }
	    
	          
	/** Generate the PowerLoom assertion string for the data in this experiment.
	 * 
	 * @param experiment The experiment for the data assertions
	 * @param includeComments Flag for generation of comments with human-readable names.
	 * @return The PowerLoom assertion form in a string
	 */	
	public static function generateExperimentDataAssertion(experiment:KefedExperiment, includeComments:Boolean): String {
			var counter:int = 0;  // Name counter for data items
			var indent:String = "\n             ";
			var experimentName:String = StringUtil.trim(experiment.modelName)
			                            + "-" + StringUtil.trim(experiment.citeKey);
			resetValueCounter();
			var pl:String = "(ASSERT (AND ";
			// TODO: Make this work with UIDs.  Do experiments currently have their own?
			if (experiment.designUid == null) {
				pl += "(Experiment " + experiment.uid + ")";
			} else {
				pl += "(" + experiment.designUid + " " + experiment.uid + ")";
			}
			pl += indent + "(element-name " + experiment.uid + " " + powerLoomString(experimentName) + ")";
			pl += indent + "(experiment-source " + experiment.uid + " " 
			                + powerLoomName(experiment.citeKey) + " " + powerLoomString(experiment.modelName)  + ")";
			// pl += indent + "(" + powerLoomName(experiment.type) + " " + experimentName + ")";
			for each (var dv:KefedObject in experiment.getMeasurements()) {
				var variableName:String = dv.uid;
				for each (var datum:Object in experiment.experimentData[dv.uid]) {
					var datumName:String = "$datum-" + counter++;
					pl += indent + "(Datum " + datumName + ")";
					var subindent:String = indent + "    ";
					pl += subindent + "(measurement-variable-datum " + experiment.uid + " " + variableName + " " + datumName +")";
					if (includeComments) pl += "  ; " + dv.nameValue;
					for (var variableUid:String in datum) {
						var variable:KefedObject = experiment.getKefedObjectFromUID(variableUid);
						if (variable) { // Skip extra stuff that isn't a KefedObject, like internal uids.
							var value:* = datum[variableUid];
							pl += generateVariableValueForm(subindent, datumName, variable, value, includeComments);
						}
					}
				}
			}
		
			pl += indent + "))";
					
//			Alert.show(pl, "PowerLoom Representation");
			
			return pl;
	}
	
	
	/** Generate the PowerLoom assertion string for the structure of this model.
	 * 
	 * @param model The model for the model assertions
	 * @param includecomments Flag for adding comments with human readable names
	 * @return The PowerLoom assertion form in a string
	 */	
	public static function generateModelDefinitionAssertion(model:KefedModel, includeComments:Boolean): String  {
		var variable:KefedObject;
		var pl:String = "";
		var prefix:String = "";
		// Generate experiment concept description.
		pl += "(DEFCONCEPT " + model.uid + " (?exp Experiment)"
		      + "\n  :=> (AND ";
		for each (variable in model.getVariables()) {
			pl += prefix + "(has-variable ?exp " + variable.uid + ")";
			if (includeComments) pl += "  ; " + variable.nameValue;
			prefix = "\n           ";
		}
		pl += prefix + ")";		
		pl += "\n  :AXIOMS (AND (element-name " + model.uid + " " + powerLoomString(model.modelName) + ")";
		if (model.citeKey != null && model.citeKey != "") {
			pl += "\n               (model-source " + model.uid + " " + powerLoomName(model.citeKey) + ")";
		}
		pl += "\n               (DOCUMENTATION " + model.uid + " " + powerLoomString(model.description) + ")";
		pl += "))\n";
		
		// Generate function definitions for multiple value field objects
		for each (variable in model.getVariables()) {
			if (variable.valueType.valueTypeName == "Table") {
				for each (var field:KefedFieldTemplate in variable.valueType.multipleSlotFields) {
					pl += "(DEFRELATION " + field.uid + " (?x ?y)"
					      + "\n  :SINGLE-VALUED TRUE"
					      + "\n  :AXIOMS (AND (element-name " + field.uid + " " + powerLoomString(field.nameValue) + ")"
					      + "\n               (has-field " + variable.uid + " " + field.uid + ")))\n";
				}
			}
		}
		
		// Generate individual variable and dependency assertions
		prefix = "";
		pl += "(ASSERT (AND ";
		for each (variable in model.getVariables()) {
			pl += prefix + "(" + variableTypeName(variable) + " " + variable.uid + ")";
			prefix = "\n             ";
			pl += prefix + "(element-name " + variable.uid + " " + powerLoomString(variable.nameValue) + ")";
			for each (var ref:OntologyTermReference in variable.ontologyIds) {
				// TODO: Limit this to PowerLoom terms when a PowerLoom web service
				//   with search capability is introduced.
				pl += prefix + "(measures " + variable.uid + " " 
				             + powerLoomName(ref.ontologyIdentifier) + ")";
			}
		}
		for each (variable in model.getMeasurements()) {
			if (includeComments) pl += prefix + ";; " + variable.uid + "  " + variable.nameValue;
			for each (var dep:KefedObject in model.getDependOnsForMeasurement(variable)) {
				pl += prefix + "(depends-on " + variable.uid + " " + dep.uid + ")";
				if (includeComments) pl += "  ; " + dep.nameValue;
			}
		}
		pl += prefix + "))\n\n";
		return pl;
	}
	
	private static function variableTypeName (obj:KefedObject):String {
		if (obj.isConstant()) return "Constant-Variable";
		else if (obj.isMeasurement()) return "Measurement-Variable";
		else if (obj.isParameter()) return "Parameter-Variable";
		else return "???";			
	}
  }
  
}