=head1 NAME

Unison::params -- Unison params table utilities
S<$Id: params.pm,v 1.9.2.2 2004/12/24 00:09:54 rkh Exp $>

=head1 SYNOPSIS

 use Unison::DBI;
 use Unison::params;
 my $u = new Unison;
 $u->get_params_id_by_name();

=head1 DESCRIPTION

B<> is a

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use Unison::Exceptions;
use Bio::Prospect::Options;


=pod

=head1 ROUTINES AND METHODS

=over

=cut


######################################################################
## run_commandline_by_params_id()

=pod

=item B<< $u->run_commandline_by_params_id( C<params_id> ) >>

Returns the command line for a params_id.

=cut

sub run_commandline_by_params_id($$) {
  my ($self,$params_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $cl = $self->selectrow_array('select commandline from params where params_id=?',
                  undef,$params_id);
  return $cl;
}


######################################################################
## params_id_by_name()

=pod

=item B<< $u->params_id_by_name( C<params_name> ) >>

=item B<< $u->get_params_id_by_name( C<params_name> ) >>

Returns the params_id for a parameter set name.

=cut

sub params_id_by_name($$) {
  my ($self,$params_name) = @_;
  $self->is_open()
  || croak("Unison connection not established");
  my $id = $self->selectrow_array('select params_id(?)',undef,uc($params_name));
  return $id;
}
sub get_params_id_by_name($$) {
  goto &params_id_by_name;
}


######################################################################
## get_p2options_by_params_id()

=pod

=item B<< $u->get_p2options_by_params_id( C<params_id> ) >>

fetches a single protein sequence from the pseq table.

=back

=cut

sub get_p2options_by_params_id($$) {
  my ($self,$run_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select * from params_prospect2 where params_id=?");
  $sth->execute($run_id);
  my $h = $sth->fetchrow_hashref();
  ## FIX: only seqfile threading is supported below:
  my $po = new Bio::Prospect::Options
	( 
	 $h->{global} ? (global=>1) : (global_local=>1),
	 $h->{commandline} =~ m/-scop/ ? (scop=>1) : (scop=>0),
	 seq=>1,
	);
  return $po;
  }



### DEPRECATED FUNCTIONS

sub get_p2options_by_run_id($) {
  warn_deprecated();
  get_p2options_by_params_id(@_);
}

sub get_p2options_by_p2params_id($) {
  warn_deprecated();
  return get_rprospect2_by_run_id(@_); 
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
