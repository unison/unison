#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;
use Prospect2::Options;
use Prospect2::LocalClient;
use Prospect2::Transformation;
use Bio::Structure::IO;

my $pdbDir = '/apps/compbio/share/prospect2/pdb';

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id p2params_id templates));

my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
if (not defined $seq)
  { $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}"); }

my @templates = split(/[\0,]/,$v->{templates});
my @missing = grep { not -f "$pdbDir/$_.pdb" } @templates;
if (@missing)
  { $p->die('missing templates',
			"I couldn't find Dave's pdb templates in $pdbDir for @missing",
			"(These are manually derived from the threading templates... go bug Dave)"); }
my $template = $templates[0];

my $po = $u->get_p2options_by_p2params_id( $v->{p2params_id} );
if (not defined $po)
  { $p->die("The p2params_id parameter ($v->p2params_id) is invalid."); }
$po->{templates} = \@templates;

my $pf = new Prospect2::LocalClient( {options=>$po} );
my $pt = new Prospect2::Transformation;
my $str = Bio::Structure::IO->new(-file => "$pdbDir/$template.pdb",
								  -format => 'pdb')->next_structure();
my $thr = ($pf->thread( $seq ))[0];

print("Content-type: application/x-rasmol\n\n",
	  $pt->outputRasmolScript( $thr, $str ));
exit(0);
