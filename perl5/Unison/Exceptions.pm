use Error qw(:try);

package Unison::Exception;
use base 'CBT::Exception';


package Unison::Exception::NotImplemented;
use base 'Unison::Exception';

package Unison::Exception::NotConnected;
use base 'Unison::Exception';

package Unison::Exception::ConnectionFailed;
use base 'Unison::Exception';

1;
