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
   RelaxedRing at 'relaxed-ring/RelaxedRing.ozf'

export
   New

define
   
   fun {New Args}
      %Listener % Component's listener
      Node     % Node implementing the behaviour
      Self     % This component

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
      
      proc {ForwardToNode Event}
         {@Node Event}
      end

      proc {InjectPermFail Event}
         injectPermFail = Event
      in
         skip
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
      
      proc {RSendTo Event}
         %rSendTo(Id Msg delivered:Flag) = Event
      %in
         skip
      end
      
      proc {SendTo Event}
         %sendTo(Id Msg ...) = Event
      %in
         skip
      end
      
      Events = events(
                  broadcast:        Broadcast
                  getFullRef:       ForwardToNode
                  getId:            ForwardToNode
                  getPred:          ForwardToNode
                  getRange:         ForwardToNode
                  getRef:           ForwardToNode
                  getRingRef:       ForwardToNode
                  getSucc:          ForwardToNode
                  injectPermFail:   InjectPermFail
                  join:             Join
                  leave:            Leave
                  rSendTo:          RSendTo
                  sendTo:           SendTo
                  setLogger:        ForwardToNode
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

      Self
   end

end

