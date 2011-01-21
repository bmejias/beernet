/*-------------------------------------------------------------------------
 *
 * Clansman.oz
 *
 *    Core of Node's implementation given as functor to be imported. To run
 *    this code on its own processor, use Node.oz as ./node
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
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Connection
   OS
   Pickle
   System
   Pbeer          at '../pbeer/Pbeer.ozf'
   Random         at '../utils/Random.ozf'
   TokenPassing   at 'TokenPassing.ozf'
   Transactions   at 'Transactions.ozf'
export
   Run
define

   Say   = System.showInfo

   proc {Loop Pbeer}
      Pred Succ SelfId
   in
      SelfId = {Pbeer getId($)}
      {Delay 1000}
      Pred = {Pbeer getPred($)}
      Succ = {Pbeer getSucc($)}
      {Say Pred.id#"<--"#SelfId#"-->"#Succ.id}
      {Loop Pbeer}
   end

   proc {TokenLoop Args PbeerToken}
      Size
   in
      {Delay 2000}
      {PbeerToken ringTrip(Size)}
      {Wait Size}
      if Size == Args.size then
         {Say "\t\t\tWe got the expected size: "#Size}
      else
         {Say "\t\t\tRing size estimation: "#Size}
         {TokenLoop Args PbeerToken}
      end
   end

   proc {ExecLoop Event PbeerToken}
      proc {TriggerEvent Apbeer}
         Flag
      in
         {Apbeer Event(Flag)}
         {Wait Flag}
      end
      RoundFlag
   in
      {Delay 1000}
      {PbeerToken ringTripExec(TriggerEvent RoundFlag)}
      {Wait RoundFlag}
   end

   proc {RefreshFingersLoop PbeerToken}
      {Say "\tRefreshing fingers..."}
      {ExecLoop refreshFingers PbeerToken}
   end

   proc {FindRSetLoop PbeerToken}
      {Say "\tFindRSet triggered..."}
      {ExecLoop findRSet PbeerToken}
   end

   proc {SizeRSetFingers Args PbeerToken}
      %% Measure network size, and notify when Args.size is reached
      {TokenLoop Args PbeerToken}
      %% Prepare infrastructure to run transactions
      {RefreshFingersLoop PbeerToken}
      {FindRSetLoop PbeerToken}
   end

   proc {PrepareSetsExperiments Args Pbeer PbeerToken Store}
      TheLogger
      RoundPort
      RoundStream
   in
      RoundPort = {Port.new RoundStream}
      TheLogger = {Connection.take {Pickle.load Args.logger}}
      {Send TheLogger setsParameters(par:par(min:Args.setsmin
                                             max:Args.setsmax
                                             step:Args.setsstep
                                             rounds:Args.setsrounds)
                                     master:RoundPort)}
      {Send Store registerLogger(Args.ring TheLogger)}
      thread
         {SizeRSetFingers Args PbeerToken}
         {RunSetsExperiments Args Pbeer PbeerToken Store TheLogger
                             Args.setsmin 1 RoundStream}
      end
   end

   proc {RunSetsExperiments Args Pbeer PbeerToken Store Logger Current R Stream}
      ExpId
   in
      ExpId = {OS.rand}
      {Say "Going to add first value to set "#ExpId}
      {Transactions.singleAdd data(pbeer:    Pbeer
                                   logger:   Logger
                                   log:      false
                                   protocol: Args.protocol
                                   set:      ExpId)}
      {Say "Set "#ExpId#" created"}
      {Send Store installFlag(ExpId _)}
      {Say "Flag stored, going to pass the experiment around"}
      {InstallOneSetsExperiment PbeerToken ExpId Current Args.size}
      {Send Store bindFlag(ExpId)}
      case Stream
      of round_done|NewStream then
         if R == Args.setsrounds then
            NewCurrent
         in
            NewCurrent = Current + Args.setsstep
            if NewCurrent > Args.setsmax then
               %% All the experiment is over
               {System.show 'Done with the experiment... FREEEEEEDDDOOOOOMM!'}
            else
               {RunSetsExperiments Args Pbeer PbeerToken Store Logger
                                   NewCurrent 1 NewStream}
            end
         else
            {RunSetsExperiments Args Pbeer PbeerToken Store Logger
                                Current R+1 NewStream}
         end
      end
   end

   proc {InstallOneSetsExperiment PbeerToken ExpId Adds Size}
      proc {DoAdd Apbeer}
         NodeRef
      in
         NodeRef = {Apbeer getRef($)}
         {Apbeer send(set(id:ExpId add:true) to:NodeRef.id)}
      end
      proc {DontAdd Apbeer}
         NodeRef
      in
         NodeRef = {Apbeer getRef($)}
         {Apbeer send(set(id:ExpId add:false) to:NodeRef.id)}
      end
      RoundFlag
   in
      {Delay 1000}
      {PbeerToken ringTripExecProb(DoAdd DontAdd Size-1 Adds RoundFlag)}
      {Wait RoundFlag}
   end

   proc {AddToSet Pbeer Store Logger Protocol}
      Event
   in
      {Pbeer receive(Event)}
      case Event
      of set(id:ExpId add:Doit) then
         if Doit then
            Flag
         in
            {System.show '************************************going to add'}
            Flag = {Send Store retrieveFlag(ExpId $)}
            thread
               {Wait Flag}
               {Transactions.singleAdd data(pbeer:    Pbeer
                                            logger:   Logger
                                            log:      true
                                            protocol: Protocol
                                            set:      ExpId)}
            end
         end
      else
         skip
      end
      {AddToSet Pbeer Store Logger Protocol}
   end

   proc {SetupExperiment Args PbeerToken Store}
      Flag
      TheLogger
   in
      {System.show 'using '#Args.logger#Args.size#Args.ring}
      TheLogger = {Connection.take {Pickle.load Args.logger}}
      {Send TheLogger setStartTimeUpon(Flag)}
      {Send TheLogger setExpectedMessages(Args.size)}
      {Send Store installFlag(Args.ring Flag)}
      {Send Store registerLogger(Args.ring TheLogger)}
      thread
         {Say "going to VERIFY SIZE, RSET and Fingers"}
         {SizeRSetFingers Args PbeerToken}
         %% Ready to make peers run the transactions
         {Say "going to bind the flag in 2 seconds"}
         {Delay 2000}
         {Send Store bindFlag(Args.ring)}
         {Say "done"}
      end
   end

   proc {RunTransactions Args Store Logger Pbeer}
      SelfId
      RingFlag
   in
      SelfId = {Pbeer getId($)}
      {Send Store retrieveFlag(Args.ring RingFlag)}
      {Send Store retrieveLogger(Args.ring Logger)}
      
      thread
         RunTrans
      in
         if Args.protocol == valueset then
            RunTrans = Transactions.adds
         else
            RunTrans = Transactions.writes
         end
         {RunTrans data(flag:    RingFlag 
                        logger:  Logger
                        protocol:Args.protocol 
                        'from':  SelfId
                        to:      SelfId + Args.trans
                        factor:  10
                        pbeer:   Pbeer)}
      end
   end

   proc {MakeTonsOfWrites Args PbeerToken Store Pbeer ReadTest ReadOps}
      TheLogger
      Expected
      RoundPort
      RoundStream
   in
      RoundPort = {Port.new RoundStream}
      TheLogger = {Connection.take {Pickle.load Args.logger}}
      Expected = (Args.size * Args.reads * 3) div 5
      {Send TheLogger params(par:par(expected:Expected) master:RoundPort)}
      {Send Store registerLogger(Args.ring TheLogger)}
      {Send Store installFlag(Args.ring _)}
      thread
         Step
      in
         Step = 128
         {SizeRSetFingers Args PbeerToken}
         for I in 1..Args.trans;Step do
            {Transactions.writes  data(flag:    unit 
                                       logger:  TheLogger
                                       protocol:Args.protocol 
                                       'from':  I
                                       to:      {Stats.min Args.trans I+Step-1}
                                       factor:  2
                                       pbeer:   Pbeer)}
            {Delay Step*5}
         end
         {Delay 3000}
         {Send TheLogger reallyDone}
         {TriggerReads RoundStream Store TheLogger PbeerToken ReadTest ReadOps}
      end
   end
   
   proc {TriggerReads Stream Store Logger PbeerToken ReadTest ReadOps}
      fun {MakeReadToken MsgLabel FlagName}
         proc {$ Apbeer}
            NodeRef
         in
            NodeRef = {Apbeer getRef($)}
            {Apbeer send(MsgLabel(FlagName) to:NodeRef.id)}
         end
      end
      proc {Loop Stream ReadMsgs}
         case Stream
         of done|NewStream then
            {Say 'done with something... thanks Logger'}
            case ReadMsgs
            of RM|RMs then
               RoundFlag
               ReadToken
            in
               ReadToken = {MakeReadToken RM RM}
               {Send Logger newRound(ReadOps.RM)}
               {Send Store installFlag(RM _)}
               {Delay 1000}
               {PbeerToken ringTripExec(ReadToken RoundFlag)}
               {Wait RoundFlag}
               {Delay 3000}
               {Say '+++ going to bind the flag '#RM}
               {Send Store bindFlag(RM)}
               {Loop NewStream RMs}
            [] nil then
               {Send Logger doneAndClose}
               {Delay 1000}
            end
         [] nil then
            skip
         end
      end
   in
      {Loop Stream ReadTest}
   end

   proc {Run Args}
      PbeerToken
      Pbeer
      Store
      Logger
      JoinAck
      ReadTest
      ReadOps
   in
      Pbeer    = {Beernet.new args(firstAck:JoinAck)}
      Store    = {Connection.take {Pickle.load Args.store}}
      if Args.readonly == all then
         ReadTest = [doGetMajority doGetOne doGetAll doGet]
      else
         ReadTest = [Args.readonly]
      end
      ReadOps  = ops(doGetOne:      getOne
                     doGetMajority: getMajority
                     doGetAll:      getAll
                     doGet:         get)
      %% Creating the network is done here.
      %% Register network if master. Join existing network otherwise
      if Args.master then
         {Send Store registerAccessPoint(Args.ring {Pbeer getFullRef($)})}
      else
         RingRef
      in
         {Send Store getAccessPoint(Args.ring RingRef)}
         case RingRef
         of none then
            {Say "couldn't get the ref to the ring"}
            {Application.exit 0}
         else
            {Pbeer join(RingRef)}
            {Wait JoinAck}
            {Send Store registerAccessPoint(Args.ring {Pbeer getFullRef($)})}
         end
      end

      %% Install the TokenPassing service
      PbeerToken  = {TokenPassing.new args(pbeer:Pbeer say:Say)}
      {Pbeer setListener(PbeerToken)}

      if Args.busy then
         thread
            {Loop Pbeer}
         end
      end

      case Args.exp
      of sets then
         %% We are going to run a huge amount of experiments on value sets
         if Args.master then
            {PrepareSetsExperiments Args Pbeer PbeerToken Store}
         else
            thread
               {Send Store retrieveLogger(Args.ring Logger)}
               {AddToSet Pbeer Store Logger Args.protocol}
            end
         end
      [] reads then
         if Args.master then
            thread
               {MakeTonsOfWrites Args PbeerToken Store Pbeer ReadTest ReadOps}
            end
            thread
               Logger = {Connection.take {Pickle.load Args.logger}}
               {PrepareToRead Args Store Logger Pbeer ReadTest ReadOps}
            end
         else
            thread
               Logger = {Connection.take {Pickle.load Args.logger}}
               {PrepareToRead Args Store Logger Pbeer ReadTest ReadOps}
            end
         end
      else
         %% Running as much transactions per second as possible
         if Args.master then
            {System.show 'GOING TO SETUP EXPERIMENT'}
            {SetupExperiment Args PbeerToken Store}
         else
            {RunTransactions Args Store Logger Pbeer}
         end
      end
   end

end
