#!/usr/bin/env perl

use strict;
use warnings;
use Unison;
use Unison::Exceptions;
use Unison::links;

my $u = new Unison();

while(<DATA>) {
  chomp;
  my ($o,$a) = split;
  try {
	printf("* $o:$a\n  %s\n  %s\n",
		   $u->origin_accession_url($o,$a),
		   $u->link_url($o,$a), "\n");
  } catch Unison::Exception with {
	warn($_[0]);
  };
}


__DATA__
BOGUSSRC bogusacc
GenenGenes UNQ123
Unison 76
UniProtKB/TrEMBL P01234
