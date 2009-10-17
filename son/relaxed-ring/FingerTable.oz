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
 *     The Finger Table does not receives messages from the comunication
 *     layer. It only sends messages through it. Messages are receive by the
 *     Finger Table from within the node using the event route(...).
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../../corecomp/Component.ozf'
   KeyRanges   at '../../utils/KeyRanges.ozf'
export
   New
define

   fun {New Args}
      Self
      Id          % Id of the owner node. Pivot for relative ids
      Fingers     % RingList => sorted using Id first reference 
      LogMaxKey   % Frequently used value
      MaxKey      % Maximum value for a key

      ComLayer    % Communication Layer, to send messages.

      proc {AddFinger Event}
         addFinger(Pbeer) = Event
      in
         skip
      end

      proc {FindFingers Event}
         findFingers(Contact) = Event
      in
         skip
      end

      proc {GetFingers Event}
         getFingers(TheFingers) = Event
      in
         TheFingers = nil
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
         route(msg:Msg srcId:SrcId target:Target) = Event
      in
         skip
      end

      proc {SetComLayer Event}
         setComLayer(NewComLayer) = Event
      in
         ComLayer := NewComLayer
      end

      proc {SetId Event}
         setId(NewId) = Event
      in
         Id := NewId
      end

      Events = events(
                  addFinger:     AddFinger
                  findFingers:   FindFingers
                  getFingers:    GetFingers
                  monitor:       Monitor
                  removeFinger:  RemoveFinger
                  route:         Route
                  setComLayer:   SetComLayer
                  setId:         SetId
                  )
   in
      Self        = {Component.newTrigger Events}
      Id          = Args.id
      MaxKey      = Args.maxKey
      LogMaxKey   = {Float.toInt {Float.log {Int.toFloat MaxKey+1}}}
      ComLayer    = {NewCell Component.dummy}
      Self
   end

end
