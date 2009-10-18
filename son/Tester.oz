%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   Application
   OS
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
   PbeersAfterMassacre
   PbeersAfterChurn
   TestBuild
   TestMassacre
   TestChurn
   NetRef

   fun {Kill N L}
      fun {RussianRoulette I L FinalCount}
         if I < N then
            case L
            of Pbeer|MorePbeers then
               if {OS.rand} mod 7 < 1 then
                  {Pbeer injectFailure}
                  {RussianRoulette I+1 MorePbeers FinalCount}
               else
                  Pbeer|{RussianRoulette I MorePbeers FinalCount}
               end
            [] nil then
               FinalCount = I
               nil
            end
         else
            FinalCount = I
         end
      end
      fun {KillingLoop L I}
         if I < N then
            NewI NewL
         in
            NewL = {RussianRoulette I L NewI}
            {KillingLoop NewL NewI}
         else
            L
         end
      end
   in
      {KillingLoop L 0}
   end

   fun {Churn N L}
      fun {ChurnRoulette I J L FinalI FinalJ}
         if I < N orelse J < N then
            case L
            of Pbeer|MorePbeers then
               Luck = {OS.rand} mod 7 
            in
               if Luck < 1 andthen I < N then
                  {Pbeer injectFailure}
                  {ChurnRoulette I+1 J MorePbeers FinalI FinalJ}
               elseif Luck > 5 andthen J < N then
                  New
               in
                  New = {NewPbeer}
                  Pbeer|New|{ChurnRoulette I J+1 MorePbeers FinalI FinalJ}
               end
            [] nil then
               FinalI = I
               FinalJ = J
               nil
            end
         else
            FinalI = I
            FinalJ = J
         end
      end
      fun {ChurnLoop L I J}
         if I < N orelse J < N then
            NewI NewJ NewL
         in
            NewL = {ChurnRoulette I J L NewI NewJ}
            {ChurnLoop NewL NewI NewJ}
         else
            L
         end
      end
   in
      {ChurnLoop L 0 0}
   end

   fun {BoolToString B}
      if B then "PASSED"
      else "FAILED" end
   end

   fun {LoopNetwork Pbeer Size}
      fun {Loop Current Pred First Counter OK Error}
         if Current == nil then
            result(passed:false
                   error:Error#" - Wrong Size "#Counter#" != "#Size)
         elseif Current.id == First.id then
            {System.showInfo Current.id}
            if Counter == Size then
               if OK then
                  result(passed:true)
               else
                  result(passed:OK error:Error)
               end
            else
               result(passed:false
                      error:Error#" - Wrong Size "#Counter#" != "#Size)
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
      First = {Pbeer getFullRef($)}
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
      Result.passed
   end
   fun {NewPbeer}
      New TmpId
   in
      New = {PbeerMaker.new args}
      {New getId(TmpId)}
      if TmpId > @MaxKey then
         MaxKey := TmpId
      end
      New
   end
in
   {System.show 'first line'}
   MasterOfPuppets = {PbeerMaker.new args}
   {System.show 'second line'}
   MaxKey = {NewCell {MasterOfPuppets getId($)}}
   Log = {Logger.new 'lucifer.log'}
   {MasterOfPuppets setLogger(Log.logger)}
   Pbeers = {List.make SIZE-1}
   NetRef = {MasterOfPuppets getFullRef($)}
   for Pbeer in Pbeers do
      Pbeer = {NewPbeer}
      {Pbeer setLogger(Log.logger)}
      {Pbeer join(NetRef)}
      %{Delay 100}
   end
   {Delay 1000}
   TestBuild = {LoopNetwork MasterOfPuppets SIZE}
   {System.showInfo "Killing 10 Pbeers"}
   PbeersAfterMassacre = {Kill 10 Pbeers}
   {Delay 4000}
   TestMassacre = {LoopNetwork MasterOfPuppets {Length PbeersAfterMassacre}}
   PbeersAfterChurn = {Churn 10 PbeersAfterMassacre}
   {Delay 4000}
   TestChurn = {LoopNetwork MasterOfPuppets {Length PbeersAfterChurn}}
   {System.showInfo "*** Test Summary ***"}
   {System.showInfo "Build Test: "#{BoolToString TestBuild}}
   {System.showInfo "Failures Test: "#{BoolToString TestMassacre}}
   {System.showInfo "Churn Test: "#{BoolToString TestChurn}}
   {Application.exit 0}
end
