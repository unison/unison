#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use File::Temp qw(tempfile);
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::Exceptions;
use Unison;
use Unison::pseq_features qw( %opts );
use Data::Dumper;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my ($png_fh, $png_fn) = File::Temp::tempfile(DIR => $p->{tmpdir},
											 SUFFIX => '.png' );
my ($png_urn) = $png_fn =~ m%^$p->{tmproot}(/.+)%;

my %opts = (%Unison::pseq_features::opts, %$v);

my $imagemap = '';

try {
  my $panel = Unison::pseq_features::pseq_features_panel($u,%opts);

  # write the png to the temp file
  $png_fh->print( $panel->gd()->png() );
  $png_fh->close();

  # assemble the imagemap as a string
  foreach my $box ( $panel->boxes() ) {
	print(STDERR "box\n");
	my ($feature, $x1, $y1, $x2, $y2) = @$box;
	my $attr = $feature->{attributes};
	next unless defined $attr;
	$imagemap .= sprintf('<AREA SHAPE="RECT" COORDS="%d,%d,%d,%d" TOOLTIP="%s" HREF="%s">'."\n",
						$x1,$y1,$x2,$y2, $attr->{tooltip}||'', $attr->{href}||'');
  }
} catch Unison::Exception with {
  $p->die(shift);
};


print $p->render("Unison:$v->{pseq_id} Features Overview",
				 $p->best_annotation($v->{pseq_id}),
				 '<hr>',
				 $p->group("Unison:$v->{pseq_id} Features",
						   "<center><img src=\"$png_urn\" usemap=\"#FEATURE_MAP\"></center>",
						   "\n<MAP NAME=\"FEATURE_MAP\">\n", $imagemap, "</MAP>\n" ),
				);
