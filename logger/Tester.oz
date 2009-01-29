%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   Application
   System
   Player      at '../network/TestPlayers.ozf'
   Logger      at 'Logger.ozf'

define

   fun {NewLogListener}
      S P
      proc {Obj Msg}
         case Msg
         of release then
            for X in S do
               {System.show X}
            end
         else
            {Port.send P Msg}
         end
      end
   in
      {NewPort S P}
      Obj
   end

in

   local
      SiteA
      SiteB
      Finish
      ThisLogger
      LogListener
      ThisCloser
   in
      SiteA       = {Player.makeNetworkPingPongPlayer}
      SiteB       = {Player.makeNetworkPingPongPlayer}
      [ThisLogger  ThisCloser] = {Logger.make none}
      {System.show 'after creating this logger'}
      LogListener = {NewLogListener}
      {System.show 'after creating log listener'}
      {ThisLogger setListener(LogListener)}
      {System.show 'after setting loglistener'}
      {SiteA setId(netfoo)}
      {SiteB setId(netbar)}
      {SiteA setFlag(Finish)}
      {SiteB setFlag(Finish)}
      {SiteA setLogger(ThisLogger)}
      {SiteB setLogger(ThisLogger)}
      {System.show 'ready to start'}
      {System.show 'starting NetworkPinPong test'}
      {SiteB setOtherPlayer({SiteA getRef($)})}
      {SiteA initPing(10 {SiteB getRef($)})}
      {Wait Finish}
      {System.show 'no more waiting'}
      {System.show 'finishing NetworkPingPong'}
      {System.show 'letting the log listener do its job'}
      {LogListener release}
      {System.show 'check also file test.log'}
   end
   {Application.exit 1}
end
