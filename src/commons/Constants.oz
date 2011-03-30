/*-------------------------------------------------------------------------
 *
 * Constants.oz
 *
 *    Static definition of default constants values.
 *
 * LICENSE
 *
 *    Beernet is released under the Beerware License (see file LICENSE) 
 * 
 * IDENTIFICATION 
 *
 *    Author: Boriss Mejias <boriss.mejias@uclouvain.be>
 *
 *    Last change: $Revision: 217 $ $Author: boriss $
 *
 *    $Date: 2010-04-12 17:23:21 +0200 (Mon, 12 Apr 2010) $
 *
 *-------------------------------------------------------------------------
 */

functor
export
   BadSecret
   NoSecret
   NotFound
   NoValue
   Public 
   Success
define

   BadSecret= error(bad_secret) % Incorrect secret
   NotFound = 'NOT_FOUND'  % To be used inside the component as constant
   Public   = public       % No secret
   Success  = success      % Correct secret, or new item created

   %% aliases
   NoValue  = NotFound
   NoSecret = Public

end

