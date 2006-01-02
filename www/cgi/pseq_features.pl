#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Unison;
use Unison::Utilities::pseq_features qw( %opts );

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my ($png_fh, $png_fn, $png_urn) = $p->tempfile( SUFFIX => '.png' );
$p->die("Couldn't create a temporary file: $!\n") unless defined $png_urn;
$p->add_footer_lines('$Id: pseq_features.pl,v 1.19 2005/07/25 22:15:33 rkh Exp $ ');

my %opts = (%Unison::Utilities::pseq_features::opts, %$v);

try {
  my $panel = new Unison::Utilities::pseq_features($u,%opts);

  # write the png to the temp file
  $png_fh->print( $panel->as_png() );
  $png_fh->close();

  my $title = (defined($opts{track_length}) 
			   ? "Secondary Structure Prediction"
			   : "Features Overview");
  print $p->render("Features for Unison:$v->{pseq_id} $title",
				   $p->best_annotation($v->{pseq_id}),
				   '<hr>',

				   'See also: <a href="pseq_history.pl?pseq_id=', $v->{pseq_id}, '">run history</a> for ',
				   'a list of analyses run on this sequence.',

				   $p->group("Unison:$v->{pseq_id} Secondary Structure",
							 "<center><img src=\"$png_urn\" usemap=\"#FEATURE_MAP\"></center>",
							 "\n<MAP NAME=\"FEATURE_MAP\">\n", 
							 $panel->imagemap_body(),
							 "</MAP>\n" ),
				  );
} catch Unison::Exception with {
  $p->die(shift);
};

exit(0);
