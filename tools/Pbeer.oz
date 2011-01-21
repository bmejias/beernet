/*-------------------------------------------------------------------------
 *
 * Pbeer.oz
 *
 *    Source of the command line utility pbeer. It execute the correspondent
 *    program given on the arguments.
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
 * NOTES
 *    
 *    This is NOT a beernet component. It is a utility to connect to a running
 *    pbeer in a given network to executes some operations.
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

end
