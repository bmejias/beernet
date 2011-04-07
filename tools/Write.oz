/*-------------------------------------------------------------------------
 *
 * Write.oz
 *
 *    pbeer subcommand. It connect to any peer and triggers a transaction.
 *    Transactions can batch several operations into a single transaction, but
 *    in this case, a single write operation is performed.
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

   fun {MakeTransaction Key Value Secret}
      proc {$ TM}
         {TM write(k:Key v:Value s:Secret r:_)}
         {TM commit}
      end
   end

   proc {Run Args}
      Pbeer
      Key
      MyPort
      Outcome
      Trans
   in
      if Args.help then
         {PbeerBaseArgs.helpMessage [key value cap ring secret store protocol]
                                    nil 
                                    write}
         {Application.exit 0}
      end
      Pbeer = {SetsCommon.getPbeer Args.store Args.ring}
      MyPort= {Port.new Outcome}
      Key   = {SetsCommon.capOrKey Args.cap Args.key}
      Trans = {MakeTransaction Key Args.value Args.secret}
      {Pbeer runTransaction(Trans MyPort Args.protocol)}
      {System.showInfo Outcome.1}
      {Application.exit 0}
   end
end
