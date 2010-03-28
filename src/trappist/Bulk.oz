/*-------------------------------------------------------------------------
 *
 * Bulk.oz
 *
 *    This component multicast message to a replica set.
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
 *    This is basically the implementation of 'bulk' operations to multicast
 *    messages to a replica set on a ring. The replica set is determined by
 *    another component. That means that this component runs independent of the
 *    replication strategy
 *
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../corecomp/Component.ozf'
   ReplicaMan  at 'Replica.ozf'
   Utils       at '../utils/Misc.ozf'
export
   New
define
   
   fun {New CallArgs}
      Self
      Listener
      MsgLayer
      Replica

      NodeRef

      proc {Bulk bulk(Key Msg)}
         skip
      end

      proc {SetRef setRef(ARef)}
         NodeRef := ARef
      end

      Events = events(
                     bulk:       Bulk
                     setRef:     SetRef
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
      NodeRef  = {NewCell noref}
      Self
   end

end
