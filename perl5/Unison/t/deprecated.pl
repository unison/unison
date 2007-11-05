#!/usr/bin/env perl

use strict;
use warnings;
use Unison::Utilities::misc;

# A: single use, one level deep
sub A1 {
    Unison::warn_deprecated('single level, one level deep, with message');
}

# B: single use, two levels deep
sub B2 {
    Unison::warn_deprecated();
}

sub B1 {
    B2();
}

# C: multiple uses in one location
sub C2 {
    Unison::warn_deprecated();
}

sub C1 {
    for ( my $i = 0 ; $i <= 3 ; $i++ ) {
        C2();
    }
}

# D: multiple uses in one function
sub D2 {
    Unison::warn_deprecated();
}

sub D1 {
    for ( my $i = 0 ; $i <= 3 ; $i++ ) {
        D2();
        D2();
    }
}

print( STDERR "# A1():\n" );
A1();

print( STDERR "\n# B1():\n" );
B1();

print( STDERR "\n# C1():\n" );
C1();

print( STDERR "\n# D1():\n" );
D1();

exit(0);

