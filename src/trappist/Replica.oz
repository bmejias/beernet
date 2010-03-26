/*-------------------------------------------------------------------------
 *
 * Replica.oz
 *
 *    This module provides operations for symmetric replication on circular
 *    address spaces.
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
 *    This might become a component in the future when eager retrieving of data
 *    upon churn is implemented. Meanwhile it just provides the set of keys
 *    corresponding to symmetric replication with plain function. 
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Utils       at '../utils/Misc.ozf'
export
   New
define
  
   MaxKey = {NewCell 666} %% stateful max key
   Factor = {NewCell 4} %% stateful replication factor

   %% Returns a list of 'f' hash keys symmetrically replicated whithin the
   %address space, from 0 to Max. 'f' is the replication Factor. The list
   %starts with the input Key. 
   fun {GetSymReplicas Key Max Factor}
      Increment = Max div Factor
      fun {GetLoop Iter Last}
         if Iter > 0 then
            New = ((Last + Increment) mod Max)
         in
            New|{GetLoop Iter - 1 New}
         else
            nil
         end
      end
      HashKey
   in
      HashKey = {Utils.hash Key Max}
      HashKey|{GetLoop Factor - 1 HashKey}
   end

   fun {New Args}
      if {HasFeature Args maxKey} then
         MaxKey := Args.maxKey
      end
      
      proc {Object Msg}
         case Msg
         of setMaxKey(Key) then
            MaxKey := Key
         [] setFactor(F) then
            Factor := F
         [] getSymReplicas(Key) then
            {GetSymReplicas Key @MaxKey @Factor}
         [] getSymReplicas(Key factor:F) then
            {GetSymReplicas Key @MaxKey F}
         [] getSymReplicas(Key maxKey:Key) then
            {GetSymReplicas Key Key @Factor}
         [] getSymReplicas(Key maxKey:Key factor:F) then
            {GetSymReplicas Key Key F}
         else
            raise error(method_not_found)
         end
      end
   end
   
end
