/*-------------------------------------------------------------------------
 *
 * Note.oz
 *
 *    This program launches a beernet peer, and it allows to kill it. It is
 *    rarely used manually. It is mostly called from programs beernet and
 *    pbeer.
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
   Property
   BaseArgs    at '../lib/tools/BaseArgs.ozf'
   Clansman    at '../lib/tools/Clansman.ozf'
define

   Args
   Help  = ["  -m, --master\tStores the ring reference (default: false)"
            "  -b, --busy\tKeeps the peer busy printing its neighbours"]
   DefArgs = record(
                     busy(single       char:&b  type:bool   default:false)
                     master(single     char:&m  type:bool   default:false)
                   )
in

   {Property.put 'print.width' 1000}
   {Property.put 'print.depth' 1000}

   Args = {BaseArgs.getArgs DefArgs}

   %% Help message
   if Args.help then
      {BaseArgs.helpMessage Help}
      {Application.exit 0}
   end

   {Clansman.run Args}

end
