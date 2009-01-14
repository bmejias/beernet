%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   System
   Component   at '../corecomp/Component.ozf'
   Timer       at 'Timer.ozf'

define
   
   fun {MakeTimerTester}

      Ref
      MyTimer

      proc {TriggerTimer Event}
         triggerTimer(Time) = Event
      in
         {MyTimer startTimer(Time Ref)}
      end
 
      proc {Timeout Event}
         {System.show 'i got a timeout'}
      end

      Events = events(
                  triggerTimer: TriggerTimer
                  timeout:      Timeout
                  )
   in
      Ref      = {Component.make Events}
      MyTimer  = {Timer.make}
      Ref
   end

   Tester

in

   Tester = {MakeTimerTester}
   {System.show foo}
   {Tester triggerTimer(1000)}
   {Tester triggerTimer(4000)}
   {Tester triggerTimer(2000)}
   {Tester triggerTimer(1000)}
end
