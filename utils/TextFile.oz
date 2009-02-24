/*-------------------------------------------------------------------------
 *
 * TextFile.oz
 *
 *    Provides an interfice to read and write text files
 *
 * LICENSE
 *
 *    Copyright (c) 2009 Universite catholique de Louvain
 *
 *    Beernet is released under the MIT License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: Boriss Mejias <boriss.mejias@uclouvain.be>
 *
 *    Last change: $Revision$ $Author$
 *
 *    $Date$
 *
 * NOTES
 *      
 *    This functor is an interface to the classes from the Mozart Open module
 *    to create text files for read and write. The idea is to concentrate class
 *    inheritance and try catch operation on this file, to avoid poluting the
 *    rest of the code. This functor is used as a library instead of a
 *    component, so no events are used.
 *
 *-------------------------------------------------------------------------
 */

functor

import
   Open
   System

export
   New

define

   class TextFile from Open.text Open.file end

   fun {New Args}
      TheFile
      proc {Obj Msg}
         case Msg
         of write(Text) then
            {TheFile putS({Value.toVirtualString Text 1000 1000})}
         [] close then
            try
               {TheFile close}
            catch E then
               {System.show 'Error: Problem closing file '#Args.name}
               {System.show 'Exception: '#E}
            end
         else
            {TheFile Msg}
         end
      end
   in
      try
         TheFile = {Object.new TextFile Args}
      catch E then
         {System.show 'Error: Trying to open file '#Args.name}
         {System.show 'Exception: '#E}
         try
            {TheFile close}
         catch _ then
            skip
         end
      end
      %% Return the file object
      Obj
   end

end
