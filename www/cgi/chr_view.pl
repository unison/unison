#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::WWW::Page;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(chr gstart gstop));

printf( "Content-type: application/geode\n"
      . "Content-Disposition: filename=\"test.geode\"\n" . "\n"
      . "protocol=by_chr_pos,chr_name=%s,chr_start=%d,chr_end=%d\n\n",
    $v->{chr}, $v->{gstart}, $v->{gstop} );

exit(0);
