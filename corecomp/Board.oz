/*-------------------------------------------------------------------------
 *
 * Board.oz
 *
 *   A board is like a uni-directional channel. Only one component publish and
 *   the others subscribe to the board to receive the messages. 
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
 *    The idea of this board is the allow the composition of three or more
 *    components. If two components are connected, the triggering of the
 *    messages can be done directly. If you want that two or more components
 *    listen to the events triggered by another one, then you can build a
 *    Board, where one component publish messages, and the board triggers them
 *    in the list of subscribed components. A Board is a component itself, but
 *    it uses its own way of handling events, because it needs to handle 'any'
 *    event.
 *
 *-------------------------------------------------------------------------
 */

functor

export
   Make

define

   fun {Make}
      Key
      Subscribers
      BoardPort
      BoardStream
      
      %% Local proceduresto modify the state. Note that the component structure
      %% provides exclusive access to the state. There is no risk of race 
      %% conditions
      proc {AddSubscriber Client}
         New Old
      in
         Old = Subscribers := New
         New = Client|Old
      end

      %% This is how other components will publish messages on the board
      proc {Publisher Msg}
         {Port.send BoardPort Msg}
      end

      proc {Subscriber Client}
         {Port.send BoardPort subscribe(Key Client)}
      end

      %% Handle events for subscription and forward any other event to the
      %% subscribers
      proc {UponEvent BoardStream}
         case BoardStream
         of subscribe(!Key Client)|NewStream then
            {AddSubscriber Client}
            {UponEvent NewStream}
         [] AnyEvent|NewStream then
            for Client in @Subscribers do
               {Client AnyEvent}
            end
            {UponEvent NewStream}
         [] nil then
            skip
         end
      end
   in
      Key         = {NewName}
      Subscribers = {Cell.new nil}
      BoardPort   = {Port.new BoardStream}
      thread
         {UponEvent BoardStream}
      end
      [Publisher Subscriber]
   end

end
