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
 *    This might become a component running on its own thread in the future
 *    when eager retrieving of data upon churn is managed by this component.
 *    Meanwhile it is implemented as a passive object, with the most basic
 *    functionality of providing the set of keys corresponding to symmetric
 *    replication.
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

      Args
      MaxKey   % Maximum key
      Factor   % Replication factor

      proc {GetSymReplicas Event}
         getSymReplicas(Key Keys ...) = Event
         MKey
         F
      in
         MKey = if {HasFeature Event maxKey} then Event.maxKey else @MaxKey end
         F    = if {HasFeature Event factor} then Event.factor else @Factor end
         Keys = {MakeSymReplicas Key MKey F}
      end

      proc {QuickRead quickRead(Key ?Value)}
         skip
      end

      proc {SetFactor setFactor(F)}
         Factor := F
      end

      proc {SetMaxKey setMaxKey(Key)}
         MaxKey := Key
      end

      Events = events(
                     getSymReplicas:GetSymReplicas
                     quickRead:     QuickRead
                     setFactor:     SetFactor
                     setMaxKey:     SetMaxKey
                     )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end

      Args     = {Utils.addDefaults CallArgs def(maxKey:666 repFactor:4)}
      MaxKey   = {NewCell Args.maxKey}
      Factor   = {NewCell Args.repFactor}

      Self 
   end
   
end
