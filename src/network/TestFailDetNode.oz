functor
import
   Connection
   Pickle
   System
   Component         at '../corecomp/Component.ozf'
   Network           at 'Network.ozf'
   FailureDetector   at 'FailureDetector.ozf'
export
   MakeNode
define

   fun {MakeNode Id}

      Self
      SelfRef
      ComLayer

      proc {ConnectTo Event}
         connectTo(Pbeer) = Event
      in
         {ComLayer monitor(Pbeer)}
         {ComLayer sendTo(Pbeer ping(@SelfRef))}
         {System.show 'Trying to connect to '#Pbeer}
      end

      proc {Crash Event}
         crash(Pbeer) = Event
      in
         {System.showInfo "Pbeer "#Pbeer.id#" has crashed!"}
      end

      proc {Ping Event}
         ping(Pbeer) = Event
      in
         {System.showInfo "Pbeer "#Pbeer.id#" is trying to contact me"}
         {ComLayer monitor(Pbeer)}
         {ComLayer sendTo(Pbeer pong(@SelfRef))}
      end

      proc {Pong Event}
         pong(Pbeer) = Event
      in
         {System.showInfo "I got contact with "#Pbeer.id}
      end

      proc {GetRef Event}
         getRef(Ref) = Event
      in
         Ref = @SelfRef
      end

      proc {SetRef Event}
         setRef(Ref) = Event
      in
         SelfRef := Ref
      end

      proc {ToTicket Event}
         toTicket(FileName) = Event
      in
         {Pickle.save {Connection.offerUnlimited @SelfRef} FileName}
      end

      Events = events(
                  connectTo:  ConnectTo
                  crash:      Crash
                  ping:       Ping
                  pong:       Pong
                  getRef:     GetRef
                  setRef:     SetRef
                  toTicket:   ToTicket
                  )
   in
      Self     = {Component.newTrigger Events}
      ComLayer = {Network.new}
      {ComLayer setId(Id)}
      {ComLayer setListener(Self)}
      SelfRef = {Cell.new {ComLayer getRef($)}}
      Self
   end
end
