use Error qw(:try);


package Unison::Exception;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use base 'CBT::Exception';


package Unison::Exception::NotImplemented;
use base 'Unison::Exception';

package Unison::Exception::NotConnected;
use base 'Unison::Exception';

package Unison::Exception::ConnectionFailed;
use base 'Unison::Exception';

package Unison::Exception::BadUsage;
use base 'Unison::Exception';
 
package Unison::Exception::RuntimeError;
use base 'Unison::Exception';

package Unison::Exception::DBIError;
use base 'Unison::Exception';

1;
