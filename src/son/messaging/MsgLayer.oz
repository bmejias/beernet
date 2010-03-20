/*-------------------------------------------------------------------------
 *
 * MsgLayer.oz
 *
 *    Messaging layer that uses any ring-based node to perform reliable message
 *    sending routing through the overlay network.
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
 *    No detailed information needed. The abstract is quite clear
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../../corecomp/Component.ozf'
   Timer       at '../../timmer/Timer.ozf'
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
         {@Node route(msg:FullMsg to:Target src:_)} 
         {TheTimer startTrigger(@Timeout timeout(MsgId) Self)}
      end

      proc {RSend Event}
         rsend(msg:Msg to:Target src:Src resp:Resp mid:MsgId) = Event
      in
         if Resp orelse Target == {@Node getId($)} then
            {@Listener Msg}
            {Port.send Src.port rsendAck(MsgId)}
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
                  {@Node route(msg:Data.msg to:Data.msg.to src:_)} 
                  {TheTimer startTrigger(@Timeout timeout(MsgId) Self)}
                  Msgs.MsgId := {Record.adjoinAt Data c Data.c-1}
               else
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
      Timeout     = {NewCell Args.tomeout}
      Tries       = {NewCell Args.tries}
      LastMsgId   = {NewCell 0}
      Msgs        = {Dictionary.new}
      Self
   end

end
