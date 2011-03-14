functor
export
   Parse
define
   %% Translate a String into an Oz entity
   fun {StringToValue Str Default}
      if {String.isFloat Str} then
         {String.toFloat Str}
      elseif {String.isInt Str} then
         {String.toInt Str}
      elseif Default == atom then
         {String.toAtom Str}
      else
         Str
      end
   end

   %% Translate strings into records
   fun {Parse Str}
      fun {LoopUntil Char L NuStr}
         case L
         of H|T then
            if H == Char then
               NuStr = T
               nil
            else
               H|{LoopUntil Char T NuStr}
            end
         else
            NuStr = nil
            nil
         end
      end
      fun {Retrieve Char In Type Next}
         Str
      in
         Str = {LoopUntil Char In Next}
         {StringToValue Str Type}
      end
   in
      case Str
      of &p|&u|&t|&(|T then
         Key Val Secret
         NextStr LastStr 
      in
         %% Matching get messages: put(Key,Val,Secret)
         Key = {Retrieve &, T atom NextStr}
         Val = {Retrieve &, NextStr string LastStr}
         Secret = {Retrieve &) LastStr atom _} 
         put(k:Key v:Val s:Secret)
      [] &g|&e|&t|&(|T then
         Key
      in
         %% Matching get messages: get(Key)
         Key = {Retrieve &) T atom _}
         get(key:Key)         
      [] &s|&i|&g|&n|&i|&n|&(|T then
         UserString PasswdString User Passwd
         NuStr
      in
         %% Matching get messages: signin(Username,Password)
         UserString = {LoopUntil &, T NuStr}
         PasswdString = {LoopUntil &) NuStr _}
         User = {StringToValue UserString atom}
         Passwd = {StringToValue PasswdString atom}
         signin(username:User password:Passwd)
      [] &v|&o|&t|&e|&(|T then
         UserStr PasswdStr RecommStr VoteStr
         User Passwd Recomm Vote
         NuStr1 NuStr2 NuStr3
      in
         %% Matching get messages: signin(Username,Password)
         UserStr = {LoopUntil &, T NuStr1}
         PasswdStr = {LoopUntil &, NuStr1 NuStr2}
         RecommStr = {LoopUntil &, NuStr2 NuStr3}
         VoteStr = {LoopUntil &) NuStr3 _}
         User = {StringToValue UserStr atom}
         Passwd = {StringToValue PasswdStr atom}
         Recomm = {StringToValue RecommStr int}
         Vote = {StringToValue VoteStr int}
         vote(username:User password:Passwd recomm:Recomm vote:Vote)
      [] &r|&e|&c|&o|&m|&m|&(|T then
         UserStr PasswdStr TitleStr ArtistStr LinkStr
         User Passwd Title Artist Link
         NuStr1 NuStr2 NuStr3 NuStr4
      in
         %% Matching get messages: signin(Username,Password)
         UserStr = {LoopUntil &, T NuStr1}
         PasswdStr = {LoopUntil &, NuStr1 NuStr2}
         TitleStr = {LoopUntil &, NuStr2 NuStr3}
         ArtistStr = {LoopUntil &, NuStr3 NuStr4}
         LinkStr = {LoopUntil &) NuStr4 _}
         User = {StringToValue UserStr atom}
         Passwd = {StringToValue PasswdStr atom}
         Title = {StringToValue TitleStr int}
         Artist = {StringToValue ArtistStr int}
         Link = {StringToValue LinkStr int}
         recomm(username:User password:Passwd
                title:Title artist:Artist link:Link)
      else
         %error("ill formed string")
         error(Str)
      end
   end

end
