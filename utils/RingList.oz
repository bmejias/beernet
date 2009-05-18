/*-------------------------------------------------------------------------
 *
 * RingList.oz
 *
 *    Collection of procedures to work with lists of peers on a circular
 *    address space sorted with a pivot.
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
   ForAll
   GetAfter
   GetBefore
   GetFirst
   GetLast
   IsIn
   Minus
   New
   Remove
define

   fun {Distance Id Pivot MaxKey}
      (MaxKey + Id - Pivot) mod MaxKey
   end

   %% Add a Peer in a sorted list with a distance relative to the pivot.
   %% Do not add a peer if it is already in the list.
   %% Return the new list as result
   fun {Add NewPeer L Pivot MaxKey}
      fun {Loop NewDist L}
         case L
         of (Dist#Peer)|Tail then
            if Dist < NewDist then
               (Dist#Peer)|{Loop NewDist Tail}
            elseif Dist == NewDist then
               L
            else
               (NewDist#NewPeer)|L
            end
         [] nil then
            (NewDist#NewPeer)|nil
         end
      end
      TheDistance = {Distance NewPeer.id Pivot MaxKey}
   in
      if TheDistance > 0 then
         {Loop TheDistance L}
      else
         L
      end
   end

   %% Compare if two lists are diferent
   fun {Different L1 L2}
      case L1#L2
      of (_/*Dist1*/#H1|T1)#(_/*Dist2*/#H2|T2) then
         if H1.id \= H2.id then
            true
         else
            {Different T1 T2}
         end
      [] nil#nil then
         false
      [] nil#_/*L2*/ then
         true
      [] _/*L1*/#nil then
         true
      end
   end

   proc {ForAll L P}
      case L
      of (_/*Dist*/#Peer)|T then
         {P Peer}
         {ForAll T P}
      [] nil then
         skip
      end
   end

   fun {GetAfter Id L Pivot MaxKey}
      fun {Loop RelId L}
         case L
         of (Dist#Peer)|T then
            if Dist >= RelId then
               Peer %% It's mee
            else
               {Loop RelId T}
            end
         [] nil then
            nil
         end
      end
   in
      {Loop {Distance Id Pivot MaxKey} L}
   end
        
   fun {GetBefore Id L Pivot MaxKey}
      fun {Loop RelId L Candidate}
         case L
         of (Dist#Peer)|T then
            if Dist > RelId then
               Candidate %% It's the previous one
            else
               {Loop RelId T Peer}
            end
         [] nil then
            Candidate
         end
      end
   in
      {Loop {Distance Id Pivot MaxKey} L nil}
   end

   fun {GetFirst L Default}
      case L
      of (_/*Dist*/#Peer)|_/*Tail*/ then
         Peer
      else
         Default
      end
   end

   fun {GetLast L Default}
      case L
      of (_/*Dist*/#Peer)|nil then
         Peer
      [] _/*Dist#Peer*/|T then
         {GetLast T Default}
      else
         Default
      end
   end

   %% Return true if Peer is found in list L
   fun {IsIn Peer L}
      case L
      of (_/*Dist*/#H)|T then
         if H == Peer then
            true
         else
            {IsIn Peer T}
         end
      [] nil then
         false
      end
   end

   %% Like Take
   %% Keep function is exatly as in CiList
   
   %% Remove a Peer from a List
   fun {Remove Peer L}
      case L
      of (Dist#HeadPeer)|Tail then
         if HeadPeer == Peer then
            Tail
         else
            (Dist#HeadPeer)|{Remove Peer Tail}
         end
      [] nil then
         nil
      end
   end

   %% Remove the last element of a list
   %% RemoveLast is jut like CiList

   %% Return a list with elements of L1 that are not present in L2
   fun {Minus L1 L2}
      case L1
      of (Dist#Peer)|T then
         if {IsIn Peer L2} then
            {Minus T L2}
         else
            (Dist#Peer)|{Minus T L2}
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
