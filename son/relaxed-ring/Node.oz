/*-------------------------------------------------------------------------
 *
 * Node.oz
 *
 *    Instance of a relaxed-ring node. It composes the relaxed-ring maintenance
 *    (RlxRing ) with routing (FingerTable). 
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
 *    This component is the interface that should be used by Pbeer if the
 *    desired overlay is the relaxed-ring. Since the relaxed-ring maintenance
 *    is orthogonal to the election of the finger-routing table, Node makes the
 *    composition of RlxRing and FingerTable, being the last one an
 *    implementation of the k-ary finger table a la DKS. 
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   System
   Component   at '../../corecomp/Component.ozf'
   RlxRing     at 'RlxRing.ozf'
   FingerTable at 'FingerTable.ozf'
export
   New
define
   
   fun {New Args}
      Self
      RlxRingNode
      TheFTable

      Events = events(
                  any:  RlxRingNode
                  )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         %Listener = FullComponent.listener
      end
      RlxRingNode = {RlxRing.new Args}
      local
         Id MaxKey ComLayer
      in
         {RlxRingNode getMaxKey(MaxKey)}
         {RlxRingNode getId(Id)}
         {RlxRingNode getComLayer(ComLayer)}
         TheFTable = {FingerTable.new args(maxKey:MaxKey id:Id)}
         {TheFTable setComLayer(ComLayer)}
      end
      %{RlxRingNode setFingerTable(TheFTable)}
      Self
   end

end
