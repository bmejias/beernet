/*-------------------------------------------------------------------------
 *
 * Pbeer.oz
 *
 *    Global API to create a Beernet Peer.
 *
 * LICENSE
 *
 *    Copyright (c) 2009 Universite catholique de Louvain
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
 *    This is the highest level component of Beernet. It implements the events
 *    described on the general API connecting with the other components that
 *    implements each behaviour.
 *
 * EVENTS
 *
 *    Accepts: eventName(arg1 argN) - Events that can be triggered on this
 *    component to request a service.
 *
 *    Confirmation: eventName(arg1 argN) - Events used by a component to
 *    confirm the completion of a request.
 *
 *    Indication: eventName(arg1 argN) - Events used by a given component to
 *    deliver information to another component
 *    
 *-------------------------------------------------------------------------
 */

functor

import
   Component   at '../corecomp/Component.ozf'
   RelaxedRing at 'relaxed-ring/Node.ozf'
   TheMsgLayer at 'messaging/MsgLayer.ozf'

export
   New

define
   
   fun {New Args}
      %Listener % Component's listener
      Node     % Node implementing the behaviour
      MsgLayer % Reliable messaging layer
      Self     % This component

      %% Inbox for receiving messages
      Inbox    % Port to receive messages
      NewMsgs  % Dynamic head of new messages

      %%--- Make Delegators ---
      fun {DelegatesTo Comp}
         proc {$ Event}
            {@Comp Event}
         end
      end

      %%--- Events ---

      proc {Any Event}
         %% Messages comming from the MsgLayer
         {Port.send Inbox Event}
      end

      proc {Broadcast Event}
%         broadcast(Range Msg) = Event
%      in
         skip
      end
      
      proc {DHTGet Event}
%         get(Key Value) = Event
%      in
         skip
      end
      
      proc {DHTPut Event}
%         put(Key Value) = Event
%      in
         skip
      end
      
      proc {InjectPermFail Event}
         injectPermFail = Event
      in
         {@Node injectPermFail}
      end
      
      proc {Join Event}
         join(RingRef) = Event
      in
         {@Node startJoin(succ:RingRef.pbeer ring:RingRef.ring)} 
      end
      
      proc {Leave Event}
         leave = Event
      in
         skip
      end
      
      proc {ReceiveTagged Event}
         receive(Msg) = Event
      in
         thread
            OldHead NewHead
         in
            OldHead = @NewMsgs := NewHead
            case OldHead
            of NewMsg|MoreMsgs then
               Msg = NewMsg
               NewHead = MoreMsgs
            [] nil then
               skip
            end
         end
      end

      proc {SendTagged Event}
      %   send(Msg to:Target ...) = Event
      %in
         {@MsgLayer Event}
      end
     
      ToNode      = {DelegatesTo Node}
      %ToMsgLayer  = {DelegatesTo MsgLayer}

      Events = events(
                  any:              Any
                  broadcast:        Broadcast
                  getFullRef:       ToNode
                  getId:            ToNode
                  getMaxKey:        ToNode
                  getPred:          ToNode
                  getRange:         ToNode
                  getRef:           ToNode
                  getRingRef:       ToNode
                  getSucc:          ToNode
                  injectPermFail:   InjectPermFail
                  join:             Join
                  leave:            Leave
                  receive:          ReceiveTagged
                  send:             SendTagged
                  setLogger:        ToNode
                  %% DHT events
                  get:              DHTGet
                  put:              DHTPut
                  )

   in
      %% Creating the component and collaborators
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         %Listener = FullComponent.listener
      end
      Node     = {NewCell {RelaxedRing.new args}} 
      MsgLayer = {NewCell {TheMsgLayer.new args}}
      {@MsgLayer setNode(@Node)}
      {@MsgLayer setListener(Self)}

      %% Creating the Inbox abstraction
      local Str in
         Inbox = {Port.new Str}
         NewMsgs = {NewCell Str}
      end

      Self
   end

end

