/*-------------------------------------------------------------------------
 *
 * DHT.oz
 *
 *    This module provides the basic operations for a distributed hash table:
 *    put, get, delete
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
 *    The basic operations for distributed hash table do not provide any sort
 *    of replication.  For replicated storage use the transactional layer. The
 *    basic operations provided are: put(key, value) - get(key) - delete(key).
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

      proc {Delete Event}
         skip
      end

      proc {Get Event}
         skip
      end

      proc {Put Event}
         put(Key Value) = Event
         HKey  % HashKey for Key
      in
         HKey = {Utils.hash Key}
         {@MsgLayer send(putItem(hash:HKey key:Key value:Value) to:HKey)}
      end

      proc {PutItem Event}
         putItem(hash:HKey key:Key value:Value) = Event
      in
         skip
      end

      proc {SetMsgLayer Event}
         setMsgLayer(AMsgLayer) = Event
      in
         MsgLayer := AMsgLayer
      end

      Events = events(
                     delete:     Delete
                     get:        Get
                     put:        Put
                     putItem:    PutItem
                     setMsgLayer:SetMsgLayer
                     )
   in
      Args = {Utils.addDefaults CallArgs def(maxKey:666)}
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
