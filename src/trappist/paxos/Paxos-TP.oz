/*-------------------------------------------------------------------------
 *
 * Paxos-TP.oz
 *
 *    Transaction Participant for the Paxos Consensus Commit Protocol    
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
 *    Implementation of transaction participant (TP) role on the paxos
 *    consensus algorithm. This is one of the replicas of the protocol. If the
 *    majority of TPs survives the transaction, the transaction will finish. 
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Component      at '../../corecomp/Component.ozf'
export
   New
define

   fun {New CallArgs}
      Self
      %Listener
      MsgLayer
      NodeRef
      DHTman

      Id
      NewItem
      Leader
      RTMs

      %% === Events =========================================================

      %% --- Interaction with TPs ---
      proc {Brew brew(hkey:   HKey
                      leader: TheLeader
                      rtms:   TheRTMs
                      tid:    Tid
                      item:   TrItem 
                      protocol:_ 
                      tag:trapp)}
         Tmp
         DHTItem
         Vote
      in 
         RTMs     = TheRTMs
         NewItem  = item(hkey:HKey item:TrItem tid:Tid)
         Leader   := TheLeader
         Tmp      = {@DHTman getItem(HKey TrItem.key $)}
         DHTItem  = if Tmp == 'NOT_FOUND' then
                        item(key:      TrItem.key
                             value:    Tmp 
                             version:  0
                             readers:  nil
                             locked:   false)
                    else
                       Tmp
                    end
         %% Brewing vote - tmid needs to be added before sending
         Vote = vote(vote:    _
                     key:     TrItem.key 
                     version: DHTItem.version 
                     tid:     Tid 
                     tp:      tp(id:Id ref:@NodeRef)
                     tag:     trapp)
         if TrItem.version >= DHTItem.version andthen {Not DHTItem.locked} then
            Vote.vote = brewed
            {@DHTman putItem(HKey TrItem.key {AdjoinAt DHTItem locked true})}
         else
            Vote.vote = denied
         end
         {@MsgLayer dsend(to:@Leader.ref 
                          {Record.adjoinAt Vote tmid @Leader.id})}
         for TM in RTMs do
            {@MsgLayer dsend(to:TM.ref {Record.adjoinAt Vote tmid TM.id})}
         end
      end

      proc {Abort abort}
         DHTItem
      in
         DHTItem = {@DHTman getItem(NewItem.hkey NewItem.item.key $)}
         {PutItemAndAck NewItem.hkey NewItem.item.key DHTItem}
         skip
      end

      proc {Commit commit}
         {PutItemAndAck NewItem.hkey NewItem.item.key NewItem.item}
      end

      proc {PutItemAndAck HKey Key Item}
         {@DHTman  putItem(HKey Key {Record.adjoinAt Item locked false})}
         {@MsgLayer dsend(to:@Leader.ref ack(key: Key
                                             tid: NewItem.tid
                                             tmid:@Leader.id
                                             tp:  tp(id:Id ref:@NodeRef)
                                             tag: trapp))}
      end

      %% --- Various --------------------------------------------------------

      proc {GetId getId(I)}
         I = Id
      end

      proc {SetDHT setDHT(ADHT)}
         DHTman := ADHT
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
         NodeRef  := {@MsgLayer getRef($)}
      end

      Events = events(
                     %% Interaction with TM
                     brew:          Brew
                     abort:         Abort
                     commit:        Commit
                     %% Various
                     getId:         GetId
                     setDHT:        SetDHT
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
      DHTman   = {NewCell Component.dummy}      

      Id       = {Name.new}
      NodeRef  = {NewCell noref}
      Leader   = {NewCell noleader}

      Self
   end
end  

