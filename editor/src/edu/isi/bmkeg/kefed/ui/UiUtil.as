// $Id: UiUtil.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextLineMetrics;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.TileList;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	/** Class with generally useful UI routines.
	 * 
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 */
	 public class UiUtil {
	 	
	 	private static const PROPERTIES_PATH:String = "/";
	 	private static const PROPERTIES_FILENAME:String = "properties";
	 	private static const H_PADDING:int = 6; 
		private static const V_PADDING_FACTOR:int = 2;

	 	
	 	/** Verify agreement to a license with the given key and text.
	 	 *  If previously agreed to, invoke the success handler.
	 	 *  Otherwise put up an alert and exit the application.
	 	 * 
	 	 * @param key A key to identify the license and version
	 	 * @param license The text of the license for agreement
	 	 * @param successHandler Function to call upon user agreement
	 	 */
	 	public static function agreeToLicense (key:String, license:String) :void {
	 		var properties:SharedObject = SharedObject.getLocal(PROPERTIES_FILENAME, PROPERTIES_PATH);
	 		if (properties.data[key] == null) { // Hasn't already agreed.
		 		var dialog:LicenseDialog = PopUpManager.createPopUp(Application.application as DisplayObject,
																	LicenseDialog, true) as LicenseDialog;
		 		dialog.licenseKey = key;
		 		dialog.licenseText = license;
				dialog.yesButton.addEventListener(MouseEvent.CLICK, handleLicenseAccepted);
				dialog.noButton.addEventListener(MouseEvent.CLICK, handleLicenseDeclined);
				PopUpManager.centerPopUp(dialog);
			}
	 	}
	 	
	 	private static function handleLicenseAccepted (evt:Event):void {
	 		var dialog:LicenseDialog = (evt.target as Button).parentDocument as LicenseDialog;
	 		var properties:SharedObject = SharedObject.getLocal(PROPERTIES_FILENAME, PROPERTIES_PATH);
	 		properties.data[dialog.licenseKey] = new Date().toDateString();
	 		properties.flush();
	 		PopUpManager.removePopUp(dialog);	 		
	 	}
	 	
	 	private static function handleLicenseDeclined (evt:Event):void {
	 		Alert.show("Since you didn't accept the license terms, you will not be able to use this application.",
	 					"License Declined");
	 		PopUpManager.removePopUp(evt.target as LicenseDialog);
	 		closeApp();
	 	}
	 	
		/** Close the application using a JavaScript call. 
		 * 
		 */		
		public static function closeApp():void {
            var urlString:String = "javascript:window.opener = self; self.close();";
            var request:URLRequest = new URLRequest(urlString);
            navigateToURL(request, "_self");
            Application.application.callLater(navigateToURL,[request, "_self"]);                                                
     	}
     	
	    /** Handles all of the callback actions, either calling back to a JavaScript
	     *  function, to a URL or to both.  This will be determined by whether or 
	     *  not callback functions or urls are null.  If both are done, the JavaScript
	     *  function is invoked first and after it returns, the callbackUrl is invoked.
	     * 
	     *  The callback function and URL transfer information using a URI-encoded 
	     *  key=value string.  This is the query string for the URL and the single 
	     *  argument for the callback function.
	     * 
	     *  Any keys in the parameters object that have explicit null values will
	     *  be reported as <key>=null in the parameter string.
	     *  
	     * @param functionName The name of a JavaScript function to call
	     * @param baseUrl The base URL for a URL callback.  May be null.
	     * @param parameters Parameters as key:value pairs in the object
	     */
	     public static function doCallback(functionName:String, baseUrl:String, parameters:Object):void {
	       	
	       	var parameterString:String = "";
	       	var connector:String = "";
	       	if (parameters != null) {
		       	for (var key:String in parameters) {
		       		parameterString += connector + key + "=" 
		       						   + ((parameters[key] == null) ? "null" : encodeURIComponent(parameters[key]));
		       		connector = "&";
		       	}
	       	}
	      	
	      	if (functionName != null && ExternalInterface.available) {
	      		trace("Making JavaScript call",functionName,parameterString);
	       		ExternalInterface.call(functionName, parameterString);
	//       		trace("Second call");
	//       		ExternalInterface.call("alert", {"foo":"bar", "baz":"ooka"});
	      		trace("Returned from JavaScript call");
	       	}
	      	if (baseUrl != null) {
	      		var fullUrlString:String = baseUrl + "?" + parameterString;
	      		var request:URLRequest = new URLRequest(fullUrlString);
	      		trace("Callback: " + fullUrlString);
	      		//Alert.show("Callback: " + fullUrlString);
	      		//navigateToURL(request, "_self");
	      		Application.application.callLater(navigateToURL, [request, "_self"]);
	      	}
	      }
	      
	      // TODO:  The following should perhaps be better encapsulated in 
	      //  a separate subclass of TileList, so it happens automatically
	      //  instead of by explicit calling of these methods.
	      
	    /** Adjust the TileList to fit the size of the largest item.
	     *  Iterates over all items in the tile list and adjusts the
	     *  tile list to fit the largest item.
	     * 
		 *  @param tlist The tile list to adjust.
		 */		
	    public static function adjustTileSizeToFit (tlist:TileList):void {
	    	var maxItemWidth:int = 0;
	    	var maxItemHeight:int = 0;
	    	for each (var item:Object in tlist.dataProvider) {
	    		var metrics:TextLineMetrics = tlist.measureText(item as String);
	    		if (metrics.width > maxItemWidth) maxItemWidth = metrics.width;
	    		if (metrics.height > maxItemHeight) maxItemHeight = metrics.height;
	    	}
	    	if (maxItemWidth != 0 && maxItemHeight != 0) {
	    		trace("Adjusting tilelist size from " + tlist.columnWidth + "x" + tlist.rowHeight 
	    				+ " to " + (maxItemWidth + H_PADDING) + "x" + (maxItemHeight * V_PADDING_FACTOR));
	    		tlist.columnWidth = maxItemWidth + H_PADDING;
	    		tlist.rowHeight = maxItemHeight * V_PADDING_FACTOR;
	    	}
	    }
	    
	    /** Adjust the TileList to fit the size of the newly added item.
	     *  Checks the size needed for the added item and if it is larger
	     *  than the existing size, enlarges the TileList
	     * 
		 *  @param tlist The tile list to adjust.
		 *  @param newText The string value of the new item.
		 */		
	    public static function adjustTileSizeForAddedItem (tlist:TileList, newText:String):void {
	    	var metrics:TextLineMetrics  = tlist.measureText(newText);
	    	var itemWidth:int = metrics.width + H_PADDING;
	    	var itemHeight:int = metrics.height * V_PADDING_FACTOR;
	  	  	if (itemWidth > tlist.columnWidth) tlist.columnWidth = itemWidth;
	    	if (itemHeight > tlist.rowHeight) tlist.rowHeight = itemHeight;
	    }
	    
	    /** Adjust the TileList to fit the size of the remaining items.
	     *  Checks the size for the removed item and if it is the same
	     *  (or bigger) than the existing size, resizes the TileList
	     *  for the remaining items.
	     * 
	     *  Note, this only checks the width, since we assume that the
	     *  height would remain the same.
	     * 
		 *  @param tlist The tile list to adjust.
		 *  @param removedText The string value of the removed item.
		 */		
	    public static function adjustTileSizeForRemovedItem (tlist:TileList, removedText:String):void {
	    	var metrics:TextLineMetrics  = tlist.measureText(removedText);
	    	var itemWidth:int = metrics.width + H_PADDING;
	  	  	if (itemWidth >= tlist.columnWidth) adjustTileSizeToFit(tlist);
	    }	    
	    

	}
}