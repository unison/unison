=head1 NAME

Unison::p2params -- Unison p2params table utilities
S<$Id: p2params.pm,v 1.4 2003/11/04 01:09:13 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;
use Prospect::Options;

sub get_p2options_by_p2params_id($)
  { return get_rprospect2_by_run_id(@_); }

sub get_p2options_by_run_id($)
  {
  my ($self,$run_id) = @_;
  $self->is_open()
  || croak("Unison connection not established");
  my $sth = $self->prepare_cached("select * from run where run_id=?");
  $sth->execute($run_id);
  my $h = $sth->fetchrow_hashref();
  ## FIX: only seqfile threading is supported below:
  my $po = new Prospect::Options( $h->{global} ? (global=>1) : (global_local=>1),
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
