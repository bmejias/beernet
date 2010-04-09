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

   proc {Put Key Val}
      {System.show 'Going to put'#Val#'with Key'#Key}
      {MasterOfPuppets put(Key Val)}
   end

   proc {Get Key}
      Val
   in
      {MasterOfPuppets get(Key Val)}
      {Wait Val}
      {System.show 'Getting'#Key#'we obtained'#Val}
   end

   proc {Delete Key}
      {System.show 'Deleting'#Key}
      {MasterOfPuppets delete(Key)}
   end

   proc {Add Key Val}
      {System.show 'Going to add'#Val#'to set'#Key}
      {MasterOfPuppets add(Key Val)}
   end

   proc {Remove Key Val}
      {System.show 'Going to remove'#Val#'from set'#Key}
      {MasterOfPuppets remove(Key Val)}
   end

   proc {ReadSet Key}
      Val
   in
      {MasterOfPuppets readSet(Key Val)}
      {Wait Val}
      {System.show 'Set'#Key#'is:'#Val}
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
   {Put foo flets}
   {Get foo}
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
   local
      Pbeer HKey
   in
      HKey = {Utils.hash foo MaxKey} 
      {MasterOfPuppets lookupHash(hkey:HKey res:Pbeer)}
      {MasterOfPuppets send(putItem(HKey foo tetete tag:dht) to:Pbeer.id)}
   end
   {Delay 1000}
   {Get foo}
   {Delete nada}
   {Delay 1000}
   {Delete foo}
   {Delay 500}
   {Get foo}
   {System.show '-------------------------------------------------------------'}
   {System.show '------- testing sets -----'}
   {Add chicos foo}
   {Add chicos flets}
   {Add chicos ina}
   {ReadSet chicos}
   {ReadSet chicas}
   {Remove chicos foo}
   {Remove chicos nada}
   {Remove chicas foo}
   {ReadSet chicos}
   {ReadSet chicas}
   {Add chicos gatos(foo flets)}
   {ReadSet chicos}
   {Application.exit 0}
end
