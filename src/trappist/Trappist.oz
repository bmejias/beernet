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
   Component      at '../corecomp/Component.ozf'
   Timer          at '../timer/Timer.ozf'
   Utils          at '../utils/Misc.ozf'
   EagerPaxosTM   at 'eagerpaxos/EagerPaxos-TM.ozf'
   EagerPaxosTP   at 'eagerpaxos/EagerPaxos-TP.ozf'
   PaxosTM        at 'paxos/Paxos-TM.ozf'
   PaxosTP        at 'paxos/Paxos-TP.ozf'
   TwoPCTM        at 'twophase/TwoPC-TM.ozf'
   TwoPCTP        at 'twophase/TwoPC-TP.ozf'
   ValueSetTM    at 'valueset/ValueSet-TM.ozf'
   ValueSetTP    at 'valueset/ValueSet-TP.ozf'
export
   New
define

   fun {New CallArgs}
      Self
      Listener
      MsgLayer
      NodeRef
      DHTman
      TheTimer

      %Timeout

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

      %% --- Creating instances of transactional objects ---
/*
      fun {NewTM Client Protocol Type}
         {TMmakers.Protocol.new args(type:Type client:Client)}
      end

      fun {NewTransactionParticipant Node Tid Protocol}
         case Type
         of twopc then
            {TwoPCTP.newTransactionParticipant Node Tid}
         [] paxos then
            {PaxosTP.newTransactionParticipant Node Tid}
         [] paxoseager then
            {PaxosEagerTP.newTransactionParticipant Node Tid}
         end
      end
*/
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
         %TM = {NewTM Client Protocol}
         TM = {TMmakers.Protocol.new args(type:leader client:Client)}
         {Trans TM}
         skip
      end

      proc {SetDHT setDHT(DHTcomponent)}
         DHTman := DHTcomponent
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
         NodeRef  := {@MsgLayer getRef($)}
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
      MsgLayer = {NewCell Component.dummy}
      DHTman   = {NewCell Component.dummy}      
      TheTimer = {Timer.new}

      Self
   end

end  

