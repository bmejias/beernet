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
 *    Quick Red: it bulks a read message, and returns the first answer.
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

      %% --- Events ---

      proc {Bulk bulk(Msg to:Key)}
         RepKeys
      in
         RepKeys = {MakeSymReplicas Key @MaxKey @Factor}
         for K in RepKeys do
            {@MsgLayer send({Record.adjoinAt Msg hkey K} to:K)}
         end
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

      proc {QuickRead quickRead(Key ?Val)}
         NewGid
      in
         NewGid   = {NextGid}
         Gvars.NewGid := var(variable:Val tries:0 state:waiting)
         {Bulk bulk(read(Key id:NewGid src:@NodeRef tag:symrep) to:Key)}
         {TheTimer startTrigger(@Timeout timeout(NewGid) Self)}
      end

      proc {Read read(Key id:Gid src:Src hkey:HKey tag:symrep)}
         Val
      in
         {@DHTman getItem(HKey Key Val)}
         {@MsgLayer dsend(to:Src readBack(value:Val gid:Gid tag:symrep))}
      end

      proc {ReadBack readBack(gid:AGid value:Val tag:symrep)}
         Gvar
      in
         Gvar = {Dictionary.condGet Gvars AGid var(state:gone)}
         if Gvar.state == waiting then
            if {Value.isFailed Val} then
               Tries = Gvar.tries+1
            in
               if Tries == @Factor then
                  Gvar.variable = Val
                  {Dictionary.remove Gvars AGid}
               else
                  Gvars.AGid := {Record.adjoinAt Gvar tries Tries}
               end
            else
               Gvar.variable = Val
               {Dictionary.remove Gvars AGid}
            end
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
         Gvar = {Dictionary.condGet Gvars AGid var(variable:_)}
         Gvar.variable = {Value.failed error('NOT FOUND')}
         {Dictionary.remove Gvars AGid}
      end

      Events = events(
                     bulk:          Bulk
                     getReplicaKeys:GetReplicaKeys
                     quickRead:     QuickRead
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
                                                 timeout:   1000)}
      MaxKey   = {NewCell Args.maxKey}
      Factor   = {NewCell Args.repFactor}
      Timeout  = {NewCell Args.timeout}

      Gvars    = {Dictionary.new}
      Gid      = {NewCell 0}
      NodeRef  = {NewCell noref}

      Self 
   end
   
end
