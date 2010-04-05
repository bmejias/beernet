/*-------------------------------------------------------------------------
 *
 * TwoPC-TM.oz
 *
 *    Transaction Manager for the Two-Phase Commit Protocol    
 *
 * LICENSE
 *
 *    Beernet is released under the Beerware License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: (main author)
 *
 *    Contributors: (if any)
 *
 *    Last change: $Revision$ $Author$
 *
 *    $Date$
 *
 * NOTES
 *
 *    Implementation of the classical two-phase commit protocol for replicated
 *    databases. It relies strongly on the transaction manager.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   OS
   System
   Component      at '../../corecomp/Component.ozf'
   Timer          at '../../timer/Timer.ozf'
   Utils          at '../../utils/Misc.ozf'
export
   New
define

   fun {New Args}
      Self
      Listener
      MsgLayer
      NodeRef
      Replica
      TheTimer

      Id             % Id of the transaction manager object
      FinalDecision  % Decision taken after collecting votes
      LocalStore     % Stores involve items with their new values and operation
      Votes          % To collect votes from Transaction Participants
      Acks           % To collect final acknoweledgements from TPs
      TPs            % Direct reference to transaction participants
      PreparedItems  % Collect items once enough votes are received 
      AckedItems     % Collect items once enough acks are received 
      Done           % Flag to know when we are done

      %% --- Util functions ---
      fun lazy {GetRemote Key}
         Item
         RemoteItem
      in
         RemoteItem = {@Replica getOne(Key $)}
         Item = try
                   {Record.adjoinAt RemoteItem op read}
                catch _ then
                   item(key:Key value:Item version:0 readers:nil op:read)
                end
         LocalStore.Key := Item 
         Item
      end

      fun {GetItem Key}
         {Dictionary.condGet LocalStore Key {GetRemote Key}}
      end

      %% --- Events ---
      %% --- Operations for the client ---
      proc {Abort abort}
         {Port.send Args.client abort}
         Done := true
         {Self signalDestroy}
      end

      proc {Commit commit}
         %% - Loop over the items on LocalStore, filtering op:write
         %% - Send 'prepare' to TPs for every item to be writen
         %% - Collect responses from TPs (from all, this 2PC
         %% - Decide on commit or abort
         %% - Propagate decision to TPs
         {System.show 'bulking prepare'}
         for I in {Dictionary.items LocalStore} do
            if I.op == write then
               {@Replica bulk(to:I.key 'prepare'(tm:@NodeRef
                                                 tid:Id
                                                 item:I
                                                 protocol:twopc
                                                 tag:trappist
                                                ))} 
               Votes.(I.key)  := nil
               Acks.(I.key)   := nil
               TPs.(I.key)    := nil
            end
         end
      end

      proc {Read read(Key ?Val)}
         Val   = {GetItem Key}.value
      end

      proc {Write write(Key Val)}
         Item
      in
         Item = {GetItem Key}
         LocalStore.Key :=  item(key:Key
                                 value:Val 
                                 version:Item.version + 1
                                 readers:Item.readers 
                                 op:write)
      end

      %% --- Interaction with TPs ---

      proc {Ack ack}
         skip
      end

      proc {Vote vote}
         skip
      end

      %% --- Various ---

      proc {GetId getId(I)}
         I = Id
      end

      proc {SetReplica setReplica(ReplicaMan)}
         Replica := ReplicaMan
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
                     setReplica:    SetReplica
                     setMsgLayer:   SetMsgLayer
                     )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Listener = FullComponent.listener
      end
      NodeRef  = {NewCell noref}
      MsgLayer = {NewCell Component.dummy}
      Replica  = {NewCell Component.dummy}      
      TheTimer = {Timer.new}

      Id             = {OS.rand}
      LocalStore     = {Dictionary.new}
      Votes          = {Dictionary.new}
      Acks           = {Dictionary.new}
      PreparedItems  = {NewCell nil}
      AckedItems     = {NewCell nil}
      Done           = {NewCell false}

      Self
   end
end  

