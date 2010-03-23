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
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../corecomp/Component.ozf'
   Utils       at '../utils/Misc.ozf'
export
   New
define
   
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
