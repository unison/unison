#!/usr/bin/env perl

BEGIN {
    $cbcdir = $ENV{'HOME'} . '/cbc';
    unshift( @INC, "$cbcdir/opt/lib/perl5" );
}
use Prosite::DB;
use Prosite::Record;

# open database
$dbfn = "$cbcdir/prosite/prosite.dat";
$db   = new Prosite::DB;
$db->open("$dbfn")
  || die("$dbfn: $!\n");

# read records
while ( defined( my $AC = shift ) ) {
    my ( $r, $t );
    if ( not defined( $r = $db->read_parse_record($AC) ) ) {
        warn("$AC: couldn't read record\n");
        next;
    }
    $t =
      defined $r->NR
      ? sprintf(
        "NR=\n"
          . $r->NR
          . "\n---------\n"
          . "TOTAL=%dU/%dT, TP=%dU/%dT, FP=%dU/%dT, UP=%dU/%dP, FN=%d, P=%d",
        $r->nTotal,           $r->nTruePositive,  $r->nFalsePositive,
        $r->nUnknownPositive, $r->nFalseNegative, $r->nPartial
      )
      : 'NO NR';
    $t =~ s/^/  /mg;
    print("* $AC\n$t\n");
}
$db->close();

