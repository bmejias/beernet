%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   Application
   OS
   System
   Component   at '../corecomp/Component.ozf'
   Network     at 'Network.ozf'
   Pp2p        at 'Pp2p.ozf'

define
   
   fun {MakePp2pPingPongPlayer}
      Id
      Flag
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
               Flag = unit
            end
         [] pong(I) then
            if I > 0 then
               {System.show Id#pong(I)}
               {Delay 100 + {OS.rand} mod 100}
               {ComLayer pp2pSend(Src ping(I-1))}
            else
               {System.show Id#pong(I)}
               Flag = unit
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

      proc {SetFlag Event}
         setFlag(TheFlag) = Event
      in
         Flag = TheFlag
      end

      Events = events(
                  initPing:      InitPing
                  getRef:        GetRef
                  pp2pDeliver:   Pp2pDeliver
                  setId:         SetId
                  setFlag:       SetFlag
                  )
   in
      ComLayer = {Pp2p.make}
      Self = {Component.make Events}
      {ComLayer setListener(Self)}
      Self
   end
  
   %% The main different of this test is that events ping and pong are defined
   %% in their own procedure, and they are inscribed as events. In the previous
   %% test, they have to be matched from the Msg delivered by the Perfect
   %% point-to-point link.
   fun {MakeNetworkPingPongPlayer}
      Id
      Flag
      ComLayer
      OtherPlayer
      Self

      proc {InitPing Event}
         initPing(I Player) = Event
      in
         OtherPlayer = Player
         {ComLayer sendTo(OtherPlayer ping(I))}
      end
 
      proc {Ping Event}
         ping(I) = Event
      in
         if I > 0 then
            {System.show Id#ping(I)}
            {Delay 100 + {OS.rand} mod 100}
            {ComLayer sendTo(OtherPlayer pong(I-1))}
         else
            {System.show Id#ping(I)}
            Flag = unit
         end
      end

      proc {Pong Event}
         pong(I) = Event
      in
         if I > 0 then
            {System.show Id#pong(I)}
            {Delay 100 + {OS.rand} mod 100}
            {ComLayer sendTo(OtherPlayer ping(I-1))}
         else
            {System.show Id#pong(I)}
            Flag = unit
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

      proc {SetOtherPlayer Event}
         setOtherPlayer(Player) = Event
      in
         OtherPlayer = Player
      end

      proc {SetFlag Event}
         setFlag(TheFlag) = Event
      in
         Flag = TheFlag
      end

      Events = events(
                  initPing:         InitPing
                  getRef:           GetRef
                  ping:             Ping
                  pong:             Pong
                  setId:            SetId
                  setFlag:          SetFlag
                  setOtherPlayer:   SetOtherPlayer
                  )
   in
      ComLayer = {Network.make}
      Self = {Component.make Events}
      {ComLayer setListener(Self)}
      Self
   end

in
   local
      SiteA
      SiteB
      Finish
   in
      SiteA = {MakePp2pPingPongPlayer}
      SiteB = {MakePp2pPingPongPlayer}
      {SiteA setId(foo)}
      {SiteB setId(bar)}
      {SiteA setFlag(Finish)}
      {SiteB setFlag(Finish)}
      {System.show 'going to start testing Pp2pPinPong'}
      {SiteA initPing(10 {SiteB getRef($)})}
      {Wait Finish}
      {System.show 'finishing Pp2pPingPong'}
   end

   local
      SiteA
      SiteB
      Finish
   in
      SiteA = {MakeNetworkPingPongPlayer}
      SiteB = {MakeNetworkPingPongPlayer}
      {SiteA setId(netfoo)}
      {SiteB setId(netbar)}
      {SiteA setFlag(Finish)}
      {SiteB setFlag(Finish)}
      {System.show 'starting NetworkPinPong test'}
      {SiteB setOtherPlayer({SiteA getRef($)})}
      {SiteA initPing(10 {SiteB getRef($)})}
      {Wait Finish}
      {System.show 'finishing NetworkPingPong'}
   end
   {Application.exit 1}
end
