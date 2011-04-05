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
 *    of replication.  For replicated storage use the transactional layer.
 *
 *    This component needs a messaging layer to be set. It uses SimpleSDB as
 *    default database, it uses a default maxkey but it basically needs one as
 *    argument.
 *
 *    The basic operations provided for key/value pairs are: put(key value
 *    secret) - get(key) - delete(key secret). The basic operations provided
 *    for key/value-sets are: add(key secret value valuesecret) - remove(key
 *    secret value valuesecret) - readSet(key).
 *
 *    SimpleSDB is used to store key/value pairs and key/value-sets. Both data
 *    storage are protected with secrets. The structure to store key/value
 *    pairs is the following: There is a dictionary to associate each key1 with
 *    its own dictionary. The second dictionary associates key2 to each value.
 *
 *    The structure to store key/value-sets is the following: As with key/value
 *    pairs, the global dictionary for key1 is used. The second dictionary
 *    instead of associating key2 to value, it associates key2 to a record of
 *    the form:
 *
 *       set(add:Dcitionary remove:Dictionary)
 *
 *    Each of these dictionaries associates a value to its operation id (opid).
 *    The key of the dictionary corresponds to a hash key for the value. The
 *    dictionary value is a tuple containing the stored value together with the
 *    opid.
 *
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../corecomp/Component.ozf'
   Constants   at '../commons/Constants.ozf'
   HashedList  at '../utils/HashedList.ozf'
   Utils       at '../utils/Misc.ozf'
   SimpleSDB    at 'SimpleSDB.ozf'
export
   New
