/*-------------------------------------------------------------------------
 *
 * Beernet.oz
 *
 *    Source of the command line utility 'beernet'. It allows to bootstrap a
 *    ring, list peers, kill and add pbeers.
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
 *    This is a simple utility that allows bootstraping and inspecting beernet
 *    rings. It provides bootstrap, list, add and kill.
 *    
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Connection
   OS
   Pickle
   Property
   System
   BaseArgs    at '../lib/tools/BaseArgs.ozf'
   Bootstrap   at '../lib/tools/Bootstrap.ozf'
   Clansman    at '../lib/tools/Clansman.ozf'
   TextFile    at '../lib/utils/TextFile.ozf'
define

   Say = System.showInfo
   Args

   proc {HelpMessage}
      {Say "Usage: "#{Property.get 'application.url'}#" <subcommand> [options]"}
      {Say ""}
      {Say '#'("Type '"#{Property.get 'application.url'}#"' help <subcommand> "
               "for help on a specific subcommand.")}
      {Say ""}
      {Say "Available subcommands:"}
      {Say "   bootstrap"}
      {Say "   help"}
      {Say ""}
   end

   proc {ErrorMsg Msg}
      {Say "ERROR: "#Msg}
      {Say ""}
      {HelpMessage}
      {Application.exit 0}
   end

   proc {ThisHelpRun _/*Args*/}
      {HelpMessage}
      {Application.exit 0}
   end

   Subcommands = subcmds(bootstrap:Bootstrap
                         help:rec(run:ThisHelpRun))
in

   {Property.put 'print.width' 1000}
   {Property.put 'print.depth' 1000}

   %% Defining input arguments
   Args = {BaseArgs.getArgs Bootstrap.defArgs}

   %% Help message
   if Args.help then
      {HelpMessage}
      {Application.exit 0}
   end

   case Args.1
   of Subcmd|MoreArgs then
      case Subcmd
      of "help" then
         case MoreArgs
         of Subcmd|nil then
            SubCommand = {String.toAtom Subcmd}
         in
            try
               {Subcommands.SubCommand.run optRec(help:true)}
            catch _ then
               {ErrorMsg "Wrong subcommand."}
            end
         else
            {ErrorMsg "Wrong invocation."}
         end
      else
         SubCommand = {String.toAtom Subcmd}
      in
         try
            {Subcommands.SubCommand.run Args}
         catch _ then
            {ErrorMsg "Wrong subcommand."}
         end
      end
   else
      {ErrorMsg "Wrong invocation."}
   end

end

