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
   System
   Component   at '../../corecomp/Component.ozf'
   KeyRanges   at '../../utils/KeyRanges.ozf'
   RingList    at '../../utils/RingList.ozf'
export
   New
define

   %% Default values
   K_DEF    = 4         % Factor k for k-ary fingers
   MAX_KEY  = 1048576   % 2^20

   fun {New Args}
      Self
      Id          % Id of the owner node. Pivot for relative ids
      Fingers     % RingList => sorted using Id first reference
      IdealIds    % Ideals ids to chose the fingers
      K           % Factor k to divide the address space to choose fingers
      %LogMaxKey   % Frequently used value
      MaxKey      % Maximum value for a key

      ComLayer    % Communication Layer, to send messages.

      % --- Utils ---
      fun {CheckNewFinger Ids Fgs New}
         case Ids
         of H|T then
            if {RingList.isEmpty Fgs} then
               {RingList.add New Fgs @Id @MaxKey}
            else
               P  = {RingList.getFirst Fgs noFinger}
               Ps = {RingList.tail Fgs}
            in
               if {KeyRanges.checkOrder @Id H P.id} then
                  if {KeyRanges.checkOrder @Id H New.id} then
                     if {KeyRanges.checkOrder @Id New.id P.id} then
                        {RingList.add New {CheckNewFinger T Ps P} @Id @MaxKey}
                     else
                        {RingList.add P {CheckNewFinger T Ps New} @Id @MaxKey}
                     end
                  else
                     Fgs
                  end
               else
                  {CheckNewFinger Ids Ps New}
               end
            end
         [] nil then
            {RingList.new}
         end
      end

      fun {ClosestPrecedingFinger Key}
         {RingList.getBefore Key @Fingers @Id @MaxKey}
      end

      proc {SetVars Args}
         if {HasFeature Args id} then
            Id := Args.id
         end
         if {HasFeature Args k} then
            K := Args.k 
         end
         if {HasFeature Args maxKey} then
            MaxKey := Args.maxKey
         end
         IdealIds := {KeyRanges.karyIdFingers @Id @K @MaxKey}
      end

      %% --- Events --- 
      proc {AddFinger Event}
         addFinger(Pbeer) = Event
      in
         Fingers := {CheckNewFinger @IdealIds @Fingers Pbeer}
      end

      proc {FindFingers Event}
         findFingers(_/*Contact*/) = Event
      in
         skip
      end

      proc {GetFingers Event}
         getFingers(TheFingers) = Event
      in
         TheFingers = @Fingers
      end

      proc {Monitor Event}
         monitor(Pbeer) = Event
      in
         Fingers := {CheckNewFinger @IdealIds @Fingers Pbeer}
      end

      proc {RemoveFinger Event}
         removeFinger(Finger) = Event
      in
         Fingers := {RingList.remove Finger @Fingers}
      end

      proc {Route Event}
         route(msg:Msg src:Src target:Target ...) = Event
      in
         {System.show going_to_route#Event}
         if {Not {Record.label Msg} == join} then
            {Monitor monitor(Src)}
         end
         {@ComLayer sendTo({ClosestPrecedingFinger Target} Event)}
      end

      proc {Reset Event}
         reset(...) = Event
      in
         {SetVars Event}
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
         IdealIds := {KeyRanges.karyIdFingers @Id @K @MaxKey}
      end

      proc {SetK Event}
         setK(NewK) = Event
      in
         K := NewK
         IdealIds := {KeyRanges.karyIdFingers @Id @K @MaxKey}
      end

      proc {SetMaxKey Event}
         setK(NewMaxKey) = Event
      in
         MaxKey := NewMaxKey
         IdealIds := {KeyRanges.karyIdFingers @Id @K @MaxKey}
      end

      Events = events(
                  addFinger:     AddFinger
                  findFingers:   FindFingers
                  getFingers:    GetFingers
                  monitor:       Monitor
                  removeFinger:  RemoveFinger
                  route:         Route
                  reset:         Reset
                  setComLayer:   SetComLayer
                  setId:         SetId
                  setMaxKey:     SetMaxKey
                  setK:          SetK
                  )
   in %% --- New starts ---
      Self        = {Component.newTrigger Events}
      Id          = {NewCell 0}
      K           = {NewCell K_DEF}
      MaxKey      = {NewCell MAX_KEY}
      IdealIds    = {NewCell nil}
      {SetVars Args} % SetVars initialize IdealIds 
      Fingers     = {NewCell {RingList.new}}
      %LogMaxKey   = {Float.toInt {Float.log {Int.toFloat @MaxKey+1}}}
      ComLayer    = {NewCell Component.dummy}
      Self
   end

end
