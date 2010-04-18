/*-------------------------------------------------------------------------
 *
 * SymmetricReplication.oz
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
 *    Pre-condition: It needs a messaging layer, the DHT component, and the
 *    Node Reference
 *
 *    Bulk: bulk operations send a message to all peers in the replica set.
 *    
 *    Get One: it bulks a read message, and returns the first answer.
 *
 *    Read All: Returns a list of items from all participants
 *
 *    Read Majority: Returns a list of items from a mojority
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../corecomp/Component.ozf'
   Timer       at '../timer/Timer.ozf'
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
      %Listener
      MsgLayer
      NodeRef
      DHTman
      TheTimer

      Args
      MaxKey   % Maximum key
      Factor   % Replication factor
      Gvars
      Gid
      Timeout

      fun {NextGid}
         OldGid NewGid
      in
         OldGid = Gid := NewGid
         NewGid = OldGid + 1
         NewGid
      end

      proc {RegisterRead Key Val Type GetType}
         NewGid
      in
         NewGid   = {NextGid}
         Gvars.NewGid := data(var:Val tries:0 state:waiting type:Type)
         {Bulk bulk(to:Key
                    read(Key id:NewGid src:@NodeRef get:GetType tag:symrep))}
         {TheTimer startTrigger(@Timeout timeout(NewGid) Self)}
      end

      proc {HandleOne AGid Val Gvar}
         Tries = Gvar.tries+1
      in
         if Val \= 'NOT_FOUND' orelse Tries == @Factor then
            Gvar.var = Val
            {Dictionary.remove Gvars AGid}
         else
            Gvars.AGid := {Record.adjoinAt Gvar tries Tries}
         end
      end

      proc {HandleList AGid Val Gvar Max}
         Tries = Gvar.tries+1
      in
         if Tries == Max then
            if Val == 'NOT_FOUND' then
               Gvar.var = nil
            else
               Gvar.var = Val|nil
            end
            {Dictionary.remove Gvars AGid}
         else
            if Val == 'NOT_FOUND' then
               Gvars.AGid := {Record.adjoin Gvar data(tries:Tries)}
            else
               NewTail
            in
               Gvar.var = Val|NewTail
               Gvars.AGid := {Record.adjoin Gvar data(tries:Tries var:NewTail)}
            end
         end
      end

      proc {HandleAll AGid Val Gvar}
         {HandleList AGid Val Gvar @Factor}
      end

      proc {HandleMajor AGid Val Gvar}
         {HandleList AGid Val Gvar (@Factor div 2 + 1)}
      end

      ReadHandles = handles(first:  HandleOne
                            all:    HandleAll
                            major:  HandleMajor)

      %% --- Events ---

      proc {Bulk bulk(Msg to:Key)}
         RepKeys
      in
         RepKeys = {MakeSymReplicas Key @MaxKey @Factor}
         for K in RepKeys do
            {@MsgLayer send({Record.adjoinAt Msg hkey K} to:K)}
         end
      end

      proc {GetFactor getFactor(F)}
         F = @Factor
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

      proc {GetOne getOne(Key ?Val)}
         {RegisterRead Key Val first getItem}
      end

      proc {GetAll getAll(Key ?Vals)}
         {RegisterRead Key Vals all getItem}
      end

      proc {GetMajority getMajority(Key ?Vals)}
         {RegisterRead Key Vals major getItem}
      end

      proc {GetOneSet getOneSet(Key ?Val)}
         {RegisterRead Key Val first readLocalSet}
      end

      proc {GetMajoritySet getMajoritySet(Key ?Vals)}
         {RegisterRead Key Vals major readLocalSet}
      end

      proc {Read read(Key id:Gid src:Src hkey:HKey get:GetType tag:symrep)}
         Val
      in
         {@DHTman GetType(HKey Key Val)}
         {@MsgLayer dsend(to:Src readBack(value:Val gid:Gid tag:symrep))}
      end

      proc {ReadBack readBack(gid:AGid value:Val tag:symrep)}
         Gvar
      in
         Gvar = {Dictionary.condGet Gvars AGid var(state:gone)}
         if Gvar.state == waiting then
            {ReadHandles.(Gvar.type) AGid Val Gvar}
         end
      end

      proc {SetDHT setDHT(DHTcomponent)}
         DHTman := DHTcomponent
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

      proc {SetTimeout setTimeout(ATime)}
         Timeout := ATime
      end

      proc {TimeoutEvent timeout(AGid)}
         Gvar
      in
         Gvar = {Dictionary.condGet Gvars AGid var(var:_)}
         Gvar.var = 'NOT_FOUND'
         {Dictionary.remove Gvars AGid}
      end

      Events = events(
                     bulk:          Bulk
                     getOne:        GetOne
                     getAll:        GetAll
                     getFactor:     GetFactor
                     getMajority:   GetMajority
                     getReplicaKeys:GetReplicaKeys
                     getOneSet:     GetOneSet
                     getMajoritySet:GetMajoritySet
                     read:          Read
                     readBack:      ReadBack
                     setDHT:        SetDHT
                     setFactor:     SetFactor
                     setMaxKey:     SetMaxKey
                     setMsgLayer:   SetMsgLayer
                     setTimeout:    SetTimeout
                     timeout:       TimeoutEvent
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
      DHTman   = {NewCell Component.dummy}      
      TheTimer = {Timer.new}

      Args     = {Utils.addDefaults CallArgs def(maxKey:    666
                                                 repFactor: 4
                                                 timeout:   7000)}
      MaxKey   = {NewCell Args.maxKey}
      Factor   = {NewCell Args.repFactor}
      Timeout  = {NewCell Args.timeout}

      Gvars    = {Dictionary.new}
      Gid      = {NewCell 0}
      NodeRef  = {NewCell noref}

      Self 
   end
   
end
