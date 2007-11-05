#!/usr/bin/env perl

use Unison;
use Unison::pset;

my $u = new Unison;

foreach my $name (qw(kinases)) {
    my (@pseq_ids) = $u->pseq_ids_by_pset($name);
    printf( "$name: %d\n", $#pseq_ids + 1 );
}

foreach my $pset_id (1050) {
    my (@pseq_ids) = $u->pseq_ids_by_pset_id($pset_id);
    printf( "$pset_id: %d\n", $#pseq_ids + 1 );
}
