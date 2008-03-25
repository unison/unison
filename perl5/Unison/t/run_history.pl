#!/usr/bin/perl

use strict;
use warnings;

my $pseq_id = 76;
my $run_id = 34;

my @tests = (
			 '$u->get_run_timestamp($pseq_id,$run_id)',
			 '$u->get_run_timestamp_ymd($pseq_id,$run_id)',
			);


my $u = new Unison(dbname => 'csb-dev');

foreach my $t (@tests) {
  print("* $t\n ==> %s\n", eval $t);
}
