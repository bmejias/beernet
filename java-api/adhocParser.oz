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
   in
      case Str
      of &p|&u|&t|&(|T then
         KeyString ValueString Key Val
         NuStr 
      in
         %% Matching put messages: put(Key,Value)
         KeyString = {LoopUntil &, T NuStr}
         ValueString = {LoopUntil &) NuStr _}
         Key = {StringToValue KeyString atom}
         Val = {StringToValue ValueString string}
         put(key:Key value:Val)
      [] &g|&e|&t|&(|T then
         KeyString Key
      in
         %% Matching get messages: get(Key)
         KeyString = {LoopUntil &) T _}
         Key = {StringToValue KeyString atom}
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
