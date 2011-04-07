/*-------------------------------------------------------------------------
 *
 * Kill.oz
 *
 *    pbeer subcommand. It injects a permanent failure on the pbeer responsible
 *    for a given key.
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
   System
   PbeerBaseArgs  at 'PbeerBaseArgs.ozf'
   PbeerCommon    at 'PbeerCommon.ozf'
export
   DefArgs
   Run
define
   DefArgs = nil

   proc {Run Args}
      Pbeer
   in
      if Args.help then
         {PbeerBaseArgs.helpMessage [hashkey ring store] nil kill}
         {Application.exit 0}
      end
      Pbeer    = {PbeerCommon.getPbeer Args.store Args.ring}
      {Pbeer send(injectPermFail to:Args.hashkey)}
      {Delay 100}
      {System.showInfo "Killing message sent"}
      {Application.exit 0}
   end
end


