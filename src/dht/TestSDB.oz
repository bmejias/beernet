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

   NoValue  = SimpleSDB.noValue
   Success  = SimpleSDB.success
   BadSecret= SimpleSDB.badSecret

   fun {PutAndGet SDB}
      R1 R2 K1 K2 V S
   in
      K1 = {Name.new}
      K2 = {Name.new}
      V  = {Name.new}
      S  = {Name.new}
      {Wisper "put and get: "} 
      {SDB put(K1 K2 V S R1)}
      if R1 == Success then
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
      if {SDB get({Name.new} {Name.new} $)} == NoValue then
         {Say "PASSED"}
         true
      else
         {Say "FAILED: Creation out of nothing"}
         false
      end
   end

   fun {Delete SDB}
      R1 R2 K1 K2 V S
   in
      K1 = {Name.new}
      K2 = {Name.new}
      V  = {Name.new}
      S  = {Name.new}
      {Wisper "delete : "}
      {SDB delete({Name.new} {Name.new} {Name.new} R1)}
      if R1 == NoValue then
         {SDB put(K1 K2 V S Success)}
         if {SDB get(K1 K2 $)} == V then
            {SDB delete(K1 K2 S R2)}
            if R2 == Success andthen {SDB get(K1 K2 $)} == NoValue then
               {Say "PASSED"}
               true
            else
               {Say "FAILED: deleting existing item did not work"}
               false
            end
         else
            {Say "FAILED: putting did not work.... VERY STRANGE"}
            false
         end   
      else
         {Say "FAILED: Deleting unexisting element did not work"}
         false
      end
   end

   fun {WrongKeysOnPut SDB}
      R1 K1 K2 V S
   in
      K1 = {Name.new}
      K2 = {Name.new}
      V  = {Name.new}
      S  = {Name.new}
      {Wisper "wrong keys on put : "}
      {SDB put(K1 K2 {Name.new} S Success)}
      {SDB put(K1 K2 V S Success)}
      if {SDB get(K1 K2 $)} == V then
         %% testing wrong K2
         {SDB put(K1 {Name.new} {Name.new} S Success)}
         if {SDB get(K1 K2 $)} == V then
            %% testing wrong secret
            {SDB put(K1 K2 {Name.new} {Name.new} R1)}
            if R1 == BadSecret then
               %% testing wrong K1
               {SDB put({Name.new} K2 {Name.new} S Success)}
               if {SDB get(K1 K2 $)} == V then
                  %% testing wrong K1 and K2
                  {SDB put({Name.new} {Name.new} {Name.new} S Success)}
                  if {SDB get(K1 K2 $)} == V then
                     {Say "PASSED"}
                     true
                  else
                     {Say "FAILED: on wrong K1 and K2"}
                     false
                  end
               else
                  {Say "FAILED: on wrong K1"}
                  false
               end
            else
               {Say "FAILED: on wrong secret"}
            end
         else
            {Say "FAILED: on wrong K2"}
            false
         end
      else
         {Say "FAILED: on basic put. VERY STRANGE!"}
         false
      end
   end

   fun {WrongKeysOnGet SDB}
      K1 K2 V S
   in
      K1 = {Name.new}
      K2 = {Name.new}
      V  = {Name.new}
      S  = {Name.new}
      {Wisper "wrong keys on get : "}
      {SDB put(K1 K2 V S Success)}
      if {SDB get(K1 K2 $)} == V then
         %% testing wrong K2
         if {SDB get(K1 {Name.new} $)} == NoValue then
            %% testing wrong K1
            if {SDB get({Name.new} K2 $)} == NoValue then
               %% testing wrong K1 and K2
               if {SDB get(K2 K1 $)} == NoValue then
                  {Say "PASSED"}
                  true
               else
                  {Say "FAILED: on wrong K1 and K2"}
                  false
               end
            else
               {Say "FAILED: on wrong K1"}
               false
            end
         else
            {Say "FAILED: on wring K2"}
            false
         end
      else
         {Say "FAILED: on basic put/get. VERY STRANGE!"}
      end
   end

   fun {WrongKeysOnDelete SDB}
      {Wisper "wrong keys on delete : "}
      true
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
      {AddTest Delete}
      {AddTest WrongKeysOnPut}
      {AddTest WrongKeysOnGet}
      {AddTest WrongKeysOnDelete}
      {List.foldL @Results Bool.and true}
   end

end
