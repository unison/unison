=head1 NAME

Unison -- interface to the Unison database
S<$Id: Unison.pm,v 1.9 2004/04/27 04:35:49 rkh Exp $>

=head1 SYNOPSIS

use Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES & METHODS

=cut


=pod

=over

=item

=back

=cut


package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

our ($RELEASE) = q$Name:  $ =~ m/Name: (\S*) /;


use Unison::utilities;
use Unison::DBI;
use Unison::Exceptions;
use Unison::pseq;
use Unison::porigin;
use Unison::paprospect2;
use Unison::pmprospect2;
use Unison::palias;
use Unison::papseq;
use Unison::params;
use Unison::run_history;
use Unison::userprefs;




=pod

=head1 BUGS

=head1 SEE ALSO

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut

1;
