/*-------------------------------------------------------------------------
 *
 * FailureDetector.oz
 *
 *    Sends keep alive messages to other nodes, and triggers crash event upon
 *    timeout without answer. Event alive is trigger to fix a false suspicion.
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
 *    Here it comes a better explanation about what the code does.
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
   Component   at '../corecomp/Component.ozf'
   PbeerList   at '../utils/PbeerList.ozf'
   Pp2p        at 'Pp2p.ozf'
   Timer       at '../timer/Timer.ozf'
export
   New
define

   DELTA       = 500    % Granularity to tune the failure detector
   TIMEOUT     = 2000   % Initial Timeout value
   MAX_TIMEOUT = 5000   % Timeout must not go beyond this value
   
   fun {New}
      ComLayer    % Low level communication layer
      Listener    % Component where the deliver messages will be triggered
      Self        % Reference to this component

      Alive       % Pbeers known to be alive
      Suspected   % List of suspected peers
      Pbeers      % Pbeers to be monitored
      NewPbeers   % Pbeers register during a ping round
      Period      % Period of time to time out
      TheTimer    % Component that triggers timeout

      proc {Monitor Event}
         monitor(Pbeer) = Event
      in
         NewPbeers := {PbeerList.add Pbeer @NewPbeers}
      end

      proc {Timeout Event}
         timeout = Event
      in
         if {PbeerList.intersection @Alive @Suspected} \= nil 
            andthen @Period + DELTA < MAX_TIMEOUT then
            Period := @Period + DELTA  
         end
         
      end

      Events = events(
                  monitor: Monitor  
                  timeout: Timeout
                  )
   in
      ComLayer    = {NewCell {Pp2p.new}}
      Pbeers      = {NewCell {PbeerList.new}}
      NewPbeers   = {NewCell {PbeerList.new}}
      Alive       = {NewCell {PbeerList.new}} 
      Suspected   = {NewCell {PbeerList.new}} 
      Period      = {NewCell TIMEOUT}
      TheTimer    = {Timer.new}

      Self        = {Component.new Events}
      Listener    = Self.listener
      {@ComLayer setListener Self.trigger}
      {TheTimer setListener(Self.trigger)}
      {TheTimer startTimer(@Period)}
      Self.trigger 
   end
end

