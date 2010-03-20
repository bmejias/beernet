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
export
   AddDefaults
define

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

end

