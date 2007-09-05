=head1 NAME

Unison::pmodelset -- Unison pmodelset table utilities
S<$Id$>

=head1 SYNOPSIS

 use Unison::DBI;
 use Unison::pmodelset;
 my $u = new Unison;
 $u->get_pmodelset_name_by_pomdelset_id();

=head1 DESCRIPTION

B<> is a

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Unison::Exceptions;
use Unison::Utilities::misc qw( warn_deprecated unison_logo use_at_runtime );

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## get_pmodelset_name_by_pmodelset_id()

=pod

=item B<< $u->get_pmodelset_name_by_pmodelset_id( C<pmodelset_id> ) >>

Returns name for the given pmodelset_id.

=cut

sub get_pmodelset_name_by_pmodelset_id($$) {
  my ($self,$pmodelset_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my (@rv) = $self->selectrow_array('select name from pmodelset where pmodelset_id=?',
									undef,$pmodelset_id);
  return @rv ? $rv[0] : undef;
}

######################################################################
## pmodelset_si_pmodelset_id()

=pod

=item B<< ::pmodelset_si_porgin_id( C<pmodelset> ) >>

=over

ensure that pmodelset is in the pmodelset table, return pmodelset_id

=back

=cut

sub pmodelset_si_pmodelset_id($$) {
  my ($self,$pmodelset) = @_;
  $self->is_open()
	|| throw Unison::Exception('Unison connection not established');
  (defined $pmodelset and $pmodelset =~ m/\w/)
	|| throw Unison::Exception("can't lookup a null pmodelset");
  my ($rv) = $self->selectrow_array("select pmodelset_si_pmodelset_id ('$pmodelset')");
  return $rv;
}

######################################################################
## pmodelset_last_updated

=pod

=item B<< ::pmodelset_last_updated( C<pmodelset_id>, [set] ) >>

If the optional second argument is defined (e.g,. pmodelset_last_updated(15,1)), then 
set the last_updated field to now.  In any case, the last_updated value is returned.

=over

=back

=cut

sub pmodelset_last_updated($$) {
  my ($self,$pmodelset_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  if (defined $_[2]) {
	$self->do("update pmodelset set last_updated=now() where pmodelset_id=$pmodelset_id");
  }
  my $sth = $self->prepare("select last_updated from pmodelset where pmodelset_id=?");
  $sth->execute( $pmodelset_id );
  my ($rv) = $sth->fetchrow_array();
  $sth->finish();
  return $rv;
}


######################################################################
## get_pmodelsets_hmm()

=pod

=item B<< $u->get_pmodelsets_hmm() >>

Returns array of [pmodelset_id, name] for hmm modelsets.

=cut

sub get_pmodelsets_hmm($) {
  my ($self) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $a = $self->selectall_arrayref('select distinct ms.pmodelset_id,s.name from pmsm_pmhmm ms join pmodelset s on s.pmodelset_id=ms.pmodelset_id');
  return @$a;
}

######################################################################
## preferred_pmodelset_id_by_pftype()

=pod

=item B<< $u->preferred_pmodelset_id_by_pftype( C<pfeature_name> ) >>

Returns the preferred pmodelset_id for a pfeature type.

=cut

sub preferred_pmodelset_id_by_pftype($$) {
  my ($self,$pfeature_name) = @_;
  $self->is_open()
  || croak("Unison connection not established");
  my $id = $self->selectrow_array('select pmodelset_id from run where run_id=preferred_run_id_by_pftype( ? )',undef,$pfeature_name);
  return $id;
}
1;
