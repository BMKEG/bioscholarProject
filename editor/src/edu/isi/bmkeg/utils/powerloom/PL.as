// $Id: PL.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//

package edu.isi.bmkeg.utils.powerloom
{
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.rpc.soap.WebService;
	
	public class PL {
		namespace plsoap = "http://www.isi.edu/powerloom/";
		
		public static function displayQueryResults(xmlDoc:XML, results:DataGrid, countLabel:Label, formatCollection:Boolean=false): void {
						
			var nResults:int = int(xmlDoc.plsoap::nresults);
			var pat:String = xmlDoc.plsoap::pattern;
			var headers:Array = pat.substring(1,pat.length-1).split(" ");
			var fields:Array = new Array(headers.length);
			var columnHeaders:Array = new Array(headers.length);
			for (var j:int = 0; j < headers.length; j++) {
				fields[j] = headers[j].substring(1);
				columnHeaders[j] = new DataGridColumn(headers[j]);
				columnHeaders[j].dataField = fields[j];
			}
			var resultsCollection:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < nResults; i++) {
				resultsCollection.addItem(makeTupleObject(fields, xmlDoc.plsoap::tuple[i], formatCollection));
			}
		
			if (countLabel != null) {
				countLabel.text = xmlDoc.plsoap::nresults.toString() + (nResults == 1 ? " answer" : " answers");
			}
			results.columns = columnHeaders;
			results.dataProvider = resultsCollection;
		}
		
		private static function makeTupleObject(fields:Array, tuple:XML, formatCollection:Boolean):Object {
			var tupleObject:Object = new Object();
			for (var i:int=0; i < fields.length; i++) {
				tupleObject[fields[i]] = formatQueryItem(tuple.plsoap::item[i], formatCollection, false);
			}
			return tupleObject;
		}
		
		/** Format the XML encoding of a PowerLoom value.  The flag determines
		 *  whether PowerLoom collection values  like LISTOF or SETOF are
		 *  returned verbatim, or formatted into a comma separated string.
		 * 
		 * @param queryitem The query item from a PowerLoom webservice query
		 * @param formatCollection Flag to control expansion of collection values
		 * @param removeQuotes Flag to control the removal of string quotes
		 * @return String representation of the query item value.
		 */
		public static function formatQueryItem(queryItem:XML, formatCollection:Boolean, removeQuotes:Boolean):String {
			return formatQueryItemHelper(queryItem.toString(), formatCollection, removeQuotes);
		}
		
		private static function formatQueryItemHelper(queryItem:String, formatCollection:Boolean, removeQuotes:Boolean):String {
			var frontPattern:RegExp = removeQuotes ? /^[|"]*/ : /^|/ ;
			var backPattern:RegExp 	= removeQuotes ? /[|"]*$/ : /|$/;	
			var itemString:String = queryItem.replace(frontPattern,"").replace(backPattern,"");
			
			if (formatCollection && (itemString.indexOf("(LISTOF") == 0 
								     || itemString.indexOf("(SETOF") == 0)) {
				 var collectionString:String = "";
				 var prefix:String = "";
				 for each (var subString:String in itemString.substring(itemString.indexOf(" ")+1, itemString.length-1).split(" ")) {
				 	collectionString += prefix + formatQueryItemHelper(subString, formatCollection, removeQuotes);
				 	prefix = ", ";
				 }
				 return collectionString;
			} else {
				return itemString;
			}
		}
		
		public static function doCommand(plws:WebService, module:String, command:String):void {
			var cmd:XML = <command xmlns="http://www.isi.edu/powerloom/">
				<module>{module}</module>
				{command}
				</command>;
				
			plws.Command(cmd);
		}
			
		public static function doAsk(plws:WebService, module:String, options:String, query:String):void {
			if (options==null) options = "";
			var cmd:XML = <ask xmlns={plsoap}>
				<module>{module}</module>
				<options>{options}</options>
				{query}
				</ask>;
						
			plws.Ask(cmd);
		}
		
		public static function doRetrieve(plws:WebService, module:String, nResults:String, pattern:String, options:String, query:String):void {
			if (nResults==null) nResults = "";
			if (pattern==null) pattern = "";
			if (options==null) options = "";
			var cmd:XML = <retrieval xmlns="http://www.isi.edu/powerloom/">
				<module>{module}</module>
				<nresults>{nResults}</nresults>
				<pattern>{pattern}</pattern>
				<options>{options}</options>
				{query}
				</retrieval>;
						
			plws.Retrieval(cmd);
		}
	
		
	}
}
