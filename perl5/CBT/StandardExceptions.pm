use strict;
use warnings;

our ($VERSION) = q$Revision$ =~ m/Revision: ([\d\.]+)/;

use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

package CBT::Exception::IOError;
use base 'CBT::Exception';

package CBT::Exception::BadUsage;
use base 'CBT::Exception';

# Use Pod::Usage w/calling module/app

package CBT::Exception::NotImplemented;
use base 'CBT::Exception';

package CBT::Exception::NotSupported;
use base 'CBT::Exception';

package CBT::Exception::NotYetSupported;
use base 'CBT::Exception';

package CBT::Exception::NotConnected;
use base 'CBT::Exception';

package CBT::Exception::ConnectionFailed;
use base 'CBT::Exception';

1;
