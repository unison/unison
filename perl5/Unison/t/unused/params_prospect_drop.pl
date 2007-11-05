#!/usr/bin/env perl

use strict;
use warnings;
use Unison;
use Data::Dumper;

my $u = new Unison( dbname => 'csb-dev' );

while ( my $id = shift ) {
    my $o = $u->get_p2options_by_params_id($id);
    print( Dumper($o), "\n" );
}
