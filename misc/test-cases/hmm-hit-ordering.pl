#!/usr/bin/env perl

use warnings;
use strict;
use Bio::PrimarySeq;
use Bio::SearchIO;
use Bio::SeqIO;
use Data::Dumper;
use Error qw(:try);
use File::Temp qw(tempfile tempdir);
use Getopt::Long qw(:config gnu_getopt);
use IO::File;
use IO::Pipe;
use Unison::Exceptions;
use Unison::SQL;
use Unison;


my @cl = ( 'cat', $ARGV[0] );
my $hmmerpipe = new IO::Pipe;
$hmmerpipe->reader( @cl )
  || die("couldn't do @cl\n");

my $in = new Bio::SearchIO(-format => 'hmmer',
						   -fh => $hmmerpipe);

while ( my $result = $in->next_result ) {
  my ($pseq_id) = $result->query_name() =~ m/Unison:(\d+)/;
	my $nretr = 0;

  RETRY:
	my $nhits = 0;
	my $nhsps = 0;
  try {
	$result->rewind if ($nretr > 0);
	while ( my $hit = $result->next_hit ) {
	  $nhits++;
	  my $acc = $hit->name();
	  $hit->rewind if ($nretr > 0);
	  while ( my $hsp = $hit->next_hsp ) {
		$nhsps++;
		printf("hit:%d; hsp:%d; [%3d,%3d] %-10s %10g\n",
			   $nhits, $nhsps,
			   $hsp->start('query'), $hsp->end('query'),
			   $acc, $hsp->evalue());
	  }
	}
  };										# end try

  print("nhits=$nhits, nhsps=$nhsps\n");
}

