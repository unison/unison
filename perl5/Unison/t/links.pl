#!/usr/bin/env perl

use strict;
use warnings;
use Unison;
use Unison::Exceptions;
use Unison::links;

my $u = new Unison;

while(<DATA>) {
  chomp;
  my ($o,$a) = split;
  try {
	print("$o:$a -> ", $u->origin_alias_url($o,$a), "\n");
  } catch Unison::Exception with {
	warn($_[0]);
  };
}


__DATA__
GenenGenes UNQ123
Unison 76
UniProtKB/TrEMBL P01234
