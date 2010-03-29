/*-------------------------------------------------------------------------
 *
 * Replica.oz
 *
 *    This module provides operations for symmetric replication on circular
 *    address spaces.
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
 *    Pre-condition: It needs a messaging layer to be set.
 *
 *    Bulk: bulk operations send a message to all peers in the replica set.
 *    
 *    Quick Red: it bulks a read message, and returns the first answer.
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../corecomp/Component.ozf'
   Utils       at '../utils/Misc.ozf'
export
   New
define
  
   %% Returns a list of 'f' hash keys symmetrically replicated whithin the
   %address space, from 0 to Max. 'f' is the replication Factor. The list
   %starts with the input Key. 
   fun {MakeSymReplicas Key Max Factor}
      Increment = Max div Factor
      fun {GetLoop Iter Last}
         if Iter > 0 then
            New = ((Last + Increment) mod Max)
         in
            New|{GetLoop Iter - 1 New}
         else
            nil
         end
      end
      HashKey
   in
      HashKey = {Utils.hash Key Max}
      HashKey|{GetLoop Factor-1 HashKey}
   end

   fun {New CallArgs}
      Self
      Listener
      MsgLayer
      NodeRef

      Args
      MaxKey   % Maximum key
      Factor   % Replication factor

      proc {Bulk Event}
         skip
      end

      proc {GetReplicaKeys Event}
         getReplicaKeys(Key Keys ...) = Event
         MKey
         F
      in
         MKey = if {HasFeature Event maxKey} then Event.maxKey else @MaxKey end
         F    = if {HasFeature Event factor} then Event.factor else @Factor end
         Keys = {MakeSymReplicas Key MKey F}
      end

      proc {QuickRead quickRead(Key ?Value)}
         {Bulk bulk}
      end

      proc {SetFactor setFactor(F)}
         Factor := F
      end

      proc {SetMaxKey setMaxKey(Key)}
         MaxKey := Key
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
         NodeRef  := {@MsgLayer getRef($)}
      end

      Events = events(
                     bulk:          Bulk
                     getReplicaKeys:GetReplicaKeys
                     quickRead:     QuickRead
                     setFactor:     SetFactor
                     setMaxKey:     SetMaxKey
                     setMsgLayer:   SetMsgLayer
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

      Args     = {Utils.addDefaults CallArgs def(maxKey:666 repFactor:4)}
      MaxKey   = {NewCell Args.maxKey}
      Factor   = {NewCell Args.repFactor}
      NodeRef  = {NewCell noref}

      Self 
   end
   
end
