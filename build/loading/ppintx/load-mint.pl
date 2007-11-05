#!/usr/bin/env perl

use strict;
use warnings;
use Unison;

my $mint_file = shift;
open( FILE, "< $mint_file" ) or die "can't open $mint_file: $!";

my $u = new Unison( dbname => 'csb-dev' );

my $sth =
  $u->prepare(
"INSERT INTO mint VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
  );

while ( my $line = <FILE> ) {

    chomp($line);

    my (
        $a1,  $a2,  $a3,  $a4,  $a5,  $a6,  $a7,  $a8,  $a9,  $a10, $a11,
        $a12, $a13, $a14, $a15, $a16, $a17, $a18, $a19, $a20, $a21, $a22,
        $a23, $a24, $a25, $a26, $a27, $a28, $a29, $a30, $a31, $a32, $a33,
        $a34, $a35, $a36, $a37, $a38, $a39, $a40, $a41, $a42
    ) = split( /\|/, $line );
    $sth->execute(
        $a1,  $a2,  $a3,  $a4,  $a5,  $a6,  $a7,  $a8,  $a9,  $a10, $a11,
        $a12, $a13, $a14, $a15, $a16, $a17, $a18, $a19, $a20, $a21, $a22,
        $a23, $a24, $a25, $a26, $a27, $a28, $a29, $a30, $a31, $a32, $a33,
        $a34, $a35, $a36, $a37, $a38, $a39, $a40, $a41, $a42
    );

    print( STDERR "loaded line $.\n" ) if $. % 100 == 0;
}

