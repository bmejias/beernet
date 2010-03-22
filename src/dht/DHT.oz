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
   SimpleDB    at 'SimpleDB.ozf'
export
   New
define
   
   fun {New CallArgs}
      Self
      Listener
      MsgLayer

      Args
      MaxKey
      DB

      proc {Delete Event}
         skip
      end

      proc {Get get(Key ?Value)}
         HKey
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(getItem(hash:HKey key:Key value:Value) to:HKey)}
      end

      proc {GetItem getItem(hash:HKey key:Key value:?Value)}
         Item
      in
         {@DB get(HKey Key Item)}
         Value = Item.value
      end

      proc {Put put(Key Value)}
         HKey  % HashKey for Key
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(putItem(hash:HKey key:Key value:Value) to:HKey)}
      end

      proc {PutItem putItem(hash:HKey key:Key value:Value)}
         {@DB put(HKey Key Value)}
      end

      proc {SetDB setDB(ADataBase)}
         @DB := ADataBase
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
      end

      Events = events(
                     delete:     Delete
                     get:        Get
                     getItem:    GetItem
                     put:        Put
                     putItem:    PutItem
                     setDB:      SetDB
                     setMsgLayer:SetMsgLayer
                     )
   in
      Args = {Utils.addDefaults CallArgs def(maxKey:666 db:{SimpleDB.new})}
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      MsgLayer = {NewCell Component.dummy}
      DB       = {NewCell Args.db}
      MaxKey   = {NewCell Args.maxKey}
      Self
   end

end
