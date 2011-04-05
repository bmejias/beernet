/*-------------------------------------------------------------------------
 *
 * ValueSet-TP.oz
 *
 *    Transaction Participant for the Key/Value-Set abstraction   
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
 *    Implementation of transaction participant (TP) role on the key/value-set
 *    protocol, which also uses consensus, as in Paxos, but it does not lock
 *    the value-sets.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Constants      at '../../commons/Constants.ozf'
   Component      at '../../corecomp/Component.ozf'
export
   New
define

   BAD_SECRET  = Constants.badSecret
   NO_VALUE    = Constants.noValue

   fun {New CallArgs}
      Self
      %Listener
      MsgLayer
      NodeRef
      DHTman

      Id
      NewOp
      Leader
      RTMs

      %% === Auxiliar Functions =============================================
      local
         Ok    = ok(add:1 remove:~1)
         Tmp   = tmp(add:tmp(add:conflict remove:not_found)
                     remove:tmp(add:duplicated remove:conflict))
         Final = ok(0:ok(add:brewed remove:not_found)
                    1:ok(add:duplicated remove:brewed))
         fun {DecisionLoop Ops NewOp State}
            case Ops
            of Op|MoreOps then
               if Op.val == NewOp.val then
                  if Op.sval == NewOp.sval then
                     if Op.status == tmp then
                        Tmp.(Op.op).(NewOp.op)
                     else
                        {DecisionLoop MoreOps NewOp (State + Ok.(Op.op))}
                     end
                  else
                     BAD_SECRET
                  end
               else
                  {DecisionLoop MoreOps NewOp State}
               end
            [] nil then
               Final.State.(NewOp.op)
            end
         end
      in
         fun {DecideVote Set SetOps NewOp}
            if Set == NO_VALUE orelse Set.s == NewOp.sec then
                  {DecisionLoop {Record.toList SetOps} NewOp 0}
            else
               BAD_SECRET
            end
         end
      end

      %% === Events =========================================================

      %% --- Interaction with TPs ---
      proc {Brew brew(hkey:   HKey
                      leader: TheLeader
                      rtms:   TheRTMs
                      tid:    Tid
                      item:   Item 
                      protocol:_ 
                      tag:trapp)}
         DHTSet
         DHTSetOps
         Vote
         Key
      in 
         RTMs     = TheRTMs
         NewOp    = {Record.adjoinAt Item hkey HKey}
         Leader   := TheLeader
         Key      = Item.key
         DHTSet   = {@DHTman getItem(HKey Key $)}
         DHTSetOps= {@DHTman readLocalSet(HKey Key $)}
         %% Brewing vote - tmid needs to be added before sending
         Vote = vote(vote:    {DecideVote DHTSet DHTSetOps NewOp}
                     key:     Key 
                     version: 0
                     tid:     Tid 
                     tp:      tp(id:Id ref:@NodeRef)
                     tag:     trapp)
         if Vote.vote == brewed then
            {@DHTman addToSet(hkey:HKey 
                              key:Key 
                              sec:NewOp.sec
                              val:{AdjoinAt NewOp status tmp})}
         end
         {@MsgLayer dsend(to:@Leader.ref 
                          {Record.adjoinAt Vote tmid @Leader.id})}
         for TM in RTMs do
            {@MsgLayer dsend(to:TM.ref {Record.adjoinAt Vote tmid TM.id})}
         end
      end

      proc {RemoveFromSet}
         {@DHTman removeFromSet(hkey:NewOp.hkey
                                key:NewOp.key 
                                sec:NewOp.sec
                                val:{AdjoinAt NewOp status tmp})}
      end

      proc {Abort abort}
         {RemoveFromSet}
      end

      proc {Commit commit}
         {RemoveFromSet}
         {@DHTman addToSet(hkey:NewOp.hkey
                           key:NewOp.key
                           sec:NewOp.sec
                           val:op(id:NewOp.id
                                  op:NewOp.op
                                  v:NewOp.val
                                  sv:NewOp.sval
                                  status:ok))}
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

