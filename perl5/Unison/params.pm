=head1 NAME

Unison::p2params -- Unison p2params table utilities
S<$Id: p2params.pm,v 1.5 2003/11/05 17:55:09 cavs Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use Unison::Exceptions;
use Bio::Prospect::Options;

sub get_params_id_by_name($$) {
  my ($self,$params_name) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $id = $self->selectrow_array('select params_id from params where upper(name)=?',
								  undef,uc($params_name));
  return $id;
}

sub get_p2options_by_params_id($) {
  my ($self,$run_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select * from params_prospect2 where params_id=?");
  $sth->execute($run_id);
  my $h = $sth->fetchrow_hashref();
  ## FIX: only seqfile threading is supported below:
  my $po = new Bio::Prospect::Options( $h->{global} ? (global=>1) : (global_local=>1),
                   seq=>1, );
  return $po;
=pod

=over

=item B<::get_p2options_by_params_id( C<params_id> )>

fetches a single protein sequence from the pseq table.

=back

=cut
  }



sub get_p2options_by_run_id($) {
  warn_deprecated();
  get_p2options_by_params_id(@_);
}

sub get_p2options_by_p2params_id($) {
  warn_deprecated();
  return get_rprospect2_by_run_id(@_); 
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
