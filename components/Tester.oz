%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   System
   Board       at 'Board.ozf'
   Component   at 'Component.ozf'

define
   
   fun {MakeSpeaker}
      Listener
      proc {Say Event}
         say(Text) = Event
      in
         {@Listener listen(Text)}
      end
      proc {SetListener Event}
         setListener(NewListener) = Event
      in
         Listener := NewListener
      end
      Events = events(
                  say:           Say
                  setListener:   SetListener
                  )
   in
      Listener = {Cell.new Component.dummy}
      {Component.make Events}
   end

   fun {MakeListener Id}
      proc {Listen Event}
         listen(Msg) = Event
      in
         {System.show Id#Msg}
      end
      Events = events(listen: Listen)
   in
      {Component.make Events}
   end

   Speaker
   Client1
   Client2
   Client3
   BoardA
   SubscriberA
   BoardB
   SubscriberB
in
   %% Initializing
   Speaker = {MakeSpeaker}
   Client1 = {MakeListener 1}
   Client2 = {MakeListener 2}
   Client3 = {MakeListener 3}
   [BoardA SubscriberA] = {Board.make}
   [BoardB SubscriberB] = {Board.make}
   %% Triggering some events and composing components
   {Speaker say(foo)}
   {Speaker setListener(Client1)}
   {Delay 1000}
   {Speaker say(first)}
   {SubscriberA Client2}
   {Speaker setListener(BoardA)}
   {Delay 1000}
   {Speaker say(second)}
   {Delay 1000}
   {SubscriberA Client1}
   {Speaker say(third)}
   {Speaker setListener(BoardB)}
   {Speaker say(forth)}
   {Delay 1000}
   {SubscriberB Client3}
   {Delay 1000}
   {Speaker say(fifth)}
   {Delay 1000}
   {SubscriberB BoardA}
   {Delay 1000}
   {Speaker say(sixth)}
end 
