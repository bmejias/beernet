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
   Network     at '../../network/Network.ozf'

export
   Make

define
   
   fun {Make}
      ComLayer    % Network component
      Listener    % Component where the deliver messages will be triggered
      Logger      % Component to log every sent and received message
      Pred        % Reference to the predecessor
      PredList    % To remember peers that haven't acked joins of new preds
      Self        % Full Component
      SelfRef     % Pbeer reference pbeer(id:<Id> port:<Port>)
      Succ        % Reference to the successor
      SuccList    % Successor List. Used for failure recovery

      %% --- Utils ---

      proc {Zend Target Msg}
         {@ComLayer sendTo(Target Msg log:rlxring)}
      end

      %TODO: This should come from Range utils
      fun {BelongsTo Id From To}
         false
      end

      %TODO: Decide whether I need a coroner or not
      proc {Coroner _} skip end

      %TODO: Forward following the routing strategy
      proc {Forward _ _ } skip end

      %%--- Events ---

      proc {Join Event}
         join(src:Src last:Last) = Event
      in
         if @Succ == nil then
            %{Blabla "sending try to join later"}
            {Zend Src tryJoinLater}
         else
            if {BelongsTo Src.id @Pred.id @SelfRef.id} then
               OldPred = @Pred
            in
               {Zend Src joinOk(pred:OldPred succ:@SelfRef succList:@SuccList)}
               Pred := Src
               %% set a failure detector on the predecessor 
               {Coroner register(watcher:@SelfRef target:Src)} 
               %{Blabla @(Self.id)#" accepts new pred "#Sender.id}
               for OldP in @PredList do
                  {Zend OldP hint(Src)}
               end
               PredList := OldPred|@PredList
            elseif Last then
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

      Events = events(
                  join:    Join
                  )
   in
      Self        = {Component.makeFull Events}
      Listener    = Self.listener
   end
end
