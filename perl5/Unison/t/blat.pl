#!/usr/bin/env perl

use warnings;
use strict;
use Unison;
use Unison::blat;

my $u = new Unison();

my $pseq_id = 62;
my @loci;

@loci = $u->get_p2gblataln_info($pseq_id);
print( "* get_blat_info($pseq_id) returns ", $#loci + 1, " results; first:\n" );
print( "  ", join( ',', @{ $loci[0] } ), "\n" );

my ( $genasm_id, $chr, $gstart, $gstop ) = @{ $loci[0] };

my @p2gblataln_ids = $u->get_p2gblataln_id( $genasm_id, $chr, $gstart, $gstop );
print(
    "* get_p2gblataln_id ($genasm_id, $chr, $gstart, $gstop) returns ",
    $#p2gblataln_ids + 1,
    " results: \n"
);
print( "  ", join( ',', @p2gblataln_ids ), "\n" );

