use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);


# Anyone using Unison::Exceptions will want the try/catch/...
# syntax; import it for them just as 'use Error qw(:try)' would do
package Unison::Exceptions;
use base qw(Exporter);
use Error qw(:try);
@EXPORT = @Error::subs::EXPORT_OK;


# Define a bunch of standard exceptions
package Unison::Exception;
use base 'CBT::Exception';

our @EXCEPTIONS = qw(NotImplemented NotConnected ConnectionFailed BadUsage
					RuntimeError DBIError);

foreach my $subtype (@EXCEPTIONS) {
  eval "package Unison::Exception::$subtype; use base 'Unison::Exception';";
}



1;
