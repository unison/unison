#!  /usr/bin/env perl

use warnings;
use strict;
use Unison;

$ENV{DEBUG} = 1;
die("USAGE: papseq.pl <blast output>\n") if $#ARGV != 0;
my $u = new Unison();

$u->load_blast_report( $ARGV[0] );
