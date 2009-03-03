/*-------------------------------------------------------------------------
 *
 * RelaxedRing.oz
 *
 *    Relaxed-ring maintenance algorithm
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
 *    Join and failure recovery are implemented here.
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
   Component   at '../../corecomp/Component.ozf'
   KeyRanges   at 'KeyRanges.ozf'   
   Network     at '../../network/Network.ozf'
   TimerMaker  at '../../timer/Timer.ozf'

export
   Make

define
   JOIN_WAIT      = 5000 % Milliseconds to wait to retry a join 
   SUCC_LIST_SIZE = 7
   BelongsTo      = KeyRanges.belongsTo

   %TODO: define if this is global or local to the peer
   %TODO: implement it correctly
   fun {GetPBeerRef}
      pbeer(id:666 port:{Port.new _})
   end

   %% Like Take
   fun {Keep N L}
      case L
      of H|T then
         if N > 0 then
            H|{Keep N - 1 T}
         else
            nil
         end
      [] nil then
         nil
      end
   end

   %% Remove a Peer from a List
   fun {Remove Peer L}
      case L
      of H|T then
         if H.id == Peer.id then
            T
         else
            H|{Remove Peer T}
         end
      [] nil then
      nil
      end
   end

   fun {Make}
      Pred        % Reference to the predecessor
      PredList    % To remember peers that haven't acked joins of new preds
      Ring        % Ring Reference ring(name:<atom> id:<name>)
      RoutTable   % Routing table 
      Self        % Full Component
      SelfRef     % Pbeer reference pbeer(id:<Id> port:<Port>)
      Succ        % Reference to the successor
      SuccList    % Successor List. Used for failure recovery
      WishedRing  % Used while trying to join a ring

      %% --- Utils ---
      ComLayer    % Network component
      Forward     % Routing component
      Listener    % Component where the deliver messages will be triggered
      Logger      % Component to log every sent and received message
      Timer       % Component to rigger some events after the requested time

      proc {BasicForward Event _ RoutingTable}
         if RoutingTable.succ \= nil then
            {Zend RoutingTable.succ Event}
         end
      end

      proc {Route Event Target}
         if {HasFeature Event last} andthen Event.last then
            %% I am supposed to be the responsible, but I have a branch
            %TODO: check also a possible forward to PredList
            {Zend @Pred Event}
            %{Blabla @(Self.id)#" forwards join of "#Sender.id#" to pred "
            %         #@(Self.pred).id}
         elseif {BelongsTo Event.src.id @SelfRef.id @Succ.id} then
            %% I think my successor is the responsible => set last = true
            {Zend @Succ {Record.adjoinAt Event last true}}
            %{Blabla @SelfRef.id#" forwards join of "#Sender.id#" to "
            %         #@(Self.succ).id}
         else
            %% Forward the message using the routing table
            {@Forward Event Event.src.id RoutTable}
            %{Blabla @SelfRef.id#" forwards join of "#Src.id}
         end
      end

      %TODO: Decide whether I need a coroner or not
      proc {Watcher _} skip end

      proc {Zend Target Msg}
         {@ComLayer sendTo(Target Msg log:rlxring)}
      end

      %%--- Events ---

      proc {BadRingRef Event}
         badRingRef = Event
      in
         skip %% TODO: trigger some error message
      end

      proc {GetPred Event}
         getSucc(Peer) = Event
      in
         Peer = @Pred
      end

      proc {GetRingRef Event}
         getRingRef(RingRef) = Event
      in
         {Wait @Ring}
         RingRef = {Record.adjoinAt @Ring pbeer:@SelfRef}
      end

      proc {GetSucc Event}
         getSucc(Peer) = Event
      in
         Peer = @Succ
      end

      proc {Hint Event}
         hint(succ:NewSucc) = Event
      in
         %TODO. First I need to guarantee that this is a safe message
         skip
      end

      proc {Init Event}
         %% TODO: Get id
         %% TODO: Get a ring reference
         RoutTable = rt(fingers: {NewCell nil}
                        pred:    Pred
                        'self':  SelfRef
                        succ:    Succ)
         Forward = {NewCell BasicForward}
         skip
      end

      proc {Join Event}
         join(src:Src ring:SrcRing ...) = Event
         %% Event join might come with flag last = true guessing to reach the
         %% responsible. If I am not the responsible, message has to be 
         %% backwarded to the branch. 
      in
         if @Ring == SrcRing then
            if @Succ \= nil then
               %TODO: I should use Better predecessor here
               if {BelongsTo Src.id @Pred.id @SelfRef.id} then
                  OldPred = @Pred
               in
                  {Zend Src joinOk(pred:OldPred
                                   succ:@SelfRef
                                   succList:@SuccList)}
                  Pred := Src
                  %% set a failure detector on the predecessor 
                  {Watcher register(watcher:@SelfRef target:Src)} 
                  %{Blabla @(Self.id)#" accepts new pred "#Sender.id}
                  for OldP in @PredList do
                     {Zend OldP hint(succ:Src)}
                  end
                  PredList := OldPred|@PredList
                  %% 'join' not for me. Route it!
               else
                  {Route Event Src.id}
               end
            else
               %{Blabla "sending try to join later"}
               {Zend Src joinLater}
            end
         else
            {Zend Src badRingRef}
         end
      end

      proc {JoinAck Event}
         joinAck(OldPred) = Event
      in
         PredList := {Remove OldPred @PredList}
      end

      proc {JoinLater Event}
         joinLater(NewSucc) = Event
      in
         {Timer JOIN_WAIT Self startJoin(succ:NewSucc ring:@WishedRing)}
      end

      proc {JoinOk Event}
         joinOk(pred:NewPred succ:NewSucc succList:NewSuccList) = Event
      in
         Succ := NewSucc
         SuccList := NewSucc|NewSuccList %TODO: get a good size for this
         %% set a failure detector on the successor
         {Watcher register(watcher:@(Self.ref) target:Succ)} 
         if @Pred == nil orelse {BelongsTo NewPred.id @Pred.id @SelfRef.id} then
            {Zend NewPred newSucc(newSucc:@SelfRef
                                 oldSucc:@Succ
                                 succList:@SuccList)}
            Pred := NewPred
            %% set a failure detector on the predecessor
            {Watcher register(watcher:@SelfRef target:NewPred)} 
         end
         %{Blabla @SelfRef.id#" joined as pred of "#@Succ.id}
         %TODO: This should be triggered only the first I'm connected
         %not on failure recovery
         %{FindAndConnectToFingers}
      end

      proc {NewSucc Event}
         newSucc(newSucc:NewSucc oldSucc:OldSucc succList:NewSuccList) = Event
      in
         %{BlablaNonl NewSucc.id#" wannabe my new succ of "#@(Self.id)} 
         if @Succ.id == OldSucc.id then
            %{Blabla " and she is"}
            SuccList := NewSucc|NewSuccList
            {Zend OldSucc joinAck(@SelfRef)}
            {Zend @Pred updSuccList(src:@SelfRef
                                    succList:@SuccList
                                    counter:SUCC_LIST_SIZE)}
            Succ := NewSucc
            {Watcher register(watcher:@SelfRef target:NewSucc)}
         end
      end

      proc {StartJoin Event}
         startJoin(succ:NewSucc ring:RingRef) = Event
      in
         @WishedRing := RingRef
         {Zend NewSucc join(src:@SelfRef ring:RingRef)}
      end

      proc {UpdSuccList Event}
         updSuccList(src:Src succList:NewSuccList counter:Counter) = Event
      in
         if @Succ.id == Src.id then
            SuccList := Src|{Keep SUCC_LIST_SIZE - 1 @SuccList}
            if Counter > 0 then
               {Zend @Pred updSuccList(src:@SelfRef
                                       succList:@SuccList
                                       counter:Counter - 1)}
            end
         end
      end

      Events = events(
                  badRingRef:    BadRingRef
                  getPred:       GetPred
                  getRingRef:    GetRingRef
                  getSucc:       GetSucc
                  hint:          Hint
                  init:          Init
                  join:          Join
                  joinAck:       JoinAck
                  joinLater:     JoinLater
                  joinOk:        JoinOk
                  newSucc:       NewSucc
                  startJoin:     StartJoin
                  updSuccList:   UpdSuccList
                  )
   in
      %% Creating the component and collaborators
      local
         FullComponent
      in
         FullComponent  = {Component.makeFull Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      Timer = {TimerMaker.make}

      %% Peer State
      SelfRef  = {GetPBeerRef}
      Pred     = {NewCell nil}    
      PredList = {NewCell nil}
      Succ     = {NewCell nil}
      SuccList = {NewCell nil} 

      Self
   end
end
