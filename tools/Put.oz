/*-------------------------------------------------------------------------
 *
 * Put.oz
 *
 *    pbeer subcommand. It connect to any peer and triggers a put operation
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
         {PbeerBaseArgs.helpMessage [key value cap ring store] nil put}
         {Application.exit 0}
      end
      Pbeer = {PbeerCommon.getPbeer Args.store Args.ring}
      {Pbeer put(Args.key Args.value)}
      {Delay 100}
      {System.showInfo "Operation put("#Args.key#" "#Args.value#") sent."}
      {Application.exit 0}
   end
end
