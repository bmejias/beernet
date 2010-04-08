/*-------------------------------------------------------------------------
 *
 * Paxos-TM.oz
 *
 *    Transaction Manager for the Paxos Consensus Algorithm    
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
 *    Implementation of Leader (TM) and replicated transaction managers (rTMs)
 *    for the Paxos Consensus algorithm protocol. The main difference with
 *    Two-Phase commit is that Paxos has a set of rTMs for resilience, and it
 *    does not need to work with all TPs, but only with the majority.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Component      at '../../corecomp/Component.ozf'
   Timer          at '../../timer/Timer.ozf'
   Utils          at '../../utils/Misc.ozf'
export
   New
define

   fun {New Args}
      Self
      %Listener
      MsgLayer
      Replica
      TheTimer

      Id             % Id of the transaction manager object
      Tid            % Id of the transaction
      RepFactor      % Replication Factor
      NodeRef        % Node Reference
      FinalDecision  % Decision taken after collecting votes
      Leader         % Transaction Leader
      LocalStore     % Stores involve items with their new values and operation
      Votes          % To collect votes from Transaction Participants
      Acks           % To collect final acknoweledgements from TPs
      Role           % Role of the TM: leader or rtm
      RTMs           % Set of replicated transaction managers rTMs
      TPs            % Direct reference to transaction participants
      VotedItems     % Collect items once enough votes are received 
      AckedItems     % Collect items once enough acks are received 
      Done           % Flag to know when we are done

      %% --- Util functions ---
      fun lazy {GetRemote Key}
         Item
         RemoteItem
         MostItems
         fun {GetNewest L Newest}
            case L
            of H|T then
               if H.version > Newest then
                  {GetNewest T H}
               else
                  {GetNewest T Newest}
               end
            [] nil then
               Newest
            end
         end
      in
         MostItems = {@Replica getMajority(Key $)}
         RemoteItem = {GetNewest MostItems item(key:     Key
                                                value:   'NOT_FOUND'
                                                version: 0
                                                readers: nil)}
         Item = {Record.adjoinAt RemoteItem op read}
         LocalStore.Key := Item 
         Item
      end

      fun {GetItem Key}
         {Dictionary.condGet LocalStore Key {GetRemote Key}}
      end

      %% --- Events --

      proc {Ack Event}
         skip
      end

      proc {Vote Event}
         skip
      end

      %% --- Operations for the client ---
      proc {Abort abort}
         {Port.send Args.client abort}
         Done := true
         {Self signalDestroy}
      end

      proc {Commit commit}
      /* This procedure only triggers the commit phase, running as follows:
      *
      *  --- Initialization ---
      *
      *  - GetReplicas of TM to init rTMs sending LocalStore
      *  - Collect RegisterRTM
      *
      *  --- Validation ---
      *
      * - Inform every rTM about other rTMs
      * - Loop over the items, sending 'brew' to the transaction 
      *   participants of every item including rTMs
      *
      * --- Consensus ---
      *
      * - Collect responses from TPs (try to collect all before timeout)
      * - Decide on commit or abort
      * - Propagate decision to TPs
      */

         {@Replica  bulk(to:@NodeRef.id initRTM(leader:  @NodeRef
                                                tid:     Tid
                                                tmid:    Id
                                                protocol:paxos
                                                client:  Args.client
                                                tag:     trapp
                                                ))} 
      end

      proc {Read read(Key ?Val)}
         Val   = {GetItem Key}.value
      end

      proc {Write write(Key Val)}
         Item
      in
         Item = {GetItem Key}
         LocalStore.Key :=  item(key:     Key
                                 value:   Val 
                                 version: Item.version+1
                                 readers: Item.readers 
                                 op:      write)
      end

      %% --- Various ---

      proc {GetId getId(I)}
         I = Id
      end

      proc {GetTid getTid(I)}
         I = Tid
      end

      proc {SetReplica setReplica(ReplicaMan)}
         Replica     := ReplicaMan
         RepFactor   := {@Replica getFactor($)}
      end

      proc {SetMsgLayer setMsgLayer(AMsgLayer)}
         MsgLayer := AMsgLayer
         NodeRef  := {@MsgLayer getRef($)}
      end

      Events = events(
                     %% Operations for the client
                     abort:         Abort
                     commit:        Commit
                     read:          Read
                     write:         Write
                     %% Interaction with TPs
                     ack:           Ack
                     vote:          Vote
                     %% Various
                     getId:         GetId
                     getTid:        GetTid
                     setReplica:    SetReplica
                     setMsgLayer:   SetMsgLayer
                     )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         %Listener = FullComponent.listener
      end
      MsgLayer    = {NewCell Component.dummy}
      Replica     = {NewCell Component.dummy}      
      TheTimer    = {Timer.new}

      Id          = {NewName}
      RepFactor   = {NewCell 0}
      NodeRef     = {NewCell noref}
      LocalStore  = {Dictionary.new}
      Votes       = {Dictionary.new}
      Acks        = {Dictionary.new}
      TPs         = {Dictionary.new}
      RTMs        = {NewCell nil}
      VotedItems  = {NewCell nil}
      AckedItems  = {NewCell nil}
      Done        = {NewCell false}
      Role        = {NewCell Args.role}
      if @Role == leader then
         Tid      = {NewName}
      end

      Self
   end
end  

