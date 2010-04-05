/*-------------------------------------------------------------------------
 *
 * Paxos-TM.oz
 *
 *    Transaction Manager for the Paxos Consensus Algorithm    
 *
 * LICENSE
 *
 *    Beernet is released under the Beerware License (see file LICENSE) 
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
 *    Implementation of Leader (TM) and replicated transaction managers (rTMs)
 *    for the Paxos Consensus algorithm protocol. The main difference with
 *    Two-Phase commit is that Paxos has a set of rTMs for resilience, and it
 *    does not need to work with all TPs, but only with the majority.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Component      at '../corecomp/Component.ozf'
   Timer          at '../timer/Timer.ozf'
   Utils          at '../utils/Misc.ozf'
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

