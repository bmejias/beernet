/*-------------------------------------------------------------------------
 *
 * PbeerCommon.oz
 *
 *    Common functionality shared by several 'pbeer' subcommands.
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
 *-------------------------------------------------------------------------
 */

functor
import
   Connection
   Pickle
   PbeerBaseArgs  at 'PbeerBaseArgs.ozf'
export
   CapOrKey
   GetCapOrKey
   GetPbeer
define

   fun {GetPbeer StoreTket RingKey}
      Mordor
   in
      Mordor = {Connection.take {Pickle.load StoreTket}}
      {Send Mordor getPbeer(RingKey $)}
   end

   fun {CapOrKey CapFile Key}
      if CapFile \= {PbeerBaseArgs.getDefault cap} then
         Cap
      in
         try
            Cap = {Pickle.load CapFile}
         catch _ then %% The CapFile does not exist. Create new cap
            Cap = {Name.new}
            {Pickle.save Cap CapFile}
         end
         Cap#("<"#CapFile#">")
      else
         Key#Key
      end
   end

   fun {GetCapOrKey CapFile Key}
      if CapFile \= {PbeerBaseArgs.getDefault cap} then
         {Pickle.load CapFile}#("<"#CapFile#">")
      else
         Key#Key
      end
   end

end

