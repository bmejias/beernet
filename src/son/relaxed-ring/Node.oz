/*-------------------------------------------------------------------------
 *
 * Node.oz
 *
 *    Instance of a relaxed-ring node. It composes the relaxed-ring maintenance
 *    (RlxRing ) with routing (FingerTable). 
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
   Component   at '../../corecomp/Component.ozf'
   RlxRing     at 'RlxRing.ozf'
   FingerTable at 'FingerTable.ozf'
export
   New
define
   
   fun {New Args}
      Self
      Suicide
      ComLayer
      RlxRingNode
      FTable

      proc {InjectPermFail injectPermFail}
         {ComLayer signalDestroy}
         {RlxRingNode signalDestroy}
         {FTable signalDestroy}
         {Suicide}
      end

      Events = events(
                  any:              RlxRingNode
                  setListener:      RlxRingNode
                  injectPermFail:   InjectPermFail
                  )
   in
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         Suicide  = FullComponent.killer
         %Listener = FullComponent.listener
      end
      RlxRingNode = {RlxRing.new Args}
      ComLayer = {RlxRingNode getComLayer($)}
      FTable   = {FingerTable.new args(node:RlxRingNode)}
      {FTable setComLayer(ComLayer)}
      {RlxRingNode setFingerTable(FTable)}
      Self
   end

end
