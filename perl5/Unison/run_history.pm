package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;


sub upd_run_history(@) {
  my $u = shift;
  return $u->selectrow_array("select upd_run_history(?,?,?,?)",undef,@_);
}


sub upd_run_histories($$$$$) {
  my ($u,$pseq_id,$params_id,$O,$M) = @_;
  my (@O) = defined $O ? ref $O ? @$O : ($O) : (undef);
  my (@M) = defined $M ? ref $M ? @$M : ($M) : (undef);
  my $n = 0;

  foreach my $o (@O) {
  foreach my $m (@M) {
	$u->upd_run_history($pseq_id,$params_id,$o,$m);
	$n++;
  }}
  return $n;
}


sub get_run_timestamp(@) {
  my $u = shift;
  return $u->selectrow_array("select get_run_timestamp(?,?,?,?)",undef,@_);
}


sub params_commandline_by_params_id($$) {
  warn_deprecated();
  my $u = shift;
  my $params_id = shift;
  my ($cl) = $u->selectrow_array("select commandline from params where params_id=$params_id");
  return $cl;
}



### DEPRECATED FUNCTIONS

sub last_run_update($$) {
  warn_deprecated();
  my $u = shift;
  my $pseq_id = shift;
  my $run_id = shift;
  return $u->selectrow_array("select last_run_update($pseq_id,$run_id)");
}

sub run_commandline_by_run_id($$) {
  warn_deprecated();
  params_commandline_by_params_id($_[0],$_[1]);
}




1;
