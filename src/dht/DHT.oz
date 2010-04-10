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
 *    This component needs a messaging layer to be set. It uses SimpleDB as
 *    default database, it uses a default maxkey but it basically needs one as
 *    argument.
 *
 *    The basic operations provided for key/value pairs are: put(key, value) -
 *    get(key) - delete(key). The basic operations provided for key/value-sets
 *    are: add(key, value) - remove(key, value) - readSet(key).
 *
 *    SimpleDB is used to store key/value pairs and key/value-sets. The
 *    structure to store key/value pairs is the following: There is a
 *    dictionary to associate each key1 with its own dictionary. The second
 *    dictionary associates key2 to each value.
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
   Utils       at '../utils/Misc.ozf'
   SimpleDB    at 'SimpleDB.ozf'
export
   New
define
   
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

      fun {AddToList L X HX}
         case L
         of Val|MoreValues then
            if HX < Val.hash then
               v(value:X hash:HX)|L
            elseif X == Val.value then
               L
            else
               Val|{AddToList MoreValues X HX}
            end
         [] nil then
            [v(value:X hash:HX)]
         end
      end

      fun {RemoveFromList L X HX}
         case L
         of Val|MoreValues then
            if X == Val.value then
               MoreValues
            elseif HX < Val.hash then
               L
            else
               Val|{RemoveFromList MoreValues X HX}
            end
         [] nil then
            nil
         end
      end

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

      proc {HandlePair ClientVar Val}
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
         if Val == SimpleDB.noValue orelse Val == nil then
            ClientVar = empty
         else
            Elements = {GetValues Val}
            ClientVar= {List.toTuple set Elements}
         end
      end

      ValueHandle = handles(pair:HandlePair set:HandleSet)

      %% === Events =========================================================

      %% --- Key/Value pairs API for applications ---------------------------
      proc {Delete delete(Key)}
         HKey
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(deleteItem(HKey Key tag:dht) to:HKey)}
      end
   
      proc {Get get(Key ?Val)}
         {SendNeedItem Key Val pair}
      end

      proc {Put put(Key Val)}
         HKey
      in
         HKey = {Utils.hash Key @MaxKey}
         {@MsgLayer send(putItem(HKey Key Val tag:dht) to:HKey)}
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

      proc {DeleteItem deleteItem(HKey Key tag:dht)}
         {@DB delete(HKey Key)}
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
         putItem(HKey Key Val ...) = Event
      in
         {@DB put(HKey Key Val)}
      end

      proc {AddToSet addToSet(HKey Key Val tag:dht)}
         Set
         HVal
      in
         Set   = {@DB get(HKey Key $)}
         HVal  = {Utils.hash Val @MaxKey}
         if Set == SimpleDB.noValue then
            {@DB put(HKey Key [v(value:Val hash:HVal)])}
         else
            {@DB put(HKey Key {AddToList Set Val HVal})}
         end
      end

      proc {RemoveFromSet removeFromSet(HKey Key Val tag:dht)}
         Set
         HVal
      in
         Set   = {@DB get(HKey Key $)}
         HVal  = {Utils.hash Val @MaxKey}
         if Set \= SimpleDB.noValue then
            {@DB put(HKey Key {RemoveFromList Set Val HVal})}
         end
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
                     deleteItem:    DeleteItem
                     getItem:       GetItem
                     needItem:      NeedItem
                     needItemBack:  NeedItemBack
                     putItem:       PutItem
                     removeFromSet: RemoveFromSet
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

      Args     = {Utils.addDefaults CallArgs def(maxKey:666 db:{SimpleDB.new})}
      DB       = {NewCell Args.db}
      MaxKey   = {NewCell Args.maxKey}
      Gvars    = {Dictionary.new}
      Gid      = {NewCell 0}
      NodeRef  = {NewCell noref}

      Self
   end

end
