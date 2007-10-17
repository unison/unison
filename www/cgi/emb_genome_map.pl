#!/usr/bin/env perl
## emb_genome_map.pl -- genome features as a Unison embeddable page
## $Id: emb_genome_map.pl,v 1.3 2006/08/10 16:43:43 mukhyala Exp $


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
	  my $ba = $u->best_annotation($v->{pseq_id}, 'HUMAN') || $u->best_annotation($v->{pseq_id});
	  my $text = $ba || '?';
	  $imagemap .= qq(<AREA SHAPE="RECT" COORDS="$x1,$y1,$x2,$y2" TOOLTIP="$text" HREF="pseq_summary.pl?pseq_id=$pseq_id">\n);
	}
	else {
	  my ($chip,$probe) = split(/:/,$fname);
	  $imagemap .= qq(<AREA SHAPE="RECT" COORDS="$x1,$y1,$x2,$y2" TOOLTIP="$chip:$probe" HREF=http://research/projects/maprofile/bin/secure/maprofile.cgi?probeid=$probe">\n);
	}
  }
} catch Unison::Exception with {
  $p->die(shift);
};


print $p->render("Genome Map",
				 "<center><img src=\"$png_urn\" usemap=\"#GENOME_MAP\"></center>",
				 "<MAP NAME=\"GENOME_MAP\">\n", $imagemap, "</MAP>\n"
				);

#-------------------------------------------------------------------------------
# NAME: usage
# PURPOSE: return usage string
#-------------------------------------------------------------------------------
sub usage {
  return( "USAGE: emb_genome_map.pl ? genasm_id=&lt;gensam_id&gt; params_id=&lt;params_id&gt; " .
     "[(chr=&lt;chr&gt; ; gstart=&lt;gstart&gt; ; gstop=&lt;gstop&gt; " .
     "|| pseq_id=&lt;pseq_id&gt;]" );
}
