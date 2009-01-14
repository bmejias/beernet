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
 *    This file is part of Beernet
 *
 *    Beernet is free software: you can redistribute it and/or modify it under
 *    the terms of the GNU General Public License as published by the Free
 *    Software Foundation, either version 2 of the License, or (at your
 *    option) any later version.
 *
 *    Beernet is distributed in the hope that it will be useful, but WITHOUT
 *    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *    FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 *    more details.
 *
 *    You should have received a copy of the GNU General Public License along
 *    with Beernet. If not, see <http://www.gnu.org/licenses/>.
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
