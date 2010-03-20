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

      %%--- Make Delegators ---
      fun {DelegatesTo Comp}
         proc {$ Event}
            {@Comp Event}
         end
      end

      %%--- Events ---

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
         skip
      end

      proc {SendTagged Event}
         send(Msg to:Target ...) = Event
      in
         skip
      end
     
      ToNode      = {DelegatesTo Node}
      ToMsgLayer  = {DelegatesTo MsgLayer}

      Events = events(
                  broadcast:        Broadcast
                  getFullRef:       ToNode
                  getId:            ToNode
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
      Node = {NewCell {RelaxedRing.new args}} 
      MsgLayer = {NewCell {TheMsgLayer.new args}}
      Self
   end

end

