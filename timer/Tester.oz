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

      proc {TriggerEvent Event}
         triggerEvent(Time) = Event
      in
         {MyTimer startTrigger(Time Ref zZz)}
      end
 
      proc {TriggerTimer Event}
         triggerTimer(Time) = Event
      in
         {MyTimer startTimer(Time Ref)}
      end
 
      proc {Timeout Event}
         {System.show 'i got a timeout'}
      end

      proc {ZZZ Event}
         {System.show 'zZzZzZzZzZzZ'}
      end

      Events = events(
                  triggerEvent:  TriggerEvent
                  triggerTimer:  TriggerTimer
                  timeout:       Timeout
                  zZz:           ZZZ
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
   {Tester triggerEvent(8000)}
   {Tester triggerTimer(1000)}
   {Tester triggerTimer(4000)}
   {Tester triggerTimer(2000)}
   {Tester triggerEvent(5000)}
   {Tester triggerTimer(1000)}
end
