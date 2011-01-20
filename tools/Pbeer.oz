/*-------------------------------------------------------------------------
 *
 * Pbeer.oz
 *
 *    Source of the command line utility 'pbeer'. It execute the correspondent
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
 *    This is NOT a beernet component. It's a utility to connect to a running
 *    pbeer in a given network to executes some operations.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Board          at '../corecomp/Board.ozf'
   Component      at '../corecomp/Component.ozf'
   RelaxedRing    at '../son/relaxed-ring/Node.ozf'
   Replication    at '../trappist/SymmetricReplication.ozf'
   TheDHT         at '../dht/DHT.ozf'
   TheMsgLayer    at '../messaging/MsgLayer.ozf'
   TransLayer     at '../trappist/Trappist.ozf'
   Utils          at '../utils/Misc.ozf'
export
   New
define

