functor
export
   Run
define
   proc {ConnectPbeers L}
      proc {ConnectPbeer PbeerRef L}
         case L
         of NextPbeer|MorePbeers then
            {NextPbeer connectTo(PbeerRef)}
            {ConnectPbeer PbeerRef MorePbeers}
         [] nil then
            skip
         end
      end
   in
      case L
      of H|T then
         HRef
      in
         {H getRef(HRef)}
         {ConnectPbeer HRef T}
         {ConnectPbeers T}
      [] nil then
         skip
      end
   end

   proc {Run Pbeers}
      {ConnectPbeers Pbeers}
      {Delay 5000}
   end
end


