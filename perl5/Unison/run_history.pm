package Unison;
# $Id: run.pm,v 1.1 2003/10/06 19:23:28 rkh Exp $

sub run_commandline_by_run_id($$) {
  my $u = shift;
  my $run_id = shift;
  my ($cl) = $u->selectrow_array("select commandline from run where run_id=$run_id");
  return $cl;
}


sub last_run_update($$) {
  my $u = shift;
  my $pseq_id = shift;
  my $run_id = shift;
  return $u->selectrow_array("select last_run_update($pseq_id,$run_id)");
}


1;
