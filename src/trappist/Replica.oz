/*-------------------------------------------------------------------------
 *
 * Replica.oz
 *
 *    This module provides operations for symmetric replication on circular
 *    address spaces.
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
 *    This is basically the implementation of 'bulk' operations to multicast
 *    messages to a replica set on a ring.
 *
 *    TODO: Implement an eager retrieving of data upon join or failure recovery
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
   fun {GetSymReplicas Key Max Factor}
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
      HashKey|{GetLoop Factor - 1 HashKey}
   end

   fun {New CallArgs}
      Self
      Listener
      MsgLayer

      Args
      MaxKey

      proc {Bulk bulk(Key Msg)}
         skip
      end
   
      Events = events(
                     bulk:       Bulk
                     )
   in
      Args = {Utils.addDefaults CallArgs def(maxKey:666 repFactor:4)}
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      MsgLayer = {NewCell Component.dummy}
      MaxKey   = {NewCell Args.maxKey}
      Self
   end

end
