#!/usr/bin/env perl

#-------------------------------------------------------------------------------
# NAME: genome_features.pl
# PURPOSE: web script to output pseq aligned to a genome
# USAGE: genome_features.pl?genasm_id=<genasm_id>;[(chr=<chr>;gstart=<gstart>;gstop=<gstop>)||(pseq_id=<pseq_id>)]
#
# $Id: genome_features.pl,v 1.16 2005/11/21 19:13:32 mukhyala Exp $
#-------------------------------------------------------------------------------

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::EmbPage;
use Unison;
use Unison::Exceptions;
use Unison::Utilities::genome_features;

my $p = new Unison::WWW::EmbPage;
my $u = $p->{unison};
my $v = $p->Vars();

# verify parameters
if ( ! ( defined $v->{genasm_id} && (
  ( defined $v->{chr} && defined $v->{gstart} && defined $v->{gstop}) ||
  ( defined $v->{pseq_id} ) )   && (defined $v->{params_id}) )) { $p->die( &usage ); }

# merge defaults and options
my %opts = (%Unison::Utilities::genome_features::opts, %$v);

# get tempfiles for the genome-feature png and imagemap
my ($png_fh, $png_fn,$png_urn) = $p->tempfile(SUFFIX=>'.png');

my $imagemap = '';


try {
  my $panel = Unison::Utilities::genome_features::genome_features_panel($u,%opts);

  # write the png to the temp file
  $png_fh->print( $panel->gd()->png() );
  $png_fh->close();

  # assemble the imagemap as a string
  foreach my $box ( $panel->boxes() ) {
	my ($feature, $x1, $y1, $x2, $y2) = @$box;
	my $fstart = $feature->start; # should be unique
	my $fname = $feature->name; # should be unique
	next if not defined $fname;
	if (my ($pseq_id) = $fname =~ m/^Unison:(\d+)/) {
	  my $text = $u->best_annotation($pseq_id) || '?';
	  $imagemap .= qq(<AREA SHAPE="RECT" COORDS="$x1,$y1,$x2,$y2" TOOLTIP="$text" HREF="pseq_summary.pl?pseq_id=$pseq_id">\n);
	}
  }
} catch Unison::Exception with {
  $p->die(shift);
};


print $p->render("Genome Map",
				 "<center><img src=\"$png_urn\" usemap=\"#GENOME_MAP\"></center>",
				 "<MAP NAME=\"GENOME_MAP\">\n", $imagemap, "</MAP>\n"
				);
