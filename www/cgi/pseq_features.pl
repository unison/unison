#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp qw(tempfile);
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison;
use Unison::pseq_features;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my ($png_fh, $png_fn) = File::Temp::tempfile(DIR => "$ENV{'DOCUMENT_ROOT'}/tmp/pseq-features/",
											 SUFFIX => '.png' );
my ($urn) = $png_fn =~ m%^$ENV{'DOCUMENT_ROOT'}(.+)%;

$png_fh->print( $u->features_graphic($v->{pseq_id}) );
$png_fh->close( );

print $p->render("Unison:$v->{pseq_id} Features Overview",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("Unison:$v->{pseq_id} Features",
						   "<center><img src=\"$urn\"></center>",
						  ),
				);
