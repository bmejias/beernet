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
export
   New
define
   
   fun {New Args}
      Self
      Listener
      Node        

      LastMsgId   = {NewCell 0}
      ClientMsgs  = {Dictionary.new}
      Msgs        = {Dictionary.new}

      fun {GetNewMsgId}
         OutId NewId
      in
         OutId = LastMsgId := NewId
         NewId = OutId + 1
         OutId
      end

      proc {Send Event}
         send(msg:Msg to:Target ...) = Event
         %% Other args: responsible (resp), outcome (out)
         Resp
         Outcome
         ClMsgId
      in
         if {HasFeature Event resp} then
            Resp = Event.resp
         else
            Resp = true
         end
         if {HasFeature Event out} then
            Outcome = Event.out
         end

         ClMsgId = {GetNewMsgId}
         ClientMsgs.ClMsgId := send(msg:Msg to:Target resp:Resp out:Outcome)

      end

      proc {SetNode Node}
         skip
      end


      Events = events(
                     send:    Send
                     setNode: SetNode
                     )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      Self
   end

end
