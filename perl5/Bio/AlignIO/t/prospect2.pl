#! /usr/bin/env perl

use Bio::AlignIO;
use warnings;
use strict;

die( "USAGE: prospect.pl <prospect-xml-file>\n" ) if $#ARGV!=0;

my $in = Bio::AlignIO->new(-file => $ARGV[0] ,'-format' => 'prospect2');
my @alignme;
while(my $aln = $in->next_aln()) {
	print '-'x80,"\n";
	foreach my $seq ($aln->each_seq()) {
		print "name: " . $seq->display_id() . "\n";
		print "seq:  " . $seq->seq() . "\n";
	}
}
