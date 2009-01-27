/*-------------------------------------------------------------------------
 *
 * Network.oz
 *
 *    Comunication layer. Higher level than point-to-point
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
 *    Implementation of the component that provides high level events to
 *    comunicate with other nodes on the network. It uses the perfect
 *    point-to-point link (pp2p) to send and deliver messages 
 *
 * EVENTS
 *
 *    Accepts: sendTo(Dest Msg) - Sends message Msg to Node Dest. Dest has to
 *    be an oz port. Msg can be anything.
 * 
 *    Accepts: getPort(P) - Binds P to the port of this site. It is a way of
 *    building a self reference to give to others.
 *
 *    Indication: It triggers whatever message is delivered by pp2p link as an
 *    event on the listener.
 *    
 *-------------------------------------------------------------------------
 */

functor

import
   Component   at '../corecomp/Component.ozf'
   Pp2p        at 'Pp2p.ozf'

export
   Make

define

   fun {Make}
      ComLayer
      Listener
      Self

      proc {SendTo Event}
         sendTo(Dest Msg) = Event
      in
         {@ComLayer pp2pSend(Dest Msg)}
      end

      proc {Deliver Event}
         pp2pDeliver(_ Msg) = Event
      in
         {@Listener Msg}
      end

      proc {GetPort Event}
         getPort(P) = Event
      in
         {@ComLayer getPort(P)}
      end

      proc {SetComLayer Event}
         setComLayer(NewComLayer) = Event
      in
         ComLayer := NewComLayer
         {@ComLayer setListener(Self.trigger)}
      end

      Events = events(
                  getPort:       GetPort
                  pp2pDeliver:   Deliver
                  sendTo:        SendTo
                  setComLayer:   SetComLayer
                  )
      in
         ComLayer = {NewCell {Pp2p.make}}
         Self = {Component.makeFull Events}
         {@ComLayer setListener(Self.trigger)}
         Listener = Self.listener
         Self.trigger
      end
end
