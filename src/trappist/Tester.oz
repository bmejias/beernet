%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor

import
   Application
   Property
   System
   Network        at '../network/Network.ozf'
   PbeerMaker     at '../pbeer/Pbeer.ozf'
   Utils          at '../utils/Misc.ozf'

define
   SIZE  = 42

   ComLayer
   MasterOfPuppets
   MasterId
   MaxKey
   Pbeers
   NetRef

   proc {CreateNetwork}
      %{System.show 'first line'}
      MasterOfPuppets = {PbeerMaker.new args}
      %{System.show 'second line'}
      MasterId = {MasterOfPuppets getId($)}
      Pbeers = {List.make SIZE-1}
      NetRef = {MasterOfPuppets getFullRef($)}
      for Pbeer in Pbeers do
         Pbeer = {PbeerMaker.new args}
         {Pbeer join(NetRef)}
         thread
            Id
            proc {ReceivingLoop}
               NewMsg
            in
               {Pbeer receive(NewMsg)}
               {Wait NewMsg}
               {System.show 'Pbeer '#Id#' got '#NewMsg.text#' from '#NewMsg.src}
               {ReceivingLoop}
            end
         in
            Id = {Pbeer getId($)}
            {ReceivingLoop}
         end
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
   end

   proc {Put Key Value}
      {System.show 'Going to put'#Value#'with Key'#Key}
      {MasterOfPuppets put(Key Value)}
   end

   proc {Get Key}
      Value
   in
      {MasterOfPuppets get(Key Value)}
      {Wait Value}
      {System.show 'Getting'#Key#'we obtained'#Value}
   end

   proc {GetOne Key}
      Value
   in
      {MasterOfPuppets getOne(Key Value)}
      {Wait Value}
      {System.show 'Getting one replica of'#Key#'we obtained'#Value}
   end

   proc {GetAll Key}
      Val
   in
      {MasterOfPuppets getAll(Key Val)}
      if {IsList Val} then skip end
      {System.show 'Reading All'#Key#'we obtained'#Val}
   end

   proc {GetMajority Key}
      Val
   in
      {MasterOfPuppets getMajority(Key Val)}
      if {IsList Val} then skip end
      {System.show 'Reading Majority'#Key#'we obtained'#Val}
   end

   proc {Delete Key}
      {System.show 'Deleting'#Key}
      {MasterOfPuppets delete(Key)}
   end

in

   {Property.put 'print.width' 1000}
   {Property.put 'print.depth' 1000}

   {CreateNetwork}
   MaxKey = {MasterOfPuppets getMaxKey($)}
   {System.show 'network created. Going to put, get and delete values'}
   {Put foo bar}
   {Put beer net}
   {Put bink beer(name:adelardus style:dubbel alc:7)}
   {System.show 'waiting a bit'}
   {Delay 1000}
   {Get foo}
   {Get beer}
   {Get bink}
   {GetOne foo}
   {GetOne beer}
   {GetOne bink}
   {Put foo flets}
   {Get foo}
   {GetOne foo}
   {GetAll foo}
   {GetMajority foo}
   {GetAll foooo}
   {GetMajority foooo}
   {System.show '---- testing some message sending ----'}
   {MasterOfPuppets send(msg(text:'hello nurse' src:foo) to:{Utils.hash foo MaxKey})}
   {MasterOfPuppets send(msg(text:bla src:foo) to:{Utils.hash ina MaxKey})}
   {Delay 1000}
   {System.show 'TESTING DIRECT ACCESS TO THE STORE OF A PEER'}
   local
      Pbeer
   in
      {MasterOfPuppets lookup(key:foo res:Pbeer)}
      {MasterOfPuppets send(put(foo bla) to:Pbeer.id)}
   end
   {Delay 1000}
   {Get foo}
   {GetOne foo}
   local
      Pbeer HKey
   in
      HKey = {Utils.hash foo MaxKey} 
      {MasterOfPuppets lookupHash(hkey:HKey res:Pbeer)}
      {MasterOfPuppets send(putItem(HKey foo tetete tag:dht) to:Pbeer.id)}
   end
   {Delay 1000}
   {Get foo}
   {GetOne foo}
   {GetOne foo}
   {Delete nada}
   {Delay 1000}
   {Delete foo}
   {Delay 500}
   {Get foo}
   {GetOne foo}
   {Application.exit 0}
end
