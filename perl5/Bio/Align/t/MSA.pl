#! /usr/bin/env perl

use warnings;
use strict;
use Bio::SeqIO;
use Bio::Tools::Blast;
use Bio::Align::MSA;
use Bio::AlignIO;
use Data::Dumper;


die( "USAGE: cavs.pl <FASTA file> <BLAST output>\n" ) if $#ARGV!=1;

$ENV{DEBUG} = 0;

# open FASTA file to retrieve information about the query sequence
my $in = Bio::SeqIO->new(-file=>$ARGV[0], '-format' => 'Fasta', );
my $query = $in->next_seq();
my $query_len = length( $query->seq() );
my $msa = new Bio::Align::MSA( $query );

# Use AlignIO.pm to create a SimpleAlign object from the blast report
my $str = Bio::AlignIO->new(-file=> $ARGV[1],'-format' => 'blast');
my @alignme;
while ( my $aln = $str->next_aln() ) {
	print STDERR '-'x80,"\n";
  # extract sequences and check values for the alignment column $pos
	my $i=0;
  foreach my $seq ($aln->each_seq) {
		push @alignme, $seq;
  }
}

print $msa->get_alignment( 'html', @alignme );
