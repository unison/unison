#! /usr/bin/env perl

use warnings;
use strict;
use Bio::SeqIO;
use Bio::Align::MSA;
use Bio::AlignIO;

die( "USAGE: MSA.pl <FASTA file> <BLAST output>\n" ) if $#ARGV!=1;

$ENV{DEBUG} = 0;

my $in = Bio::SeqIO->new(-file=>$ARGV[0], '-format' => 'Fasta', );
my $query = $in->next_seq();
my $msa = new Bio::Align::MSA( $query );

# Use AlignIO.pm to create SimpleAlign objects from the blast report
my $str = Bio::AlignIO->new(-file=> $ARGV[1],'-format' => 'blast');
my @alignme;
while ( my $aln = $str->next_aln() ) {
  foreach my $seq ($aln->each_seq) {
    push @alignme, $seq;
  }
}

print $msa->get_alignment( 'html', @alignme );
