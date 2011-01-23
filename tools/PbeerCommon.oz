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
export
   GetPbeer
define

   fun {GetPbeer StoreTket RingKey}
      Mordor
   in
      Mordor = {Connection.take {Pickle.load StoreTket}}
      {Send Mordor getPbeer(RingKey $)}
   end
end

