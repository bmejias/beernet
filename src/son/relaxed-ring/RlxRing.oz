/*-------------------------------------------------------------------------
 *
 * RelaxedRing.oz
 *
 *    Relaxed-ring maintenance algorithm
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
   Utils       at '../../utils/Misc.ozf'
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
   fun {New CallArgs}
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
      Listener    % Component where the deliver messages will be triggered
      %Logger      % Component to log every sent and received message
      Timer       % Component to rigger some events after the requested time

      Args
      FirstAck    % One shoot acknowledgement for first join

      fun {AddToList Peer L}
         {RingList.add Peer L @SelfRef.id MaxKey}
      end

      %% TheList should have no more than Size elements
      fun {UpdateList MyList NewElem OtherList}
         FinalList _/*DropList*/
      in
         FinalList = {NewCell MyList}
         {RingList.forAll {Vacuum {AddToList NewElem OtherList} @Crashed}
                           proc {$ Pbeer}
                              FinalList := {AddToList Pbeer @FinalList}
                           end}
         FinalList := {RingList.keepAndDrop LogMaxKey @FinalList _/*DropList*/}
         % TODO: verify this operation
         %{UnregisterPeers DropList}
         {WatchPeers @FinalList}
         @FinalList
      end

      proc {BasicForward Event}
         case Event
         of route(msg:Msg src:_ to:_) then
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

      proc {RlxRoute Event Target}
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
            {@FingerTable route(msg:Event src:Event.src to:Target)}
            %{Blabla @SelfRef.id#" forwards join of "#Src.id}
         end
      end

/*
      proc {UnregisterPeers Peers}
         {RingList.forAll Peers
            proc {$ Peer}
               {@ComLayer stopMonitor(Peer)}
            end}
      end
*/

      proc {WatchPeers Peers}
         {RingList.forAll Peers
            proc {$ Peer}
               {@ComLayer monitor(Peer)}
            end}
      end

      proc {Zend Target Msg}
         %{System.show @SelfRef.id#'sending a darn message'#Msg#to#Target.id}
         {@ComLayer sendTo(Target Msg log:rlxring)}
      end

      %%--- Events ---

      proc {Alive Event}
      %% TODO
      %   alive(Pbeer) = Event
      %in
         skip
      end

      proc {Any Event}
         %{System.show '++++++++++triggering Event to Listener'#Event}
         %{System.show 'Listener'#@Listener}
         {@Listener Event}
      end

      proc {BadRingRef Event}
         badRingRef = Event
      in
         {System.show 'BAD ring reference. I cannot join'}
         skip %% TODO: trigger some error message
      end

      proc {Crash crash(Pbeer)}
         {System.showInfo '#'("Peer " Pbeer.id " has crashed. Detected by "
                              @SelfRef.id)}
         Crashed  := {PbeerList.add Pbeer @Crashed}
         SuccList := {RingList.remove Pbeer @SuccList}
         PredList := {RingList.remove Pbeer @PredList}
         {@FingerTable removeFinger(Pbeer)}
         if Pbeer == @Succ then
            Succ := {RingList.getFirst @SuccList @SelfRef}
            {Monitor @Succ}
            {Zend @Succ fix(src:@SelfRef)}
         end
         if Pbeer == @Pred then
            if @PredList \= nil then
               Pred := {RingList.getLast @PredList @Pred}
               {Monitor @Pred}
            end
         end
      end

      %% DSend
      %% Send directly to a port with the correct format
      proc {DSend Event}
         dsend(Msg to:To ...) = Event
      in
         if {HasFeature Event log} then   
            {@ComLayer sendTo(To Msg log:Event.log)}
         else
            {@ComLayer sendTo(To Msg)}
         end
      end

      %%% Midnattsol
      %% Fix means 'Self is Src's new succ' and 'Src wants to be Self's pred'
      %% Src is accepted as predecessor if:
      %% 1 - the current predecessor is dead
      %% 2 - Src is in (pred, self]
      %% Otherwise is a better predecessor of pred.
      proc {Fix fix(src:Src)}
         %% Src thinks I'm its successor so I add it to the predList
         PredList := {AddToList Src @PredList}
         {Monitor Src}
         if {PbeerList.isIn @Pred @Crashed} then
            Pred := Src %% Monitoring Src already and it's on predList
            {Zend Src fixOk(src:@SelfRef succList:@SuccList)}
            {Monitor Src}
         elseif {BelongsTo Src.id @Pred.id @SelfRef.id-1} then
            Pred := Src %% Monitoring Src already and it's on predList
            {Zend Src fixOk(src:@SelfRef succList:@SuccList)}
            %{Zend Src predFound(pred:Src last:true) Self}
            {Monitor Src}
         else
            {System.show 'GGGGGGGGGGRRRRRRRRRRRAAAAAAAAAA'#@SelfRef.id}
            %% Just keep it in a branch
            %{RlxRoute predFound(pred:Src last:true) Src.id Self}
            skip
         end
      end

      proc {FixOk fixOk(src:Src succList:SrcSuccList)}
         SuccList := {UpdateList @SuccList Src SrcSuccList}
         {Zend @Pred updSuccList(src:@SelfRef
                                 succList:@SuccList
                                 counter:LogMaxKey)}
      end

      proc {GetComLayer getComLayer(Res)}
         Res = @ComLayer
      end

      proc {GetFullRef getFullRef(FullRef)}
         FullRef = ref(pbeer:@SelfRef ring:@Ring)
      end

      proc {GetId getId(Res)}
         Res = @SelfRef.id
      end

      proc {GetMaxKey getMaxKey(Res)}
         Res = MaxKey
      end

      proc {GetPred getPred(Peer)}
         Peer = @Pred
      end

      proc {GetRange getRange(Res)}
      	Res = (@Pred.id+1 mod MaxKey)#@SelfRef.id
      end

      proc {GetRef getRef(Res)}
      	Res = @SelfRef
      end

      proc {GetRingRef getRingRef(RingRef)}
         RingRef = @Ring
      end

      proc {GetSucc getSucc(Peer)}
         Peer = @Succ
      end

      proc {Hint Event}
         hint(succ:_/*NewSucc*/) = Event
      in
         %%TODO. First I need to guarantee that this is a safe message
         skip
      end

      proc {IdInUse idInUse(Id)}
         %%TODO. Get a new id and try to join again
         if @SelfRef.id == Id then
            {System.show 'I cannot join because my Id is already in use'}
         else
            {System.showInfo '#'("My id " @SelfRef.id
                                 " is considered to be in use as " Id)}
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
               {RlxRoute Event Src.id}
            end
         else
            {Zend Src joinLater}
         end
      end

      proc {PredNoMore predNoMore(OldPred)}
         PredList := {RingList.remove OldPred @PredList}
         %% TODO: Add treatment of hint message here
      end

      proc {JoinLater joinLater(NewSucc)}
         {Timer JOIN_WAIT Self startJoin(succ:NewSucc ring:@WishedRing)}
      end

      proc {JoinOk joinOk(pred:NewPred succ:NewSucc succList:NewSuccList)}
         if {BelongsTo NewSucc.id @SelfRef.id @Succ.id} then
            Succ := NewSucc
            SuccList := {UpdateList @SuccList NewSucc NewSuccList}
            Ring := @WishedRing
            WishedRing := none
            {Monitor NewSucc} 
            {@FingerTable monitor(NewSucc)}
            {RingList.forAll @SuccList proc {$ Pbeer}
                                          {@FingerTable monitor(Pbeer)}
                                       end}
            FirstAck = unit
         end
         if {BelongsTo NewPred.id @Pred.id @SelfRef.id} then
            {Zend NewPred newSucc(newSucc:@SelfRef succList:@SuccList)}
            Pred := NewPred
            PredList := {AddToList NewPred @PredList}
            %% set a failure detector on the predecessor
            {Monitor NewPred} 
            {@FingerTable monitor(NewPred)}
         end
      end

      proc {Lookup lookup(key:Key res:Res)}
         HKey
      in
         HKey = {Utils.hash Key MaxKey}
         {LookupHash lookupHash(hkey:HKey res:Res)}
      end

      proc {LookupHash lookupHash(hkey:HKey res:Res)}
         {Route route(msg:lookupRequest(res:Res) src:@SelfRef to:HKey)}
      end

      proc {LookupRequest lookupRequest(res:Res)}
         %% TODO: mmm... can we trust distributed variable binding?
         Res = @SelfRef
      end

      proc {NewSucc newSucc(newSucc:NewSucc succList:NewSuccList)}
         %{BlablaNonl NewSucc.id#" wannabe my new succ of "#@(Self.id)} 
         if {BelongsTo NewSucc.id @SelfRef.id @Succ.id} then
            SuccList := {UpdateList @SuccList NewSucc NewSuccList}
            {Zend @Succ predNoMore(@SelfRef)}
            {Zend @Pred updSuccList(src:@SelfRef
                                    succList:@SuccList
                                    counter:LogMaxKey)}
            Succ := NewSucc
            {Monitor NewSucc}
            {@FingerTable monitor(NewSucc)}
            {RingList.forAll @SuccList proc {$ Pbeer}
                                          {@FingerTable monitor(Pbeer)}
                                       end}
         end
      end

      proc {Route Event}
         route(msg:Msg src:_ to:Target ...) = Event
      in
         %{System.show 'going to route '#Msg}
         if {BelongsTo Target @Pred.id @SelfRef.id} then
            %{System.show @SelfRef.id#' it is mine '#Event}
            %% This message is for me
            {Self Msg}
         elseif {HasFeature Event last} andthen Event.last then
            %{System.show @SelfRef.id#' gotta go backwards '#Event}
            %% I am supposed to be the responsible, but I have a branch
            %% or somebody was missed (non-transitive connections)
            {Backward Event Target}
         elseif {BelongsTo Target @SelfRef.id @Succ.id} then
            %% I think my successor is the responsible => set last = true
            %{System.show @SelfRef.id#' I missed one week? '#Event}
            {Zend @Succ {Record.adjoinAt Event last true}}
            %{Blabla @SelfRef.id#" forwards join of "#Sender.id#" to "
            %         #@(Self.succ).id}
         else
            %% Forward the message using the routing table
            %{System.show @SelfRef.id#'Forwarding '#Event}
            {@FingerTable Event}
            %{Blabla @SelfRef.id#" forwards join of "#Src.id}
         end
      end

      proc {SetFingerTable setFingerTable(NewFingerTable)}
         FingerTable := NewFingerTable
      end

      proc {SetLogger Event}
         {@ComLayer Event}
      end

      proc {StartJoin startJoin(succ:NewSucc ring:RingRef)}
         %{System.show @SelfRef.id#'starting to join'}
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
            {RingList.forAll @SuccList proc {$ Pbeer}
                                          {@FingerTable monitor(Pbeer)}
                                       end}
         end
      end

      ToFingerTable = {Utils.delegatesTo FingerTable}

      Events = events(
                  alive:         Alive
                  any:           Any
                  crash:         Crash
                  badRingRef:    BadRingRef
                  dsend:         DSend
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
                  join:          Join
                  joinLater:     JoinLater
                  joinOk:        JoinOk
                  lookup:        Lookup
                  lookupHash:    LookupHash
                  lookupRequest: LookupRequest
                  needFinger:    ToFingerTable
                  newFinger:     ToFingerTable
                  newSucc:       NewSucc
                  predNoMore:    PredNoMore
                  route:         Route
                  refreshFingers:ToFingerTable
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
         Listener = FullComponent.listener
      end
      Timer = {TimerMaker.new}
      ComLayer = {NewCell {Network.new}}
      {@ComLayer setListener(Self)}

      Args        = {Utils.addDefaults CallArgs def(firstAck:_ maxKey:MAX_KEY)}
      FirstAck    = Args.firstAck
      MaxKey      = Args.maxKey
      LogMaxKey   = {Float.toInt {Float.log {Int.toFloat MaxKey+1}}}

      %% Peer State
      if {HasFeature Args id} then
         SelfRef = {NewCell pbeer(id:Args.id)}
      else
         SelfRef = {NewCell pbeer(id:{KeyRanges.getRandomKey MaxKey})}
      end
      SelfRef := {Record.adjoinAt @SelfRef port {@ComLayer getPort($)}}
      {@ComLayer setId(@SelfRef.id)}

      Pred        = {NewCell @SelfRef}
      Succ        = {NewCell @SelfRef}
      PredList    = {NewCell {RingList.new}}
      SuccList    = {NewCell {RingList.new}} 
      Crashed     = {NewCell {PbeerList.new}}
      Ring        = {NewCell ring(name:lucifer id:{Name.new})}
      WishedRing  = {NewCell none}
      FingerTable = {NewCell BasicForward}
      %% Return the component
      Self
   end
end
