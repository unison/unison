#!/usr/bin/env perl
#############################################################
# compare_scores.pl -- compare scoring systems for pmodelsets
# $ID = q$Id: compare_scores.pl,v 1.10 2005/07/18 20:56:23 rkh Exp $;
#############################################################
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;
use Unison::Exceptions;
use Unison::Utilities::compare_scores;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
$p->add_footer_lines('$Id: compare_scores.pl,v 1.10 2005/07/18 20:56:23 rkh Exp $ ');

if ($u->is_public()) {
  $p->die('Prospect threadings not available.', <<EOT);
Sorry, Prospect threading results are not part of the public Unison
release. We load these data using scripts which are part of the <a
href="http://unison-db.sourceforge.net/">Unison source distribution</a> and
our <a href="http://sourceforge.net/projects/prospect-if">Prospect
Interface</a> modules for perl.
EOT
}



#globals, scores: %$scores, %$data for GD::Graph
my ($scores,$data);

my %defaults = 
  (
   pmodelset_id => 3,
   pcontrolset_id => 500,
   tag => '',
  );

my $v = $p->Vars();
my %v = (%defaults, %$v);
$v = \%v;

# get tempfiles for the comparison graph's png files
my ($png_fh, $png_fn, $png_urn) = $p->tempfile(SUFFIX=>'.png');

sub main {
  try {
##
## code for submit button
## generates graphs
##

    if (exists $v->{submit}) {
      ($scores) = Unison::Utilities::compare_scores::get_p2_scores($u,$v,$v->{score});

      if(scalar keys %$scores < 1) {$v->{tag} = "NO DATA" ;}
      else {

	#get scop and pdb codes for all pmodels in pmodelset;
	Unison::Utilities::compare_scores::get_scop_pdb($u);
	
	if($v->{Plot} eq 'Clustered') {
	  $v->{tag} = Unison::Utilities::compare_scores::display_table($u);
	}
	elsif($v->{Plot} eq 'Scatter') {

	    my ($data,$map) = Unison::Utilities::compare_scores::display_points($png_fh);
	    $v->{tag} = sprintf('<IMG SRC="%s" usemap="#scattermap">%s',$png_urn,$map->imagemap($png_fn, $data));
	  }
	elsif($v->{Plot} eq 'Range') {

	  Unison::Utilities::compare_scores::display_bars($png_fh);
	  $v->{tag} = sprintf('<IMG SRC="%s"',$png_urn);
	}
	$v->{tag} .= _footnote($v->{Plot});
      }
    }

    #get all the pmodels in pmodelset
    my @models = @{ $u->selectall_arrayref('select pmodelset_id,name from pmodelset order by pmodelset_id') };
    my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" } @models;


    #get the control sets in pset
    my @controls = @{ $u->selectall_arrayref('select ps.pset_id,ps.name from pset ps where ps.pset_id = '.$v->{pcontrolset_id}.' order by ps.pset_id') };
    my %cs = map { $_->[0] => "$_->[1] (set $_->[0])" } @controls;

    #get params
    my @params = @{$u->selectall_arrayref(' select params_id,name from params where name like \'Prospect2 default%\'')};
    my %params = map { $_->[0] => "$_->[1]" } @params;

    _render_page(\%ms,\@models,\%cs,\@controls,\%params,\@params);

  } catch Unison::Exception with {
    $p->die(shift);
  };
}

##INTERNALS
#############################################################################################
##
sub _render_page {

  my ($models_href,$models_aref,$controls_href,$controls_aref,$params_href,$params_aref) = @_;

  #begin page rendering
  print $p->render("Scoring Methods Assessment",
		   '<p>This page allows you to quantitatively asses the scoring methods that are part of the Threading tools we use, using various types of plots.
                                 1) Select the Model Set, Control Set, Scoring method, and a Graph format,
                                 2) click "vroom".',
		     $p->tip($p->tooltip('Green text','This is sample descriptive text'),
			     ' indicates elements with descriptive mouseover text.'),

		     $p->start_form(-method=>'GET'),

		     '<table border=1 width=100%>',
		     '<tr>',
		     '<th colspan="5">',
		     $p->submit(-name=>'submit', -value=>'vroom'),
		     '</th>',
		     '</tr>',

		     '<tr>',
		     '<th width = 20%>',
		     $p->tooltip('Select Model Set ','Threading scores for the primary sequences of the seleted modelset (\'known members\') will be compared against those of other model sets(\'known non-menbers\') against structure templates from this model set.'),
		     '</th>',
		     '<th width=20%>',
		     $p->tooltip('Select Control Set ','Sequences from the selected model set will be deleted from the control set plotting the scores'),
		   '</th>',
		   '<th width="20%">',
		   $p->tooltip('Select Parameters ','Unison currently has data for params_id=1'),
		   '</th>',
		   '<th width=20%>',
		   $p->tooltip('Select Score ','svm and raw score are part of the Prospect2 threading method'),
		   '</th>',
		   '<th width=20%>',
		     $p->tooltip('Select Plots ','All plots show scores of sequences(known and known-not) against models (from the selected model set)'),
		     '</th>',
		     '</tr>',"\n",

		     '<tr>',
		     '<th>',
		     $p->popup_menu(-name => 'pmodelset_id',
				    -values => [map {$_->[0]} @$models_aref],
				    -labels => $models_href,
				    -default => "$v->{pmodelset_id}"),
		     '</th>',

		     '<th>',
		     $p->popup_menu(-name => 'pcontrolset_id',
				    -values => [map {$_->[0]} @$controls_aref],
				    -labels => $controls_href,
				    -default => "$v->{pcontrolset_id}"),
		     '</th>',						

		   '<th>',
		   $p->popup_menu(-name => 'params_id',
				  -values => [map {$_->[0]} @$params_aref],
				  -labels => $params_href,
				  -default => $v->{params_id}||undef),
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
		     '</tr>',
		   '<tr>',
		   '<td align="center" colspan="5">', $v->{tag},'</td>',
		   '</tr>',
		
		   "</table>",

		     $p->end_form(),
		    );#end page rendering
}


sub _footnote {

  my ($plot) = @_;

  my $ret = "'</td>','</tr>','<td align=\"center\" colspan=\"5\">";

  if($plot eq 'Clustered') {
    $ret .= "Note : Data for the selected model set are seperated from the rest by an inserted row.";
  }
  elsif($plot eq 'Scatter') {
    $ret .= "Note : Data for the selected model set are seperated from the rest by a dashed line in the plot. Some sequence_ids might not be labelled due to lack of space";
  }
  elsif($plot eq 'Range') {
    $ret .= "Note : Data for the selected model set are seperated from the rest by a black line in the plot. Some sequence_ids might not be labelled due to lack of space";
  }
  return $ret;
}
main();
exit(0);
