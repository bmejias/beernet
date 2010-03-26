/*-------------------------------------------------------------------------
 *
 * Logger.oz
 *
 *    Log change of state, communication events, and whatever. 
 *
 * LICENSE
 *
 *    Beernet is released under the Beerware License (see file LICENSE) 
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
 *    This component writes into a file whatever information is given to it.
 *    The information is also forwarded to a listener.  It does not use the
 *    tipical core Component framework because it logs any event, even
 *    'setListener'. This is why it has its own way on setting the log
 *    listener.  There are two ways of using a logger. You use it as a
 *    component and you explicitly send the events you want to log. The second
 *    choice is to put it in a board together with another component. Then,
 *    every message sent to the board will be automatically handle by the
 *    component and sent to the logger.
 *
 * EVENTS
 *
 *    Accepts: whatever - Every event will be log as is, without making a
 *    special treatment.
 *
 *    Indication: whatever - Just transmit whatever message to a possible
 *    listener
 *
 *-------------------------------------------------------------------------
 */

functor

import
   System
   Component   at '../corecomp/Component.ozf'
   TextFile    at '../utils/TextFile.ozf'

export
   New 

define

   fun {New FileName}
      KeyCloser
      KeyListener
      LogFile
      LogListener
      LogPort

      proc {Logger Event}
         {Port.send LogPort Event}
      end

      proc {Closer}
         {Port.send LogPort close(KeyCloser)}
      end

      proc {SetListener NewListener}
         {Port.send LogPort setListener(KeyListener NewListener)}
      end

      proc {UponEvent EventStream}
         case EventStream
         of close(!KeyCloser)|_ then
            {LogFile write("\n")}
            {LogFile close}
         [] setListener(!KeyListener NewListener)|NewStream then
            LogListener := NewListener
            {UponEvent NewStream}
         [] AnyEvent|NewStream then
            {@LogListener AnyEvent}
            {LogFile write(AnyEvent)}
            {UponEvent NewStream}
         end
      end
   in
      {System.show 'got'#FileName}
      if FileName == none then
         LogFile = Component.dummy
      else
         LogFile = {TextFile.new init(name:  FileName
                                      flags: [write create truncate text])}
      end
      {System.show 'logfile created'}
      LogListener = {NewCell Component.dummy}
      KeyCloser   = {NewName}
      KeyListener = {NewName}
      {System.show 'loglistener and key created'}
      local
         LogStream
      in
         {Port.new LogStream LogPort}
         thread 
            {UponEvent LogStream}
         end
      end
      {System.show 'loop launched'}
      log(logger:Logger close:Closer setListener:SetListener)
   end
end

