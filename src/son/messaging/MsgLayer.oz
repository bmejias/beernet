/*-------------------------------------------------------------------------
 *
 * MsgLayer.oz
 *
 *    Messaging layer that uses any ring-based node to perform reliable
 *    message sending routing through the overlay network.
 *
 * LICENSE
 *
 *    Copyright (c) 2010 Universite catholique de Louvain
 *
 *    Beernet is released under the MIT License (see file LICENSE) 
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
 *    The messaging layer needs a Node to route and receive messages. It also
 *    needs to be registered as listener of the Node, in other case, messages
 *    won't be delivered to the upper layer.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   System
   Component   at '../../corecomp/Component.ozf'
   Timer       at '../../timer/Timer.ozf'
   Utils       at '../../utils/Misc.ozf'
export
   New
define
   
   fun {New CallArgs}
      Self
      Listener
      Node
      TheTimer

      Args
      LastMsgId
      Msgs
      Timeout
      Tries

      fun {GetNewMsgId}
         OutId NewId
      in
         OutId = LastMsgId := NewId
         NewId = OutId + 1
         OutId
      end

      proc {Send Event}
         send(Msg to:Target ...) = Event
         %% Other args: responsible (resp), outcome (out)
         Resp
         Outcome
         FullMsg
         MsgId
      in
         %{System.show 'MsgLayer is going to send :'#Msg}
         if {HasFeature Event resp} then
            Resp = Event.resp
         else
            Resp = true
         end
         if {HasFeature Event out} then
            Outcome = Event.out
         end
         MsgId = {GetNewMsgId}
         FullMsg = rsend(msg:Msg to:Target src:{@Node getRef($)}
                         resp:Resp mid:MsgId)
         Msgs.MsgId := data(msg:FullMsg outcome:Outcome c:@Tries)
         {@Node route(msg:FullMsg to:Target src:{@Node getRef($)})} 
         {TheTimer startTrigger(@Timeout timeout(MsgId) Self)}
      end

      proc {RSend Event}
         rsend(msg:Msg to:Target src:Src resp:Resp mid:MsgId) = Event
      in
         %{System.show '+_+_MAYBE+_+_+_+_+_+_+_+_+_+got a message '#Msg}
         if Resp orelse Target == {@Node getId($)} then
            %{System.show '+_+_+_+_+_+_+_+_+_+_+_+got a message '#Msg}
            {@Listener Msg}
            {@Node dsend(to:Src rsendAck(MsgId))}
         end
      end

      proc {RSendAck Event}
         rsendAck(MsgId) = Event
      in
         local
            Data = {Dictionary.condGet Msgs MsgId done}
         in
            if Data \= done then
               Data.outcome = true
               %{System.show 'Msg'#MsgId#' was correctly received'}
               {Dictionary.remove Msgs MsgId}
            end
         end
      end

      proc {SetNode Event}
         setNode(ANode) = Event
      in
         Node := ANode
      end

      proc {TimeoutEvent Event}
         timeout(MsgId) = Event
      in
         local
            Data = {Dictionary.condGet Msgs MsgId done} 
         in
            if Data \= done then
               if Data.c > 1 then
                  {@Node route(msg:Data.msg 
                               to:Data.msg.to 
                               src:{@Node getRef($)})} 
                  {TheTimer startTrigger(@Timeout timeout(MsgId) Self)}
                  Msgs.MsgId := {Record.adjoinAt Data c Data.c-1}
               else
                  {System.show 'msg '#MsgId#' never arrived'}
                  Data.outcome = false
                  {Dictionary.remove Msgs MsgId}
               end
            end
         end
      end

      Events = events(
                     rsend:      RSend
                     rsendAck:   RSendAck
                     send:       Send
                     setNode:    SetNode
                     timeout:    TimeoutEvent
                     )
   in
      Args = {Utils.addDefaults CallArgs def(timeout:1000 tries:5)}
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      Node        = {NewCell Component.dummy}
      TheTimer    = {Timer.new}
      Timeout     = {NewCell Args.timeout}
      Tries       = {NewCell Args.tries}
      LastMsgId   = {NewCell 0}
      Msgs        = {Dictionary.new}
      Self
   end

end