define

   NO_ACK      = Constants.noAck
   NO_SECRET   = Constants.noSecret
   NO_VALUE    = Constants.noValue

   fun {New CallArgs}
      Self
      %Listener
      MsgLayer

      Args
      DB
      Gvars
      Gid
      MaxKey
      NodeRef

      %% === Auxiliar functions =============================================

      fun {NextGid}
         OldGid NewGid
      in
         OldGid = Gid := NewGid
         NewGid = OldGid + 1
         NewGid
      end

      proc {SendNeedItem Key Val Type}
         HKey
         NewGid
      in
         HKey     = {Utils.hash Key @MaxKey}
         NewGid   = {NextGid}
         Gvars.NewGid := data(var:Val type:Type)
         {@MsgLayer send(to:HKey
                         needItem(HKey Key src:@NodeRef gid:NewGid tag:dht))}
      end

      proc {SendSetOperation Key Val Op}
         HKey
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(Op(HKey Key Val tag:dht) to:HKey)}
      end


      %% --- Handling NeedItem back replies ---------------------------------

      proc {HandleBind ClientVar Val}
         ClientVar = Val
      end

      proc {HandleSet ClientVar Val}
         fun {GetValues L}
            case L
            of H|T then
               H.value|{GetValues T}
            [] nil then
               nil
            end
         end
         Elements
      in
         if Val == NO_VALUE then
            ClientVar = Val
         elseif Val.ops == nil then
            ClientVar = empty
         else
            Elements = {GetValues Val.ops}
            ClientVar= {List.toTuple set Elements}
         end
      end

      ValueHandle = handles(pair:HandleBind set:HandleSet bind:HandleBind)

      %% === Events =========================================================

      %% --- Key/Value pairs API for applications ---------------------------
      proc {Delete delete(k:Key s:Secret r:Result)}
         HKey NewGid
      in
         HKey = {Utils.hash Key @MaxKey}
         NewGid   = {NextGid}
         Gvars.NewGid := data(var:Result type:bind)
         {@MsgLayer send(deleteItem(hk:HKey
                                    k:Key
                                    s:Secret
                                    src:@NodeRef
                                    gid:NewGid
                                    tag:dht) to:HKey)}
      end
   
      proc {Get get(k:Key v:?Val)}
         {SendNeedItem Key Val pair}
      end

      proc {Put put(s:Secret k:Key v:Val r:Result)}
         HKey NewGid
      in
         HKey     = {Utils.hash Key @MaxKey}
         NewGid   = {NextGid}
         Gvars.NewGid := data(var:Result type:bind)
         {@MsgLayer send(putItem(hk:HKey
                                 k:Key
                                 v:Val
                                 s:Secret
                                 src:@NodeRef
                                 gid:NewGid
                                 tag:dht) to:HKey)}
      end

      %% --- Key/Value-Set API for applications -----------------------------

      proc {Add add(Key Val)}
         {SendSetOperation Key Val addToSet}
      end 

      proc {Remove remove(Key Val)}
         {SendSetOperation Key Val removeFromSet}
      end

      proc {ReadSet readSet(Key ?Val)}
         {SendNeedItem Key Val set}
      end

      %% --- Events used by system protocols --------------------------------

      %% To be used locally, within the peer. (it binds a variable)
      proc {GetItem getItem(HKey Key ?Val)}
         {@DB get(HKey Key Val)}
      end

      proc {DeleteItem Event}
         deleteItem(hk:HKey k:Key s:Secret gid:Gid src:Src tag:dht) = Event
         Result
      in
         {@DB delete(HKey Key Secret Result)}
         {@MsgLayer dsend(to:Src bindResult(gid:Gid r:Result tag:dht))}
      end

      proc {NeedItem needItem(HKey Key src:Src gid:AGid tag:dht)}
         Val
      in
         {GetItem getItem(HKey Key Val)}
         {@MsgLayer dsend(to:Src needItemBack(gid:AGid value:Val tag:dht))}
      end

      proc {NeedItemBack needItemBack(gid:AGid value:Val tag:dht)}
         Gdata
      in
         Gdata = {Dictionary.condGet Gvars AGid data(var:_ type:pair)}
         {ValueHandle.(Gdata.type) Gdata.var Val}
         {Dictionary.remove Gvars AGid}
      end

      proc {PutItem Event}
         putItem(hk:HKey k:Key v:Val s:Secret gid:Gid src:Src ...) = Event
         Result
      in
         {@DB put(HKey Key Val Secret Result)}
         if Gid \= NO_ACK then
            {@MsgLayer dsend(to:Src bindResult(gid:Gid r:Result tag:dht))}
         end
      end

      proc {BindResult bindResult(gid:Gid r:Result tag:dht)}
         Gdata
      in
         Gdata = {Dictionary.condGet Gvars Gid data(var:_ type:bind)}
         {ValueHandle.(Gdata.type) Gdata.var Result}
         {Dictionary.remove Gvars Gid}
      end

      %% WARNING: Creation of set with silent failure
      proc {CreateSet Event}
         createSet(hk:HKey k:Key s:Secret ms:MasterSecret ...) = Event
      in
         if {@DB get(HKey Key $)} == NO_VALUE then
            {@DB put(HKey Key set(s:Secret ops:nil) MasterSecret _)}
         end   
      end

      %% WARNING: Destruction of set with silent failure
      proc {DestroySet Event}
         destroySet(hk:HKey k:Key ms:MasterSecret ...) = Event
      in
         case {@DB get(HKey Key $)}
         of set(s:_ ops:_) then
            {@DB delete(HKey Key MasterSecret _)}
         end   
      end

      proc {AddToSet Event}
         addToSet(hk:HKey k:Key s:Secret v:Val ...) = Event
         Set
         HVal
      in
         Set   = {@DB get(HKey Key $)}
         HVal  = {Utils.hash Val @MaxKey}
         if Set == NO_VALUE then
            {CreateSet createSet(hk:HKey k:Key s:Secret ms:NO_SECRET)}
            {AddToSet Event}
         else
            if Set.s == Secret then
               {@DB put(HKey 
                        Key
                        set(ops:{HashedList.add Set.ops Val HVal} s:Set.s)
                        NO_SECRET
                        _)}
            end
         end
      end

      proc {RemoveFromSet Event}
         removeFromSet(hk:HKey k:Key s:Secret v:Val ...) = Event
         Set
         HVal
      in
         Set   = {@DB get(HKey Key $)}
         HVal  = {Utils.hash Val @MaxKey}
         if Set \= NO_VALUE andthen Set.s == Secret then
            {@DB put(HKey
                     Key
                     sets(ops:{HashedList.remove Set.ops Val HVal} s:Set.s)
                     NO_SECRET
                     _)}
         end
      end

      proc {ReadLocalSet readLocalSet(HKey Key Val)}
         Set
      in
         Set = {GetItem getItem(HKey Key $)}
         {ValueHandle.set Val Set}
      end

      %% --- Component Setters ----------------------------------------------
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
                     %% Key/Value pairs
                     delete:        Delete
                     get:           Get
                     put:           Put
                     %% Key/Value-Sets
                     add:           Add
                     remove:        Remove
                     readSet:       ReadSet
                     %% System protocols
                     addToSet:      AddToSet
                     bindResult:    BindResult
                     createSet:     CreateSet
                     deleteItem:    DeleteItem
                     destroySet:    DestroySet
                     getItem:       GetItem
                     needItem:      NeedItem
                     needItemBack:  NeedItemBack
                     putItem:       PutItem
                     removeFromSet: RemoveFromSet
                     readLocalSet:  ReadLocalSet
                     %% Setters
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
         %Listener = FullComponent.listener
      end
      MsgLayer = {NewCell Component.dummy}

      Args     = {Utils.addDefaults CallArgs def(maxKey:666 db:{SimpleSDB.new})}
      DB       = {NewCell Args.db}
      MaxKey   = {NewCell Args.maxKey}
      Gvars    = {Dictionary.new}
      Gid      = {NewCell 0}
      NodeRef  = {NewCell noref}

      Self
   end

end
