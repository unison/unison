package Unison;
# $Id$

sub run_commandline_by_run_id($$) {
  my $u = shift;
  my $run_id = shift;
  my ($cl) = $u->selectrow_array("select commandline from run where run_id=$run_id");
  return $cl;
}


1;
