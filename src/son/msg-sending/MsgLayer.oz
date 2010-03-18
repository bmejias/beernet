/*-------------------------------------------------------------------------
 *
 * MsgLayer.oz
 *
 *    Messaging layer that uses any ring-based node to perform reliable message
 *    sending routing through the overlay network.
 *
 * LICENSE
 *
 *    Copyright (c) 2010 Universite catholique de Louvain
 *
 *    Beernet is released under the MIT License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: Boriss Mejias <boriss.mejias@uclouvain.be>
 *
 *    Last change: $Revision$ $Author$
 *
 *    $Date$
 *
 * NOTES
 *      
 *    No detailed information needed. The abstract is quite clear
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../../corecomp/Component.ozf'
export
   New
define
   
   fun {New Args}
      Self
      Listener
      Node

      proc {Send Event}
         send(msg:Msg to:Target ...) = Event

      Events = events(
                     send:    Send
                     setNode: SetNode
                     )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      Self
   end

end
