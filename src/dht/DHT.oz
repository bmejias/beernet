/*-------------------------------------------------------------------------
 *
 * DHT.oz
 *
 *    This module provides the basic operations for a distributed hash table:
 *    put, get, delete
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
   System
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
      DB
      Gvars
      Gid
      MaxKey
      NodeRef

      fun {NextGid}
         OldGid NewGid
      in
         OldGid = Gid := NewGid
         NewGid = OldGid + 1
         NewGid
      end

      proc {Delete delete(Key)}
         HKey
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(deleteItem(HKey Key tag:dht) to:HKey)}
      end
   
      proc {DeleteItem deleteItem(HKey Key tag:dht)}
         {@DB delete(HKey Key)}
      end

      proc {Get get(Key ?Val)}
         HKey
         NewGid
      in
         HKey     = {Utils.hash Key @MaxKey}
         NewGid   = {NextGid}
         Gvars.NewGid := Val
         {@MsgLayer send(needItem(HKey Key src:@NodeRef gid:NewGid tag:dht)
                         to:HKey)}
      end

      %% To be used locally, within the peer. (it binds a variable)
      proc {GetItem getItem(HKey Key ?Val)}
         {@DB get(HKey Key Val)}
      end

      proc {NeedItem needItem(HKey Key src:Src gid:AGid tag:dht)}
         Val
      in
         {GetItem getItem(HKey Key Val)}
         {@MsgLayer dsend(to:Src needItemBack(gid:AGid value:Val tag:dht))}
      end

      proc {NeedItemBack needItemBack(gid:AGid value:Val tag:dht)}
         GVal
      in
         %{System.show 'got the value back'#Val#'for gid'#AGid}
         GVal = {Dictionary.condGet Gvars AGid _}
         GVal = Val
         {Dictionary.remove Gvars AGid}
      end

      proc {Put put(Key Val)}
         HKey  % HashKey for Key
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(putItem(HKey Key Val tag:dht) to:HKey)}
      end

      proc {PutItem putItem(HKey Key Val tag:dht)}
         {@DB put(HKey Key Val)}
      end

      proc {SetDB setDB(ADataBase)}
         @DB := ADataBase
      end

      proc {SetMaxKey setMaxKey(Int)}
         MaxKey := Int
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
         NodeRef  := {@MsgLayer getRef($)}
      end

      Events = events(
                     delete:        Delete
                     deleteItem:    DeleteItem
                     get:           Get
                     getItem:       GetItem
                     needItem:      NeedItem
                     needItemBack:  NeedItemBack
                     put:           Put
                     putItem:       PutItem
                     setDB:         SetDB
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

      Args     = {Utils.addDefaults CallArgs def(maxKey:666 db:{SimpleDB.new})}
      DB       = {NewCell Args.db}
      MaxKey   = {NewCell Args.maxKey}
      Gvars    = {Dictionary.new}
      Gid      = {NewCell 0}
      NodeRef  = {NewCell noref}

      Self
   end

end
