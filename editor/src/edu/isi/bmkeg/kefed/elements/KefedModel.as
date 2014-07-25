// $Id: KefedModel.as 50 2011-06-09 22:55:52Z taruss2000@gmail.com $
//
//  $Date: 2011-06-09 15:55:52 -0700 (Thu, 09 Jun 2011) $
//  $Revision: 50 $
//
package edu.isi.bmkeg.kefed.elements
{
	import com.kapit.diagram.IDiagramElement;
	
	import edu.isi.bmkeg.kefed.ui.kapit.DiagramMappings;
	import edu.isi.bmkeg.utils.DataUtil;
	
	import flare.analytics.graph.LinkDistance;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.utils.UIDUtil;

	/**  KefedModel representation.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-06-09 15:55:52 -0700 (Thu, 09 Jun 2011) $
	 * @version $Revision: 50 $
	 * 
	 *   NOTE: There is a need to also update 
	 *   KefedPersevereInterface.deserializeKefedModel
	 *   for structural changes here.
	 * 
	 */
	public class KefedModel extends Data {

		public var id:String;  // Needed for Persevere store.  Should be handled differently.
		
		/** Version of the model structure.
		 */
		public var kefedVersion:String = "2.0";

		public var diagramXML:XML = new XML("<diagram/>");
		
		[Bindable]
		public var type:String;

		[Bindable]
		public var source:String;
		
		[Bindable]
		public var citeKey:String;
				
		[Bindable]
		public var modelName:String;

		private var _uid:String;

		public function get uid():String{ return _uid; }
		public function set uid(newValue:String):void { _uid = newValue; }

		[Bindable]
		public var description:String;

		[Bindable]
		public var dateTime:String;
		
		[Bindable]
		private var _bNodes:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		private var _bEdges:ArrayCollection = new ArrayCollection();
				
		public function get bNodes():ArrayCollection { return _bNodes; }
		public function get bEdges():ArrayCollection { return _bEdges; }
		
		override public function addNode(d:Object=null):NodeSprite {
			_bNodes.addItem(d);
			return super.addNode(d);	
		}

		override public function addEdge(e:EdgeSprite):EdgeSprite {
			_bEdges.addItem(e);
			return super.addEdge(e);	
		}

		override public function removeNode(n:NodeSprite):Boolean {
			
			var kn:KefedObject = KefedObject(n);
			
			var pos:int = -1; 
			for(var i:int=0; i < this._bNodes.length; i++) {
				var obj:KefedObject = _bNodes[i];
				if (obj.uid == kn.uid) {
					pos = i;
					break;
				}
			}
			
			if( pos != -1 ) {
				_bNodes.removeItemAt(pos);
			} else {
				throw new Error("Can't find node, uid: " + kn.uid );
			}
			
			return super.removeNode(n);	
		
		}

		override public function removeEdge(e:EdgeSprite):Boolean {
			
			var ke:KefedLink = KefedLink(e);
			
			var pos:int = -1; 
			for(var i:int=0; i < this._bNodes.length; i++) {
				var link:KefedLink = _bEdges[i];
				if (link.uid == ke.uid) {
					pos = i;
					break;
				}
			}
			
			if( pos != -1 ) {
				_bEdges.removeItemAt(pos);
			} else {
				throw new Error("Can't find edge, uid: " + ke.uid );
			}
			
			return super.removeEdge(e);	
		
		}

		public function KefedModel(directedEdges:Boolean=true)
		{
			updateTime();
			updateUID();
			this.diagramXML = this.generateEmptyDiagramXML();
			super(directedEdges);
		}
		
		/** Return a top-level clone of this KefedModel.
		 */
		public function clone():KefedModel {
			var clone:KefedModel = new KefedModel(directedEdges);
			// clone.id = id;
			clone.diagramXML = diagramXML;
			clone.type = type;
			clone.source = source;
			clone.citeKey = citeKey;
			clone.modelName = modelName;
			clone.description = description;
			
			for(var i:int = 0; i < bNodes.length; i++) {
				clone.addNode(bNodes[i]);
			}
			for(var j:int = 0; j < bEdges.length; j++) {
				clone.addEdge(bEdges[j]);
			}
			return clone;
		}
	
		public function getKefedObjectFromDiagramElement(el:IDiagramElement):KefedObject {
			return this.getKefedObjectFromUID(el.dataobjectid);
		}
		
		/** Returns the KefedObject in this model that matches
		 *  the supplied uid.
		 * 
		 * @param uid The unique identifier of the desired object
		 * @returns The matching object, or null if none matches.
		 */
		public function getKefedObjectFromUID(uid:String):KefedObject {
			if (uid) {
				for(var i:int=0; i < this.nodes.length; i++) {
					var obj:KefedObject = this.nodes[i];
					if (obj.uid == uid) {
						return obj;								
					}
				}
			}
			return null;
		}
		
		/** Returns the KefedObject in this model that matches
		 *  the supplied name.  Note that this may not be a unique
		 *  match.  If more than one object matches, an arbitrary
		 *  one of them will be returned.
		 * 
		 * @param targetName The name of the desired object
		 * @returns The matching object, or null if none matches.
		 */
		public function getKefedObjectFromName(targetName:String):KefedObject {
			if (targetName) {
				for(var i:int=0; i < this.nodes.length; i++) {
					var obj:KefedObject = this.nodes[i];
					if (obj.nameValue == targetName) {
						return obj;								
					}
				}
			}
			return null;
		}
		
		public function getKefedLinkFromDiagramElement(el:IDiagramElement):KefedLink
		{
			return this.getKefedLinkFromUID(el.dataobjectid);
		}
		
		/** Returns the link object with the given UID.
		 * 
		 * @param uid The uid of the link object
		 * @returns The matching link object
		 */
		public function getKefedLinkFromUID(uid:String):KefedLink {
			if (uid) {
				for(var i:int=0; i < this.edges.length; i++) {
					var obj:KefedLink = this.edges[i];
					if (obj.uid == uid)	{
						return obj;								
					}
				}
			}
			return null;
		}
		
		/** Update the timestamp on this object to be the current time.
		 *  This should be called before saving the model to the
		 *  repository if there have been any changes to it.
		 */
		public function updateTime():void{ 
			this.dateTime = (new Date()).toString(); 
		}

		/** Update the UID of this model.
		 *  Also recursively update the uids of all the
		 *  model nodes.
		 * 
		 * @return the old UID.
		 */
		public function updateUID():String{ 
			var oldId:String = this._uid;
			var uidMap:Object = new Object();
			this._uid = UIDUtil.createUID();
			//  We update each of the component UIDs, and then update
			//  the XML structure for those new UIDs to preserve the
			//  link between diagram elements and model elements.
			for each (var n:KefedObject in _bNodes) {
				var oldObjectId:String = n.updateUID();
				uidMap[oldObjectId] = n.uid;
			}
			DataUtil.updateXmlTagAttributes(diagramXML, "sprite", "dataid", uidMap);
			return oldId;
		}
		
		private function getModelElement(targetId:String):ArrayCollection {
			var vbArray:ArrayCollection = new ArrayCollection();

        	for(var i:int=0; i<this._bNodes.length; i++) {
        		var n:KefedObject = KefedObject( this._bNodes[i] );
			
				if( n.spriteid == targetId) {
		        	vbArray.addItem(n);
		  		}	
        	}       
            return vbArray;
		}
		
		public function getActivities():ArrayCollection {
			return getModelElement(DiagramMappings.ACTIVITY_SPRITE_ID);
		}
		
		public function getExperimentalObjects():ArrayCollection {
			return getModelElement(DiagramMappings.ENTITY_SPRITE_ID);
		}
		
		public function getForks():ArrayCollection {
			return getModelElement(DiagramMappings.FORK_SPRITE_ID);
		}

		public function getBranches():ArrayCollection {
			return getModelElement(DiagramMappings.BRANCH_SPRITE_ID);
		}

		
		public function getParameters():ArrayCollection {
			return getModelElement(DiagramMappings.PARAMETER_SPRITE_ID);
		}
		
		public function getConstants():ArrayCollection {
			return getModelElement(DiagramMappings.CONSTANT_SPRITE_ID);
		}
		
		public function getMeasurements():ArrayCollection {
			return getModelElement(DiagramMappings.MEASUREMENT_SPRITE_ID);
		}
		
		public function getVariables():ArrayCollection {
			var variables:ArrayCollection = getParameters();
			variables.addAll(getConstants());
			variables.addAll(getMeasurements());
			return variables;
		}
		
		private function getVariablesForMeasurement(measurementVariable:KefedObject,
													targetId:String):ArrayCollection {

			var vbArray:ArrayCollection = new ArrayCollection();

            if( !measurementVariable.isMeasurement() ) {
            	return vbArray;
            }	

		    var linkD:LinkDistance = new LinkDistance();
		    linkD.links = NodeSprite.OUT_LINKS;

        	for(var i:int=0; i<this._bNodes.length; i++) {
        		var n:KefedObject = KefedObject( this._bNodes[i] );
			
				if( n.spriteid == targetId) {
		        	linkD.calculate(this, new Array(n));
		        	var depV_dist:Number = measurementVariable.props["distance"];
		  			if( depV_dist < 1e6 ) {		  				
        				vbArray.addItem(n);
        				n.pos = depV_dist;
		  			}
		  		}	
        	}
        	         
			var dataSortField:SortField = new SortField();
           	dataSortField.name = "pos";
			dataSortField.numeric = true;
			dataSortField.descending = true;

            /* Create the Sort object and add the SortField object created earlier 
            to the array of fields to sort on. */
            var numericDataSort:Sort = new Sort();
            numericDataSort.fields = [dataSortField];

            /* Set the ArrayCollection object's sort property to our custom sort, 
            and refresh the ArrayCollection. */
            vbArray.sort = numericDataSort;
            vbArray.refresh();
        	         
            return vbArray;
		}
		
		/** Gets the parameters that the given measurement depends on.
		 * 
		 * @param measurement The measurement variable
		 * @return the parameters that measurement depends on
		 */
		public function getParametersForMeasurement(measurement:KefedObject):ArrayCollection {
		    return getVariablesForMeasurement(measurement, DiagramMappings.PARAMETER_SPRITE_ID);
		}
		
		/** Gets the constants that the given measurement depends on.
		 * 
		 * @param measurement The measurement variable
		 * @return the constants that measurement depends on
		 */	
		 public function getConstantsForMeasurement(measurement:KefedObject):ArrayCollection {
		    return getVariablesForMeasurement(measurement, DiagramMappings.CONSTANT_SPRITE_ID);
		}
		
		/** Gets the variables that the given measurement depends on.  This
		 *  includes both parameters and constants.  Other measurements not
		 *  included.  Constants appear first, followed by parameters.
		 * 
		 * @param measurement The measurement variable
		 * @return the variables that measurement depends on
		 */	
		 public function getDependOnsForMeasurement(measurement:KefedObject):ArrayCollection {
			var dependOns:ArrayCollection = getConstantsForMeasurement(measurement);
			dependOns.addAll(getParametersForMeasurement(measurement));
			return dependOns;
		}
		
        private function generateEmptyDiagramXML():XML {
        	var str:String = "<diagram version=\"0\" width=\"2879\" height=\"2879\" " + 
        			"id=\"" + UIDUtil.createUID() + "\">\n  <columns id=\"" + 
        			UIDUtil.createUID() + "\" multicolumn=\"false\">\n    <column id=\"" + 
        			UIDUtil.createUID() + "\" width=\"2817\" height=\"30\" " + 
        			"title=\"Default column\"/>\n  </columns>\n  <panels id=\"" + 
        			UIDUtil.createUID() + "\" multipanel=\"false\">\n    <panel id=\"" + 
        			UIDUtil.createUID() + "\" height=\"2879\" title=\"Kefed Model\">\n" + 
        			"      <lane id=\"" + UIDUtil.createUID() + "\" height=\"2879\" " +
        			"title=\"Kefed Model\">\n        <links id=\"" + UIDUtil.createUID() + 
        			"\"/>\n        <sprites id=\"" + UIDUtil.createUID() + "\"/>\n        " +
        			"<annotations id=\"" + UIDUtil.createUID() + "\"/>\n      </lane>\n      " + 
        			"<links id=\"" + UIDUtil.createUID() + "\"/>\n      <annotations id=\"" + 
        			UIDUtil.createUID() + "\"/>\n    </panel>\n    <links id=\"" + 
        			UIDUtil.createUID() + "\"/>\n    <annotations id=\"" + UIDUtil.createUID() + 
        			"\"/>\n  </panels>\n</diagram>"
        	return new XML(str);
        }

				
	}

}