=head1 NAME

Unison::porigin -- Unison porigin table utilities
S<$Id: pm,v 1.2 2001/06/12 05:38:24 reece Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;

sub porigin_si_porigin_id
  {
  my ($self,$origin) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my ($rv) = $self->{'dbh'}->selectrow_array("select porigin_si_porigin_id ('$origin')");
  return $rv;
  }
=pod

=over

=item B<Unison::porigin_si_porgin_id( C<origin> )>

ensure that origin is in the porigin table, return porigin_id

=back

=cut






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
