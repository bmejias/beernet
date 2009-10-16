/*-------------------------------------------------------------------------
 *
 * FingerTable.oz
 *
 *    K-ary finger table to route message in O(log_k(N)) hops.
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
 * NOTES
 *      
 *     This Finger Table is based on DKS generalization of Chord fingers to
 *     guarantee O(log_k(N)) hops (at the level of the overlay, not counting
 *     tcp/ip connections). The idea is that the address space of size N is
 *     divided in k, and then, the smallest fraction is divided again into k,
 *     until the granularity is small enough.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   KeyRanges   at '../../utils/KeyRanges.ozf'
export
   New
define

   fun {New Args}
      Id          % Id of the owner node. Pivot for relative ids
      Fingers     % RingList => sorted using Id first reference 

      proc {AddFinger Event}
         addFinger(Pbeer) = Event
      in
         skip
      end

      proc {GetFingers Event}
         getFingers(TheFingers) = Event
      in
         TheFingers = nil
      end

      proc {Init Event}
         init(id:TheId succ:Succ pred:Pred succList:SuccList) = Event
      in
         skip
      end

      proc {Monitor Event}
         monitor(Pbeer) = Event
      in
         skip
      end

      proc {RemoveFinger Event}
         removeFinger(Finger) = Event
      in
         skip
      end

      proc {Route Event}
         route(msg:Msg srcId:SrcId targetId:Tgid) = Event
      in
         skip
      end

      proc {SetId Event}
         setId(NewId) = Event
      in
         Id := NewId
      end

      Events = events(
                  addFinger:     AddFinger
                  getFingers:    getFingers
                  init:          Init
                  monitor:       Monitor
                  removeFinger:  RemoveFinger
                  route:         Route
                  setId:         setId
                  )
   in
      fingerTable
   end

end
