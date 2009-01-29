/*-------------------------------------------------------------------------
 *
 * Logger.oz
 *
 *    Log change of state, communication events, and whatever. 
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
 *    This component writes whatever information is given into a file and to a
 *    listener. One possible use is to attached it as extra listener (in a
 *    board) of another component in order to automatically log events.  It
 *    does not use the tipical core Component framework because it can handle
 *    any event.
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
   Open
   System
   Component   at '../corecomp/Component.ozf'

export
   Make

define

   class TextFile from Open.text Open.file end

   fun {Make FileName}
      Key
      LogFile
      LogListener
      LogPort

      proc {Logger Event}
         {Port.send LogPort Event}
      end

      proc {Closer}
         {Port.send LogPort close(Key)}
      end

      proc {UponEvent EventStream}
         case EventStream
         of close(!Key)|_ then
            {LogFile putS("\n")}
            {LogFile close}
         [] AnyEvent|NewStream then
            {@LogListener AnyEvent}
            {LogFile putS({Value.toVirtualString AnyEvent 1000 1000})}
            {UponEvent NewStream}
         end
      end
   in
      {System.show 'got'#FileName}
      if FileName == none then
         LogFile = Component.dummy
      else
         LogFile = {New TextFile init(name:  LogFile
                                      flags: [write create truncate text])}
      end
      {System.show 'logfile created'}
      LogListener = {NewCell Component.dummy}
      Key = {NewName}
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
      [Logger Closer]
   end
end

