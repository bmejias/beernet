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
 *    The basic operations for distributed hash table do not provide any sort
 *    of replication.  For replicated storage use the transactional layer. The
 *    basic operations provided are: put(key, value) - get(key) - delete(key).
 *
 *    It needs a messaging layer to be set. It uses SimpleDB as default
 *    database, it uses a default maxkey but it basically needs one as
 *    argument.
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

      proc {Delete delete(Key)}
         HKey
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(deleteItem(HKey Key tag:dht) to:HKey)}
      end
   
      proc {DeleteItem deleteItem(HKey Key tag:dht)}
         {@DB delete(HKey Key)}
      end

      proc {Get get(Key ?Value)}
         HKey
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(getItem(HKey Key Value tag:dht) to:HKey)}
      end

      proc {GetItem getItem(HKey Key ?Value tag:dht)}
         {@DB get(HKey Key Value)}
      end

      proc {Put put(Key Value)}
         HKey  % HashKey for Key
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(putItem(HKey Key Value tag:dht) to:HKey)}
      end

      proc {PutItem putItem(HKey Key Value tag:dht)}
         {@DB put(HKey Key Value)}
      end

      proc {SetDB setDB(ADataBase)}
         @DB := ADataBase
      end

      proc {SetMaxKey setMaxKey(Int)}
         MaxKey := Int
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
      end

      Events = events(
                     delete:     Delete
                     deleteItem: DeleteItem
                     get:        Get
                     getItem:    GetItem
                     put:        Put
                     putItem:    PutItem
                     setDB:      SetDB
                     setMaxKey:  SetMaxKey
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
