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
   Blabla %% For verbose feedback
   Args   %% Application arguments
   Server %% THIS socket connection for listening other programs
 
   %% Behaviour of the socket server is defined here
   class Accepted from Open.socket 

      meth report(H P)
         TheMsg
      in
         {self read(list:TheMsg)}
         {Blabla "Got "#TheMsg}
         case {Parse TheMsg}
         of put(k:_/*Key*/ v:_/*Val*/ s:_/*Secret*/) then 
            {self randomReply(put)}
         [] get(k:_/*Key*/) then 
            {self randomReply(get)}
         [] error(E) then
            {Blabla E}
            {self write(vs:"Please, avoid sending rubish!\n")}
         end
      end

      meth randomReply(Kind)
         Choice
      in
         Choice = 1 + {OS.rand} mod 2
         {Blabla "Got a correct "#Kind#" message"}
         case Kind
         of put then
            {self write(vs:PUT.Choice)}
         [] get then
            {self read(vs:GET.Choice)}
         end
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
      Blabla = Say
   %else
   %   Blabla = proc {$ _} skip end
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
