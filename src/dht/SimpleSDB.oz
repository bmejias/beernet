/*-------------------------------------------------------------------------
 *
 * SimpleSDB.oz
 *
 *    SimpleSDB provides basic storage operations for items identified with two
 *    keys and a secret. The secret is used for put and delete, but not for
 *    read. If the secret matches, the result is bound to success. If it
 *    doesn't match, it is bound to error(bad_secret)
 *
 * LICENSE
 *
 *    Beernet is released under the Beerware License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: Boriss Mejias <boriss.mejias@uclouvain.be>
 *
 *    Contributors: Xavier de Coster, Matthieu Ghilain.
 *
 *    Last change: $Revision: -1 $ $Author: $
 *
 *    $Date: $
 *
 * NOTES
 *      
 *    Operations provided by SimpleSDB are:
 *
 *       put(key1 key2 value secret result)
 *
 *       get(key1 key2 result)
 *
 *       delete(key1 key2 secret result)
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Component   at '../corecomp/Component.ozf'
export
   New
   NoValue
   Success
   BadSecret
define

   NO_VALUE = 'NOT_FOUND'  % To be used inside the component as constant
   SUCCESS  = success      % Correct secret, or new item created 
   ERROR    = error(bad_secret) % Incorrect secret
   
   NoValue  = NO_VALUE     % Nicer name for the export
   Success  = SUCCESS
   BadSecret= ERROR

  
   %%To use tuples instead of records
   SECRET   = 1
   VALUE    = 2

   fun {New}
      DB
      Self

      proc {Delete delete(Key1 Key2 Secret Result)}
         KeyDict
      in
         KeyDict = {Dictionary.condGet DB Key1 unit}
         if KeyDict \= unit then
            Item = {Dictionary.condGet KeyDict Key2 unit}
         in
            if Item \= unit then
               if Item.SECRET == Secret then 
                  {Dictionary.remove KeyDict Key2}
                  Result = SUCCESS
               else
                  Result = ERROR
               end
            else %% No item using Key1/Key2. Nothing to be done.
               Result = NO_VALUE
            end
         else %% No key using Key1. Nothing to be done.
            Result = NO_VALUE
         end
      end

      proc {Get get(Key1 Key2 Result)}
         KeyDict
      in
         KeyDict = {Dictionary.condGet DB Key1 unit}
         if KeyDict == unit then
            Result = NO_VALUE
         else
            Item = {Dictionary.condGet KeyDict Key2 item(SECRET:unit
                                                         VALUE:NO_VALUE)}
         in
            Result = Item.VALUE
         end
      end

      proc {Put put(Key1 Key2 Val Secret Result)}
         KeyDict
      in
         KeyDict = {Dictionary.condGet DB Key1 unit}
         if KeyDict \= unit then
            Item = {Dictionary.condGet KeyDict Key2 unit}
         in
            if Item \= unit then
               if Item.SECRET == Secret then 
                  {Dictionary.put KeyDict Key2 item(SECRET:Secret VALUE:Val)}
                  Result = SUCCESS
               else
                  Result = ERROR
               end
            else %% New item, first used of Key1/Key2
               {Dictionary.put KeyDict Key2 item(SECRET:Secret VALUE:Val)}
               Result = SUCCESS
            end
         else %% New item, first used of Key1
            NewDict = {Dictionary.new}
         in
            {Dictionary.put DB Key1 NewDict}
            {Dictionary.put NewDict Key2 item(SECRET:Secret VALUE:Val)}
            Result = SUCCESS
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

