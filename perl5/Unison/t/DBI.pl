#!/usr/bin/env perl

# This script is similar to Unison.pl except that it DOES NOT use the
# "common" includes. It's intended as an example for people who do not
# wish to use Unison conventions for env vars and command-line parsing.

use strict;
use warnings;
use Unison::DBI;
use Unison::Exceptions;
use Data::Dumper;

# must provide at least the following connection info
my $u = new Unison( host=>'csb', dbname=>'csb', username=>'PUBLIC' );

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
