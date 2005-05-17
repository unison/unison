#!/usr/bin/env perl

use strict;
use warnings;

use Unison;
use Unison::Utilities::misc qw(sequence_md5);

my $printmod = 100;

my $u = new Unison;
my $sth = $u->prepare('select md5,seq from pseq where pseq_id=?');

my @ids = map {eval "$_"} @ARGV;

for(my $i=0; $i<=$#ids; $i++) {
  my $pseq_id = $ids[$i];

  my ($umd5,$seq) = $u->selectrow_array($sth,undef,$pseq_id);
  if (not defined $seq) {
	warn("Unison:$pseq_id not found\n");
	next;
  }

  my $pmd5 = sequence_md5( $seq );
  if ($umd5 ne $pmd5) {
	warn("\n!! Unison md5 doesn't match perl md5 for pseq_id=$pseq_id\n");
  }

  if ( ($i==$#ids) or (0 == $i % $printmod) ) {
	printf(STDERR "\r%8d/%8d (%5.1f%%): pseq_id=%10s",
		   $i+1, $#ids+1, 100*($i+1)/($#ids+1), $pseq_id);
  }
}

print(STDERR "..... done\n");
