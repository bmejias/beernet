/*-------------------------------------------------------------------------
 *
 * TwoPC-TP.oz
 *
 *    Transaction Participant for the Two-Phase Commit Protocol    
 *
 * LICENSE
 *
 *    Beernet is released under the Beerware License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: (main author)
 *
 *    Contributors: (if any)
 *
 *    Last change: $Revision$ $Author$
 *
 *    $Date$
 *
 * NOTES
 *
 *    Implementation of the classical two-phase commit protocol for replicated
 *    databases. This is one of the replicas of the protocol. Known as the
 *    transaction participant.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Component      at '../../corecomp/Component.ozf'
   Timer          at '../../timer/Timer.ozf'
   Utils          at '../../utils/Misc.ozf'
export
   New
define

   fun {New CallArgs}
      Self
      Listener
      MsgLayer
      NodeRef
      DHTman
      TheTimer

      %% --- Event --

      Events = events(
                     )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      MsgLayer = {NewCell Component.dummy}
      DHTman   = {NewCell Component.dummy}      
      TheTimer = {Timer.new}

      Self
   end
end  

