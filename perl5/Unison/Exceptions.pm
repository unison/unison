use Error qw(:try);


package Unison::Exception;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);
use base 'CBT::Exception';



foreach my $subtype (qw(NotImplemented NotConnected ConnectionFailed
                        BadUsage RuntimeError DBIError)) {
  eval "package Unison::Exception::$subtype; use base 'Unison::Exception';";
}



1;
