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
 *    pbeer in a given network to executes some operations. Available
 *    operations are:
 *
 *    Key/value pair operations
 *       put
 *       get
 *       delete
 *
 *    Key/value-sets operations
 *       add
 *       readSet
 *       remove
 *
 *    Key/value pair operations with replication
 *       write
 *       read
 *    
 *    Lookup operations
 *       lookup
 *       lookupHash
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Property
   System
   BaseArgs       at '../lib/tools/BaseArgs.ozf'
   Delete         at '../lib/tools/Delete.ozf'
   Get            at '../lib/tools/Get.ozf'
   Lookup         at '../lib/tools/Lookup.ozf'
   LookupHash     at '../lib/tools/LookupHash.ozf'
   PbeerBaseArgs  at '../lib/tools/PbeerBaseArgs.ozf'
   Put            at '../lib/tools/Put.ozf'
define

   Say = System.showInfo
   Args
   
   proc {HelpMessage}
      {Say "Usage: "#{Property.get 'application.url'}#" <subcommand> [options]"}
      {Say ""}
      {Say '#'("Type '"#{Property.get 'application.url'}#" help <subcommand>' "
               "for help on a specific subcommand.")}
      {Say ""}
      {Say "Available subcommands with an example of use:"}
      {Say ""}
      {Say "   Key/value pair operations"}
      {Say "\tput\t-k key -v value"}
      {Say "\tget\t-k key"}
      {Say "\tdelete\t-k key"}
      {Say ""}
      {Say "   Key/value-sets operations"}
      {Say "\tadd\t-k key -v any_value"}
      {Say "\treadSet\t-k key"}
      {Say "\tremove\t-k key -v any_value"}
      {Say ""}
      {Say "   Key/value pair operations with replication"}
      {Say "\twrite\t-k key -v value"}
      {Say "\tread\t-k key -v value"}
      {Say ""}
      {Say "   Lookup operations"}
      {Say "\tlookup\t-k key"}
      {Say "\tlookupHash --hashkey 666"}
      {Say ""}
   end

   proc {ThisHelpRun _/*Args*/}
      {HelpMessage}
      {Application.exit 0}
   end

   proc {ErrorMsg Msg}
      {Say "ERROR: "#Msg}
      {Say ""}
      {HelpMessage}
      {Application.exit 0}
   end

   Subcommands = subcmds(
                         delete:    Delete
                         put:       Put
                         get:       Get
                         lookup:    Lookup
                         lookupHash:LookupHash
                         help:      rec(defArgs:nil
                                        run:ThisHelpRun))
in

   {Property.put 'print.width' 1000}
   {Property.put 'print.depth' 1000}

   Args = {PbeerBaseArgs.getArgs record}

   %% Help message
   if Args.help then
      {HelpMessage}
      {Application.exit 0}
   end

   {BaseArgs.runSubCommand Args Subcommands ErrorMsg}
end
