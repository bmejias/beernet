%% Test the DHT functionality implemented on DHT.oz

functor
import
   Application
   Property
   System
   Network        at '../network/Network.ozf'
   PbeerMaker     at '../pbeer/Pbeer.ozf'
   Utils          at '../utils/Misc.ozf'
export
   Run
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
      {MasterOfPuppets singleAdd(Key Val)}
   end

   proc {Remove Key Val}
      {System.show 'Going to remove'#Val#'from set'#Key}
      {MasterOfPuppets singleRemove(Key Val)}
   end

   proc {ReadSet Key}
      Val
   in
      {MasterOfPuppets singleReadSet(Key Val)}
      {Wait Val}
      {System.show 'Set'#Key#'is:'#Val}
   end

   %% For feedback
   Show   = System.show
   Say    = System.showInfo
   
   proc {HelpMessage}
      {Say "Usage: "#{Property.get 'application.url'}#" <test> [option]"}
      {Say ""}
      {Say "Tests:"}
      {Say "\tall\tRun all tests (default)"}
      {Say "\tpairs\tTest key/value pairs"}
      {Say "\tsets\tTest key/value-sets"}
      {Say ""}
      {Say "Options:"}
      {Say "  -h, -?, --help\tThis help"}
   end

   proc {Bootstrap}
      {CreateNetwork}
      MaxKey = {MasterOfPuppets getMaxKey($)}
   end

   proc {TestPairs}
      {Show 'network created. Going to put, get and delete values'}
      {Put foo bar}
      {Put beer net}
      {Put bink beer(name:adelardus style:dubbel alc:7)}
      {Show 'waiting a bit'}
      {Delay 1000}
      {Get foo}
      {Get beer}
      {Get bink}
      {Put foo flets}
      {Get foo}
      {Show '---- testing some message sending ----'}
      {MasterOfPuppets send(msg(text:'hello nurse' src:foo)
                            to:{Utils.hash foo MaxKey})}
      {MasterOfPuppets send(msg(text:bla src:foo) 
                            to:{Utils.hash ina MaxKey})}
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
   end

   proc {TestSets}
      {Show '-------------------------------------------------------------'}
      {Show '------- testing sets -----'}
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
      {Add chicos ina}
      {ReadSet chicos}
      {Add chicos foo}
      {ReadSet chicos}
      {Remove chicos gatos(foo flets)}
      {Remove chicos ina}
      {Remove chicos foo}
      {Remove chicos flets}
      {ReadSet chicos}
      {Add chicos foo}
      {Add chicos flets}
      {ReadSet chicos}
      {Get chicos}
      {Put chicos nil}
      {Get chicos}
      {ReadSet chicos}
   end

   proc {TestAll}
      {TestPairs}
      {TestSets}
   end
   
   fun {Run Args}

      {Property.put 'print.width' 1000}
      {Property.put 'print.depth' 1000}

      %% Help message
      if Args.help then
         {HelpMessage}
         {Application.exit 0}
      end
      
      case Args.1
      of "dht"|Subcommand|nil then
         case Subcommand
         of "all" then
            {Bootstrap}
            {TestAll}
         [] "pairs" then
            {Bootstrap}
            {TestPairs}
         [] "sets" then
            {Bootstrap}
            {TestSets}
         else
            {Say "ERROR: Invalid invocation\n"}
            {HelpMessage}
         end
      [] nil then
         {Say "Running all threads"}
         {Bootstrap}
         {TestAll}
      else
         {Say "ERROR: Invalid invocation\n"}
         {HelpMessage}
      end
      true
   end

end
