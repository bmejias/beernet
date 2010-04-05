/*-------------------------------------------------------------------------
 *
 * TwoPC-TP.oz
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
   System
   Component      at '../../corecomp/Component.ozf'
   Timer          at '../../timer/Timer.ozf'
   Utils          at '../../utils/Misc.ozf'
export
   New
define

   fun {New CallArgs}
      Self
      Listener
      MsgLayer
      DHTman
      TheTimer

      Id
      NodeRef
      NewItem
      %% --- Event --

      %% --- Interaction with TPs ---
      proc {Brew brew(hkey:HKey tm:TM tid:Tid item:TrItem protocol:_ tag:trapp)}
         Tmp
         DHTItem
         Vote
      in 
         {System.show 'starting to brew'#TrItem.key#'at'#@NodeRef.id}
         NewItem  = TrItem % To be used when decision is taken
         Tmp      = {@DHTman getItem(HKey TrItem.key $)}
         {System.show 'keeping on brewing'}
         DHTItem  = if Tmp == 'NOT_FOUND' then
                        {System.show 'the value is failed'}
                        item(key:      TrItem.key
                             value:    Tmp 
                             version:  0
                             readers:  nil
                             locked:   false)
                    else
                        {System.show 'the value is NOT failed'}
                        {System.show Tmp}
                       Tmp
                    end
         %% Brewing vote
         Vote = vote(vote: _
                     key:  TrItem.key 
                     rkey: HKey 
                     tid:  Tid 
                     tp:   tp(id:Id src:@NodeRef)
                     tag:  trapp)
         if TrItem.version >= DHTItem.version andthen {Not DHTItem.locked} then
            Vote.vote = brewed
            {System.show 'going to lock'#TrItem.key#'at'#@NodeRef.id}
            {@DHTman putItem(HKey TrItem.key {AdjoinAt DHTItem locked true})}
         else
            Vote.vote = denied
         end
         {@MsgLayer  dsend(to:TM Vote)}
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
         Listener = FullComponent.listener
      end
      MsgLayer = {NewCell Component.dummy}
      DHTman   = {NewCell Component.dummy}      
      TheTimer = {Timer.new}

      NodeRef  = {NewCell noref}
      Id       = {NewName}

      Self
   end
end  

