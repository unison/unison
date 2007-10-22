#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use Unison::WWW;
use Unison::WWW::EmbPage;
use Unison::WWW::Table;
use Unison::Exceptions;

my $p = new Unison::WWW::EmbPage;
my $u = $p->{unison};
my $v = $p->Vars();

try {

  my $urls = _search_category_urls();
  print $p->render("Search Categories:",
		   $urls,
		  );
} catch Unison::Exception with {
  $p->die($_[0]);
};


###################################################################################################

sub _search_category_urls {
  my $ret ="<p>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('alias')\">Accession</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('protcomp')\">Celluar Localization</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('pepcoil')\">Coiled Coil</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('hmm')\">Domains</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('pmap')\">Genomic Location</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('bigpi')\">GPI Modification Site</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('seg')\">Low Complexity Region</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('regexp')\">Patterns</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('physical')\">Physical Characteristics</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('psipred')\">Secondary Structure</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('signalp')\">Signalp Peptide</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('tax')\">Taxonomy</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('pdb')\">Tertiary Structure</a>";
  $ret .=  "<p><a href=\"javascript:update_emb_search_form('tmhmm')\">Trans Membrane Regions</a>";
  return $ret;
}
