/*-------------------------------------------------------------------------
 *
 * Pbeer.oz
 *
 *    Global API to create a Beernet Peer.
 *
 * LICENSE
 *
 *    Beernet is released under the Beerware License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: Boriss Mejias <boriss.mejias@uclouvain.be>
 *
 *    Last change: $Revision: 140 $ $Author: boriss $
 *
 *    $Date: 2010-03-22 12:34:12 +0100 (Mon, 22 Mar 2010) $
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
   System
   Board          at '../corecomp/Board.ozf'
   Component      at '../corecomp/Component.ozf'
   RelaxedRing    at '../son/relaxed-ring/Node.ozf'
   Replication    at '../trappist/SymmetricReplication.ozf'
   TheDHT         at '../dht/DHT.ozf'
   TheMsgLayer    at '../messaging/MsgLayer.ozf'
   TransLayer     at '../trappist/Trappist.ozf'
   Utils          at '../utils/Misc.ozf'
export
   New
define
   
   fun {New Args}
      %Listener % Component's listener
      Node     % Node implementing the behaviour
      DHT      % DHT functionality
      MsgLayer % Reliable messaging layer
      Replica  % Symmetric replication
      Self     % This component
      Trappist % Transactional layer

      %% Inbox for receiving messages
      Inbox    % Port to receive messages
      NewMsgs  % Dynamic head of new messages

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
      
      proc {InjectPermFail injectPermFail}
         {@Node injectPermFail}
      end
      
      proc {Join join(RingRef)}
         {@Node startJoin(succ:RingRef.pbeer ring:RingRef.ring)} 
      end
      
      proc {Leave Event}
         leave = Event
      in
         skip
      end
      
      proc {ReceiveTagged receive(Msg)}
         thread
            OldHead NewHead
         in
            OldHead = NewMsgs := NewHead
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
     
      ToNode      = {Utils.delegatesTo Node}
      ToDHT       = {Utils.delegatesTo DHT}
      ToReplica   = {Utils.delegatesTo Replica}
      ToTrappist  = {Utils.delegatesTo Trappist}
      %ToMsgLayer  = {DelegatesTo MsgLayer}

      Events = events(
                     %any:              Any
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
                     lookup:           ToNode
                     lookupHash:       ToNode
                     receive:          ReceiveTagged
                     send:             SendTagged
                     setLogger:        ToNode
                     %% DHT events
                     delete:           ToDHT
                     get:              ToDHT
                     put:              ToDHT
                     %% Replication events
                     bulk:             ToReplica
                     quickRead:        ToReplica
                     readAll:          ToReplica
                     readMajority:     ToReplica
                     %% Trappist Transactional layer
                     becomeReader:     ToTrappist
                     getLocks:         ToTrappist
                     runTransaction:   ToTrappist
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
      Trappist = {NewCell {TransLayer.new args}}
      local
         MaxKey
      in
         MaxKey = {@Node getMaxKey($)}
         DHT      = {NewCell {TheDHT.new args(maxKey:MaxKey)}}
         Replica  = {NewCell {Replication.new args(maxKey:MaxKey repFactor:4)}}
      end
      {@MsgLayer setNode(@Node)}
      {@Node setListener(@MsgLayer)}
      {@DHT setMsgLayer(@MsgLayer)}
      {@Replica setMsgLayer(@MsgLayer)}
      {@Replica setDHT(@DHT)}
      {@Trappist setMsgLayer(@MsgLayer)}
      {@Trappist setDHT(@DHT)}
      {@Trappist setReplica(@Replica)}
      local
         StorageBoard StorageSubscriber
      in
         [StorageBoard StorageSubscriber] = {Board.new}
         {StorageSubscriber Self}
         {StorageSubscriber tagged(@DHT dht)}
         {StorageSubscriber tagged(@Replica symrep)}
         {StorageSubscriber tagged(@Trappist trappist)}
         {@MsgLayer setListener(StorageBoard)}
      end

      %% Creating the Inbox abstraction
      local Str in
         Inbox = {Port.new Str}
         NewMsgs = {NewCell Str}
      end

      Self
   end

end

