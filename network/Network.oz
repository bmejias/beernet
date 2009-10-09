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
 *    point-to-point link (pp2p) to send and deliver messages. It assigns an
 *    incremented number to every message that is sent, logging all the
 *    information to a setable logger. Nodes are supposed to be identified by
 *    an Id, and reachable via an Oz port.
 *
 * EVENTS
 *
 *    Accepts: sendTo(Dest Msg) - Sends message Msg to Node Dest. Dest is a
 *    record of the form node(id:Id port:P), where Id is the identifier
 *    equivalent to self identifier, and P is an oz port. Msg can be anything.
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
   New
define

   fun {New}
      ComLayer    % Low level communication layer
      Listener    % Component where the deliver messages will be triggered
      Logger      % Component to log every sent and received message
      MsgCounter  % Identifier for every node
      Self        % Full Component
      SelfId      % Id that can be assinged by a external component
      SelfPort    % Reference to the port of the low level communication layer
      
      %% --- Utils ---

      proc {NewMsgId ?New}
         Old
      in
         Old = MsgCounter := New
         New = Old + 1
      end

      %%--- Events ---

      proc {Deliver Event}
         pp2pDeliver(_ '#'(SrcId MsgId Msg)) = Event
      in
         {@Logger 'in'(src:SrcId n:MsgId dest:@SelfId msg:Msg)}
         {@Listener Msg}
      end

      proc {GetPort Event}
         getPort(P) = Event
      in
         P = SelfPort
      end

      proc {GetRef Event}
         getRef(R) = Event
      in
         R = node(port:SelfPort id:@SelfId)
      end

      proc {SendTo Event}
         sendTo(Dest Msg ...) = Event
         MsgId
         LogTag
      in
         MsgId = {NewMsgId}
         if {HasFeature Event log} then
            LogTag = Event.log
         else
            LogTag = network
         end
         {@Logger out(src:@SelfId n:MsgId dest:Dest.id msg:Msg tag:LogTag)}
         {@ComLayer pp2pSend(Dest.port '#'(@SelfId MsgId Msg))}
      end

      proc {SetComLayer Event}
         setComLayer(NewComLayer) = Event
      in
         ComLayer := NewComLayer
         {@ComLayer setListener(Self.trigger)}
      end

      proc {SetId Event}
         setId(NewId) = Event
      in
         SelfId := NewId
      end

      proc {SetLogger Event}
         setLogger(NewLogger) = Event
      in
         Logger := NewLogger
      end

      Events = events(
                  getPort:       GetPort
                  getRef:        GetRef
                  pp2pDeliver:   Deliver
                  sendTo:        SendTo
                  setComLayer:   SetComLayer
                  setId:         SetId
                  setLogger:     SetLogger
                  )
   in
      ComLayer    = {NewCell {Pp2p.new}}
      MsgCounter  = {NewCell 0}
      Logger      = {NewCell Component.dummy}
      Self        = {Component.new Events}
      SelfPort    = {@ComLayer getPort($)}
      SelfId      = {NewCell none}
      Listener    = Self.listener
      {@ComLayer setListener(Self.trigger)}
      Self.trigger
   end
end
