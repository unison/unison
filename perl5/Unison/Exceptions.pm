
=head1 NAME

Unison::Exceptions -- Unison Exceptions

S<$Id$>

=head1 SYNOPSIS

 use Unison::Exceptions;
 try {
   do_something;
 } catch Unison::Exception with {
   warn("I'm ignoring this exception:", @_);
 } otherwise {
   die("untrapped exception here");
 } finally {
   # wrap up (close file, say bye, etc)
 };

=head1 DESCRIPTION

B<Unison::Exceptions> does two things: 1) it imports the try...catch...etc
syntax from Error (as with C<use Error qw(:try)>), and 2) it defines the
following Unison::Exception subclassess:

	Unison::Exception::BadUsage
	Unison::Exception::ConnectionFailed
	Unison::Exception::DBIError
	Unison::Exception::NotConnected
	Unison::Exception::NotImplemented
	Unison::Exception::RuntimeError

Just as with Error's try syntax the try... command must end with a
semicolon (or be at the end of block). You will get unpredictable and
often bizarre results otherwise. Take Reece's word for it: just add the
semicolon. Now, for the really and truly dense, let's reiterate:

=over

B<END THE TRY..CATCH... COMMAND WITH A SEMICOLON.>

=back


=head1 ROUTINES AND METHODS

This module provides no methods or routines other than those inherited
from Unison::Exceptions.

=over

=cut

use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

# Anyone using Unison::Exceptions will want the try/catch/...
# syntax; import it for them just as 'use Error qw(:try)' would do
package Unison::Exceptions;
use base qw(Exporter);
use Error qw(:try);
@EXPORT = @Error::subs::EXPORT_OK;

# Define some standard exceptions
package Unison::Exception;
use base 'Unison::Exception';

our @EXCEPTIONS = qw(NotImplemented NotConnected ConnectionFailed BadUsage
  RuntimeError DBIError);

foreach my $subtype (@EXCEPTIONS) {
    eval "package Unison::Exception::$subtype; use base 'Unison::Exception';";
}

=pod

=back

=head1 BUGS

Please report bugs to Reece Hart E<lt>hart.reece@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc Unison

=back

=head1 AUTHOR

see C<perldoc Unison> for contact information

=cut

1;
