/*-------------------------------------------------------------------------
 *
 * EventViewer.oz
 *
 *    Graphical display of node's time lines with their local events and
 *    message exchange
 *
 * LICENSE
 *
 *    Copyright (c) 2009 Universite catholique de Louvain
 *
 *    PEPINO is released under the MIT License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: Boriss Mejias <boriss.mejias@uclouvain.be>
 *
 *    Contributors: Based on the code of Donatien Grolaux
 *
 *    Last change: $Revision$ $Author$
 *
 *    $Date$
 *
 * NOTES
 *      
 *    This event viewer is meant to be included as part of PEPINO. It creates
 *    a timeline for every node/peer. Whenever an event is triggered on a
 *    node, it is represented on the time line. When messages are have a known
 *    source and destination, an arrow labeled with the message is drawn
 *    between the corresponding timeline.
 *    
 *-------------------------------------------------------------------------
 */
                                                                                             
declare
COL_WIDTH  = 100
LINE_WIDTH = 16

fun{InteractiveLogViewer Log}  %% Log is a stream or a list
   Window = {New Tk.toplevel tkInit(delete:proc{$}
                                               {@OnClose Window}
                                            end)}
   {Tk.send wm(title Window "PEPINO")}
   PanedWindow = {New {Tk.newWidgetClass noCommand panedwindow}
                  tkInit(parent:Window
                         orient:horizontal
                         showhandle:true
                         sashrelief:raised
                         opaqueresize:true)}
   
   ControlFrame = {New Tk.frame tkInit(parent:Window)}
      
   LogFrame     = {New Tk.frame tkInit(parent:PanedWindow relief:raised)}

   LogCanvas = {New Tk.canvas tkInit(parent:LogFrame bg:white)}
   Title = {New Tk.canvas tkInit(parent:LogFrame height:LINE_WIDTH*2 bg:white)}
   ScrollH = {New Tk.scrollbar tkInit(parent:LogFrame orient:horizontal)}
   ScrollV = {New Tk.scrollbar tkInit(parent:LogFrame orient:vertical)}
   {Window tkBind(event:'<MouseWheel>' args:[int('D')]
                  action:proc{$ D}
                            {LogCanvas tk(yview scroll (D div ~120) units)}
                         end)}

   {Tk.send grid(rowconfigure Window 0 weight:1)}
   {Tk.send grid(columnconfigure Window 0 weight:1)}
   {Tk.send grid(configure PanedWindow column:0 row:0 sticky:nswe)}
   {Tk.send grid(configure ControlFrame column:0 row:1 sticky:swe)}

   {PanedWindow tk(add LogFrame)}

   StopButton  = {New Tk.button tkInit(parent:ControlFrame
                                       text:"[]"
                                       relief:sunken
                                       action:CO#stop)}
   FrameButton = {New Tk.button tkInit(parent:ControlFrame
                                       text:"|>"
                                       relief:raised
                                       action:CO#oneFrame)}
   PlayButton  = {New Tk.button tkInit(parent:ControlFrame
                                       text:">"
                                       relief:raised
                                       action:CO#play(speed:250))}
   FFButton    = {New Tk.button tkInit(parent:ControlFrame
                                       text:">>"
                                       relief:raised
                                       action:CO#play(speed:100))}
   FFFButton   = {New Tk.button tkInit(parent:ControlFrame
                                       text:">>>"
                                       relief:raised
                                       action:CO#play(speed:50))}
   ToEndButton = {New Tk.button tkInit(parent:ControlFrame
                                       text:">|"
                                       relief:raised
                                       action:CO#runToEnd)}
   IndexVar={New Tk.variable tkInit(0)}
   IndexText={New Tk.entry tkInit(parent:ControlFrame textvariable:IndexVar)}
   {IndexText tkBind(event:'<Return>'
                     action:proc{$}
                               V1=try {IndexVar tkReturnInt($)} catch _ then ~1 end
                               V=if {Int.is V1} then V1 else ~1 end
                            in
                               {CO goto(V)}
                            end)}
   Label={New Tk.label tkInit(parent:ControlFrame text:"Message: ")}
   PatternVar={New Tk.variable tkInit("")}
   PatternText={New Tk.entry tkInit(parent:ControlFrame
                                    textvariable:PatternVar)} 
   {PatternText tkBind(event:'<Return>'
                       action:proc{$}
                                 Str = {PatternVar tkReturn($)}
                              in
                                 {Wait Str}
                                    %{System.show Str}
                                    %{@OnEnter Str}
                              end)}
   {Tk.send pack(side:left
                 StopButton FrameButton PlayButton FFButton FFFButton
                 ToEndButton IndexText Label)}
   {Tk.send pack(side:left fill:x expand:true PatternText)}

   {Tk.send grid(rowconfigure LogFrame 1 weight:1)}
   {Tk.send grid(columnconfigure LogFrame 0 weight:1)}
   {Tk.send grid(configure Title column:0 row:0 sticky:nwe)}
   {Tk.send grid(configure LogCanvas column:0 row:1 sticky:nswe)}
   {Tk.send grid(configure ScrollH column:0 row:2 sticky:we)}
   {Tk.send grid(configure ScrollV column:1 row:0 rowspan:2 sticky:ns)}
   {Tk.defineUserCmd xscroll
    proc{$ L}
       {LogCanvas tk(xview b(L))}
       {Title tk(xview b(L))}
    end [list(atom)] _}
   {Tk.send v('proc xscroll2 args {\n' #
              '   eval xscroll {$args}\n' #
              '}')}
   {LogCanvas tk(configure xscrollcommand:s(ScrollH set))}
   {ScrollH tk(configure command:xscroll2)}
   {Tk.addYScrollbar LogCanvas ScrollV}

%   {PanedWindow tk(sash place 0 300 0)}
      
   NodeCount={NewCell 0}
   LineIdx={NewCell ~1}
   NodeDict={Dictionary.new}
   OriginIdx={Dictionary.new}
   Conf={NewCell c}

   MaxX={NewCell 100.0}
   MaxY={NewCell 100.0}
   OnParse      = {NewCell proc{$ _} skip end}
   OnClick      = {NewCell proc{$ _} skip end}
   OnEnter      = {NewCell proc{$ _} skip end}
   OnRunTrans   = {NewCell proc{$ _} skip end}  
   OnBreakPoint = {NewCell proc{$ _} skip end}
   OnResume     = {NewCell proc{$ _} skip end}
   OnCrashTM    = {NewCell proc{$ _} skip end}
   OnClose      = {NewCell proc{$ C} {C tkClose} end}
   fun{IncLineIdx}
      O N
   in
      {Exchange LineIdx O N}
      N=O+1
      {LogCanvas tk(configure scrollregion:q(~COL_WIDTH 0
                                             {Access NodeCount}*COL_WIDTH (N+3)*LINE_WIDTH))}
      {Title tk(configure scrollregion:q(~COL_WIDTH 0
                                         {Access NodeCount}*COL_WIDTH LINE_WIDTH*2))}
      {LogCanvas tk(yview moveto 1.0)}
      N
   end
   PI=3.14159264
   proc{AddNode Id}
      if {Not {Dictionary.member NodeDict Id}} then
         Col={Length {Dictionary.keys NodeDict}}+1
         Col
      in
         NodeCount:=@NodeCount+1
         Col = @NodeCount
         {Dictionary.put NodeDict Id unit#0#Col}
         {Title tk(create text COL_WIDTH*Col-(COL_WIDTH div 2) LINE_WIDTH text:Id)}
         {LogCanvas tk(create
                       line
                       COL_WIDTH*Col-(COL_WIDTH div 2)
                       LINE_WIDTH
                       COL_WIDTH*Col-(COL_WIDTH div 2)
                       100000)}
      end
   end
   proc{StoreIdx K1 K2 K3 V}
      D1={Dictionary.condGet OriginIdx K1 unit}
      D1x=if D1==unit then
             D={Dictionary.new}
             {Dictionary.put OriginIdx K1 D}
          in
             D
          else D1 end
      D2={Dictionary.condGet D1x K2 unit}
      D2x=if D2==unit then
             D={Dictionary.new}
             {Dictionary.put D1x K2 D}
          in
             D
          else D2 end
   in
      {Dictionary.put D2x K3 V}
   end
   fun{GetIdx K1 K2 K3}
      try
         D={Dictionary.get {Dictionary.get OriginIdx K1} K2}
         V={Dictionary.get D K3}
      in
         {Dictionary.remove D K3}
         V
      catch _ then 
         {IncLineIdx}
      end
   end
   FirstArrowId
   TagDict={Dictionary.new}
   fun{GetTags S R}
      M1={Min S R}
      M2={Max S R}
      D1=if {Dictionary.member TagDict M1} then
            {Dictionary.get TagDict M1}
         else
            D={Dictionary.new}
         in
            {Dictionary.put TagDict M1 D}
            D
         end
   in
      if {Dictionary.member D1 M2} then
         {Dictionary.get D1 M2}
      else
         T={New Tk.canvasTag tkInit(parent:LogCanvas)}#{New Tk.canvasTag tkInit(parent:LogCanvas)}#{New Tk.canvasTag tkInit(parent:LogCanvas)}
         proc{Raise} % T.1 is text, T.2 is arrow, T.3 is blackbox
            {LogCanvas tk('raise' T.2)}
            {LogCanvas tk('raise' T.3)}
            {LogCanvas tk('raise' T.1)}
            {LogCanvas tk(itemconfigure T.2 width:3)}
            {LogCanvas tk(itemconfigure T.3 outline:black fill:white)}
         end
         proc{Lower}
            {LogCanvas tk(lower T.2)}
            {LogCanvas tk('raise' T.3 FirstArrowId)}
            {LogCanvas tk(itemconfigure T.2 width:1)}
            {LogCanvas tk(itemconfigure T.3 fill:white outline:white)}
         end
      in
         {T.1 tkBind(event:"<Enter>" action:Raise)}
         {T.1 tkBind(event:"<Leave>" action:Lower)}
         {T.2 tkBind(event:"<Enter>" action:Raise)}
         {T.2 tkBind(event:"<Leave>" action:Lower)}
         {Dictionary.put D1 M2 T}
         T
      end
   end
   Tick={NewCell _}
   SetIndex={NewName}
   proc{Loop I N}
      {Wait @Tick}
      {Tk.send update(idletasks)}
      {CO SetIndex(I)}
      case N of Nx|Ns then
         case Nx
         of 'in'(n:Message_id dest:Receiver_id src:Sender_id msg:Message ...) then
            {AddNode Sender_id}
            {AddNode Receiver_id}
            Color={CondSelect Nx color gray}
            Receiver_thread_id=777
         in
            {Browse 'i got an in message'}
            if {CondSelect @Conf Color true} then
               OrgLine={GetIdx Sender_id Receiver_id Message_id}
               DestLine={IncLineIdx}
               Node={Dictionary.get NodeDict Receiver_id}
               {Dictionary.put NodeDict Receiver_id Receiver_thread_id#DestLine#Node.3}
               OrgCol={Dictionary.get NodeDict Sender_id}.3
               DestCol=Node.3
               %% draw an arrow between (orgline,orgcol) and (destline,destcol)
               Tags={GetTags Sender_id Receiver_id}
               AId={LogCanvas
                    tkReturnInt(create(line
                                       OrgCol*COL_WIDTH-(COL_WIDTH div 2)
                                       (OrgLine+2)*LINE_WIDTH
                                       DestCol*COL_WIDTH-(COL_WIDTH div 2)
                                       (DestLine+2)*LINE_WIDTH
                                       fill:{CondSelect Nx color gray}
                                       arrow:last
                                       tags:Tags.2
                                       arrowshape:q(10 10 5)) $)}
               if {IsFree FirstArrowId} then
                  {Wait AId} FirstArrowId=AId
               end
               TId={LogCanvas
                    tkReturnInt(create(text
                                       (OrgCol*COL_WIDTH-(COL_WIDTH div 2)+DestCol*COL_WIDTH-(COL_WIDTH div 2)) div 2
                                       (((OrgLine+2)*LINE_WIDTH+(DestLine+2)*LINE_WIDTH) div 2)-(LINE_WIDTH div 3)
                                       fill:{CondSelect Nx color gray}
                                       tags:Tags.1
                                       text:{Value.toVirtualString Message 10000 10000}) $)}
               [X1 Y1 X2 Y2]={LogCanvas tkReturnListInt(bbox(TId) $)}
               BId={LogCanvas
                    tkReturnInt(create(rect
                                       X1-2
                                       Y1-2
                                       X2+2
                                       Y2+2
                                       fill:white
                                       outline:white
                                       tags:Tags.3) $)}
            in
               {LogCanvas tk(lower AId)}
               {LogCanvas tk('raise' BId FirstArrowId)}
               {LogCanvas tk('raise' TId)}
            end
         [] out(n:Message_id src:Sender_id dest:Receiver_id ...) then
            {AddNode Sender_id}
            {AddNode Receiver_id}
            Color={CondSelect Nx color gray}
            Sender_thread_id = 666
         in
            if {CondSelect @Conf Color true} then
               %% outgoing message this message should not be drawed
               %% yet, instead we remember where we are so that can
               %% draw it when it is received where we are is either
               %% the next available line, or the continuation of
               %% where this node already is (same thread_id)
               Line
               Node={Dictionary.get NodeDict Sender_id}
            in
               if Node.1==Sender_thread_id then
                  Line=Node.2
               else
                  Line={IncLineIdx}
               end
               {Dictionary.put NodeDict Sender_id Sender_thread_id#Line#Node.3}
               {StoreIdx Sender_id Receiver_id Message_id Line}
               %%      {Dictionary.put OriginIdx Message_id Line}
            end
         [] next(Site_id ...) then
            {AddNode Site_id}
            Node={Dictionary.get NodeDict Site_id}
         in
            {Dictionary.put NodeDict Site_id unit#0#Node.3}
         [] comment(Message ...) then
            Color={CondSelect Nx color black}
            Line={IncLineIdx}
            Tags={GetTags ~1 ~1}
            TId={LogCanvas tkReturnInt(create(text
                                              (COL_WIDTH div 2)
                                              (Line+2)*LINE_WIDTH
                                              anchor:w
                                              fill:Color
                                              tags:Tags.1
                                              text:I#": "#{Value.toVirtualString Message 10000 10000}) $)}
         in
            {LogCanvas tk('raise' TId)}   
         [] event(Site_id Message ...) then
            {AddNode Site_id}
            Color={CondSelect Nx color gray}
         in
            if {CondSelect @Conf Color true} then
               Tags={GetTags Site_id Site_id}
               Node={Dictionary.get NodeDict Site_id}
               Line={IncLineIdx}
               Col=Node.3
               {Dictionary.put
                NodeDict
                Site_id
                {CondSelect Nx thid unit}#Line#Col}
               TId={LogCanvas tkReturnInt(create(text
                                                 Col*COL_WIDTH-(COL_WIDTH div 2)
                                                 (Line+2)*LINE_WIDTH
                                                 fill:{CondSelect Nx color red}
                                                 tags:Tags.1
                                                 text:{Value.toVirtualString
                                                       Message 10000 10000}) $)}
            in
               {LogCanvas tk('raise' TId)}     
            end
         else
            {System.show ignored#Nx}
         end
         {@OnParse Nx}
         {Loop I+1 Ns}
      else 
         Line={IncLineIdx}
      in
         {LogCanvas tk(create line 0 (Line+2)*LINE_WIDTH
                       100000 (Line+2)*LINE_WIDTH)}
         {CO stop}
      end
   end
   thread
      {Loop 1 Log}
   end
   Init={NewName}


   ButtonList=[StopButton FrameButton PlayButton FFButton FFFButton ToEndButton]

   proc{SinkButton B}
      {ForAll ButtonList
       proc{$ N}
          if N==B then
             {B tk(configure relief:sunken)}
          else
             {N tk(configure relief:raised)}
          end
       end}
   end

   class Controller
      prop locking
      attr
         PlayThId
         Goto
         Match
         Index
         outputline
      meth !Init
         PlayThId:=unit
         Goto:=~1
         Match:=fun{$ _} false end
         {self onParse(proc{$ _} skip end)}
         Index:=0
         outputline := 0
      end
      meth Change(B)
         try {Thread.terminate @PlayThId} catch _ then skip end
         Goto:=~1
         {SinkButton B}
      end
      meth normal
         {Tk.send wm(state Window normal)}
      end
      meth minimize
         {Tk.send wm(state Window iconic)}
      end
      meth maximize
         {Tk.send wm(state Window zoomed)}
      end
      meth runToEnd
         {self Change(ToEndButton)}
         @Tick=unit
      end
      meth stop
         O N
      in
         {self Change(StopButton)}
         O=Tick:=N
         if {IsFree O} then
            N=O
         end
      end
      meth oneFrame
         {self Change(StopButton)}
         unit=Tick:=_
      end
      meth onParse(P)
         OnParse:=proc{$ E}
                     {P E}
                     if {@Match E} then
                        {self stop}
                     end
                  end
      end
      meth onClick(P)
         OnClick:=P
      end
      meth onEnter(P)
         OnEnter:=P
      end
      meth onRunTrans(P)
         OnRunTrans:=P
      end
      meth onBreakPoint(P)
         OnBreakPoint:=P
      end
      meth onResume(P)
         OnResume:=P
      end
      meth onCrashTM(P)
         OnCrashTM:=P
      end
      meth onClose(P)
         OnClose:=P
      end
      meth play(speed:Speed<=100)
         N
      in
         {self Change(if Speed>=250 then PlayButton
                      elseif Speed>=100 then FFButton
                      else FFFButton end)}
         PlayThId:=N
         thread
            proc{Loop}
               unit=Tick:=_
               {Delay Speed}
               {Loop}
            end
         in
            N={Thread.this}
            {Loop}
         end
         {Wait N}
      end
      meth display(...)=M
         Conf:=M
      end
      meth goto(V)
         if V<@Index then
            {Tk.send bell}
            {IndexVar tkSet(@Index)}
         else
            {self Change(FFFButton)}
            Goto:=V
            @Tick=unit
         end
      end
      meth gotomatch(P)
         {self Change(FFFButton)}
         Match:=P
         @Tick=unit
      end
      meth !SetIndex(I)
         Index:=I
         {IndexVar tkSet(I)}
         if I==@Goto then
            {self stop}
         end
      end
   end
   CO={New Controller Init}
in
   CO
end


declare
[TextFile] = {Module.link ['../utils/TextFile.ozf']}
FN
fun{ReadLog FileName}
   Out
   S={NewCell Out}
   DummyPort={NewPort _}
   DummyChunk={Chunk.new c}
   DummyName={NewName}
   
   fun{Replace Str}
      case Str
      of &<|&P|&o|&r|&t|&>|Ls then
         &D|&u|&m|&m|&y|&P|&o|&r|&t|{Replace Ls}
      [] &<|&C|&h|&u|&n|&k|&>|Ls then
         &D|&u|&m|&m|&y|&C|&h|&u|&n|&k|{Replace Ls}
      [] &<|&N|&>|Ls then
         &D|&u|&m|&m|&y|&N|&a|&m|&e|{Replace Ls}      
      [] Lx|Ls then
         Lx|{Replace Ls}
      else nil end
   end
   thread
      try
         {TextFile.new init(name:FileName)}=FN
         proc{Loop}
            if {FN atEnd($)} then
               raise atEnd end
            end
            Str1={FN getS($)}
            Str={Replace Str1}
         in
            try
               M={Compiler.evalExpression Str env('DummyPort':DummyPort 'DummyChunk':DummyChunk 'DummyName':DummyName) _ $}
               O N
               in
               {Exchange S O N}
               O=M|N
            catch _ then 
               {System.showInfo "Ignored line "#Str1}
            end
            {Loop}
         end
      in
         {Loop}
      catch _ then
         try {Access S}=nil catch _ then skip end
         thread try {FN close} catch _ then skip end end
      end
   end
in
   Out
end

declare
O={InteractiveLogViewer {ReadLog 'lucifer.log'}}
Logger = proc{$ _} skip end
{O display(network:true rlxring:true)}
{O onParse(proc{$ E}
              {Browse [going to test E]}
              case E
              of event(_ event(connect#node(_ id:_)) color:blue ...) then
                 skip
                       %{O addEdge(F T black)}
              [] event(F event(disconnect#node(_ id:T)) color:blue ...) then
                 {O removeEdge(F T black)}
              [] event(F event(permFail#node(_ id:T)) color:blue ...) then
                 for Colour in [black green red lightblue] do
                    {O removeEdge(F T Colour)}
                 end
                       %{O removeEdge(F M red)}
                       %{O addEdge(F N red)}
              [] comment(permFail(Dead) color:red ...) then
                 Info={O getNodeInfo(Dead $)}
              in
                 {O removeAllOutEdges(Dead)}
                 {Info.canvas tk(itemconfigure Info.box fill:red)}
              [] event(F succChanged(N M) color:darkblue ...) then
                 {O removeEdge(F M green)}
%         {O removeAttractor(F M)}
                 {O addEdge(F N green)}
%         {O addAttractor(F N)}
              [] event(F succDisco(N) color:darkblue ...) then
                 {O removeEdge(F N green)}
                 {O removeAttractor(F N)}
              [] event(F rangeChanged(N M) color:darkblue ...) then
                 {O removeEdge(F M red)}
                 {O addEdge(F N red)}
%      [] event(F succListChanged(N M) color:darkblue ...) then
%         {ForAll M proc{$ E} if {Not {List.member E N}} then {O removeEdge(F E yellow)} end end}
%         {ForAll N proc{$ E} if {Not {List.member E M}} then {O addEdge(F E yellow)} end end}
              [] event(_/*F*/ predSetChanged(_ _) color:darkblue ...) then
                 skip
                       %{ForAll M proc{$ E} if {Not {List.member E N}} then {O removeEdge(F E lightblue)} end end}
                       %{ForAll N proc{$ E} if {Not {List.member E M}} then {O addEdge(F E lightblue)} end end}
              [] event(F onRing(true) color:darkblue ...) then
                 Info={O getNodeInfo(F $)}
              in
                 {Info.canvas tk(itemconfigure Info.box fill:yellow)}
              [] event(F onRing(false) color:darkblue ...) then
                 Info={O getNodeInfo(F $)}
              in
                 {Info.canvas tk(itemconfigure Info.box fill:white)}
              [] event(F leader ...) then
                 Info={O getNodeInfo(F $)}
              in
                 {Info.canvas tk(itemconfigure Info.box fill:green)}
              [] event(F rtm ...) then
                 Info={O getNodeInfo(F $)}
              in
                 {Info.canvas tk(itemconfigure Info.box fill:cyan)}
              [] event(F participant color:darkblue ...) then
                 Info={O getNodeInfo(F $)}
              in
                 {Info.canvas tk(itemconfigure Info.box fill:lightblue)}
              [] event(F 'lock'(true) color:darkblue ...) then
                 Info={O getNodeInfo(F $)}
              in
                 {Info.canvas tk(itemconfigure Info.box fill:darkblue)}
              [] event(F 'lock'(false) color:darkblue ...) then
                 Info={O getNodeInfo(F $)}
              in
                 {Info.canvas tk(itemconfigure Info.box fill:yellow)}
              else
                 skip
              end       
           end)}
{O onClick(proc{$ E}
              proc{RunMenu L}
                 Menu={New Tk.menu tkInit(parent:E.canvas)}
                 {ForAll L
                  proc{$ E}
                     case E of nil then
                        {New Tk.menuentry.separator tkInit(parent:Menu) _}
                     [] T#P then
                        {New Tk.menuentry.command tkInit(parent:Menu
                                                         label:T
                                                         action:P) _}
                     end
                  end}
              in
                 {Menu tk(post {Tk.returnInt winfo(rootx E.canvas)}+E.x
                          {Tk.returnInt winfo(rooty E.canvas)}+E.y)}
              end
           in
              case E of node(N ...) then
                 SomePeers
              in
                 SomePeers = nil
                 {ForAll SomePeers
                  proc{$ P}
                     if {P getId($)}==N then
                        {RunMenu ["Info..."#proc{$} {Browse {P dump($)}} end
                                  nil
                                  nil
                                  nil]}
                     end
                  end}
              [] edge(_/*From*/ _/*To*/ ...) then
                 {RunMenu ["tempFail"#proc{$} skip end
                           "normal"#proc{$} skip end]}
              else skip end
           end)}
      
%      case E of node(N ...) then
%         {ForAll Peers
%          proc{$ P}
%        if {P getId($)}==N then
%           {P leave}
%        end
%          end}
%      else skip end

%{O onClose(proc{$ C}
%              {CloseLogFile}
%              {FN close}
%              {C tkClose}
%              {Application.exit 0}
%           end)}
                
