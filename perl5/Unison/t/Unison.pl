#!/usr/bin/env perl

# This script is similar to DBI.pl except that it uses the "common"
# includes, including the Unison conventions for env vars and command-line
# parsing.

use strict;
use warnings;
use Unison;
use Unison::Exceptions;

my $u = new Unison();

select(STDERR); $|++;
select(STDOUT); $|++;


print("* Unison object $u =\n  ", 
	  join(',',map {defined $u->{$_} ? $u->{$_} : 'undef'}
		   (qw(dbname host username password))),
	  "\n\n");

try {
  foreach my $sql 
	(
	 'select version()',
	 'select current_user',
	 'select count(*) from porigin',
	 'select * from v_run_history where pseq_id=12',

	 # EXPECT errors for the following:
	 "select 'EXPECT ERRORS FOR THE FOLLOWING SQL:'",
	 'select from bogus'
	) {
	  my (@rall) = @{ $u->selectall_arrayref($sql) };
	  my (@r) = map { defined $_ ? $_ : 'undef'} @{$rall[0]};
	  print("* $sql returns ", $#rall+1, " rows; first row:\n  ",join(',',@r),"\n");
	}
} catch Unison::Exception::DBIError with {
  warn("======= caught a DBI error:\n", $_[0]);
} catch Unison::Exception with {
  warn("======= caught this error:\n", $_[0]);
};
