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
   Component      at '../corecomp/Component.ozf'
   Timer          at '../timer/Timer.ozf'
   Utils          at '../utils/Misc.ozf'
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
      PreparedItems  % Collect items once enough votes are received 
      AckedItems     % Collect items once enough acks are received 
      Done           % Flag to know when we are done

      %% --- Events ---

      %% --- Operations for the client ---
      proc {Abort abort}
         {Port.send Args.client abort}
         Done := true
         {Self signalDestroy}
      end

      proc {Commit commit}
         %% Trigger the whole thing
         skip % for now :)
      end

      proc {Read read(Key ?Value)}
         Item
      in 
         Item = {Dictionary.condGet }
         {@Replica bulk(read())}
      end

      proc {Write write(Key Value)}
         skip
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

