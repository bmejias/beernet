%% Test the DHT functionality implemented on DHT.oz

functor
import
   Property
   System
   Network        at '../network/Network.ozf'
   PbeerMaker     at '../pbeer/Pbeer.ozf'
   Utils          at '../utils/Misc.ozf'
   SimpleSDB      at 'SimpleSDB.ozf'
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

   %% For feedback
   Say    = System.showInfo
   Wisper   = System.printInfo

   NoValue  = SimpleSDB.noValue
   Success  = SimpleSDB.success
   BadSecret= SimpleSDB.badSecret

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

   %% --------------------------------------------------------------------
   %% Here come every test

   fun {PutAndGet Pbeer}
      R1 R2 K V S
   in
      K = {Name.new}
      V = {Name.new}
      S = {Name.new}
      {Wisper "put and get: "} 
      {Pbeer put(s:S k:K v:V r:R1)}
      if R1 == Success then
         {Pbeer get(k:K v:R2)}
         if R2 == V then
            {Say "PASSED"}
            true
         else
            {Say "FAILED - could not retrieve stored value"}
            false
         end
      else
         {Say "FAILED - Single put did not work"}
         false
      end
   end
   
   fun {GetNoValue Pbeer}
      {Wisper "get no value: "}
      if {Pbeer get(k:{Name.new} v:$)} == NoValue then
         {Say "PASSED"}
         true
      else
         {Say "FAILED: Creation out of nothing"}
         false
      end
   end

   fun {Delete Pbeer}
      R1 R2 K V S
   in
      K = {Name.new}
      V = {Name.new}
      S = {Name.new}
      {Wisper "delete : "}
      {Pbeer delete(k:{Name.new} s:{Name.new} r:R1)}
      if R1 == NoValue then
         {Pbeer put(k:K v:V s:S r:Success)}
         if {Pbeer get(k:K v:$)} == V then
            {Pbeer delete(k:K s:S r:R2)}
            if R2 == Success andthen {Pbeer get(k:K v:$)} == NoValue then
               {Say "PASSED"}
               true
            else
               {Say "FAILED: deleting existing item did not work"}
               false
            end
         else
            {Say "FAILED: putting did not work.... VERY STRANGE"}
            false
         end   
      else
         {Say "FAILED: Deleting unexisting element did not work"}
         false
      end
   end

   fun {WrongKeysOnPut Pbeer}
      R K V S
   in
      K = {Name.new}
      V = {Name.new}
      S = {Name.new}
      {Wisper "wrong keys on put : "}
      {Pbeer put(k:K v:{Name.new} s:S r:Success)}
      {Pbeer put(k:K v:V s:S r:Success)}
      if {Pbeer get(k:K v:$)} == V then
         %% testing wrong secret
         {Pbeer put(k:K v:{Name.new} s:{Name.new} r:R)}
         if R == BadSecret then
            %% testing wrong key
            {Pbeer put(k:{Name.new} v:{Name.new} s:S r:Success)}
            if {Pbeer get(k:K v:$)} == V then
               %% testing wrong K1 and Secret 
               {Pbeer put(k:{Name.new} v:{Name.new} s:{NewName} r:Success)}
               if {Pbeer get(k:K v:$)} == V then
                  {Say "PASSED"}
                  true
               else
                  {Say "FAILED: on wrong K and Secret"}
                  false
               end
            else
               {Say "FAILED: on wrong K1"}
               false
            end
         else
            {Say "FAILED: on wrong secret"}
         end
      else
         {Say "FAILED: on basic put. VERY STRANGE!"}
         false
      end
   end

   fun {WrongKeysOnGet Pbeer}
      K V S
   in
      K = {Name.new}
      V = {Name.new}
      S = {Name.new}
      {Wisper "wrong keys on get : "}
      {Pbeer put(k:K v:V s:S r:Success)}
      if {Pbeer get(k:K v:$)} == V then
         if {Pbeer get(k:{Name.new} v:$)} == NoValue then
            {Say "PASSED"}
            true
         else
            {Say "FAILED: on wrong K"}
            false
         end
      else
         {Say "FAILED: on basic put/get. VERY STRANGE!"}
      end
   end

   fun {WrongKeysOnDelete Pbeer}
      K V S
   in
      K = {Name.new}
      V = {Name.new}
      S = {Name.new}
      {Wisper "wrong keys on delete : "}
      {Pbeer put(k:K v:V s:S r:Success)}
      %% testing wrong K
      {Pbeer delete(k:{Name.new} s:S r:NoValue)}
      if {Pbeer get(k:K v:$)} == V then
         %% testing worng secret
         {Pbeer delete(k:K s:{Name.new} r:BadSecret)}
         if {Pbeer get(k:K v:$)} == V then
            {Say "PASSED"}
            true
         else
            {Say "FAILED: deleted item event with the wrong secret"}
            false
         end
      else
         {Say "FAILED: deleted value only with K2 and S but wrong K1"}
         false
      end
   end

   %% -------------------------------------------------------------------
   %% End of individual tests - going to global organization of tests 
   %% -------------------------------------------------------------------

   fun {TestPairs}
      Results = {NewCell nil}
      proc {AddTest Test}
         Results := {Test MasterOfPuppets}|@Results
      end
   in
      {AddTest PutAndGet} 
      {AddTest GetNoValue} 
      {AddTest Delete}
      {AddTest WrongKeysOnPut}
      {AddTest WrongKeysOnGet}
      {AddTest WrongKeysOnDelete}
      {MasterOfPuppets send(msg(text:'hello nurse' src:foo)
                            to:{Utils.hash foo MaxKey})}
      {MasterOfPuppets send(msg(text:bla src:foo) 
                            to:{Utils.hash ina MaxKey})}
      {System.show 'TESTING DIRECT ACCESS TO THE STORE OF A PEER'}
      local
         Pbeer
      in
         {MasterOfPuppets lookup(key:foo res:Pbeer)}
         {MasterOfPuppets send(put(foo bla) to:Pbeer.id)}
      end
      {Delay 1000}
      local
         Pbeer HKey
      in
         HKey = {Utils.hash foo MaxKey} 
         {MasterOfPuppets lookupHash(hkey:HKey res:Pbeer)}
         {MasterOfPuppets send(putItem(HKey foo tetete tag:dht) to:Pbeer.id)}
      end
      {List.foldL @Results Bool.and true}
   end

   fun {TestSets}
      true
   end

   fun {TestAll}
      {Bool.and {TestPairs} {TestSets}}
   end
   
   fun {Run Args}

      {Property.put 'print.width' 1000}
      {Property.put 'print.depth' 1000}

      %% Help message
      if Args.help then
         {HelpMessage}
         false
      else 
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
               {Say {Value.toVirtualString Args 100 100}}
               {HelpMessage}
               false
            end
         [] nil then
            {Say "Running all threads"}
            {Bootstrap}
            {TestAll}
         else
            {Say "ERROR: Invalid invocation\n"}
            {Say {Value.toVirtualString Args 100 100}}
            {HelpMessage}
            false
         end
      end
   end

end
