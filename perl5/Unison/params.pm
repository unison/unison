=head1 NAME

Unison::p2params -- Unison p2params table utilities
S<$Id: pm,v 1.2 2001/06/12 05:38:24 reece Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;
use Prospect2::Options;

sub get_p2options_by_p2params_id($)
  {
  my ($self,$p2params_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select * from p2params where p2params_id=?");
  $sth->execute($p2params_id);
  my $h = $sth->fetchrow_hashref();
  my $po = new Prospect2::Options( $h->{global} ? (global=>1) : (global_local=>1),
								   seq=>1, );
  return $po;
=pod

=over

=item B<::get_sequence_by_pseq_id( C<pseq_id> )>

fetches a single protein sequence from the pseq table.

=back

=cut
  }






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
