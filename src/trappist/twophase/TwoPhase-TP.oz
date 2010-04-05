/*-------------------------------------------------------------------------
 *
 * TwoPhase-TP.oz
 *
 *    Transaction Participant for the Two-Phase Commit Protocol    
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
 *    Implementation of the classical two-phase commit protocol for replicated
 *    databases. This is one of the replicas of the protocol. Known as the
 *    transaction participant.
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
      MsgLayer
      DHTman

      Id
      NodeRef
      NewItem
      Leader
      %% --- Event --

      %% --- Interaction with TPs ---
      proc {Brew brew(hkey:HKey tm:TM tid:Tid item:TrItem protocol:_ tag:trapp)}
         Tmp
         DHTItem
         Vote
      in 
         NewItem  = item(hkey:HKey item:TrItem tid:Tid)
         Leader   = TM
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
         %% Brewing vote
         Vote = vote(vote:    _
                     key:     TrItem.key 
                     version: DHTItem.version 
                     tid:     Tid 
                     tp:      tp(id:Id ref:@NodeRef)
                     tag:     trapp)
         if TrItem.version > DHTItem.version andthen {Not DHTItem.locked} then
            Vote.vote = brewed
            {@DHTman putItem(HKey TrItem.key {AdjoinAt DHTItem locked true})}
         else
            Vote.vote = denied
         end
         {@MsgLayer dsend(to:Leader Vote)}
      end

      proc {PutItemAndAck HKey Key Item}
         {@DHTman  putItem(HKey Key {Record.adjoinAt Item locked false})}
         {@MsgLayer dsend(to:Leader ack(key:Key
                                        tid:NewItem.tid
                                        tp:tp(id:Id ref:@NodeRef)
                                        tag:trapp))}
      end

      proc {Abort abort}
         DHTItem
      in
         DHTItem = {@DHTman getItem(NewItem.hkey NewItem.item.key $)}
         {PutItemAndAck NewItem.hkey NewItem.item.key DHTItem}
      end

      proc {Commit commit}
         {PutItemAndAck NewItem.hkey NewItem.item.key NewItem.item}
      end

      %% --- Various ---

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
      Self     = {Component.new Events}.trigger
      MsgLayer = {NewCell Component.dummy}
      DHTman   = {NewCell Component.dummy}      

      NodeRef  = {NewCell noref}
      Id       = {NewName}

      Self
   end
end  

