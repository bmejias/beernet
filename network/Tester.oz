%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   OS
   System
   Component   at '../corecomp/Component.ozf'
   Pp2p        at 'pp2p.ozf'

define
   
   fun {MakePingPongPlayer}
      Id
      ComLayer
      Self

      proc {InitPing Event}
         initPing(I OtherPlayer) = Event
      in
         {ComLayer pp2pSend(OtherPlayer ping(I))}
      end
 
      proc {Pp2pDeliver Event}
         pp2pDeliver(Src Msg) = Event
      in
         case Msg
         of ping(I) then
            if I > 0 then
               {System.show Id#ping(I)}
               {Delay 100 + {OS.rand} mod 100}
               {ComLayer pp2pSend(Src pong(I-1))}
            else
               {System.show Id#ping(I)}
            end
         [] pong(I) then
            if I > 0 then
               {System.show Id#pong(I)}
               {Delay 100 + {OS.rand} mod 100}
               {ComLayer pp2pSend(Src ping(I-1))}
            else
               {System.show Id#pong(I)}
            end
         else
            {System.show Id#'Something went wrong'#Msg}
         end
      end

      proc {GetRef Event}
         getRef(Ref) = Event
      in
         {ComLayer getPort(Ref)}
      end

      proc {SetId Event}
         setId(TheId) = Event
      in
         Id = TheId
      end

      Events = events(
                  initPing:      InitPing
                  getRef:        GetRef
                  pp2pDeliver:   Pp2pDeliver
                  setId:         SetId
                  )
   in
      ComLayer = {Pp2p.make}
      Self = {Component.make Events}
      {ComLayer setListener(Self)}
      Self
   end

   SiteA
   SiteB

in

   SiteA = {MakePingPongPlayer}
   SiteB = {MakePingPongPlayer}
   {SiteA setId(foo)}
   {SiteB setId(bar)}

   {SiteA initPing(10 {SiteB getRef($)})}
end
