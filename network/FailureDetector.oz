/*-------------------------------------------------------------------------
 *
 * FailureDetector.oz
 *
 *    Eventually perfect failure detector
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
 *    Sends keep alive messages to other nodes, and triggers crash event upon
 *    timeout without answer. Event alive is trigger to fix a false suspicion.
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
%   System
   Component   at '../corecomp/Component.ozf'
   PbeerList   at '../utils/PbeerList.ozf'
   Timer       at '../timer/Timer.ozf'
export
   New
define

   DELTA       = 500    % Granularity to tune the failure detector
   TIMEOUT     = 500   % Initial Timeout value
   MAX_TIMEOUT = 2000   % Timeout must not go beyond this value
   
   fun {New}
      ComLayer    % Low level communication layer
      Listener    % Component where the deliver messages will be triggered
      Self        % Reference to this component
      SelfPbeer   % Pbeer reference assinged by a external component

      Alive       % Pbeers known to be alive
      Suspected   % List of suspected peers
      Notified    % Pbeers already notified as crashed
      Pbeers      % Pbeers to be monitored
      NewPbeers   % Pbeers register during a ping round
      Period      % Period of time to time out
      TheTimer    % Component that triggers timeout

      %% Sends a ping message to all monitored pbeers and launch the timer
      proc {NewRound Event}
         start = Event
      in
         for Pbeer in @Pbeers do
            %{System.show 'sending ping to'#Pbeer}
            {ComLayer sendTo(Pbeer ping(@SelfPbeer tag:fd) log:faildet)}
         end
         {TheTimer startTimer(@Period)}
      end

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
         Suspected := {PbeerList.minus @Pbeers @Alive}
         %% Only notify about new suspicions
         for Pbeer in {PbeerList.minus @Suspected @Notified} do
            {@Listener crash(Pbeer)}
         end
         %% Clear up and get ready for new ping round
         Notified    := {PbeerList.union @Notified @Suspected}
         Alive       := {PbeerList.new}
         Suspected   := {PbeerList.new}
         Pbeers      := {PbeerList.union @Pbeers @NewPbeers}
         NewPbeers   := {PbeerList.new}
         {NewRound start}
      end

      proc {Ping Event}
         ping(Pbeer tag:fd) = Event
      in
%         {System.show 'pingpingpingping'#@SelfPbeer.id#' got ping from '#Pbeer.id}
         {ComLayer sendTo(Pbeer pong(@SelfPbeer tag:fd) log:faildet)}
      end

      proc {Pong Event}
         pong(Pbeer tag:fd) = Event
      in
%         {System.show 'pongpongpong'#@SelfPbeer.id#'       got pong from'#Pbeer.id}
         Alive := {PbeerList.add Pbeer @Alive}
         if {PbeerList.isIn Pbeer @Notified} then
            {Listener alive(Pbeer)}
         end
      end

      proc {SetPbeer Event}
         setPbeer(NewPbeer) = Event
      in
         SelfPbeer := NewPbeer
      end

      proc {SetComLayer Event}
         setComLayer(TheComLayer) = Event
      in
         ComLayer = TheComLayer
         SelfPbeer := {ComLayer getRef($)} 
      end

      proc {StopMonitor Event}
         stopMonitor(Pbeer) = Event
      in
         Pbeers := {PbeerList.remove Pbeer @Pbeers}
      end

      Events = events(
                  monitor:       Monitor
                  ping:          Ping
                  pong:          Pong
                  setPbeer:      SetPbeer
                  setComLayer:   SetComLayer
                  stopMonitor:   StopMonitor
                  start:         NewRound
                  timeout:       Timeout
                  )
   in
      Pbeers      = {NewCell {PbeerList.new}}
      NewPbeers   = {NewCell {PbeerList.new}}
      Alive       = {NewCell {PbeerList.new}} 
      Suspected   = {NewCell {PbeerList.new}} 
      Notified    = {NewCell {PbeerList.new}}
      Period      = {NewCell TIMEOUT}
      SelfPbeer   = {NewCell pbeer(id:~1 port:_)}
      TheTimer    = {Timer.new}

      Self        = {Component.new Events}
      Listener    = Self.listener
      {TheTimer setListener(Self.trigger)}
      {NewRound start}
      Self.trigger 
   end
end

