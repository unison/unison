=head1 NAME

Unison::params -- Unison params table utilities
S<$Id: params.pm,v 1.17 2006/11/06 22:01:13 rkh Exp $>

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
use Unison::Utilities::misc qw( warn_deprecated unison_logo use_at_runtime );

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
## get_params_name_by_params_id()

=pod

=item B<< $u->get_params_name_by_params_id( C<params_id> ) >>

Returns name for the given params_id.

=cut

sub get_params_name_by_params_id($$) {
  my ($self,$params_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my (@rv) = $self->selectrow_array('select name from params where params_id=?',
									undef,$params_id);
  return @rv ? $rv[0] : undef;
}


######################################################################
## get_params_info_by_pftype_id()

=pod

=item B<< $u->get_params_info_by_pftype_id( C<pftype_id> ) >>

Returns array of [params_id, name] for the given pftype_id, in order of
decreasing relevance.

=cut

sub get_params_info_by_pftype_id($$) {
  my ($self,$pftype_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $a = $self->selectall_arrayref('select params_id,name from params where pftype_id=? order by params_id desc',
									undef,$pftype_id);
  return @$a;
}

######################################################################
## get_params_info_by_pftype()

=pod

=item B<< $u->get_params_info_by_pftype( C<pftype_id> ) >>

Returns array of [params_id, name] for the given pftype, in order of
decreasing relevance.

=cut

sub get_params_info_by_pftype($$) {
  my ($self,$pftype) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $a = $self->selectall_arrayref('select params_id,name from only params where pftype_id=pftype_id(?) order by params_id desc',
									undef,$pftype);
  return @$a;
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
## preferred_params_id_by_pftype()

=pod

=item B<< $u->preferred_params_id_by_pftype( C<pfeature_name> ) >>

Returns the preferred params_id for a pfeature type.

=cut

sub preferred_params_id_by_pftype($$) {
  my ($self,$pfeature_name) = @_;
  $self->is_open()
  || croak("Unison connection not established");
  my $id = $self->selectrow_array('select params_id from run where run_id=preferred_run_id_by_pftype( ? )',undef,$pfeature_name);
  return $id;
}

sub current_params_id_by_pftype($$) {
  warn_deprecated();
  goto &preferred_params_id_by_pftype;
}


######################################################################
## get_p2options_by_params_id()

=pod

=item B<< $u->get_p2options_by_params_id( C<params_id> ) >>

get options from the params table and fill in a few prospect-specific hash elements.

This function is completely misplaced and should be moved elsewhere. It's
presence here is historical.

=back

=cut

sub get_p2options_by_params_id($$) {
  my ($self,$run_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $h = $self->selectrow_hashref("select * from params where params_id=$run_id");

  ## FIX: only seqfile threading is supported below:
  use_at_runtime 'Bio::Prospect::Options';
  my $po = Bio::Prospect::Options->new
	( 
	 $h->{commandline} =~ m/-global_local/ 	? (global_local=>1,global=>0) : (global_local=>0,global=>1),
	 $h->{commandline} =~ m/-scop/ 			? (scop=>1)   : (scop=>0),
	 seq=>1,
	);
  return $po;
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
