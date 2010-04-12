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
                  if Op.status == tmp then
                     Tmp.(Op.op).(NewOp.op)
                  else
                     {DecisionLoop MoreOps NewOp (State + Ok.(Op.op))}
                  end
               else
                  {DecisionLoop MoreOps NewOp State}
               end
            [] nil then
               Final.State.(NewOp.op)
            end
         end
      in
         fun {DecideVote Set NewOp}
            {DecisionLoop {Record.toList Set} NewOp 0}
         end
      end

      %% === Events =========================================================

      %% --- Interaction with TPs ---
      proc {Brew brew(hkey:   HKey
                      leader: TheLeader
                      rtms:   TheRTMs
                      tid:    Tid
                      item:   op(id:OpId op:Op val:Val key:Key)
                      protocol:_ 
                      tag:trapp)}
         DHTSet
         Vote
      in 
         RTMs     = TheRTMs
         NewOp    = op(hkey:HKey id:OpId op:Op val:Val key:Key)
         Leader   := TheLeader
         DHTSet   = {@DHTman readLocalSet(HKey Key $)}
         %% Brewing vote - tmid needs to be added before sending
         Vote = vote(vote:    {DecideVote DHTSet NewOp}
                     key:     Key 
                     version: 0
                     tid:     Tid 
                     tp:      tp(id:Id ref:@NodeRef)
                     tag:     trapp)
         if Vote.vote == brewed then
            {@DHTman addToSet(HKey Key {AdjoinAt NewOp status tmp})}
         end
         {@MsgLayer dsend(to:@Leader.ref 
                          {Record.adjoinAt Vote tmid @Leader.id})}
         for TM in RTMs do
            {@MsgLayer dsend(to:TM.ref {Record.adjoinAt Vote tmid TM.id})}
         end
      end

      proc {Abort abort}
         {@DHTman removeFromSet(NewOp.hkey
                                NewOp.key 
                                {AdjoinAt NewOp status tmp})}
      end

      proc {Commit commit}
         {@DHTman removeFromSet(NewOp.hkey
                                NewOp.key
                                {AdjoinAt NewOp status tmp})}
         {@DHTman addToSet(NewOp.hkey NewOp.key op(id:NewOp.id
                                                   op:NewOp.op
                                                   val:NewOp.val
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

