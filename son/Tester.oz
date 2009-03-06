%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   Application
   System
   Logger         at '../logger/Logger.ozf'
   Network        at '../network/Network.ozf'
   PbeerMaker     at 'Pbeer.ozf'

define
   SIZE  = 42

   ComLayer
   Log
   MasterOfPuppets
   MaxKey
   Pbeers
   RingRef

   proc {LoopNetwork Pbeer}
      fun {Loop Current Pred First Counter OK Error}
         if Current == nil then
            result(passed:false
                   error:Error#" - Wrong Size "#Counter#" != "#SIZE)
         elseif Current.id == First.id then
            {System.showInfo Current.id}
            if Counter == SIZE then
               if OK then
                  result(passed:true)
               else
                  result(passed:OK error:Error)
               end
            else
               result(passed:false
                      error:Error#" - Wrong Size "#Counter#" != "#SIZE)
            end
         else
            Succ
         in
            Succ = {ComLayer sendTo(Current getSucc($))}
            {System.printInfo Current.id#"->"}
            if Succ.id < Current.id andthen Current.id \= @MaxKey then
               {Loop Succ Current First Counter+1
                     false Error#Current.id#"->"#Succ.id#" "}
            else
               {Loop Succ Current First Counter+1 OK Error}
            end
         end
      end
      First
      Result
   in
      ComLayer = {Network.new}
      First = {Pbeer getRingRef($)}
      {System.showInfo "Network "#First.ring.name}
      {System.printInfo First.pbeer.id#"->"}
      Result = {Loop {Pbeer getSucc($)} 
                     First.pbeer 
                     First.pbeer 
                     1 
                     true
                     nil}
      if Result.passed then
         {System.showInfo "\n+++ PASSED +++"}
      else
         {System.showInfo "\n+++ FAILED +++"}
         {System.showInfo "Error: "#Result.error}
      end
   end
in
   MasterOfPuppets = {PbeerMaker.new args}
   MaxKey = {NewCell {MasterOfPuppets getId($)}}
   Log = {Logger.new 'lucifer.log'}
   {MasterOfPuppets setLogger(Log.logger)}
   Pbeers = {List.make SIZE-1}
   RingRef = {MasterOfPuppets getRingRef($)}
   for Pbeer in Pbeers do
      Pbeer = {PbeerMaker.new args}
      local
         TmpId
      in
         {Pbeer getId(TmpId)}
         if TmpId > @MaxKey then
            MaxKey := TmpId
         end
      end
      {Pbeer setLogger(Log.logger)}
      {Pbeer join(RingRef)}
      %{Delay 100}
   end
   {Delay 1000}
   {LoopNetwork MasterOfPuppets}
   {Application.exit 0}
end
