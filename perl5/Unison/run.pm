
=head1 NAME

Unison::run -- API to the Unison run table

S<$Id$

=head1 SYNOPSIS

 use Unison;
 use Unison::run;
 my $u = new Unison(...);

=head1 DESCRIPTION

B<Unison::blat> provides run-related methods to the B<Unison::>
namespace.

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
##  get_run_params

=pod

=item B<< $u->get_run_params_id( C<run_id>) >>

=cut

sub get_run_params_id(@) {
    my $u = shift;
    return $u->selectrow_array( "select params_id from run where run_id=?",
        undef, @_ );
}

######################################################################
##  get_run_params_id_pmodelset_id

=pod

=item B<< $u->get_run_params_id_pmodelset_id( C<run_id>, C<pftype> ) >>

Identifies the params_id and pmodelset_id for
the specified run

=cut

sub get_run_params_id_pmodelset_id(@) {

    my $u = shift;
    return $u->selectrow_array(
        "select params_id,pmodelset_id from run where run_id=?",
        undef, @_ );
}

######################################################################
##  get_preferred_run_params_id_pmodelset_id

=pod

=item B<< $u->get_run_params_id_pmodelset_id( C<pfeature_name> ) >>

Identifies the params_id and pmodelset_id for
preferred run_id for a pfeature type.

=cut

sub get_preferred_run_params_id_pmodelset_id($$) {
    my ( $self, $pfeature_name ) = @_;
    $self->is_open()
      || croak("Unison connection not established");
    return $self->selectrow_array(
"select params_id,pmodelset_id from run where run_id=preferred_run_id_by_pftype( ?) ",
        undef, $pfeature_name
    );
}

######################################################################
## preferred_run_id_by_pftype()

=pod

=item B<< $u->preferred_run_id_by_pftype( C<pfeature_name> ) >>

Returns the preferred run_id for a pfeature type.

=cut

sub preferred_run_id_by_pftype($$) {
    my ( $self, $pfeature_name ) = @_;
    $self->is_open()
      || croak("Unison connection not established");
    my $id = $self->selectrow_array( 'select preferred_run_id_by_pftype( ? )',
        undef, $pfeature_name );
    return $id;
}

=pod

=back

=head1 BUGS

Please report bugs to Reece Hart E<lt>hart.reece@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc Unison

=back

=head1 AUTHOR

see C<perldoc Unison> for contact information

=cut

1;
