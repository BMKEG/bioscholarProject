// $Id: KefedBaseValueTemplate.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
//
//  $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
//  $Revision: 38 $
//

package edu.isi.bmkeg.kefed.elements
{
	
	import mx.collections.ArrayCollection;
	
	/**  Template for describing the constraints and descriptions for
	 *   a Kefed variable's simple value, or for the value of a
	 *   field in a table variable.
	 * 
	 * @author University of Southern California
	 * @date $Date: 2011-03-17 22:41:28 -0700 (Thu, 17 Mar 2011) $
	 * @version $Revision: 38 $
	 * 
	 */
	public class KefedBaseValueTemplate
	{
		public static const DEFAULT_VALUE_TYPE:String = "Text";
		// Is this really used?
		[Bindable]
		public var nameValue:String = "";
		
		/** The name of the type represented by this template.
		 * 
		 *  By doing the dispatch here, we can switch easily 
		 *  between types while keeping all of the information
		 *  from other type choices around, so a switch back 
		 *  doesn't lose any information.
		 */
		[Bindable]
		public var valueTypeName:String = DEFAULT_VALUE_TYPE;	
		
		/** Collection of strings that identify the values that
		 *  can be provided for a variable.  These get interpreted
		 *  relative to the type of value this is.  They can be
		 *  numeric, arbitrary strings or the names of terms.
		 */
		[Bindable]
		public var allowedValues:ArrayCollection = new ArrayCollection();
		
		/** Lookup function that maps term names into term objects
		 *  in the underlying logic (usually PowerLoom).  The values
		 *  of term types are either the names of terms or a string
		 *  that can be mapped into the term name by using an appropriate
		 *  (logical) function that returns the term name.
		 * 
		 *  If this is null or the empty string, then the value of
		 *  the variable is the term name itself.
		 */
		[Bindable]
		public var termLookupFunction:String = "";
		
		/** Minimum value that can be taken on.  Applies to numeric
		 *  values and values with units.  In the units case, it must
		 *  be specified with the unit.
		 */
		[Bindable]
		public var minimumValue:String = "";
		
		/** Maximum value that can be taken on.  Applies to numeric
		 *  values and values with units.   In the units case, it must
		 *  be specified with the unit.
		 */
		[Bindable]
		public var maximumValue:String = "";
		
		/** Flag which indicates that the values in the allowedValues
		 *  are considered an ordered set.  This should only be true
		 *  if all of the values are specified (in other words, 
		 *  allowOtherValues is false).
		 */
		[Bindable]
		public var orderedValues:Boolean = false;
		
		/** List of the units that are allowed for this value.  Applies
		 *  to decimal with units type.
		 */
		[Bindable]
		public var allowedUnits:ArrayCollection = new ArrayCollection();
		
		/** List of patterns that are allowed for image and file values.
		 *  This is used when the image and file values will be the names
		 *  of the files.  The intent is to allow for wildcard values such
		 *  as "*.jpeg" or "*.zip"
		 */
		[Bindable]
		public var allowedPatterns:ArrayCollection = new ArrayCollection();

		/** Flag that indicates that additional values besides those
		 *  in the allowedValues list can be entered for this variable.
		 *  Should be false if the collection of values is ordered.
		 */
		[Bindable]
		public var allowFreeValueInput:Boolean = true;
		
		/** Flag that indicates that additional units besides those
		 *  in the allowedUnits list can be entered for this variable.
		 */
		[Bindable]
		public var allowFreeUnitInput:Boolean = true;
		
		/** Flag that indicates that filenames do not have to conform
		 *  to the patterns in the allowedPatterns list.
		 */
		[Bindable]
		public var allowFreePatternInput:Boolean = true;

	}
}