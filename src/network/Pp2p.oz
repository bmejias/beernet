/*-------------------------------------------------------------------------
 *
 * pp2p.oz
 *
 *    Implements perfect point-to-point link from Guerraoui's book
 *
 * LICENSE
 *
 *    Copyright (c) 2009 Universite catholique de Louvain
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
 *    This is an implementation of module 2.3 of R. Guerraouis book on reliable
 *    distributed programming. Properties "reliable delivery", "no duplication"
 *    and "no creation" are guaranteed by the implementation of Port in Mozart.
 *
 * EVENTS
 *
 *    Accepts: pp2pSend(Dest Msg) - Sends message Msg to destination Dest. Dest
 *    must be an Oz Port
 *
 *    Indication: pp2pDeliver(Src Msg) - Delivers message Msg sent by source
 *    Src.
 *    
 *-------------------------------------------------------------------------
 */

functor

import
   Component   at '../corecomp/Component.ozf'

export
   New

define

   fun {New}
      SitePort       % Port to receive messages
      Listener       % Upper layer component
      FullComponent  % This component

      proc {GetPort getPort(P)}
         P = SitePort
      end

      proc {PP2PSend pp2pSend(Dest Msg)}
         {Send Dest SitePort#Msg}
      end

      proc {HandleMessages Str}
         case Str
         of (Src#Msg)|NewStr then
            {@Listener pp2pDeliver(Src Msg)}
            {HandleMessages NewStr}
         [] nil then % Port close
            skip
         %% To avoid crashing when the format is not respected,
         %% uncomment the else statement
         %else
         %   {HandleMessages Str.2}
         end
      end

      Events = events(
                  getPort:    GetPort
                  pp2pSend:   PP2PSend
                  )

   in
      local
         Stream
      in
         {Port.new Stream SitePort}
         thread
            {HandleMessages Stream}
         end
      end
      FullComponent = {Component.new Events}
      Listener = FullComponent.listener
      FullComponent.trigger
   end
end
