/*-------------------------------------------------------------------------
 *
 * Misc.oz
 *
 *    Miscellaneous procedures that can be useful to other modules
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
   Pickle
export
   AddDefaults
   Hash
   GetSymReplicas
define

   %% Add default fields to a record.
   %% Rec is the input record
   %% Defaults follows the pattern: def(field1:value1 ... fieldN:valueN)
   fun {AddDefaults Rec Defaults}
      fun {AddingLoop Fields Acc}
         case Fields
         of Field|MoreFields then
            NewAcc
         in
            if {HasFeature Rec Field} then
               NewAcc = {Record.adjoinAt Acc Field Rec.Field}
            else
               NewAcc = {Record.adjoinAt Acc Field Defaults.Field}
            end
            {AddingLoop MoreFields NewAcc} 
         [] nil then
            Acc
         end
      end
   in
      {AddingLoop {Arity Defaults} Rec}
   end

   %% algorithm from http://www.cse.yorku.ca/~oz/hash.html
   %% Returns a hash value for N between 0 and Max
   fun {Hash N Max}
      B = {Pickle.pack N}
      L = {ByteString.length B}
      fun{Loop I Old}
         if I < L then
            {Loop I + 1 ((Old*33) + {ByteString.get B I}) mod Max}
         else
            Old
         end
      end
   in
      {Loop 0 5381}
   end

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
      HashKey = {Hash Key Max}
      HashKey|{GetLoop Factor - 1 HashKey}
   end

end

