/*-------------------------------------------------------------------------
 *
 * SetsCommon.oz
 *
 *    Common run procedure for the three operations associated to key/value
 *    sets, presented as pbeer subcommands. Support for capabilities does not
 *    work correctly.
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

   proc {Run Args Op}
      Pbeer
      Key
      MyPort
      MyStream
   in
      if Args.help then
         Use
      in
         if Op == readSet then
            Use = [key cap ring store] 
         else
            Use = [key value cap ring store]
         end 
         {PbeerBaseArgs.helpMessage Use nil Op}
         {Application.exit 0}
      end
      Pbeer = {PbeerCommon.getPbeer Args.store Args.ring}
      MyPort = {Port.new MyStream}
      if Op == readSet then
         Result
      in
         Key#_ = {PbeerCommon.getCapOrKey Args.cap Args.key}
         {Pbeer readSet(Key Result _)}
         for I in 1..{Record.width Result} do
            {Wait Result.I}
            {System.show Result.I}
         end
      else
         Key#_ = {PbeerCommon.capOrKey Args.cap Args.key}
         {Pbeer Op(Key Args.value MyPort)}
         {System.showInfo MyStream.1}
      end
      {Application.exit 0}
   end
end
