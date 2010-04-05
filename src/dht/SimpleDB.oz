/*-------------------------------------------------------------------------
 *
 * SimpleDB.oz
 *
 *    SimpleDB provides basic storage operations for items identified with two
 *    keys.
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
 * NOTES
 *      
 *    Operations provided by SimpleDB are:
 *
 *       put(key1 key2 value)
 *       get(key1 key2)
 *       delete(key1 key2)
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../corecomp/Component.ozf'
export
   New
define

   NO_VALUE = 'NOT_FOUND'

   fun {New}
      DB
      Self

      proc {Delete delete(Key1 Key2)}
         KeyDict
      in
         KeyDict = {Dictionary.condGet DB Key1 unit}
         if KeyDict \= unit then
            {Dictionary.remove KeyDict Key2}
         end
      end

      proc {Get get(Key1 Key2 Val)}
         KeyDict
      in
         KeyDict = {Dictionary.condGet DB Key1 unit}
         if KeyDict == unit then
            Val = NO_VALUE
         else
            Val = {Dictionary.condGet KeyDict Key2 NO_VALUE}
         end
      end

      proc {Put put(Key1 Key2 Val)}
         KeyDict
      in
         KeyDict = {Dictionary.condGet DB Key1 unit}
         if KeyDict \= unit then
            {Dictionary.put KeyDict Key2 Val}
         else
            NewDict = {Dictionary.new}
         in
            {Dictionary.put DB Key1 NewDict}
            {Dictionary.put NewDict Key2 Val}
         end
      end

      Events = events(
                     delete:  Delete
                     get:     Get
                     put:     Put
                     )
   in
      Self = {Component.newTrigger Events}
      DB = {Dictionary.new}
      Self
   end

end

