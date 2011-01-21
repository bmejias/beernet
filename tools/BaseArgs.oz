/*-------------------------------------------------------------------------
 *
 * BaseArgs.oz
 *
 *    Base arguments to launch a beernet ring. Help message associated to base
 *    arguments is also provided here.
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
   System
export
   BuildDefArgs
   Defaults
   GetArgs
   HelpMessage
define

   ACHEL_TKET  = 'achel.tket'
   LOG_FILE    = 'usetime'
   LOG_PATH    = './'
   LOG_TKET    = 'logger.tket'
   LOG_SITE    = 'localhost'
   NODE_PATH   = './'
   DIST_MODE   = localhost
   TRANS_PROT  = paxos
   N_TRANS     = 10
   N_READS     = 100
   READ_BUFF   = 20
   READ_ONLY   = all
   RING_NAME   = eldorado
   RING_SIZE   = 16
   DEF_SITES   = 1
   SCRP_FIRST  = firstPbeer
   SCRP_ANY    = anyPbeer
   SETS_MIN    = 2
   SETS_MAX    = 10
   SETS_STEP   = 2
   SETS_ROUNDS = 10
   STORE_PATH  = './'
   STORE_TKET  = 'mordor.tket'
   STORE_SITE  = 'localhost'

   Say         = System.showInfo

   proc {HelpMessage ExtraText}
      proc {Loop Lines}
         case Lines
         of Line|MoreLines then
            {Say Line}
            {Loop MoreLines}
         [] nil then
            skip
         end
      end
   in
      {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
      {Say ""}
      {Say "Options:"}
      {Say "  -r, --ring\tRing name (default: "#RING_NAME#")"}
      {Say "      --size\tExpected network size (default: "#RING_SIZE#")"}
      {Say '#'("      --sites\tAmount of machines to be used (default: "
               DEF_SITES ")")}
      {Say '#'("  -p, --protocol Transactional protocol to be used (default: "
               TRANS_PROT ")")}
      {Say '#'("  -t, --trans\tAmount of transactions to be run (default: "
               N_TRANS ")")}
      {Say "      --reads\tAmount of reads per peer (default: "#N_READS#")"}
      {Say "      --readbuff Buffer of reads (default: "#READ_BUFF#")"}
      {Say "      --readonly Run only this test (default: "#READ_ONLY#")"}
      {Say "  -s, --store\tTicket to the store (default: "#STORE_TKET#")"}
      {Say "      --storepath Store's ticket path (default: "#STORE_PATH#")"}
      {Say "      --storesite Store's site (default: "#STORE_SITE#")"}
      {Say "      --logger\tTicket to the logger (default: "#LOG_TKET#")"}
      {Say "      --logpath\tPath to logger's ticket (default: "#LOG_PATH#")"}
      {Say "      --logsite\tLogger's site (default: "#LOG_SITE#")"}
      {Say "      --logfile\tFile to log stats (default uses current time)"}
      {Say "      --nodepath\tPath to node's scripts (default: "#NODE_PATH#")"}
      {Say "  -d, --dist\tDistributed mode (default: "#DIST_MODE#")"}
      {Say "  -a, --achel\tStop notification point (default: "#ACHEL_TKET#")"}
      {Say ""}

      {Loop ExtraText}

      {Say ""}
      {Say "  -h, --help\tThis help"}
   end

   Defaults = record(
               achel(single      char:&a  type:atom   default:ACHEL_TKET)
               dist(single       char:&d  type:atom   default:DIST_MODE)
               logfile(single             type:atom   default:LOG_FILE)
               logger(single              type:atom   default:LOG_TKET)
               logpath(single             type:atom   default:LOG_PATH)
               logsite(single             type:atom   default:LOG_SITE)
               nodepath(single            type:atom   default:NODE_PATH)
               protocol(single   char:&p  type:atom   default:TRANS_PROT)
               reads(single               type:int    default:N_READS)
               readbuff(single            type:int    default:READ_BUFF)
               readonly(single            type:atom   default:READ_ONLY)
               ring(single       char:&r  type:atom   default:RING_NAME)
               scrpfirst(single           type:atom   default:SCRP_FIRST)
               scrpany(single             type:atom   default:SCRP_ANY)
               sites(single               type:int    default:DEF_SITES)
               size(single                type:int    default:RING_SIZE)
               store(single      char:&s  type:atom   default:STORE_TKET)
               storepath(single           type:atom   default:STORE_PATH)
               storesite(single           type:atom   default:STORE_SITE)
               trans(single      char:&t  type:int    default:N_TRANS)
               help(single       char:[&? &h]         default:false)
               )
   
   fun {BuildDefArgs MoreArgs}
      {Record.adjoin Defaults MoreArgs}
   end

   fun {GetArgs MoreArgs}
      DefArgs
   in
      DefArgs  = {BuildDefArgs MoreArgs}
      try
         {Application.getArgs DefArgs}
      catch _ then
         {Say 'Unrecognised arguments'}
         optRec(help:true)
      end
   end

end


