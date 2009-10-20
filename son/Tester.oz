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
   CHURN = 7

   ComLayer
   Log
   MasterOfPuppets
   MaxKey
   Pbeers
   PbeersAfterMassacre
   PbeersAfterChurn
   TestBuild
   TestBuildPred
   TestMassacre
   TestMassacrePred
   TestChurn
   TestChurnPred
   NetRef

   fun {Kill N L}
      fun {RussianRoulette I L FinalCount}
         if I < N then
            case L
            of Pbeer|MorePbeers then
               if {OS.rand} mod 7 < 1 then
                  {Pbeer injectPermFail}
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
            L
         end
      end
      fun {KillingLoop I L}
         if I < N then
            NewI NewL
         in
            NewL = {RussianRoulette I L NewI}
            {KillingLoop NewI NewL}
         else
            L
         end
      end
   in
      {KillingLoop 0 L}
   end

   fun {Churn N L}
      fun {ChurnRoulette I J L FinalI FinalJ}
         if I < N orelse J < N then
            case L
            of Pbeer|MorePbeers then
               Luck = {OS.rand} mod 7 
            in
               if Luck < 1 andthen I < N then
                  {Pbeer injectPermFail}
                  {ChurnRoulette I+1 J MorePbeers FinalI FinalJ}
               elseif Luck > 5 andthen J < N then
                  New
               in
                  New = {NewPbeer}
                  Pbeer|New|{ChurnRoulette I J+1 MorePbeers FinalI FinalJ}
               else
                  Pbeer|{ChurnRoulette I J MorePbeers FinalI FinalJ}
               end
            [] nil then
               FinalI = I
               FinalJ = J
               nil
            end
         else
            FinalI = I
            FinalJ = J
            L
         end
      end
      fun {ChurnLoop I J L}
         if I < N orelse J < N then
            NewI NewJ NewL
         in
            NewL = {ChurnRoulette I J L NewI NewJ}
            {ChurnLoop NewI NewJ NewL}
         else
            L
         end
      end
   in
      {ChurnLoop 0 0 L}
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

   fun {LoopNetworkPred Pbeer Size}
      fun {Loop Current Succ First Counter OK Error}
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
            Pred
         in
            Pred = {ComLayer sendTo(Current getPred($))}
            {System.printInfo Current.id#"->"}
            if Pred.id > Current.id andthen Pred.id \= @MaxKey then
               {Loop Pred Current First Counter+1
                     false Error#Current.id#"->"#Pred.id#" "}
            else
               {Loop Pred Current First Counter+1 OK Error}
            end
         end
      end
      First
      Result
   in
      First = {Pbeer getFullRef($)}
      {System.showInfo "Network following PRED "#First.ring.name}
      {System.printInfo First.pbeer.id#"->"}
      Result = {Loop {Pbeer getPred($)} 
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
   ComLayer = {Network.new}
   {Delay 1000}
   local
      P I S
   in
      {MasterOfPuppets getPred(P)}
      {MasterOfPuppets getId(I)}
      {MasterOfPuppets getSucc(S)}
      {System.showInfo "MASTER: "#P.id#"<-"#I#"->"#S.id}
   end
   TestBuild = {LoopNetwork MasterOfPuppets SIZE}
   TestBuildPred = {LoopNetworkPred MasterOfPuppets SIZE}
   {System.showInfo "Killing "#CHURN#" Pbeers"}
   PbeersAfterMassacre = {Kill CHURN Pbeers}
   {System.show PbeersAfterMassacre}
   {Delay 4000}
   TestMassacre = {LoopNetwork MasterOfPuppets {Length PbeersAfterMassacre}}
   %TestMassacrePred = {LoopNetworkPred MasterOfPuppets {Length PbeersAfterMassacre}}
   PbeersAfterChurn = {Churn CHURN PbeersAfterMassacre}
   {System.show PbeersAfterChurn}
   {Delay 4000}
   TestChurn = {LoopNetwork MasterOfPuppets {Length PbeersAfterChurn}}
   %TestChurnPred = {LoopNetworkPred MasterOfPuppets {Length PbeersAfterChurn}}
   {System.showInfo "*** Test Summary ***"}
   {System.showInfo "Build Test: "#{BoolToString TestBuild}}
   {System.showInfo "Build Test Pred: "#{BoolToString TestBuildPred}}
   {System.showInfo "Failures Test: "#{BoolToString TestMassacre}}
   %{System.showInfo "Failures Test Pred: "#{BoolToString TestMassacrePred}}
   {System.showInfo "Churn Test: "#{BoolToString TestChurn}}
   %{System.showInfo "Churn Test Pred: "#{BoolToString TestChurnPred}}
   {Application.exit 0}
end
