/*-------------------------------------------------------------------------
 *
 * Beernet.oz
 *
 *    Source of the command line utility 'beernet'. It allows to bootstrap a
 *    ring, list peers, kill and add pbeers.
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
 *    This is a simple utility that allows bootstraping beernet rings.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Connection
   OS
   Pickle
   Property
   System
   BaseArgs at '../lib/tools/BaseArgs.ozf'
   Clansman at '../lib/tools/Clansman.ozf'
   TextFile at '../lib/utils/TextFile.ozf'
define

   Say         = System.showInfo

   Args
   AllNodes
   Stop
   StopS

   fun {NodeCall}
      '#'("./node --ring " Args.ring
                " --protocol " Args.protocol
                " --store " Args.store
                " --logger " Args.logger
                )
   end

   fun {MasterCall}
      '#'({NodeCall}
                " --master"
                " --size " Args.size
                )
   end

   proc {CreateScript Name Call}
      Flag Script
   in
      Script = {New TextFile.textFile init(name:Name
                                           flags:[write create truncate text])}
      {Script putS("#!/bin/sh\n")}
      {Script putS("cd "#Args.nodepath)}
      {Script putS("scp "#Args.storesite#":~/"#Args.storepath#Args.store#" .")}
      {Script putS("scp "#Args.logsite#":~/"#Args.logpath#Args.logger#" .")}
      {Script putS("linux32 "#{Call})}
      {Script close}
      {OS.system "chmod +x "#Name Flag}
      {Wait Flag}
   end

   LoginData   = data(tuetue: data(user:tchorix          nodes:tuetue_nodes)
                      caixa:  data(user:'boriss.mejias'  nodes:caixa_nodes)
                      manekenk: data(user:tchorix        nodes:manekenk_nodes)
                     )
   NodeScript
   RunScript

   proc {LaunchMasterScript Site User}
      %% Launch master script
      {LaunchRemoteScript Site User}
      %% And switch to any pbeer for the next calls
      NodeScript  := Args.scrpany
      RunScript   := LaunchRemoteScript
      {Delay 1666}
   end

   proc {LaunchRemoteScript Site User}
      SshCall = "ssh -t -l "#User#" "#Site#" sh "#Args.nodepath#"/"#@NodeScript
      Flag
   in
      {OS.system SshCall#" || echo \"failed\" &" Flag}
      {Wait Flag}
      {Delay 500}
   end

   proc {LaunchLocalNodes}
      {Delay 1666}
      {Say "Launching the master node"}
      {OS.system "linux32 "#{MasterCall}#" &" _}
      {Delay 1666}
      for I in 1..(Args.size-1) do
         {OS.system "linux32 "#{NodeCall}#" &" _}
         {Delay 100}
      end
   end

   proc {LaunchSimNodes}
      {Delay 1666}
      {Say "Launching the master node"}
      {Clansman.run {Record.adjoin Args args(master:true busy:false)}}
      {Delay 1666}
      for I in 1..(Args.size-1) do
         {Clansman.run {Record.adjoin Args args(master:false busy:false)}}
         {Delay 100}
      end
   end

   proc {LaunchSharedDiskNodes}
      proc {Loop Nodes I}
         if I =< Args.size then 
            case Nodes
            of Node|MoreNodes then
               {@RunScript Node LoginData.(Args.dist).user}
                  if I mod Args.sites == 0 then
                  {Loop AllNodes I+1}
               else
                  {Loop MoreNodes I+1}
               end
            [] nil then
               {Loop AllNodes I}
            end
         else
            {Say "All pbeers launched"}
         end
      end
   in
      {CreateScript Args.scrpfirst MasterCall}
      {CreateScript Args.scrpany NodeCall}
      AllNodes = {TextFile.read LoginData.(Args.dist).nodes}
      {Loop AllNodes 1}
   end

   fun {GetDate}
      GmTime Year Month Day Hour Min
   in
      GmTime   = {OS.gmTime}
      Year     = GmTime.year+1900
      Month    = if GmTime.mon < 9 then "0"#GmTime.mon+1 else GmTime.mon+1 end
      Day      = if GmTime.mDay < 10 then "0"#GmTime.mDay else GmTime.mDay end
      Hour     = if GmTime.hour < 10 then "0"#GmTime.hour else GmTime.hour end
      Min      = if GmTime.min < 10 then "0"#GmTime.min else GmTime.min end
      '#'(Year Month Day "-" Hour Min)
   end
in

   {Property.put 'print.width' 1000}
   {Property.put 'print.depth' 1000}

   %% Defining input arguments
   Args = {BaseArgs.getArgs record}

   %% Help message
   if Args.help then
      {BaseArgs.helpMessage nil}
      {Application.exit 0}
   end

   NodeScript  = {NewCell Args.scrpfirst}
   RunScript   = {NewCell LaunchMasterScript}

   Stop = {NewPort StopS}
   thread
      User
      Mordor
      proc {KillSites I Nodes}
         case Nodes
         of Node|MoreNodes then
            if I =< Args.sites then
               {OS.system '#'("ssh -t -l " User " " Node 
                              " sh " Args.nodepath "/killer &") _}
               {KillSites I+1 MoreNodes}
            end
         [] nil then
            {KillSites I AllNodes}
         end
      end
   in
      {Wait StopS.1} %% Waiting for message 'done' sent from the Logger
      {Say "The logger has saved the stats..."}
      {Say "Going to kill everything in 3 seconds..."}
      {Delay 3000}
      if {List.member Args.dist [tuetue caixa manekenk]} then
         User = LoginData.(Args.dist).user
         {KillSites 1 AllNodes}
      end
      Mordor = {Connection.take {Pickle.load Args.store}}
      {Send Mordor theonering}
      {Delay 1000}
      {Application.exit 0}
   end
   {Pickle.save {Connection.offerUnlimited Stop} Args.achel}

   {Say "Lauching Mordor Store"}
   {OS.system "linux32 ./mordor --ticket "#Args.storepath#Args.store#" &" _}
   {Delay 1666}
   {Say "Launching the Logger"}
   local
      Trans
      LogFile
   in
      Trans    = Args.trans * (Args.size div 2)
      if Args.logfile == usetime then
         LogFile  = {GetDate}#"-"#Args.size#"-"#Trans#".log"
      else
         LogFile = Args.logfile
      end
      {OS.system '#'("linux32 "
                     "./logger --ticket " Args.logpath Args.logger
                             " --achel " Args.achel
                             " --exp " Args.exp
                             " --logfile " LogFile " &") _}
   end

   case Args.dist
   of cluster then
      {LaunchSharedDiskNodes}
   [] localhost then
      {LaunchLocalNodes}
   [] sim then
      {LaunchSimNodes}
   else
      {Say "Wrong distribution mode. Running as localhost"}
      {LaunchLocalNodes}
   end
end

