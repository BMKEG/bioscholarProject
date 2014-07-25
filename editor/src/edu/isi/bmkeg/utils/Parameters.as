// $Id: Parameters.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//

package edu.isi.bmkeg.utils
{
	import mx.core.Application;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.utils.URLUtil;
	
	/**  Parameters object for holding configuration and other
	 *   additional parameters passed via flashVars or the
	 *   invoking URL.
	 * 
	 *   Parameters can come from an XML document that is
	 *   passed on object creation, the suppying of flashVars
	 *   to the Flex application or from parsing the query and
	 *   fragment parts of the URL that contains the Flex
	 *   Application.  These methods are explained in more detail
	 *   in http://livedocs.adobe.com/flex/3/html/help.html?content=passingarguments_3.html
	 *   and http://livedocs.adobe.com/flex/3/html/help.html?content=deep_linking_5.html#245869
	 * 
	 *   The order of search for parameter values will be
	 *   1. Parameter passed from the URL fragment.
	 *   2. Parameter values from the URL query part.
	 *   3. Parameter values from flashVars
	 *   4. Parameter values from the XML document.
	 *
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 *   NOTE: There is a need to also update 
	 *   KefedPersevereInterface.deserializeKefedModel
	 *   for structural changes here.
	 * 
	 */
	public dynamic class Parameters {
		
		/** Create a parameters object.  This will be initialized with
		 *  values from the XML document if one is provided.  It will
		 *  augment the values with additional parameter values from 
		 *  flashVars or the URL of the containing page.
		 * 
		 *  The XML document is a simple one that uses the following
		 *  structure:
		 *  <?xml version="1.0" encoding="UTF-8"?>
		 *  <parameters>
		 *    <NAME1>VALUE1</NAME1>
		 *    <NAME2>VALUE2</NAME2>
		 *    ...
		 *  </parameters>
		 * 
		 * The parameters can either be accessed using the standard ActionScript
		 * property accessor methods, or the method getValue defined below can be
		 * used.  The latter method also allows specifying a default value.
		 * 
		 * @param parameterValues parameter values to use from XML
		 */
		public function Parameters (parameterValues:XML) {
			addUrlParameters();
			addApplicationParameters();
			addXmlParameters(parameterValues);
		}
		
		/** Adds a parameter and a value unless there is already
		 *  a parameter of that name defined.
		 *
		 * @param name The name of the parameter
		 * @param value The string representaiton of the parameter value
		 */
		private function addParameter (name:String, value:String):void {
			// trace("Adding parameter " + name + "=" + value);
			if (!this.hasOwnProperty(name)) {
				this[name] = value;
			}
		}
		
		/** Adds parameters from a dynamic object by iterating over
		 *  the enumerable properties
		 * 
		 * @param propertyObject
		 */
		private function addParametersFromObject (propertyObject:Object):void {
			for (var key:String in propertyObject) {
				addParameter(key, propertyObject[key]);
			}
		}
		
		/** Add parameters derived from the fragment and query portions
		 *  of the URL of the page that contains this application.
		 */
		private function addUrlParameters ():void {
			var bm:IBrowserManager = BrowserManager.getInstance();
			if (bm != null) {
				bm.init();
				trace("URL = " + bm.url);
				if (bm.fragment != "") {
					addParametersFromObject(URLUtil.stringToObject(bm.fragment, "&", true));
				}
				if (bm.base != null) {
					var queryStart:int = bm.base.lastIndexOf("?");
					if (queryStart >= 0) {
						var fragmentStart:int = bm.base.lastIndexOf("#", queryStart);
						var queryEnd:int = (fragmentStart >= 0) ? fragmentStart - 1: bm.base.length;
						trace("Query = " + ((queryStart >= 0) ? bm.base.substring(queryStart+1, queryEnd) : ""));
						addParametersFromObject(URLUtil.stringToObject(bm.base.substring(queryStart+1, queryEnd), "&", true));
					}
				}
			}				
		}
		
		/** Adds parameters that come from the flashVars property of
		 *  the application.
		 */
		private function addApplicationParameters ():void {
			addParametersFromObject(Application.application.parameters);
		}
		
		/** Adds the parameters that come from the XML object.
		 *  These will be the elements inside the top-level <parameters> tag.
		 *  (Note: The tag name is not currently checked).
		 */
		private function addXmlParameters (parameterValues:XML):void {
			if (parameterValues != null) {
				// trace("parameterValues.elements('*') = " + parameterValues.elements("*"));
				for each (var key:XML in parameterValues.elements("*")) {
					addParameter(key.name(), key.text());
				}
			}
		}
		
		/** Gets the value of the indicated parameter if it exists, or else
		 *  it returns the default value specified.  This is a convenience 
		 *  method for handling defaults, since one could always use the
		 *  standard ActionScript methods for getting property values.
		 * 
		 * @param parameterName Name of the parameter to get.
		 * @param defaultValue Value to return if no such parameter exists.  Defaults to null
		 * @return The value if it exists, or else the default value.
		 */
		public function getValue (parameterName:String, defaultValue:String=null):String {
			if (this.hasOwnProperty(parameterName)) {
				return this[parameterName];
			} else {
				return defaultValue;
			}
		}
	}
}