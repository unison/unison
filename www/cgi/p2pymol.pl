#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Error qw(:try);
use Bio::Structure::IO;

# uses below here might come from ../perl5 if available
use Unison::WWW;
use Unison::WWW::Page;

use Bio::Prospect::Options;
use Bio::Prospect::LocalClient;
use Bio::Prospect::Exceptions;



my $pdbDir = '/apps/compbio/share/prospect2/pdb';

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id params_id templates));

my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
if (not defined $seq) {
  $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}"); 
}

my @templates = split(/[\0,]/,$v->{templates});
my @missing = grep { not -f "$pdbDir/$_.pdb" } @templates;
if (@missing) {
  $p->die('missing templates',
		  "I couldn't find Dave's pdb templates in $pdbDir for @missing",
		  "(These are manually derived from the threading templates... go bug Dave)"); 
}
my $template = $templates[0];

my $po = $u->get_p2options_by_params_id( $v->{params_id} );
if (not defined $po) {
  $p->die("The params_id parameter ($v->{params_id}) is invalid."); 
}
$po->{templates} = \@templates;


try {
  my $pf = new Bio::Prospect::LocalClient( {options=>$po} );
  my $str = Bio::Structure::IO->new(-file => "$pdbDir/$template.pdb",
									-format => 'pdb')->next_structure();
  my $thr = ($pf->thread( $seq ))[0];
  $thr->qname($v->{pseq_id});
  my $root = sprintf("%s-%s-%s",$v->{pseq_id},$template,$v->{params_id});
  my $filename = "$root.pml";
  print("Content-type: application/x-pymol\n",
		# "Content-disposition: inline; filename=$filename\n",
		"Content-disposition: attachment; filename=$filename\n",
		"\n",
		$thr->output_pymol_script( $str, $root ),
	   );
} catch Bio::Prospect::RuntimeError with {
  $p->die("couldn't generate rasmol script",@_)
};


exit(0);
