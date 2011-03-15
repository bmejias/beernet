/*-------------------------------------------------------------------------
 *
 * socketServer 
 *
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Browser
   Open
   OS
   Property
   System
   AdhocParser at 'adhocParser.ozf'
define
   DEFAULTPORT = 91530
   PUT = rec(success(0) error(1))
   GET = rec(any_value 'NOT_FOUND')

   Parse  = AdhocParser.parse %% To parse strings that arrived on the socket
   Say    = System.showInfo %% For feedback to the standard output
   Browse = Browser.browse
   Blabla %% For verbose feedback
   Bla    %% For verbose feedback without newline
   Args   %% Application arguments
   Server %% THIS socket connection for listening other programs

   fun {GetVS Set Field}
      {Value.toVirtualString Set.Field 100 100}
   end

   %% Behaviour of the socket server is defined here
   class Accepted from Open.socket 

      meth report(H P)
         TheMsg
      in
         {self read(list:TheMsg)}
         {Browse TheMsg}
         {Bla "Got "#TheMsg}
         case {Parse TheMsg}
         of put(k:_/*Key*/ v:_/*Val*/ s:_/*Secret*/) then 
            {self randomReply(put)}
         [] get(k:_/*Key*/) then 
            {self randomReply(get)}
         [] error(E) then
            {Bla E}
            {self toSocket("Please, avoid sending rubish!")}
         end
      end

      meth randomReply(Kind)
         Choice
      in
         Choice = 1 + {OS.rand} mod 2
         {Blabla "Got a correct "#Kind#" message"}
         case Kind
         of put then
            {Blabla "going to reply "#{GetVS PUT Choice}} 
            {self toSocket({GetVS PUT Choice})}
         [] get then
            {Blabla "going to reply "#{GetVS GET Choice}}
            {self toSocket({GetVS GET Choice})}
         end
      end

      meth toSocket(VS)
         {self write(vs:VS#"\n")}
      end
   end
   
   %% Loop for reading every input to the socket
   proc {Accept}
      H P A
   in 
      {Server accept(acceptClass:Accepted host:?H port:?P accepted:?A)}
      thread
         {A report(H P)}  
      end 
      {Accept}
   end 
in
   %% Defining the arguments
   Args = try
             {Application.getArgs
              record(help(single char:[&? &h] default:false)
                     port(single char:[&p] type:int default:DEFAULTPORT)
                    )}
          catch _ then
             {Say 'Unrecognised arguments'}
             optRec(help:true)
          end
   %% Help message
   if Args.help orelse Args.1 \= nil then
      {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
      {Say "Options:"}
      {Say '#'("  -p, --port NUM\tPort number for the socket (default "
               DEFAULTPORT ")")}
      {Say "  -h, -?, --help\tThis help"}
      {Application.exit 0}
   end

   %% Defining verbose feedback
   %if Args.verbose then
      Blabla   = Say
      Bla      = System.printInfo
   %else
   %   Blabla   = proc {$ _} skip end
   %   Bla      = proc {$ _} skip end
   %end
   
   %% Let there be a socket connection
   try P in
      Server={New Open.socket init}
      {Server bind(port:P takePort:Args.port)}
      {Server listen}
      {Say "The socket server is listening to port number:"}
      {System.show P}
      {Accept}
   catch E then
      {Say "No socket connection."}
      {Say "Probably, the address is already in use. Here is the exception:"}
      {System.show E}
      {Say "----------------------------------------------------------------"}
      {Application.exit 1}
   end
end   
