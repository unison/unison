package CBT::Root;
use strict;
use warnings;

our ($VERSION) = q$Revision$ =~ m/Revision: ([\d\.]+)/;

use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

1;
