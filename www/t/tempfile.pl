#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};

my ($fh,$fn,$urn) = $p->tempfile();
$fh->print("fn: $fn\nurn: $urn\n");
$fh->close();

my $full_url      	= $p->url(-full=>1);
my $rel_url  		= $p->url(-relative=>1);
my $abs_url  		= $p->url(-absolute=>1);
my $url_path 		= $p->url(-path_info=>1);
my $url_path_query	= $p->url(-path_info=>1,-query=>1);
my $netloc        	= $p->url(-base => 1);


print <<EOF;
Content-type: text/html

<pre>
trp: $p->{tmp_root_path}
tru: $p->{tmp_root_urn}
tdp: $p->{tmp_droot_path}
tdu: $p->{tmp_droot_urn}

fh: $fh
fn: $fn
urn: <a href=\"$urn\">$urn</a>

full_url: $full_url
rel_url: $rel_url
abs_url: $abs_url
url_path: $url_path
url_path_query: $url_path_query
netloc: $netloc
</pre>
EOF

exit(0);
