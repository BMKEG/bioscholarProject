// $Id: BindingDebugger.as 38 2011-03-18 05:41:28Z taruss2000@gmail.com $
package edu.isi.bmkeg.utils {
	// Attributed to Cahtal Golden.
	// From http://dodgybits.org/2009/04/12/flex-data-binding-pitfalls/
	//
	//  Usage:  Include  BindingDebugger.debugComponent(this);
	//
	
  import mx.binding.BindingManager;
  import mx.binding.IBindingClient;
  import mx.core.UIComponent;
  import mx.core.mx_internal;
 
  use namespace mx_internal;
 
  // Kudos to Cathal Golden for coming up with this technique
  public class BindingDebugger {
 
    private static const BINDINGS_PROPERTY:String = "_bindingsByDestination";

    public static function debugComponent (displayObject:Object, recursive:Boolean = true):void {
      if (displayObject is IBindingClient) {
        var bindings:Object = displayObject[ BINDINGS_PROPERTY ];
        for (var binding:String in bindings ) {
          BindingManager.debugBinding(binding);
        }
      }
 
      if (recursive && displayObject is UIComponent) {
        var component : UIComponent = UIComponent( displayObject );
        for (var i:int = 0; i < component.numChildren; i++) {
          debugComponent(component.getChildAt(i), true);
        }
      }
    }
  }
}