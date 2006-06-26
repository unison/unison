=head1 NAME

Unison::run_history -- API to the Unison run_history table

S<$Id: run_history.pm,v 1.11 2006/06/16 17:53:38 rkh Exp $>

=head1 SYNOPSIS

 use Unison;
 use Unison::run_history;
 my $u = new Unison(...);

=head1 DESCRIPTION

B<Unison::blat> provides BLAT-related methods to the B<Unison::>
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
## upd_run_history

=pod

=item B<< $u->upd_run_history( C<pseq_id>, C<params_id>, C<origin_id>, C<pmodelset_id>, failed ) >>

=cut

sub upd_run_history(@) {
  my $u = shift;
  my ($q,$p,$o,$m,$f) = @_;
  $f ||= 'FALSE';
  return $u->selectrow_array("select upd_run_history(?,?,?,?,?)"
							 ,undef, $q,$p,$o,$m,$f);
}


######################################################################
## upd_run_histories

=pod

=item B<< $u->upd_run_histories( C<pseq_id>, C<params_id>, C<[origin_ids]>, C<[pmodelset_ids]>  ) >>

=cut

sub upd_run_histories($$$$$) {
  my ($u,$pseq_id,$params_id,$O,$M,$f) = @_;
  my (@O) = defined $O ? ref $O ? @$O : ($O) : (undef);
  my (@M) = defined $M ? ref $M ? @$M : ($M) : (undef);
  my $z;
  foreach my $o (@O) {
	foreach my $m (@M) {
	  $z = $u->upd_run_history($pseq_id,$params_id,$o,$m,$f);
	}
  }
  return $z;
}



######################################################################
## already_ran

=pod

=item B<< $u->already_ran( C<pseq_id>, C<params_id>, C<[origin_ids]>, C<[pmodelset_ids]> ) >>

=cut

sub already_ran ($$$$$) {
  my ($u,$pseq_id,$params_id,$O,$M) = @_;
  my (@O) = defined $O ? ref $O ? @$O : ($O) : (undef);
  my (@M) = defined $M ? ref $M ? @$M : ($M) : (undef);

  foreach my $o (@O) {
	foreach my $m (@M) {
	  if (defined( my $z = $u->get_run_timestamp($pseq_id,$params_id,$o,$m ))) {
		# arbitrarily return this timestamp (others might have matched)
		return $z ;
	  }
	}
  }
  return undef;
}



######################################################################
##  get_run_timestamp

=pod

=item B<< $u->get_run_timestamp( C<pseq_id>, C<params_id>, C<origin_id>, C<pmodelset_id> ) >>

=cut

sub get_run_timestamp(@) {
  my $u = shift;
  return $u->selectrow_array("select get_run_timestamp(?,?,?,?)",undef,@_);
}
sub get_run_timestamp_ymd(@) {
  my $u = shift;
  return $u->selectrow_array("select to_char(get_run_timestamp(?,?,?,?),'YYYY-MM-DD')",undef,@_);
}


######################################################################
##  get_current_params_id_by_pftype

=pod

=item B<< $u->get_current_params_id_by_pftype( C<pseq_id>, C<pftype> ) >>

Identifies the most current params_id by pftype (NOT pftype_id!) based
on the run history for the specified sequence.

=cut

sub get_current_params_id_by_pftype(@) {

  # deprecated on 2006-05-04
  # use preferred_params_id_by _pftype
  warn_deprecated();

  my $u = shift;
  my $a = $u->selectrow_array(<<EOSQL,undef,@_);
SELECT	RH.params_id
  FROM	run_history RH
  JOIN	params P  ON rh.params_id=P.params_id
 WHERE	RH.pseq_id=?
   AND  P.pftype_id=pftype_id(?)
 ORDER	BY params_id DESC
 LIMIT  1;
EOSQL
  return $a;
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
