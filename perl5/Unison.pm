=head1 NAME

Unison -- interface to the Unison database
S<$Id: Unison.pm,v 1.5 2003/06/30 15:33:50 rkh Exp $>

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
use Unison::Exceptions;
use Unison::pseq;
use Unison::porigin;
use Unison::paprospect2;
use Unison::pmprospect2;
use Unison::rprospect2;
use Unison::palias;
use Unison::papseq;
use Unison::run;

#use Unison::p2params;
#use Unison::p2template;
#use Unison::p2thread;
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
