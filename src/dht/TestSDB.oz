%% Test the functionality of the simple data base using secrets
%% implemented on SimpleSDB.oz

functor
import
   System
   SimpleSDB   at 'SimpleSDB.ozf'
export
   Run
define

   Say      = System.showInfo
   Wisper   = System.printInfo
   KEYS     = keys(1:foo 2:bar 3:alice)
   VALUES   = vals(1:value1 2:value2 3:value3)
   SECRETS  = sect(1:public 2:secret)
   NOVALUE  = SimpleSDB.noValue

   fun {PutAndGet SDB}
      R1 R2 K1 K2 V S
   in
      K1 = {Name.new}
      K2 = {Name.new}
      V  = {Name.new}
      S  = {Name.new}
      {Wisper "put and get: "} 
      {SDB put(K1 K2 V S R1)}
      if R1 == success then
         {SDB get(K1 K2 R2)}
         if R2 == V then
            {Say "PASSED"}
            true
         else
            {Say "FAILED - could not retrieve stored value"}
            false
         end
      else
         {Say "FAILED - Single put did not work"}
         false
      end
   end
   
   fun {GetNoValue SDB}
      {Wisper "get no value: "}
      if {SDB get({Name.new} {Name.new} $)} == NOVALUE then
         {Say "PASSED"}
         true
      else
         {Say "FAILED: Creation out of nothing"}
         false
      end
   end

   fun {Run _/*Args*/}
      Results = {NewCell nil}
      SDB
      proc {AddTest Test}
         Results := {Test SDB}|@Results
      end
   in
      SDB = {SimpleSDB.new}
      {AddTest PutAndGet} 
      {AddTest GetNoValue} 
      {List.foldL @Results Bool.and true}
   end

end
