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
   Timer          at '../timer/Timer.ozf'
   Utils          at '../utils/Misc.ozf'
   EagerPaxosTM   at 'eagerpaxos/EagerPaxos-TM.ozf'
   EagerPaxosTP   at 'eagerpaxos/EagerPaxos-TP.ozf'
   PaxosTM        at 'paxos/Paxos-TM.ozf'
   PaxosTP        at 'paxos/Paxos-TP.ozf'
   TwoPCTM        at 'twophase/TwoPC-TM.ozf'
   TwoPCTP        at 'twophase/TwoPC-TP.ozf'
   ValueSetTM     at 'valueset/ValueSet-TM.ozf'
   ValueSetTP     at 'valueset/ValueSet-TP.ozf'
export
   New
define

   fun {New CallArgs}
      Self
      Listener
      MsgLayer
      NodeRef
      DHTman
      Replica
      TheTimer

      %Timeout
      TMs
      TPs

      TMmakers = tms(eagerpaxos: EagerPaxosTM
                     paxos:      PaxosTM
                     twopc:      TwoPCTM
                     valueset:   ValueSetTM
                     )
      TPmakers = tms(eagerpaxos: EagerPaxosTP
                     paxos:      PaxosTP
                     twopc:      TwoPCTP
                     valueset:   ValueSetTP
                     )

      %% --- Event ---

      proc {BecomeReader Event}
         skip
      end

      proc {GetLocks Event}
         skip
      end

      proc {RunTransaction runTransaction(Trans Client Protocol)}
         TM
      in
         {System.show 'going to run transaction'}
         TM = {TMmakers.Protocol.new args(type:leader client:Client)}
         {TM setMsgLayer(@MsgLayer)}
         {TM setReplica(@DHTman)}
         TMs.{TM getId($)} := TM
         {System.show 'going to run transaction'#{TM getId($)}}
         {Trans TM}
         skip
      end

/*
      proc {RunTransaction Event}
         {System.show 'what the hell'}
      end
*/
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
                     becomeReader:  BecomeReader
                     getLocks:      GetLocks
                     runTransaction:RunTransaction
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
         Listener = FullComponent.listener
      end
      NodeRef  = {NewCell noref}
      MsgLayer = {NewCell Component.dummy}
      DHTman   = {NewCell Component.dummy} 
      Replica  = {NewCell Component.dummy}
      TheTimer = {Timer.new}

      TMs   = {Dictionary.new}
      TPs   = {Dictionary.new}

      Self
   end

end  

