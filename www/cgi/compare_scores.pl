#!/usr/bin/env perl
# compare_scores.pl -- compare scoring systems for pmodelsets

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;
use Unison::Exceptions;
use Unison::compare_scores;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};

#globals, scores: %$scores, %$data for GD::Graph
my ($scores,$data);

my %defaults = 
  (
   pmodelset_id => 3,
   tag => '',
  );

my $v = $p->Vars();
my %v = (%defaults, %$v);
$v = \%v;

# get tempfiles for the comparison graph's png files
my ($png_fh, $png_fn) = File::Temp::tempfile(DIR => $p->{tmpdir}, SUFFIX=>'.png');
my ($png_urn) = $png_fn =~ m%^$p->{tmproot}(/.+)%;


sub main {
  try {
##
## code for submit button
## generates graphs
##

    if (exists $v->{submit}) {
      ($scores) = Unison::compare_scores::get_p2_scores($u,$v);

      if(scalar keys %$scores < 1) {$v->{tag} = "NO DATA" ;}
      else {

	#get scop and pdb codes for all pmodels in pmodelset;
	Unison::compare_scores::get_scop_pdb($u);
	
	if($v->{Plot} eq 'Clustered') {
	  $v->{tag} = Unison::compare_scores::display_table();
	}
	elsif($v->{Plot} eq 'Scatter') {

	    my ($data,$map) = Unison::compare_scores::display_points($png_fh);
	    $v->{tag} = sprintf('<IMG SRC="%s" usemap="#scattermap">%s',$png_urn,$map->imagemap($png_fn, $data));
	  }
	elsif($v->{Plot} eq 'Range') {

	  Unison::compare_scores::display_bars($png_fh);
	  $v->{tag} = sprintf('<IMG SRC="%s"',$png_urn);
	}	
      }
    }

    #get all the pmodels in pmodelset
    my @models = @{ $u->selectall_arrayref('select pmodelset_id,name from pmodelset order by pmodelset_id') };
    my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" } @models;

    _render_page(\%ms,\@models);

  } catch Unison::Exception with {
    $p->die(shift);
  };
}

##INTERNALS
#############################################################################################
##
sub _render_page {

  my ($models_href,$models_aref) = @_;

  #begin page rendering
  print $p->render("Assessment of Scoring Methods",
		   '<p>This page allows you to asses quantitavely (using sensitivity and specificity measures) and qualitatively (using various types of plots), the scoring methods that are part of the Threading tools we use.
                                 1) Select the Model Set, the Scoring method, and a Graph format,
                                 2) click "vroom".',
		     $p->tip($p->tooltip('Green text','This is sample descriptive text'),
			     ' indicates elements with descriptive mouseover text.'),

		     $p->start_form(-method=>'GET'),

		     '<table border=1 width="100%">', "\n",
		     '<tr>',
		     '<th colspan="3">',
		     $p->submit(-name=>'submit', -value=>'vroom'),
		     '</th>',
		     '</tr>',

		     '<tr>',
		     '<th>',
		     $p->tooltip('Select from the following model sets ','Threading scores for the primary sequences of the seleted modelset (\'known members\') will be compared against those of other model sets(\'known non-menbers\') against structure templates from this model set.'),
		     '</th>',
		     '<th>',
		     $p->tooltip('Select from the following scores ','svm and raw score are part of the Prospect2 threading method'),
		     '</th>',
		     '<th>',
		     $p->tooltip('Select from the following plots ','All plots show scores of sequences(known and known-not) against models (from the selected model set)'),
		     '</th>',
		     '</tr>',"\n",

		     '<tr>',
		     '<th>', 
		     $p->popup_menu(-name => 'pmodelset_id',
				    -values => [map {$_->[0]} @$models_aref],
				    -labels => $models_href,
				    -default => "$v->{pmodelset_id}"),
		     '</th>',						
								
		     '<th>', $p->radio_group(-name=>'score',
					     -values=>['svm','raw'],
					     -linebreak=>'true',
					     -default=>'svm'),
		     '</th>',
		     '<th>', $p->radio_group(-name=>'Plot',
					     -values=>['Scatter','Range','Clustered'],
					     -linebreak=>'true',
					     -default=>'Scatter'),
		     '</th>',						
		     '</tr>',"\n",

		     '<tr>',
		     '<td align="center" colspan="3">', $v->{tag} ,'</td>',
		     '</tr>',"\n",

		     "</table>\n",

		     $p->end_form(), "\n",
		    );#end page rendering
}

main();
exit(0);
