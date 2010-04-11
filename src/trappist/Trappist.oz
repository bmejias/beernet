/*-------------------------------------------------------------------------
 *
 * Trappist.oz
 *
 *    Interface to the different strategies for transactional storage
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
 *    Pre-condition: It needs a messaging layer, the DHT component, a
 *    replication manager and the Node Reference
 *
 *-------------------------------------------------------------------------
 */

functor
import
   System
   Component      at '../corecomp/Component.ozf'
   EagerPaxosTM   at 'eagerpaxos/EagerPaxos-TM.ozf'
   EagerPaxosTP   at 'eagerpaxos/EagerPaxos-TP.ozf'
   PaxosTM        at 'paxos/Paxos-TM.ozf'
   PaxosTP        at 'paxos/Paxos-TP.ozf'
   TwoPhaseTM     at 'twophase/TwoPhase-TM.ozf'
   TwoPhaseTP     at 'twophase/TwoPhase-TP.ozf'
   ValueSetTM     at 'valueset/ValueSet-TM.ozf'
   ValueSetTP     at 'valueset/ValueSet-TP.ozf'
export
   New
define

   fun {New CallArgs}
      Self
      %Listener
      MsgLayer
      NodeRef
      DHTman
      Replica

      %Timeout
      TMs
      TPs

      TMmakers = tms(eagerpaxos: EagerPaxosTM
                     paxos:      PaxosTM
                     twophase:   TwoPhaseTM
                     valueset:   ValueSetTM
                     )
      TPmakers = tms(eagerpaxos: EagerPaxosTP
                     paxos:      PaxosTP
                     twophase:   TwoPhaseTP
                     valueset:   ValueSetTP
                     )

      proc {AddTransObj TransDict Tid ObjId Obj}
         TheObjs
      in
         TheObjs = {Dictionary.condGet TransDict Tid objs}
         TransDict.Tid := {Record.adjoinAt TheObjs ObjId Obj}
      end

      %% --- Events ---

      proc {BecomeReader Event}
         skip
      end

      proc {GetLocks Event}
         skip
      end

      proc {RunTransaction runTransaction(Trans Client Protocol)}
         TM
      in
         TM = {TMmakers.Protocol.new args(role:leader client:Client)}
         {TM setMsgLayer(@MsgLayer)}
         {TM setReplica(@Replica)}
         {AddTransObj TMs {TM getTid($)} {TM getId($)} TM}
         {Trans TM}
      end

      %% --- For the TMs ---
      proc {InitRTM Event}
         initRTM(client:Client protocol:Protocol tid:Tid ...) = Event
         RTM
      in
         if @NodeRef.id \= Event.leader.ref.id then
            RTM = {TMmakers.Protocol.new args(role:rtm client:Client)}
            {RTM setMsgLayer(@MsgLayer)}
            {RTM setReplica(@Replica)}
            {AddTransObj TMs Tid {RTM getId($)} RTM}
            {RTM Event}
         end
      end

      proc {ForwardToTM Event}
         {TMs.(Event.tid).(Event.tmid) Event}
      end 

      %% --- For the TPs ---
      proc {Brew Event}
         brew(tid:Tid protocol:Protocol ...) = Event
         TP
      in
         TP = {TPmakers.Protocol.new args(tid:Tid)} 
         {TP setMsgLayer(@MsgLayer)}
         {TP setDHT(@DHTman)}
         {AddTransObj TPs Tid {TP getId($)} TP}
         {TP Event}
      end

      proc {Final Event}
         {TPs.(Event.tid).(Event.tpid) Event.decision}
      end

      %% --- Internal to the Pbeer ---
      proc {SetDHT setDHT(DHTcomponent)}
         DHTman := DHTcomponent
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
         NodeRef  := {@MsgLayer getRef($)}
      end

      proc {SetReplica setReplica(ReplicaMan)}
         Replica := ReplicaMan
      end

      %proc {SetTimeout setTimeout(ATime)}
      %   Timeout := ATime
      %end

      Events = events(
                     %% Trappist's API
                     becomeReader:  BecomeReader
                     getLocks:      GetLocks
                     runTransaction:RunTransaction
                     %% For the TMs
                     ack:           ForwardToTM
                     initRTM:       InitRTM
                     registerRTM:   ForwardToTM
                     rtms:          ForwardToTM
                     setFinal:      ForwardToTM
                     vote:          ForwardToTM
                     voteAck:       ForwardToTM
                     %% For the TPs
                     brew:          Brew
                     final:         Final
                     %% Internal to the Pbeer
                     setDHT:        SetDHT
                     setMsgLayer:   SetMsgLayer
                     setReplica:    SetReplica
                     %setTimeout:    SetTimeout
                     %timeout:       TimeoutEvent
                     )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
%         Listener = FullComponent.listener
      end
      NodeRef  = {NewCell noref}
      MsgLayer = {NewCell Component.dummy}
      DHTman   = {NewCell Component.dummy} 
      Replica  = {NewCell Component.dummy}

      TMs   = {Dictionary.new}
      TPs   = {Dictionary.new}

      Self
   end

end  

