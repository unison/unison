=head1 NAME

Unison::Exceptions -- Unison Exceptions

S<$Id: utilities.pm,v 1.5 2004/05/07 21:36:21 rkh Exp $>

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
from CBT::Exceptions.

=cut

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



=pod

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut

1;

