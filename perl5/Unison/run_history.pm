=head1 NAME

Unison::run_history -- API to the Unison run_history table

S<$Id: run_history.pm,v 1.6 2005/01/20 01:05:17 rkh Exp $>

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

=item B<< $u->upd_run_history( C<pseq_id>, C<params_id>, C<porigin_id>, C<pmodelset_id> ) >>

=cut

sub upd_run_history(@) {
  my $u = shift;
  return $u->selectrow_array("select upd_run_history(?,?,?,?)",undef,@_);
}


######################################################################
## upd_run_histories

=pod

=item B<< $u->upd_run_histories( C<pseq_id>, C<params_id>, C<[porigin_ids]>, C<[pmodelset_ids]> ) >>

=cut

sub upd_run_histories($$$$$) {
  my ($u,$pseq_id,$params_id,$O,$M) = @_;
  my (@O) = defined $O ? ref $O ? @$O : ($O) : (undef);
  my (@M) = defined $M ? ref $M ? @$M : ($M) : (undef);
  my $z;
  foreach my $o (@O) {
	foreach my $m (@M) {
	  $z = $u->upd_run_history($pseq_id,$params_id,$o,$m);
	}
  }
  return $z;
}



######################################################################
## already_ran

=pod

=item B<< $u->already_ran( C<pseq_id>, C<params_id>, C<[porigin_ids]>, C<[pmodelset_ids]> ) >>

=cut

sub already_ran ($$$$$) {
  my ($u,$pseq_id,$params_id,$O,$M) = @_;
  my (@O) = defined $O ? ref $O ? @$O : ($O) : (undef);
  my (@M) = defined $M ? ref $M ? @$M : ($M) : (undef);

  foreach my $o (@O) {
	foreach my $m (@M) {
	  if ($u->get_run_timestamp($pseq_id,$params_id,$o,$m)) {
		return 1;
	  }
	}
  }
  return 0;
}



######################################################################
##  get_run_timestamp

=pod

=item B<< $u->get_run_timestamp( C<pseq_id>, C<params_id>, C<porigin_id>, C<pmodelset_id> ) >>

=cut

sub get_run_timestamp(@) {
  my $u = shift;
  return $u->selectrow_array("select get_run_timestamp(?,?,?,?)",undef,@_);
}




### DEPRECATED FUNCTIONS

sub last_run_update($$) {
  warn_deprecated();
  my $u = shift;
  my $pseq_id = shift;
  my $run_id = shift;
  return $u->selectrow_array("select last_run_update($pseq_id,$run_id)");
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
