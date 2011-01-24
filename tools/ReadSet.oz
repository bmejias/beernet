/*-------------------------------------------------------------------------
 *
 * Remove.oz
 *
 *    pbeer subcommand. It connect to any peer and triggers a readSet
 *    operation.It retrieves the set from the majority of the replicas.
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
   SetsCommon     at 'SetsCommon.ozf'
export
   DefArgs
   Run
define
   DefArgs = nil

   proc {Run Args}
      Pbeer
      Key
      Result
   in
      if Args.help then
         {PbeerBaseArgs.helpMessage [key cap ring store] nil read}
         {Application.exit 0}
      end
      Pbeer = {SetsCommon.getPbeer Args.store Args.ring}
      Key   = {SetsCommon.getCapOrKey Args.cap Args.key}
      {Pbeer readSet(Key Result)}
      for I in 1..{Record.width Result} do
         {Wait Result.I}
         {System.show Result.I}
      end
      {Application.exit 0}
   end
end
