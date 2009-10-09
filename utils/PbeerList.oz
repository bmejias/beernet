/*-------------------------------------------------------------------------
 *
 * PbeerList.oz
 *
 *    This files contains general functions asociated with list, but actually,
 *    they work some times as if they were sets.
 *
 * LICENSE
 *
 *    Copyright (c) 2009 Universite catholique de Louvain
 *
 *    Beernet is released under the MIT License (see file LICENSE) 
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
export
   Add
   Different
   IsIn
   Keep
   Minus
   New
   Remove
   RemoveLast  
define

   %% Add a Peer in a sorted list.
   %% Return the new list as result
   fun {Add Peer L}
      case L
      of H|T then
         if H.id < Peer.id then
            H|{Add Peer T}
         elseif H == Peer then
            %% Compare the whole peer, because it could be they have same id
            %% but different ports
            L
         else
            Peer|L
         end
      [] nil then
         Peer|nil
      end
   end

   %% Compare if two lists are diferent
   fun {Different L1 L2}
      case L1#L2
      of (H1|T1)#(H2|T2) then
         if H1.id \= H2.id then
            true
         else
            {Different T1 T2}
         end
      [] nil#nil then
         false
      [] nil#_ then
         true
      [] _#nil then
         true
      end
   end

   %% Return true if Peer is found in list L
   fun {IsIn Peer L}
      case L
      of H|T then
         if H.id == Peer.id then
            true
         else
            {IsIn Peer T}
         end
      [] nil then
         false
      end
   end

   %% Like Take
   fun {Keep N L}
      case L
      of H|T then
         if N > 0 then
            H|{Keep N - 1 T}
         else
            nil
         end
      [] nil then
         nil
      end
   end         
   
   %% Remove a Peer from a List
   fun {Remove Peer L}
      case L
      of H|T then
         if H == Peer then
            T
         else
            H|{Remove Peer T}
         end
      [] nil then
         nil
      end
   end

   %% Remove the last element of a list
   fun {RemoveLast L}
      case L
      of _|nil then
         nil
      [] H|T then
         H|{RemoveLast T}
      [] nil then
         nil
      end
   end

   %% Return a list with elements of L1 that are not present in L2
   fun {Minus L1 L2}
      case L1
      of H|T then
         if {IsIn H L2} then
            {Minus T L2}
         else
            H|{Minus T L2}
         end
      [] nil then
         nil
      end
   end

   %% For the sake of completeness of the ADT
   fun {New}
      nil
   end
end   