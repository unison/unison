#!/usr/bin/env perl
#$ID = q$Id: pseq_structure.pl,v 1.10 2005/07/25 22:15:33 rkh Exp $;
#render the Structure page(tab) in Unison
###########################################################
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use IO::String;

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Unison::Jmol;


use Unison::Utilities::pseq_structure;
use Unison::Utilities::pseq_features qw( %opts );

#this is a list of columns we want in the structure templates table
my @templates_cols = qw(alias qstart qstop tstart tstop gaps eval score pct_ident len pct_coverage method descr);

#this is a list of columns we want in the snp table
my @snp_cols = qw(wt_aa variant_aa position_in_sequence Description);

my $p = new Unison::WWW::Page;

my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id));
$p->add_footer_lines('$Id: pseq_structure.pl,v 1.10 2005/07/25 22:15:33 rkh Exp $ ');

# these files are for the image map
my ($png_fh, $png_fn, $png_urn) = $p->tempfile(SUFFIX => '.png' );

my $pseq_structure = new Unison::Utilities::pseq_structure($v->{pseq_id});
$pseq_structure->unison($u);

my $jmol = new Unison::Jmol(600,300);
$pseq_structure->jmol($jmol);

my %opts = (%Unison::Utilities::pseq_features::opts, %$v);

try {

    my $structure_templates_ar=$pseq_structure->find_structure_templates();
    $p->die("Sorry no structures/templates found\n") if($pseq_structure->{'num_structure_templates'} == 0);
    $pseq_structure->find_snps();

    $structure_templates_ar = edit_structure_rows($structure_templates_ar,1);
    my $snp_ar = edit_snp_rows(\@snp_cols);

    $pseq_structure->load_first_structure();

    $p->add_html($jmol->script_header());

    my $iframe_url = "emb_pseq_structure.pl?pseq_id=$v->{pseq_id}";
    $iframe_url .= "&userfeatures=$v->{userfeatures}" if($v->{userfeatures});
    $iframe_url .= "&highlight=$v->{highlight}" if($v->{highlight});

    print $p->render("Unison:$v->{pseq_id}",
		     $pseq_structure->set_js_vars(),
		     "<script>jmolInitialize(\"../js/jmol/\");</script>",
		     $p->best_annotation($v->{pseq_id}),
		     $p->iframe("structure",$iframe_url),
		     $p->group("Structural Templates found for Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@templates_cols,$structure_templates_ar,{scroll => 1})),
		     '<p>',
		     $p->group("SNPs in Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@snp_cols,$snp_ar,{scroll => 1}))
		   );
} catch Unison::Exception with {
    $p->die($_[0]);
};


#=================================================================================================
sub edit_structure_rows {
  my ($ar,$sh) = @_;
  foreach my $r (@$ar) {
    shift @$r if($sh);
    my $rnew; #will replace r with an extra aln checkbox column at the start
    # build checkbox for alignment
    my ($pdb_id,$chain) = (substr($r->[0],0,4),substr($r->[0],4,1));
    $r->[0] = $jmol->changeStructureLink($jmol->load("pdb$pdb_id.ent",$chain),$r->[0]);
    foreach my $i(@$r) {$i = "<center><font size=2>$i</font></center>" if(defined($i));}
    push @$rnew, @$r;
    $r = $rnew;
  }
  return $ar;
}

#=================================================================================================
sub edit_snp_rows {
  my ($hr) = @_;
  my $href = "http://us.expasy.org/cgi-bin/get-sprot-variant.pl?";
  my $ar;
  foreach my $r (@{$pseq_structure->{'features'}{'snps'}}) {
    my $snp_lnk = "<a href=\"javascript:".$jmol->selectPosition($r->{'start'}, $r->{'wt_aa'})."\">$r->{'wt_aa'}</a>";
    my $name = (defined($r->{name}) ? $r->{name}  : $r->{ref});
    my $swiss_lnk = "<a href=\"$href$r->{ref}\">$name</a>";
    push @$ar, [($snp_lnk,$r->{'var_aa'},$r->{'start'},$swiss_lnk)];
  }
  #just to make the data centered in each table cell
  foreach my $r (@$ar) {
    foreach my $i(@$r) {$i = "<center><font size=2>$i</font></center>";}
  }
  return $ar;
}
