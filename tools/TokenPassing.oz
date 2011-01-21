/*-------------------------------------------------------------------------
 *
 * TokenPassing.oz
 *
 *    Component on top of Beernet. It does a round trip to the ring following
 *    successor link. It misses nodes in branches.
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
   System
   Component   at '../corecomp/Component.ozf'
   Random      at '../utils/Random.ozf'
export
   New
define
  
   fun {New Args}
      %Listener
      Self
      Pbeer
      Token
      TripId
      Trips

      proc {PassToken passToken(TheTripId#TheToken#Size tag:tokken)}
         if Token == TheToken then
            %% we made a round trip
            {Args.say "\t\t\tThere is a round trip done"}
            Trips.TheTripId = Size
         else
            %% just increase the size and pass the token
            Succ
         in
            %{Args.say "\t\t\tPassing the token"}
            Succ = {Pbeer getSucc($)}
            {Pbeer send(passToken(TheTripId#TheToken#Size+1 tag:tokken) 
                        to:Succ.id)}
         end
      end

      proc {PassExec passExec(TheTripId#TheToken#Proc tag:tokken)}
         {Proc Pbeer}
         if Token == TheToken then
            %% we made a round trip
            {Args.say "\t\t\tThere is a round trip done of executions"}
            Trips.TheTripId = unit
         else
            %% execute and pass the token
            Succ
         in
            Succ = {Pbeer getSucc($)}
            {Pbeer send(passExec(TheTripId#TheToken#Proc tag:tokken) 
                        to:Succ.id)}
         end
      end

      proc {PassExecProb passExecProb(TheTripId#TheToken#Data tag:tokken)}
         if Token == TheToken then
            %% we made a round trip
            {Args.say '#'("\t\t\t"
                          "There is a round trip done of prob executions "
                          TheTripId)}
            Trips.TheTripId = unit
         else
            %% execute if we got chance and pass the token
            Succ
            Chance
            NewP
         in
            Chance = {Random.urandInt 1 Data.max}
            if Chance =< Data.p then
               {Data.yes Pbeer}
               NewP = Data.p - 1
            else
               {Data.no Pbeer}
               NewP = Data.p
            end
            Succ = {Pbeer getSucc($)}
            {Pbeer dsend(passExecProb('#'(TheTripId
                                          TheToken
                                          data(max:Data.max-1
                                               p:NewP
                                               yes:Data.yes
                                               no:Data.no))
                                      tag:tokken)
                        to:Succ)}
         end
      end

      proc {BootstrapTrip Flag MsgLabel MsgValue}
         ThisId NextTrip Succ
      in
         ThisId = TripId := NextTrip
         Trips.ThisId := Flag
         NextTrip = ThisId + 1
         Succ = {Pbeer getSucc($)}
         {Pbeer send(MsgLabel(ThisId#Token#MsgValue tag:tokken) to:Succ.id)}
      end

      proc {RingTrip ringTrip(Size)}
         {BootstrapTrip Size passToken 1}
      end

      proc {RingTripExec ringTripExec(Proc Flag)}
         {BootstrapTrip Flag passExec Proc}
      end

      proc {RingTripExecProb ringTripExecProb(Proc NoProc Max P Flag)}
         {System.show 'GOING TO LAUNCH A PROBABILISTIC TOKKEN PASSING'}
         {BootstrapTrip Flag passExecProb data(yes:Proc no:NoProc max:Max p:P)}
      end

      proc {DoNothing _}
         skip
      end

      Events = events(
                     any:           DoNothing
                     passExec:      PassExec  
                     passExecProb:  PassExecProb
                     passToken:     PassToken
                     ringTrip:      RingTrip
                     ringTripExec:  RingTripExec
                     ringTripExecProb:RingTripExecProb
                     )
   in
      %% Creating the component and collaborators
      local
         FullComponent
      in
         FullComponent  = {Component.new Events}
         Self     = FullComponent.trigger
         %Listener = FullComponent.listener
      end
      Pbeer    = Args.pbeer
      Token    = {Name.new}

      Trips    = {Dictionary.new}
      TripId   = {NewCell 1} 

      Self
   end
end
