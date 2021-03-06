/*-------------------------------------------------------------------------
 *
 * Remove.oz
 *
 *    pbeer subcommand. It connect to any peer and triggers a remove operation.
 *    The value is removed from the majority of the replicas hosting the set.
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
      MyPort
      Outcome
   in
      if Args.help then
         {PbeerBaseArgs.helpMessage [key value cap ring store] nil remove}
         {Application.exit 0}
      end
      Pbeer = {SetsCommon.getPbeer Args.store Args.ring}
      MyPort= {Port.new Outcome}
      Key   = {SetsCommon.capOrKey Args.cap Args.key}
      {Pbeer remove(Key Args.value MyPort)}
      {System.showInfo Outcome.1}
      {Application.exit 0}
   end
end
