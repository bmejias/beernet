%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   Application
   Property
   System
   TestPlayers at 'TestPlayers.ozf'

define
   
   Say    = System.showInfo
   Blabla
   Args

   proc {HelpMessage}
      App = {Property.get 'application.url'}
   in
      {Say "Usage: "}
      {Say "\t"#App#" --verbose"}
      {Say "\t"#App}
   end

in

   {Property.put 'print.width' 1000}
   {Property.put 'print.depth' 1000}

   %% Defining input arguments
   Args = try
             {Application.getArgs
              record(
                     help(single char:[&? &h] default:false)
                     verbose(single char:&v default:false)
                     )}
          catch _ then
             {Say 'Unrecognised arguments'}
             optRec(help:true)
          end

   %% Help message
   if Args.help then
      {HelpMessage}
      {Application.exit 0}
   end

   if Args.verbose then
      Blabla = proc{$ Msg}
                  if {VirtualString.is Msg} then
                     {Say Msg}
                  else
                     {System.show Msg}
                  end
               end
   else
      Blabla = proc {$ _} skip end
   end

   local
      SiteA
      SiteB
      Finish
   in
      {Say "Test: Pp2p layer"}
      SiteA = {TestPlayers.makePp2pPingPongPlayer}
      SiteB = {TestPlayers.makePp2pPingPongPlayer}
      {SiteA setId(foo)}
      {SiteB setId(bar)}
      {SiteA setFlag(Finish)}
      {SiteB setFlag(Finish)}
      {SiteA setBlabla(Blabla)}
      {SiteB setBlabla(Blabla)}
      {Say 'going to start testing Pp2pPinPong'}
      {SiteA initPing(10 {SiteB getRef($)})}
      {Wait Finish}
      {Say 'finishing Pp2pPingPong'}
   end

   local
      SiteA
      SiteB
      Finish
   in
      {Say "Test: Network layer"}
      SiteA = {TestPlayers.makeNetworkPingPongPlayer}
      SiteB = {TestPlayers.makeNetworkPingPongPlayer}
      {SiteA setId(netfoo)}
      {SiteB setId(netbar)}
      {SiteA setFlag(Finish)}
      {SiteB setFlag(Finish)}
      {SiteA setBlabla(Blabla)}
      {SiteB setBlabla(Blabla)}
      {Say'starting NetworkPinPong test'}
      {SiteB setOtherPlayer({SiteA getRef($)})}
      {SiteA initPing(10 {SiteB getRef($)})}
      {Wait Finish}
      {Say 'finishing NetworkPingPong'}
   end
   {Application.exit 0}
end
