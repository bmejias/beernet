/*-------------------------------------------------------------------------
 *
 * Pbeer.oz
 *
 *    Global API to create a Beernet Peer from an Oz program.
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
 *    This is the highest level component of Beernet. It implements the events
 *    described on the general API connecting with the other components that
 *    implements each behaviour.
 *
 *-------------------------------------------------------------------------
 */

functor
import
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
      Listener % Component's listener
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
         %% Mainly used by the application.
         %{System.showInfo "Got "#Event#" to be sent to "#Listener}
         {@Listener Event}
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
         {@Node injectPermFail}
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
     
      %% --- Forwarding to DHT with different event name --------------------
      proc {SingleAdd Event}
         {@DHT {Record.adjoinList add {Record.toListInd Event}}}
      end

      proc {SingleRemove Event}
         {@DHT {Record.adjoinList remove {Record.toListInd Event}}}
      end

      proc {SingleReadSet Event}
         {@DHT {Record.adjoinList readSet {Record.toListInd Event}}}
      end
      %% --- end forward to DHT with different event name -------------------

      ToNode      = {Utils.delegatesTo Node}
      ToDHT       = {Utils.delegatesTo DHT}
      ToReplica   = {Utils.delegatesTo Replica}
      ToTrappist  = {Utils.delegatesTo Trappist}
      %ToMsgLayer  = {DelegatesTo MsgLayer}

      Events = events(
                     any:              Any
                     broadcast:        Broadcast
                     dsend:            SendTagged
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
                     refreshFingers:   ToNode
                     send:             SendTagged
                     setLogger:        ToNode
                     %% DHT events
                     delete:           ToDHT
                     get:              ToDHT
                     put:              ToDHT
                     singleAdd:        SingleAdd
                     singleRemove:     SingleRemove
                     singleReadSet:    SingleReadSet
                     %% Replication events
                     bulk:             ToReplica
                     findRSet:         ToReplica
                     getOne:           ToReplica
                     getAll:           ToReplica
                     getMajority:      ToReplica
                     %% Trappist Transactional layer
                     becomeReader:     ToTrappist
                     executeTransaction:ToTrappist
                     getLocks:         ToTrappist
                     runTransaction:   ToTrappist
                     add:              ToTrappist
                     remove:           ToTrappist
                     readSet:          ToTrappist
                     )

   in
      %% Creating the component and collaborators
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      Node     = {NewCell {RelaxedRing.new Args}}
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
         {StorageSubscriber tagged(@Trappist trapp)}
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

