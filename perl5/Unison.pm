=head1 NAME

Unison -- interface to the Unison database
S<$Id: pm,v 1.2 2001/06/12 05:38:24 reece Exp $>

=head1 SYNOPSIS

use Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES & METHODS

=cut


=pod

=over

=item

d28 1

=cut


package Unison;
use Unison::DBI;
use Unison::pseq;
use Unison::p2params;
use Unison::porigin;
use Unison::p2template;
use Unison::palias;
=pod
use Unison::deprecated;
=head1 SEE ALSO
=over
=pod
=back
=head1 BUGS

=head1 SEE ALSO


=head1 AUTHOR
 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0
 South San Francisco, CA  94080-4990    reece@harts.net, GPG: 0x25EC91A0

=cut

1;
