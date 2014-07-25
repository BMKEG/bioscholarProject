// $Id: KefedLink.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//
package edu.isi.bmkeg.kefed.elements
{
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import mx.utils.UIDUtil;
	

	public class KefedLink extends EdgeSprite
	{
		[Bindable]
		public var uid:String;
		
		public function KefedLink(uid:String=null, source:NodeSprite=null, 
				target:NodeSprite=null, directed:Boolean=true)	{
					
			this.uid = uid;
			super(source, target, directed);
		}
		
		/** Update the UID of this model.
		 *  Also recursively update the uids of all the
		 *  model nodes.
		 */
		public function updateUID():void{ 
			uid = UIDUtil.createUID();
		}
		
	}
	
}