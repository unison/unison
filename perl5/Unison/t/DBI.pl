#!/usr/bin/env perl

use strict;
use warnings;
use Unison;

use lib '..';

my $u = new Unison();

print("$_: ", defined $u->{$_} ? $u->{$_} : 'undef', "\n") 
  for (qw(dbname host username password));


__END__

foreach my $h (undef,$ENV{PGHOST}) {
foreach my $u (undef,'PUBLIC',$ENV{PGUSER}) {
foreach my $p (undef,$ENV{PGPASSWORD}) {
  printf("%-10s %-10s %-10s: %s\n",
		 $h, $u, $p, try_connection($h,$u,$p) ? 'success' : 'failure');
}}}


sub try_connection {
  my ($h,$u,$p) = @_;
  return new Unison(host=>$h, username=>$u, password=>$p);
}
