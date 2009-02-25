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
               {Self.var.coroner register(watcher:@(Self.ref) target:Sender)} 
               %{Blabla @(Self.id)#" accepts new pred "#Sender.id}
               for OldP in @PredList do
                  {Zend OldP hint(Sender) Self}
               end
               (Self.predList) := OldPred|@(Self.predList)
            elseif Last then
               {Zend @(Self.pred) Msg Self}
               {Blabla @(Self.id)#" forwards join of "#Sender.id#" to pred "
                        #@(Self.pred).id}
            elseif {BelongsTo Sender.id @(Self.id) @(Self.succ).id} then
               {Zend @(Self.succ) join(sender:Sender last:true) Self}
               {Blabla @(Self.id)#" forwards join of "#Sender.id#" to "
                        #@(Self.succ).id}
            else
               {Forward Msg Sender.id Self}
               {Blabla @(Self.id)#" forwards join of "#Sender.id}
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
