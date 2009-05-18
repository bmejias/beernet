/*-------------------------------------------------------------------------
 *
 * KeyRanges.oz
 *
 *    Procedures for a clockwise circular identifier address space.
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
import
   Random   at '../../utils/Random.ozf'
export
   BelongsTo
   GetRandomKey
   GetUniqueKey
   InsertPeer
   InsertPeerWithOmega
   ChordIdFingers
   Log
define

   %% Check if a Key is in between From and To considering circular ranges
   fun {BelongsTo Key From To}
      if From < To then
         From < Key andthen Key =< To
      else
         From < Key orelse Key =< To
      end
   end
   
   %% Random Key generator
   fun {GetRandomKey NetworkSize}
      {Random.urandInt 0 NetworkSize}
   end

   %% Make sure that the randomly generated key is not already taken
   %% by another node. All the generated Ids should be included in AddBook.
   %% This function is only useful in simulation mode with a global view.
   fun {GetUniqueKey NetworkSize AddBook}
      Key = {GetRandomKey NetworkSize}
   in
      if {Dictionary.member AddBook Key} then
         {GetUniqueKey NetworkSize AddBook}
      else
         Key
      end
   end

   %% Insert New peer circular-clockwise in a sorted list of Peers.
   %% Pivot is the starting point of clockwise order.
   %% N is the size of the address space.
   %% Do not insert the peer if it is already in the list
   %% Returns the new list with the New peer inserted
   fun {InsertPeer New Pivot N Peers}
      fun {Relative Id}
         ((Id - Pivot) + N) mod N
      end
   in
      case Peers
      of Peer|Rest then
         if {Relative New.id} < {Relative Peer.id} then
            New|Peers
         elseif New.id == Peer.id then
            Peers
         else
            Peer|{InsertPeer New Pivot N Rest}
         end
      [] nil then
         [New]
      end
   end

   %% Do not insert more peers than Omega
   %% This algorithm is useful in case we decide to use Palta topology
   fun {InsertPeerWithOmega New Pivot N Peers Omega}
      if {List.length Peers} > Omega then
         Peers
      else
         {InsertPeer New Pivot N Peers}
      end
   end

   %% According to Id and N, it returns a list of ids for fingers
   fun {ChordIdFingers Id N}
      fun {Loop Id N I Acc}
         D = N div I
      in
         if D > 1 then
            {Loop Id N I*2 ((Id + D) mod N)|Acc}
         else
            Acc
         end
      end    
   in
      {Loop Id N 2 nil}
   end

   %% Integer version of logarithmic function (approximated)
   fun {Log Base Value}
      fun {Loop I Acc}
         NewAcc = Acc*Base
      in
         if NewAcc >= Value then
            I
         else
            {Loop I+1 NewAcc}
         end
      end
   in
      {Loop 1 1}
   end
end
