=head1 NAME

Unison::utilities -- general Unison utilities

S<$Id: utilities.pm,v 1.5 2004/05/07 21:36:21 rkh Exp $>

=head1 SYNOPSIS

 use Unison;
 my $u = new Unison;

(etc.)

=head1 DESCRIPTION

B<Unison::utilities> is a collection of utility functions intended for use
within the Unison modules. All routines may used outside of Unison and
I<are not> called with Unison object references (i.e., they're not
methods).

=head1 ROUTINES AND METHODS

=cut






######################################################################
## connect
sub connect {

=pod

=head2 ::connect()

=over

Establishes a connection to the Unison database.

The PGUSER, PGPASSWORD, PGHOST, PGPORT, and PGDATABASE environment
variables are honored if set. If not, reasonable defaults for the
Genentech environment are used.

=back

=cut

my $u = shift;

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
