/*-------------------------------------------------------------------------
            crash:         Crash
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
   System
   Component   at '../../corecomp/Component.ozf'
   KeyRanges   at '../../utils/KeyRanges.ozf'   
   Network     at '../../network/Network.ozf'
   PbeerList   at '../../utils/PbeerList.ozf'
   RingList    at '../../utils/RingList.ozf'
   TimerMaker  at '../../timer/Timer.ozf'
export
   New
define
   JOIN_WAIT   = 5000      % Milliseconds to wait to retry a join 
   MAX_KEY     = 1048576   % 2^20

   BelongsTo      = KeyRanges.belongsTo

   %% --- Utils ---
   fun {Vacuum L Dust}
      case Dust
      of DeadPeer|MoreDust then
         {Vacuum {RingList.remove DeadPeer L} MoreDust}
      [] nil then
         L
      end
   end

   %% --- Exported ---
   fun {New Args}
      Crashed     % List of crashed peers
      LogMaxKey   % Frequently used value
      MaxKey      % Maximum value for a key
      Pred        % Reference to the predecessor
      PredList    % To remember peers that haven't acked joins of new preds
      Ring        % Ring Reference ring(name:<atom> id:<name>)
      FingerTable % Routing table 
      Self        % Full Component
      SelfRef     % Pbeer reference pbeer(id:<Id> port:<Port>)
      Succ        % Reference to the successor
      SuccList    % Successor List. Used for failure recovery
      WishedRing  % Used while trying to join a ring

      %% --- Utils ---
      ComLayer    % Network component
      %Listener    % Component where the deliver messages will be triggered
      %Logger      % Component to log every sent and received message
      Timer       % Component to rigger some events after the requested time

      fun {AddToList Peer L}
         {RingList.add Peer L @SelfRef.id MaxKey}
      end

      %% TheList should have no more than Size elements
      fun {UpdateList MyList NewElem OtherList}
         FinalList DropList
      in
         FinalList = {NewCell MyList}
         {RingList.forAll {Vacuum OtherList @Crashed}
                           proc {$ Pbeer}
                              FinalList := {AddToList Pbeer @FinalList}
                           end}
         FinalList := {RingList.keepAndDrop LogMaxKey @FinalList DropList}
         {UnregisterPeers DropList}
         {WatchPeers @FinalList}
         @FinalList
      end

      proc {BasicForward Event}
         case Event
         of route(msg:Msg srcId:_ target:_) then
            if @Succ \= nil then
               {Zend @Succ Msg}
            end
         else
            skip
         end
      end

      proc {Backward Event Target}
         ThePred = {RingList.getAfter Target @PredList @SelfRef.id MaxKey}
      in
         if ThePred \= nil then
            {Zend ThePred Event}
         else
            %%TODO: acknowledge somehow that the message is lost
            {System.showInfo "Something went wrong, I cannot backward msg"}
            skip
         end
      end

%      fun {GetNewPBeerRef}
%         pbeer(id:{KeyRanges.getRandomKey MaxKey}
%               port:{@ComLayer getPort($)})
%      end

      %% Registering a Pbeer on the failure detector
      proc {Monitor Pbeer}
         {@ComLayer monitor(Pbeer)}
      end

      proc {Route Event Target}
         if {HasFeature Event last} andthen Event.last then
            %% I am supposed to be the responsible, but I have a branch
            %% or somebody was missed (non-transitive connections)
            {Backward Event Target}
         elseif {BelongsTo Event.src.id @SelfRef.id @Succ.id} then
            %% I think my successor is the responsible => set last = true
            {Zend @Succ {Record.adjoinAt Event last true}}
            %{Blabla @SelfRef.id#" forwards join of "#Sender.id#" to "
            %         #@(Self.succ).id}
         else
            %% Forward the message using the routing table
            {@FingerTable route(msg:Event srcId:Event.src.id target:Target)}
            %{Blabla @SelfRef.id#" forwards join of "#Src.id}
         end
      end

      proc {UnregisterPeers Peers}
         {RingList.forAll Peers
            proc {$ Peer}
               {@ComLayer stopMonitor(Peer)}
            end}
      end

      proc {WatchPeers Peers}
         {RingList.forAll Peers
            proc {$ Peer}
               {@ComLayer monitor(Peer)}
            end}
      end

      proc {Zend Target Msg}
         {System.show @SelfRef.id#'sending a darn message'#Msg#to#Target.id}
         {@ComLayer sendTo(Target Msg log:rlxring)}
      end

      %%--- Events ---

      proc {BadRingRef Event}
         badRingRef = Event
      in
         {System.show 'BAD ring reference. I cannot join'}
         skip %% TODO: trigger some error message
      end

      proc {Crash Event}
         crash(Pbeer) = Event
      in
         {System.showInfo "Peer "#Pbeer.id#" has crashed. Detected by "#@SelfRef.id}
         Crashed  := {PbeerList.add Pbeer @Crashed}
         SuccList := {RingList.remove Pbeer @SuccList}
         PredList := {RingList.remove Pbeer @PredList}
         {@FingerTable remove(Pbeer)}
         if Pbeer == @Succ then
            Succ := {RingList.getFirst @SuccList @SelfRef}
            {Monitor @Succ}
            {Zend @Succ fix(src:@SelfRef)}
         end
         if Pbeer == @Pred then
            if @PredList \= nil then
               Pred := {RingList.getLast @PredList}
            end
         end
      end

      %%% Midnattsol
      %% Fix means 'Self is Src's new succ' and 'Src wants to be Self's pred'
      %% Src is accepted as predecessor if:
      %% 1 - the current predecessor is dead
      %% 2 - Src is in (pred, self]
      %% Otherwise is a better predecessor of pred.
      proc {Fix Event}
         fix(src:Src) = Event
      in
         %% Src thinks I'm its successor so I add it to the predList
         PredList := {AddToList Src @PredList}
         {Monitor Src}
         if {PbeerList.isIn @Pred @Crashed} then
            Pred := Src %% Monitoring Src already and it's on predList
            {Zend Src fixOk(src:@SelfRef succList:@SuccList)}
         elseif {BelongsTo Src.id @Pred.id @SelfRef.id-1} then
            Pred := Src %% Monitoring Src already and it's on predList
            {Zend Src fixOk(src:@SelfRef succList:@SuccList)}
            %{Zend Src predFound(pred:Src last:true) Self}
         else
            %% Just keep it in a branch
            %{Route predFound(pred:Src last:true) Src.id Self}
            skip
         end
      end

      proc {FixOk Event}
         fixOk(src:Src succList:SrcSuccList) = Event
      in
         SuccList := {UpdateList @SuccList Src SrcSuccList}
         {Zend @Pred updateSuccList(src:@SelfRef
                                    succList:@SuccList
                                    counter:LogMaxKey)}
      end

      proc {GetComLayer Event}
         getComLayer(Res) = Event
      in
         Res = @ComLayer
      end

      proc {GetFullRef Event}
         getFullRef(FullRef) = Event
      in
         FullRef = ref(pbeer:@SelfRef ring:@Ring)
      end

      proc {GetId Event}
         getId(Res) = Event
      in
         Res = @SelfRef.id
      end

      proc {GetMaxKey Event}
         getMaxKey(Res) = Event
      in
         Res = MaxKey
      end

      proc {GetPred Event}
         getSucc(Peer) = Event
      in
         Peer = @Pred
      end

      proc {GetRange Event}
         getRange(Res) = Event
      in
      	Res = (@Pred.id+1 mod MaxKey)#@SelfRef.id
      end

      proc {GetRef Event}
         getRef(Res) = Event
      in
      	Res = @SelfRef
      end

      proc {GetRingRef Event}
         getRingRef(RingRef) = Event
      in
         RingRef = @Ring
      end

      proc {GetSucc Event}
         getSucc(Peer) = Event
      in
         Peer = @Succ
      end

      proc {Hint Event}
         hint(succ:_/*NewSucc*/) = Event
      in
         %%TODO. First I need to guarantee that this is a safe message
         skip
      end

      proc {IdInUse Event}
         idInUse(Id) = Event
      in
         %%TODO. Get a new id and try to join again
         if @SelfRef.id == Id then
            {System.show 'I cannot join because my Id is already in use'}
         else
            {System.showInfo "My id "#@SelfRef.id#" is considered to be in use as "#Id}
         end
      end

      proc {Init Event}
         skip
      end

      proc {Join Event}
         join(src:Src ring:SrcRing ...) = Event
         %% Event join might come with flag last = true guessing to reach the
         %% responsible. If I am not the responsible, message has to be 
         %% backwarded to the branch. 
      in
         if @Ring \= SrcRing then
            {Zend Src badRingRef}
         elseif @SelfRef.id == Src.id then
            {Zend Src idInUse(Src.id)}
         elseif {Not {PbeerList.isIn @Succ @Crashed}} then
            if {BelongsTo Src.id @Pred.id @SelfRef.id} then
               OldPred = @Pred
            in
               {Zend Src joinOk(pred:OldPred
                                succ:@SelfRef
                                succList:@SuccList)}
               Pred := Src
               {Monitor Src} 
               %{Blabla @(Self.id)#" accepts new pred "#Sender.id}
               PredList := {AddToList @Pred @PredList}
            else
               %NOT FOR ME - going to route
               {Route Event Src.id}
            end
         else
            {Zend Src joinLater}
         end
      end

      proc {PredNoMore Event}
         predNoMore(OldPred) = Event
      in
         PredList := {RingList.remove OldPred @PredList}
         %% TODO: Add treatment of hint message here
      end

      proc {JoinLater Event}
         joinLater(NewSucc) = Event
      in
         {Timer JOIN_WAIT Self startJoin(succ:NewSucc ring:@WishedRing)}
      end

      proc {JoinOk Event}
         joinOk(pred:NewPred succ:NewSucc succList:NewSuccList) = Event
      in
         if {BelongsTo NewSucc.id @SelfRef.id @Succ.id} then
            Succ := NewSucc
            SuccList := {UpdateList @SuccList NewSucc NewSuccList}
            Ring := @WishedRing
            WishedRing := none
            {Monitor @Succ} 
            {@FingerTable findFingers(Succ)}
         end
         if {BelongsTo NewPred.id @Pred.id @SelfRef.id} then
            {Zend NewPred newSucc(newSucc:@SelfRef succList:@SuccList)}
            Pred := NewPred
            PredList := {AddToList NewPred @PredList}
            %% set a failure detector on the predecessor
            {Monitor NewPred} 
         end
      end

      proc {NewSucc Event}
         newSucc(newSucc:NewSucc succList:NewSuccList) = Event
      in
         %{BlablaNonl NewSucc.id#" wannabe my new succ of "#@(Self.id)} 
         if {BelongsTo NewSucc.id @SelfRef.id @Succ.id} then
            SuccList := {UpdateList @SuccList NewSucc NewSuccList}
            {Zend @Succ predNoMore(@SelfRef)}
            {Zend @Pred updSuccList(src:@SelfRef
                                    succList:@SuccList
                                    counter:LogMaxKey)}
            Succ := NewSucc
            {Monitor NewSucc}
         end
      end

      proc {SetFingerTable Event}
         setFingerTable(NewFingerTable) = Event
      in
         FingerTable := NewFingerTable
      end

      proc {SetLogger Event}
         {@ComLayer Event}
      end

      proc {StartJoin Event}
         startJoin(succ:NewSucc ring:RingRef) = Event
      in
         {System.show @SelfRef.id#'starting to join'}
         WishedRing := RingRef
         {Zend NewSucc join(src:@SelfRef ring:RingRef)}
      end

      proc {UpdSuccList Event}
         updSuccList(src:Src succList:NewSuccList counter:Counter) = Event
      in
         if @Succ.id == Src.id then
            SuccList := {UpdateList @SuccList Src NewSuccList}
            if Counter > 0 then
               {Zend @Pred updSuccList(src:@SelfRef
                                       succList:@SuccList
                                       counter:Counter - 1)}
            end
         end
      end

      Events = events(
                  crash:         Crash
                  badRingRef:    BadRingRef
                  fix:           Fix
                  fixOk:         FixOk
                  getComLayer:   GetComLayer
                  getFullRef:    GetFullRef
                  getId:         GetId
                  getMaxKey:     GetMaxKey
                  getPred:       GetPred
                  getRange:      GetRange
                  getRef:        GetRef
                  getRingRef:    GetRingRef
                  getSucc:       GetSucc
                  hint:          Hint
                  idInUse:       IdInUse
                  init:          Init
                  injectPermFail:InjectPermFail
                  join:          Join
                  predNoMore:    PredNoMore
                  joinLater:     JoinLater
                  joinOk:        JoinOk
                  newSucc:       NewSucc
                  setFingerTable:SetFingerTable
                  setLogger:     SetLogger
                  startJoin:     StartJoin
                  updSuccList:   UpdSuccList
                  )

   in %% --- New starts ---
      %% Creating the component and collaborators
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         %Listener = FullComponent.listener
      end
      Timer = {TimerMaker.new}
      ComLayer = {NewCell {Network.new}}
      {@ComLayer setListener(Self)}

      if {HasFeature Args maxKey} then
         MaxKey = Args.maxKey
      else
         MaxKey = MAX_KEY
      end
      LogMaxKey = {Float.toInt {Float.log {Int.toFloat MaxKey+1}}}

      %% Peer State
      if {HasFeature Args id} then
         SelfRef = {NewCell pbeer(id:Args.id)}
      else
         SelfRef = {NewCell pbeer(id:{KeyRanges.getRandomKey MaxKey})}
      end
      SelfRef := {Record.adjoinAt @SelfRef port {@ComLayer getPort($)}}
      {@ComLayer setId(@SelfRef.id)}

      Crashed     = {NewCell {PbeerList.new}}
      Pred        = {NewCell @SelfRef}
      PredList    = {NewCell {RingList.new}}
      Succ        = {NewCell @SelfRef}
      SuccList    = {NewCell {RingList.new}} 
      Ring        = {NewCell ring(name:lucifer id:{NewName})}
      WishedRing  = {NewCell none}
      FingerTable = {NewCell BasicForward}
      %% Return the component
      Self
   end
end
