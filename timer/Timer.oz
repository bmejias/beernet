/*-------------------------------------------------------------------------
 *
 * Timer.oz
 *
 *    Provies a timer that triggers timeout on the caller component
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
 *    This component has no state. It receives only one event on request,
 *    which is 'startTimer', with a time and a component as parameter. Once
 *    the time has passed, it triggers (as indication) the event 'timeout' on
 *    the caller component.
 *
 * EVENTS
 *
 *    Accepts: startTimer(Time Component) - Start the timer that will confirm to
 *    Component after Time milliseconds.
 *
 *    Confirmation: timeout - Used to indicate that Time milliseconds has
 *    passed.
 *
 *-------------------------------------------------------------------------
 */

functor

import
   Component   at '../corecomp/Component.ozf'

export
   Make

define   

   fun {Make}

      proc {StartTimer Event}
         startTimer(Time Component) = Event
      in
         thread
            {Delay Time}
            {Component timeout}
         end
      end
   
      Events = events(startTimer: StartTimer)
   in
      {Component.make Events}
   end

end
