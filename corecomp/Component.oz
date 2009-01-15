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
   MakeFull
   Dummy

define

   %% MakeFull returns a record with the procedure to trigger events on it,
   %% which is equivalent to a regular component. But it also include a field
   %% with the default listener
   fun {MakeFull Events}
      CompPort       % Receive events from other components
      CompListener   % Default component to trigger messages

      %% This is the way to trigger an event on a component. It just send a
      %% message using the port. It is an asynchronous procedure.
      proc {Trigger Msg}
         {Port.send CompPort Msg}
      end

      %% Loop through the EventStream. Every event is handle with the state as
      %% extra parameter and a new state is returned.
      proc {UponEvent EventStream}
         case EventStream
         of Event|NewStream then
            EventName = {Label Event}
         in
            if {Member EventName {Arity Events}} then
               {Events.EventName Event} % Handle the event
               {UponEvent NewStream} % Loop for new events
            else
               %% Use default events
               case Event 
               of setListener(NewListener) then
                  CompListener := NewListener
                  {UponEvent NewStream} % Loop for new events
               else
                  skip %% Discard unkown event
               end
            end
         [] nil then %% Component close
            skip
         end
      end

   in
      local
         CompStream
      in
         {Port.new CompStream CompPort}
         thread 
            {UponEvent CompStream}
         end
      end
      CompListener = {NewCell Dummy} 

      component(trigger:Trigger
                listener:CompListener)
   end

   %% This is the function to use if you do not want to use the default
   %% Listener of the full component.
   fun {Make Events}
      FullComponent
   in
      FullComponent = {MakeFull Events}
      FullComponent.trigger
   end

   %% This component is useful when you want to discard events triggered by
   %% another component
   proc {Dummy _}
      skip
   end
end
