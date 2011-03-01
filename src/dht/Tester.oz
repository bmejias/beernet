%% This file is meant to test the functionality of the functors implemented on
%% this module.

functor
import
   Application
   Property
   System
   TestDHT        at 'TestDHT.ozf'
   TestSDB        at 'TestSDB.ozf'
define

   %% For feedback
   %Show   = System.show
   Say    = System.showInfo
   Args
   
   proc {HelpMessage}
      {Say "Usage: "#{Property.get 'application.url'}#" <test> [option]"}
      {Say ""}
      {Say "Tests:"}
      {Say "\tdht\tTest the DHT running on a network"}
      {Say "\tsdb\tTest the functionality of the simple db with secrets"}
      {Say ""}
      {Say "Options:"}
      {Say "  -h, -?, --help\tThis help"}
   end

   proc {FinalMsg Flag}
      if Flag then
         {Say "PASSED"}
      else
         {Say "FAILED: Some tests did not pass. Check above for details"}
      end
   end

in

   {Property.put 'print.width' 1000}
   {Property.put 'print.depth' 1000}

   %% Defining input arguments
   Args = try
             {Application.getArgs
              record(
                     help(single char:[&? &h] default:false)
                     )}

          catch _ then
             {Say 'Unrecognised arguments'}
             optRec(help:true)
          end

   %% Help message
   if Args.help then
      {HelpMessage}
      {Application.exit 0}
   end
   
   case Args.1
   of Command|nil then
      case Command
      of "dht" then
         {FinalMsg {TestDHT.run Args}}
      [] "sdb" then
         {FinalMsg {TestSDB.run Args}}
      else
         {Say "ERROR: Invalid invocation\n"}
         {HelpMessage}
      end
   else
      {Say "ERROR: Invalid invocation\n"}
      {HelpMessage}
   end

   {Application.exit 0}
end
