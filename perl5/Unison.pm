=head1 NAME

Unison -- Unison database API for perl

S<$Id: Unison.pm,v 1.17 2005/06/15 03:49:03 rkh Exp $>

=head1 SYNOPSIS

 use Unison;

=head1 DESCRIPTION

C<use Unison;> loads the most commonly used Unison modules into the
Unison:: namespace.  See `perldoc Unison::common' for information about
which modules are included, and see `perldoc Unison::intro' for more
information about the Unison API.

=cut


package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';

use Unison::common;


=pod

=head1 SEE ALSO

=over

=item perldoc Unison::intro

=item perldoc Unison::common

=back

=head1 AUTHOR

 Reece Hart, Ph.D.                      rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                        650-225-6133 (voice), -5389 (fax)
 Bioinformatics and Protein Engineering
 1 DNA Way, MS-93                       http://harts.net/reece/
 South San Francisco, CA  94080-4990    reece@harts.net, GPG: 0x25EC91A0

=cut

1;
