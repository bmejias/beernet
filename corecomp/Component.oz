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

import
   System

export
   New
   NewTrigger
   Dummy

define

   %% New returns a record with the procedure to trigger events on it,
   %% which is equivalent to a regular component. But it also include a field
   %% with the default listener
   fun {New Events}
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
            Implemented = {Arity Events}
         in
            if {Member EventName Implemented} then
               {Events.EventName Event} % Handle the event
               {UponEvent NewStream} % Loop for new events
            else
               %% Use default events
               case Event 
               of setListener(NewListener) then
                  CompListener := NewListener
                  {UponEvent NewStream} % Loop for new events
               [] signalDestroy then
                  skip % Stop looping
               else
                  if {Member any Implemented} then
                     {Events.any Event}
                  else
                     {System.show 'Unknown event'#Event}
                  end
                  {UponEvent NewStream} % Loop for new events
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
   fun {NewTrigger Events}
      FullComponent
   in
      FullComponent = {New Events}
      FullComponent.trigger
   end

   %% This component is useful when you want to discard events triggered by
   %% another component
   proc {Dummy _}
      skip
   end
end
