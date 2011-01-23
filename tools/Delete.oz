/*-------------------------------------------------------------------------
 *
 * Delete.oz
 *
 *    pbeer subcommand. It connect to any peer and triggers a delete operation
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
   PbeerCommon at 'PbeerCommon.ozf'
export
   DefArgs
   Run
define
   DefArgs = nil

   proc {Run Args}
      Pbeer
   in
      if Args.help then
         {PbeerBaseArgs.helpMessage [key cap ring store] nil delete}
         {Application.exit 0}
      end
      Pbeer = {PbeerCommon.getPbeer Args.store Args.ring}
      {Pbeer delete(Args.key)}
      {Delay 100}
      {System.showInfo "Operation delete("#Args.key#") sent."}
      {Application.exit 0}
   end
end
