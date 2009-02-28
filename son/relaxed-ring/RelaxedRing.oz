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
   JOIN_WAIT   = 5000 % Milliseconds to wait to retry a join 
   BelongsTo   = KeyRanges.belongsTo

   %TODO: define if this is global or local to the peer
   %TODO: implement it correctly
   fun {GetPBeerRef}
      pbeer(id:666 port:{Port.new _})
   end

   fun {Make}
      Pred        % Reference to the predecessor
      PredList    % To remember peers that haven't acked joins of new preds
      Self        % Full Component
      SelfRef     % Pbeer reference pbeer(id:<Id> port:<Port>)
      Succ        % Reference to the successor
      SuccList    % Successor List. Used for failure recovery

      %% --- Utils ---
      ComLayer    % Network component
      Listener    % Component where the deliver messages will be triggered
      Logger      % Component to log every sent and received message
      Timer       % Component to rigger some events after the requested time

      proc {Zend Target Msg}
         {@ComLayer sendTo(Target Msg log:rlxring)}
      end

      %TODO: Forward following the routing strategy
      proc {Forward _ _ } skip end

      %TODO: Decide whether I need a coroner or not
      proc {Watcher _} skip end

      %%--- Events ---

      proc {Hint Event}
         hint(succ:NuSucc) = Event
      in
         %TODO. First I need to guarantee that this is a safe message
         skip
      end

      proc {Join Event}
         join(src:Src ...) = Event
         %% Event join might come with flag last = true guessing to reach the
         %% responsible. If I am not the responsible, message has to be 
         %% backwarded to the branch. 
      in
         if @Succ == nil then
            %{Blabla "sending try to join later"}
            {Zend Src joinLater}
         else
            if {BelongsTo Src.id @Pred.id @SelfRef.id} then
               OldPred = @Pred
            in
               {Zend Src joinOk(pred:OldPred succ:@SelfRef succList:@SuccList)}
               Pred := Src
               %% set a failure detector on the predecessor 
               {Watcher register(watcher:@SelfRef target:Src)} 
               %{Blabla @(Self.id)#" accepts new pred "#Sender.id}
               for OldP in @PredList do
                  {Zend OldP hint(succ:Src)}
               end
               PredList := OldPred|@PredList
            elseif {HasFeature Event last} andthen Event.last then
               %TODO: check also a possible forward to PredList
               {Zend @Pred Event}
               %{Blabla @(Self.id)#" forwards join of "#Sender.id#" to pred "
               %         #@(Self.pred).id}
            elseif {BelongsTo Src.id @SelfRef.id @Succ.id} then
               {Zend @Succ join(src:Src last:true)}
               %{Blabla @SelfRef.id#" forwards join of "#Sender.id#" to "
               %         #@(Self.succ).id}
            else
               {Forward Event Src.id}
               %{Blabla @SelfRef.id#" forwards join of "#Src.id}
            end
         end
      end

      proc {JoinLater Event}
         joinLater(NuSucc) = Event
      in
         {Timer JOIN_WAIT Self startJoin(succ:NuSucc)}
      end

      proc {JoinOk Event}
         joinOk(pred:NuPred succ:NuSucc succList:NuSuccList) = Event
      in
         Succ := NuSucc
         SuccList := NuSucc|NuSuccList %TODO: get a good size for this
         %% set a failure detector on the successor
         {Watcher register(watcher:@(Self.ref) target:Succ)} 
         if @(Self.pred) == nil orelse
            {BelongsTo Pred.id @(Self.pred).id @(Self.id)} then
            if {GetConnection Self} then
               {Zend Pred newSucc(newSucc:@(Self.ref)
                                 oldSucc:@(Self.succ)
                                 succList:@(Self.succList)) Self}
               (Self.pred) := Pred
               %% set a failure detector on the predecessor
               {Self.var.coroner register(watcher:@(Self.ref) target:Pred)} 
            else
               Blacklist = {Dictionary.condGet Self.var blacklist nil}
            in
               Self.var.blackList := Pred.id|Blacklist
               {Blabla @(Self.id)#" didn't get connection to "#Pred.id}
               (Self.pred) := Pred
            end
         end
         {Blabla @(Self.id)#" joined as pred of "#@(Self.succ).id}
         {FindAndConnectToFingers Self}
         unit = {Dictionary.condGet Self.var joinAck unit}
      end

      proc {StartJoin Event}
         startJoin(NuSucc) = Event
      in
         {Zend NuSucc startJoin(src:@SelfRef)}
      end

      Events = events(
                  hint:       Hint
                  join:       Join
                  joinLater:  JoinLater
                  joinOk:     JoinOk
                  startJoin:  StartJoin
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
