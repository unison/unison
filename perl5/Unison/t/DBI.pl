#!/usr/bin/env perl

use strict;
use warnings;
use Unison;
use CBT::Exceptions;

my $u = new Unison();

print("$u: (", 
	  join(',',map {defined $u->{$_} ? $u->{$_} : 'undef'}
		   (qw(dbname host username password))),
	  ")\n");


select(STDERR); $|++;
select(STDOUT); $|++;

try {
  foreach my $sql ('select count(*) from porigin',
				   'select * from v_run_history where pseq_id=5',
				   'select from bogus') {
	my (@r) = map { defined $_ ? $_ : 'undef'} $u->selectrow_array($sql);
	print("$sql returns <",join(',',@r),">\n");
  }
} catch Unison::Exception with {
  die($_[0]);
}




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
