/*-------------------------------------------------------------------------
 *
 * ListPbeers.oz
 *
 *    It connects to any pbeer from a given ring, and list pbeers from it
 *    following the successor pointer. It misses branches if any. The amount of
 *    pbeers to be listed is parametrizable.
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
   Application
   Connection
   OS
   Pickle
   System
   BaseArgs at 'BaseArgs.ozf'
   Clansman at 'Clansman.ozf'
   TextFile at '../utils/TextFile.ozf'
export
   DefArgs
   Run
define

   START_KEY   = 0
   MAX         = 0

   %% ListPbeers uses the following Args from BaseArgs:
   %%    ring
   %%    store
   %%    storepath
   %%    storesite
   DefArgs = record(
                     fromkey(single type:int default:START_KEY)
                     max(single     type:int default:MAX)
                   )

   proc {Run Args}
      Mordor
      Pbeer
   in
      Mordor   = {Connection.take {Pickle.load Args.store}}
      Pbeer    = {Send Mordor getPbeer(Args.ring $)}
   end

end
