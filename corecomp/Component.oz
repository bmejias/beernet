/*-------------------------------------------------------------------------
 *
 * Component.oz
 *
 *    Provides a component creator with an asynchronous procedure to send
 *    messages to it.
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
 *    This is a module with a very basic event-driven component model. To
 *    create a component, the programmer has to provide a set of events and
 *    the representation of the state. Both are tuples. The component has a
 *    port as input mechanism. It runs on its own light thread and loops over
 *    the stream associated to the port. Every message received is an event to
 *    handle using the state as extra parameter.
 *
 *-------------------------------------------------------------------------
 */

functor

export
   Make
   Dummy

define

   fun {Make Events}
      CompPort
      CompStream

      %% This is the way to trigger an event on a component. It just send a
      %% message using the port. It is an asynchronous procedure.
      proc {Component Msg}
         {Port.send CompPort Msg}
      end

      %% Loop through the EventStream. Every event is handle with the state as
      %% extra parameter and a new state is returned.
      proc {UponEvent EventStream}
         case EventStream
         of Event|NewStream then
            {Events.{Label Event} Event} % Handle the event
            {UponEvent NewStream} % Loop for new events
         [] nil then
            skip
         end
      end

   in
      {Port.new CompStream CompPort}
      thread 
         {UponEvent CompStream}
      end
      Component
   end

   %% This component is useful when you want to discard events triggered by
   %% another component
   proc {Dummy _}
      skip
   end
end
