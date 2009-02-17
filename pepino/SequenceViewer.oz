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
ColWidth=100
LineWidth=16
Weight=100.
MaxSpeed=16.0
MinSpeed=2.0
MaxDistance=500.0
Attraction = {NewCell 0.3}
Repulsion  = {NewCell 0.1}
fun {Head Xs} Xs.1 end
fun {Tail Xs} Xs.2 end

fun {Distance A#B C#D}
   AC=A-C
   BD=B-D
in
   {Max {Sqrt AC*AC + BD*BD} 1.0}
end

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
   GraphCanvas  = {New Tk.canvas tkInit(parent:PanedWindow
                                        bg:white
                                        relief:raised)}
      
   LogCanvas = {New Tk.canvas tkInit(parent:LogFrame bg:white)}
   Title = {New Tk.canvas tkInit(parent:LogFrame height:LineWidth*2 bg:white)}
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

   {PanedWindow tk(add LogFrame GraphCanvas)}

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
   ColorFrame={New Tk.frame tkInit(parent:ControlFrame)}
   ColorButtons={Dictionary.new}
   CurrentAttractorColor={NewCell black}

   {Tk.send pack(side:left StopButton FrameButton PlayButton FFButton FFFButton ToEndButton IndexText Label)}
   {Tk.send pack(side:left fill:x expand:true PatternText)}
   {Tk.send pack(side:right fill:x ColorFrame)}

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

   {PanedWindow tk(sash place 0 300 0)}
      
   NodeCount={NewCell 0}
   LineIdx={NewCell ~1}
   NodeDict={Dictionary.new}
   OriginIdx={Dictionary.new}
   Conf={NewCell c}

   MaxX={NewCell 100.0}
   MaxY={NewCell 100.0}
   GraphNodes={Dictionary.new}
   GraphEdges={Dictionary.new}
   GraphAttractors={Dictionary.new}
   Attractors={NewCell c}
%      Repulsors={NewCell c}
   Active = {NewCell _}   % whether the nodes are active in the window
   {GraphCanvas tkBind(event:"<Enter>" action:proc {$} @Active = unit end)}
   {GraphCanvas tkBind(event:"<Leave>" action:proc {$} unit = Active := _ end)}
   {GraphCanvas tkBind(event:"<Configure>" action:proc{$}
                                                     {Assign MaxX {Tk.returnFloat winfo(width GraphCanvas)}}
                                                     {Assign MaxY {Tk.returnFloat winfo(height GraphCanvas)}}
%                    @Active = unit
%                    thread
%                       {Delay 100}
%                       O N
%                    in
%                       {Exchange Active O N}
%                       if {IsFree O} then N=O end
%                    end
                                                  end)}
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
      {LogCanvas tk(configure scrollregion:q(~ColWidth 0
                                             {Access NodeCount}*ColWidth (N+3)*LineWidth))}
      {Title tk(configure scrollregion:q(~ColWidth 0
                                         {Access NodeCount}*ColWidth LineWidth*2))}
      {LogCanvas tk(yview moveto 1.0)}
      N
   end
   PI=3.14159264
   fun{Complement L}
      D={Dictionary.clone GraphNodes}
   in
      {ForAll L proc{$ K} {Dictionary.remove D K} end}
      {Dictionary.keys D}
   end
   proc{AddColor C}
      O N
   in
      {Dictionary.condExchange ColorButtons C unit O N}
      if O==unit then
         N={New Tk.button tkInit(parent:ColorFrame text:C
                                 action:proc{$}
                                           {ForAll {Dictionary.items ColorButtons}
                                            proc{$ L}
                                               {L tk(configure relief:if L==N then sunken else raised end)}
                                            end}
                                           {SetAttractorColor C}
                                        end
                                 bg:C)}
         {Tk.send pack(side:left N)}
         if C==@CurrentAttractorColor then
            {N tk(configure relief:sunken)}
         end
      else
         N=O
      end
   end
   proc{AddNode Id}
      if {Not {Dictionary.member NodeDict Id}} then
         fun{Loop N}
            %% divide the circle in sections
            %% N>=0 & N<2 =>angle=0+(n*pi)
            %% N>=2 & N<4 => angle=pi/2+((n-2)*pi)
            %% N>=4 & N<8 => angle=pi/4+((n-4)*(pi/2))
            %% N>=8 & N<16 => angle=pi/8+((n-8)*(pi/4))
            fun{ILoop C Delta Seg}
               if N>=C andthen N<(C*2) then
                  Delta+{Int.toFloat (N-C)}*Seg
               else
                  {ILoop C*2 Delta/2.0 Seg/2.0}
               end
            end
         in
            if N==0 then 0.0 elseif N==1 then PI
            else
               {ILoop 2 PI/2.0 PI}
            end
         end
         Col={Length {Dictionary.keys NodeDict}}+1
         T={New Tk.canvasTag tkInit(parent:GraphCanvas)}
         T2={New Tk.canvasTag tkInit(parent:GraphCanvas)}
         T3={New Tk.canvasTag tkInit(parent:GraphCanvas)}
       
         Angle={Loop @NodeCount}
       
         W={Max 50.0 {Min @MaxX @MaxY}/2.0-20.0}
         X=@MaxX/2.0+W*{Cos Angle}
         Y=@MaxY/2.0+W*{Sin Angle}
       
%      {GraphCanvas tk(create text 100 100+10*Col text:{Value.toVirtualString node(id:Id x:X y:Y angle:Angle w:W maxx:@MaxX maxy:@MaxY) 1000 1000})}
%      OI={GraphCanvas tkReturnInt(create(oval X-10. Y-10. X+10. Y+10. fill:white tags:T) $)}
         TI={GraphCanvas tkReturnInt(create(text X Y text:Id tags:T) $)}
         [X1 Y1 X2 Y2]={GraphCanvas tkReturnListInt(bbox(TI) $)}
         BI={GraphCanvas tkReturnInt(create(rect X1-2 Y1-2 X2+2 Y2+2 fill:white outline:black tags:T) $)}
         {GraphCanvas tk('raise' TI)}
         {T tkBind(event:'<Enter>' action:proc{$}
                                             unit = Active := _
                                             {GraphCanvas tk('raise' TI)}
                                             {GraphCanvas tk(lower BI TI)}
                                             {GraphCanvas tk(itemconfigure T2 width:3)}
                                             {GraphCanvas tk(itemconfigure T3 width:3 stipple:gray50)}
                                          end)}
         {T tkBind(event:'<Leave>' action:proc{$}
                                             @Active=unit
                                             {GraphCanvas tk(lower TI)}
                                             {GraphCanvas tk(lower BI TI)}
                                             {GraphCanvas tk(itemconfigure T2 width:1)}
                                             {GraphCanvas tk(itemconfigure T3 width:1 stipple:'')}
                                          end)}
         {T tkBind(event:'<3>'
                   args:[int(x) int(y)]
                   action:proc{$ X Y}
                             {@OnClick node(Id
                                            tag:T
                                            canvas:GraphCanvas
                                            x:X
                                            y:Y)}
                          end)}


         Dragging = {NewCell false}
         DragTo   = {NewCell nil}
         {T tkBind(event:  "<Button-1>"
                   args:   [float(x) float(y)]
                   action: proc {$ X Y} DragTo := X#Y Dragging := true @Active = unit end)}
         {T tkBind(event:  "<Motion>"
                   args:   [float(x) float(y)]
                   action: proc {$ X Y}
                              if @Dragging then DragTo := X#Y end
                           end)}
         {T tkBind(event:  "<ButtonRelease-1>"
                   action: proc {$} Dragging := false end)}
      in
         {Dictionary.put NodeDict Id unit#0#Col}
         {Title tk(create text ColWidth*Col-(ColWidth div 2) LineWidth text:Id)}
         {LogCanvas tk(create line ColWidth*Col-(ColWidth div 2) LineWidth
                       ColWidth*Col-(ColWidth div 2) 100000)}
         NodeCount:=@NodeCount+1
         {Dictionary.put GraphNodes Id n(t:T
                                         'from':T2
                                         to:T3
                                         box:BI
                                         text:TI
                                         c:(X#Y)|_)}
         thread
            %% constant update node position
            proc{Loop OX#OY CheckAtt Att Rep}
               {Delay 100}
               {Wait @Active}
               Old=GraphNodes.Id
               NCheckAtt NAtt NRep
               X1#Y1=if @Dragging then
                        NAtt=Att
                        NRep=Rep
                        NCheckAtt=CheckAtt            
                        @DragTo
                     else
                        %% list of attractors is GraphAttractors.Id
                        %% list of repulsors is {Complement Id|GraphAttractors.Id}
                        if @Attractors==CheckAtt then
                           NAtt=Att
                           NRep=Rep
                           NCheckAtt=CheckAtt
                        else
                           NCheckAtt=@Attractors
                           if {CondSelect NCheckAtt Id nil}==nil then
                              NAtt=nil
                              NRep=nil %% unconnected nodes don't count
%            {Map {List.filter {Dictionary.keys GraphNodes}
%                  fun{$ K} K\=Id andthen {CondSelect NCheckAtt K nil}\=nil end}
%                  fun{$ K}
%                {Dictionary.get GraphNodes K}.c
%                  end}
                           else
                              NAtt={Map NCheckAtt.Id
                                    fun{$ K}
                                       {Dictionary.get GraphNodes K}.c
                                    end}
                              NRep={Map {List.filter
                                         {Complement Id|NCheckAtt.Id}
                                         fun{$ K}
%                     {CondSelect @Repulsors K false}\=false
                                            {CondSelect @Attractors K nil}\=nil
                                         end}
                                    fun{$ K}
                                       {Dictionary.get GraphNodes K}.c
                                    end}
%            {Show Id#NCheckAtt.Id#{List.filter
%                  {Complement Id|NCheckAtt.Id}
%                  fun{$ K} {CondSelect @Attractors K nil}\=nil end}#@Attractors}
                           end
                        end
                        Moves1={Map NAtt
                                fun{$ X}
                                   A#B={Head X}
                                   D = {Distance A#B OX#OY}
                                   F = (@Attraction * (D-Weight) / D)
                                in
                                   (F*(A-OX))#(F*(B-OY))
                                end}
                        Moves2={Map NRep
                                fun{$ X}
                                   A#B={Head X}
                                   D = {Distance A#B OX#OY}
                                   F=(if D>MaxDistance then
                                         0.0
                                      else
                                         @Repulsion * Weight * Weight / (D*D)
                                      end)
                                in
                                   (F*(OX-A))#(F*(OY-B))
                                end}
                     in
                        {FoldL {Append Moves1 Moves2}
                         fun {$ A#B C#D} (A+C)#(B+D) end OX#OY}
                     end
               X2#Y2={Min {Max 10.0 X1} {Access MaxX}-10.0}#{Min {Max 10.0 Y1} {Access MaxY}-10.0}
               ND={Distance OX#OY X2#Y2}
               XN#YN=if @Dragging then
                        X2#Y2 %% no speed limit for the user
                     elseif ND<MinSpeed then OX#OY
                     elseif ND<MaxSpeed then X2#Y2 else
                        (OX+(X2-OX)*MaxSpeed/ND)#(OY+(Y2-OY)*MaxSpeed/ND)
                     end
               N
            in
               {GraphCanvas tk(move T XN-OX YN-OY)}
               Old.c.2=(XN#YN)|N
               {Dictionary.put GraphNodes Id
                {Record.adjoinAt Old c (XN#YN)|N}}
%       if @Dragging then
%          {Loop XN#YN CheckAtt Att Rep}
%       else§
               {Loop XN#YN NCheckAtt {List.map NAtt Tail} {List.map NRep Tail}}
%       end
            end
         in
            {Loop X#Y c nil nil}
%         {Loop X#Y nil nil {Map {List.filter {Dictionary.keys GraphNodes}
%                  fun{$ K} K\=Id end}
%             fun{$ K}
%                  {Dictionary.get GraphNodes K}.c
%             end}}
         end
      end
   end
   proc{AddEdge From To Color}
      {AddNode From}
      {AddNode To}
      {AddColor Color}
      D1={Dictionary.condGet GraphEdges From unit}
      D2=if D1==unit then
            {Dictionary.put GraphEdges From D2}
            {Dictionary.new}
         else D1 end
      D3={Dictionary.condGet D2 To unit}
      D=if D3==unit then
           {Dictionary.put D2 To D}
           {Dictionary.new}
        else D3 end
      Tag={New Tk.canvasTag tkInit(parent:GraphCanvas)}
      LI={GraphCanvas tkReturnInt(create(line 0. 0. 0. 0.
                                         tags:q(Tag {Dictionary.get GraphNodes From}.'from' {Dictionary.get GraphNodes To}.'to')
                                         arrow:last fill:Color smooth:true) $)}
      {Dictionary.put D LI e(c:Color
                             tag:Tag
                             t:F)} %% when F is bound, edge is removed
      {Tag tkBind(event:'<Enter>' action:proc{$}
                                            unit = Active := _
                                            {GraphCanvas tk(itemconfigure LI width:3)}
                                         end)}
      {Tag tkBind(event:'<Leave>' action:proc{$}
                                            @Active=unit
                                            {GraphCanvas tk(itemconfigure LI width:1)}
                                         end)}
      {Tag tkBind(event:'<3>'
                  args:[int(x) int(y)]
                  action:proc{$ X Y}
                            {@OnClick edge(From To
                                           tag:Tag
                                           canvas:GraphCanvas
                                           x:X y:Y)}
                         end)}
      F

      Dist={Length {Dictionary.keys D}}
   in
      if Color==@CurrentAttractorColor then
         {AddAttractor From To}
      end
      thread
         proc{Loop C1 C2 OFrom OTo}
            Which={Record.waitOr c(C1 C2 F)}
         in
            if Which==3 then
               {Dictionary.remove D LI}
               {GraphCanvas tk(delete LI)}
            else
               NFrom
               NTo
               NC1 NC2
               if Which==1 then
                  NTo=OTo
                  NC2=C2
                  case C1 of X#Y|Ls then
                     NFrom=X#Y
                     NC1=Ls
                  else
                     F=unit
                     NC1=_
                     NFrom=unit
                  end
               else
                  NFrom=OFrom
                  NC1=C1
                  case C2 of X#Y|Ls then
                     NTo=X#Y
                     NC2=Ls
                  else
                     F=unit
                     NC2=_
                     NTo=unit
                  end
               end
            in
               if NFrom\=unit andthen NTo\=unit then
                  %% set coords
                  X1#Y1=NFrom
                  X2#Y2=NTo
                  D = {Distance X1#Y1 X2#Y2}
                  Xa#Ya=X1#Y1
                  Xb#Yb=X2+(X1-X2)*10./D#Y2+(Y1-Y2)*10./D
                  Xc#Yc=((Xb+Xa)/2.0)#((Yb+Ya)/2.0)
                  Xd#Yd=(~Yb+Ya)#(Xb-Xa)
%          {GraphCanvas tk(delete ttfg1)}
%          {GraphCanvas tk(create line Xa Ya (Xa+Xd) (Ya+Yd) fill:red tags:ttfg1)}
%          Xe#Ye=(Xc+(((D/5.0)*{Int.toFloat Dist})*Xd)/N)#(Yc+(((D/5.0)*{Int.toFloat Dist})*Yd)/N)
                  Ecart={Min D/6.0 20.0}*{Int.toFloat Dist}
                  Xe#Ye=(Xc+(Ecart*Xd)/D)#(Yc+(Ecart*Yd)/D)
               in
                  {GraphCanvas tk(coords LI Xa Ya Xe Ye Xb Yb)}
               end
               {Loop NC1 NC2 NFrom NTo}
            end
         end
      in
         {Loop GraphNodes.From.c GraphNodes.To.c unit unit}
      end
   end
   proc{RemoveEdge From To Color}
      D1={Dictionary.condGet GraphEdges From unit}
      D2=if D1==unit then
            {Dictionary.put GraphEdges From D2}
            {Dictionary.new}
         else D1 end
      D3={Dictionary.condGet D2 To unit}
      D=if D3==unit then
           {Dictionary.put D2 To D}
           {Dictionary.new}
        else D3 end
   in
      if Color==@CurrentAttractorColor then
         {RemoveAttractor From To}
      end
      {ForAll {Dictionary.entries D}
       proc{$ _/*Id*/#E}
          if E.c==Color then
             E.t=unit
          end
       end}
   end
   proc{SetAttractorColor C}
      CurrentAttractorColor:=C
      {Dictionary.removeAll GraphAttractors}
      {ForAll {Dictionary.entries GraphEdges}
       proc{$ From#D}
          {ForAll {Dictionary.entries D}
           proc{$ To#DD}
              {ForAll {Dictionary.items DD}
               proc{$ E}
                  if E.c==C then
                     D1={Dictionary.condGet GraphAttractors From unit}
                     D2=if D1==unit then
                           {Dictionary.put GraphAttractors From D2}
                           {Dictionary.new}
                        else D1 end
                     Old={Dictionary.condGet D2 To 0}
                  in
                     {Dictionary.put D2 To Old+1}
                  end
               end}
           end}
       end}
     
      {UpdateAttractors}
   end
   proc{RemoveAllOutEdges From}
      D1={Dictionary.condGet GraphEdges From unit}
      D2=if D1==unit then
            {Dictionary.put GraphEdges From D2}
            {Dictionary.new}
         else D1 end
   in
      {ForAll {Dictionary.entries D2}
       proc{$ _#D}
          {ForAll {Dictionary.items D}
           proc{$ E} E.t=unit end}
       end}
      {Dictionary.remove GraphAttractors From}
      {UpdateAttractors}
   end
   proc{UpdateAttractors}
      Nodes={Dictionary.keys GraphNodes}
      A={List.toRecord g {List.map Nodes fun{$ K} K#{Dictionary.new} end}}
   in
%   Repulsors:=c
      {ForAll {Dictionary.entries GraphAttractors}
       proc{$ From#ToDict}
          {ForAll {Dictionary.keys ToDict}
           proc{$ To}
              if To\=From then
                 A.From.To:=unit
                 A.To.From:=unit
%         if {CondSelect @Repulsors To false}==false then
%            Repulsors:={Record.adjoinAt @Repulsors To true}
%         end
              end
           end}
       end}
%   {Show updAttr#{List.toRecord c {List.map {Dictionary.entries GraphAttractors} fun{$ Id#D} Id#{Dictionary.entries D} end}}}
      Attractors:={Record.map A Dictionary.keys}
   end
   proc{AddAttractor From To}
      {AddNode From}
      {AddNode To}
      D1={Dictionary.condGet GraphAttractors From unit}
      D2=if D1==unit then
            {Dictionary.put GraphAttractors From D2}
            {Dictionary.new}
         else D1 end
      Old={Dictionary.condGet D2 To 0}
   in
      {Dictionary.put D2 To Old+1}
      if Old==0 then
         {UpdateAttractors}
      end
   end
   proc{RemoveAttractor From To}
      D1={Dictionary.condGet GraphAttractors From unit}
      D2=if D1==unit then
            {Dictionary.put GraphAttractors From D2}
            {Dictionary.new}
         else D1 end
      Old={Dictionary.condGet D2 To ~1}
   in
      if Old>1 then
         {Dictionary.put D2 To Old-1}
      elseif Old>0 then
         {Dictionary.remove D2 To}
         {UpdateAttractors}
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
         of 'in'(Message_id Receiver_id Receiver_thread_id Sender_id Message ...) then
            {AddNode Sender_id}
            {AddNode Receiver_id}
            Color={CondSelect Nx color gray}
         in
            if {CondSelect @Conf Color true} then
               OrgLine={GetIdx Sender_id Receiver_id Message_id}
               DestLine={IncLineIdx}
               Node={Dictionary.get NodeDict Receiver_id}
               {Dictionary.put NodeDict Receiver_id Receiver_thread_id#DestLine#Node.3}
               OrgCol={Dictionary.get NodeDict Sender_id}.3
               DestCol=Node.3
               %% draw an arrow between (orgline,orgcol) and (destline,destcol)
               Tags={GetTags Sender_id Receiver_id}
               AId={LogCanvas tkReturnInt(create(line OrgCol*ColWidth-(ColWidth div 2) (OrgLine+2)*LineWidth
                                                 DestCol*ColWidth-(ColWidth div 2) (DestLine+2)*LineWidth
                                                 fill:{CondSelect Nx color gray}
                                                 arrow:last
                                                 tags:Tags.2
                                                 arrowshape:q(10 10 5)) $)}
               if {IsFree FirstArrowId} then
                  {Wait AId} FirstArrowId=AId
               end
               TId={LogCanvas tkReturnInt(create(text
                                                 (OrgCol*ColWidth-(ColWidth div 2)+DestCol*ColWidth-(ColWidth div 2)) div 2
                                                 (((OrgLine+2)*LineWidth+(DestLine+2)*LineWidth) div 2)-(LineWidth div 3)
                                                 fill:{CondSelect Nx color gray}
                                                 tags:Tags.1
                                                 text:{Value.toVirtualString Message 10000 10000}) $)}
               [X1 Y1 X2 Y2]={LogCanvas tkReturnListInt(bbox(TId) $)}
               BId={LogCanvas tkReturnInt(create(rect X1-2 Y1-2 X2+2 Y2+2 fill:white outline:white tags:Tags.3) $)}
            in
               {LogCanvas tk(lower AId)}
               {LogCanvas tk('raise' BId FirstArrowId)}
               {LogCanvas tk('raise' TId)}
            end
         [] out(Message_id Sender_id Sender_thread_id Receiver_id ...) then
            {AddNode Sender_id}
            {AddNode Receiver_id}
            Color={CondSelect Nx color gray}
         in
            if {CondSelect @Conf Color true} then
               %% outgoing message
               %% this message should not be drawed yet, instead we remember where we are
               %% so that can draw it when it is received
               %% where we are is either the next available line,
               %% or the continuation of where this node already is (same thread_id)
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
                                              (ColWidth div 2) (Line+2)*LineWidth
                                              anchor:w
                                              fill:Color
                                              tags:Tags.1
                                              text:I#": "#{Value.toVirtualString Message 10000 10000}) $)}
            /*
            LId={LogCanvas tkReturnInt(create(line
                                              0 (Line+2)*LineWidth
                                              10000 (Line+2)*LineWidth
                                              tags:Tags.2
                                              fill:Color) $)}
            [X1 Y1 X2 Y2]={LogCanvas tkReturnListInt(bbox(TId) $)}
            BId={LogCanvas tkReturnInt(create(rect X1-2 Y1-2 X2+2 Y2+2 fill:white tags:Tags.3 outline:white) $)}
            */
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
               {Dictionary.put NodeDict Site_id {CondSelect Nx thid unit}#Line#Col}
               TId={LogCanvas tkReturnInt(create(text
                                                 Col*ColWidth-(ColWidth div 2)
                                                 (Line+2)*LineWidth
                                                 fill:{CondSelect Nx color red}
                                                 tags:Tags.1
                                                 text:{Value.toVirtualString Message 10000 10000}) $)}
%                  [X1 Y1 X2 Y2]={LogCanvas tkReturnListInt(bbox(TId) $)}
%                  BId={LogCanvas tkReturnInt(create(rect X1-2 Y1-2 X2+2 Y2+2 fill:white tags:Tags.3 outline:white) $)}
%       ECmd={VirtualString.toAtom e#TId}
%       LCmd={VirtualString.toAtom l#TId}
%       {Tk.defineUserCmd ECmd
%        proc{$}
%           {LogCanvas tk('raise' TId)}
%           {LogCanvas tk(lower BId TId)}
%           {LogCanvas tk(itemconfigure BId outline:black fill:white)}
%        end nil _}
%       {Tk.defineUserCmd LCmd
%        proc{$}
%           {LogCanvas tk(itemconfigure BId fill:white outline:white)}
%        end nil _}
            in
               {LogCanvas tk('raise' TId)}     
%       {LogCanvas tk(bind TId '<Enter>' ECmd)}
%       {LogCanvas tk(bind TId '<Leave>' LCmd)}
            end
         else
            {System.show ignored#Nx}
         end
         {@OnParse Nx}
         {Loop I+1 Ns}
      else 
         Line={IncLineIdx}
      in
         {LogCanvas tk(create line 0 (Line+2)*LineWidth 100000 (Line+2)*LineWidth)}
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
      meth addEdge(F T C)
         {AddEdge F T C}
      end
      meth removeEdge(F T C)
         {RemoveEdge F T C}
      end
      meth removeAllOutEdges(F)
         {RemoveAllOutEdges F}
      end
      meth addAttractor(F T)
         lock
            {AddAttractor F T}
         end
      end
      meth removeAttractor(F T)
         lock
            {RemoveAttractor F T}
         end
      end
      meth setAttractorColor(C)
         lock
            {SetAttractorColor C}
         end
      end
      meth getNodeInfo(F $)
         R={Dictionary.condGet GraphNodes F unit}
      in
         if R\=unit then
            node(id:F
                 canvas:GraphCanvas
                 box:R.box
                 text:R.text
                 tag:R.t
                 c:R.c)
         else R end
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


