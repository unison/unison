#!/usr/bin/env perl
$ID = $Id$;
#render the Structure page(tab) in Unison
###########################################################
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use IO::String;

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Unison::Jmol;

use Unison::pseq_structure;
use Unison::pseq_features qw( %opts );

# for running pairwise blast between pdb sequence from atom records 
# and its actual complete sequence
$ENV{'PATH'} = "$ENV{'PATH'}:/gne/compbio/i686-linux-2.6/opt/blast/bin/";
$ENV{'BLASTMAT'} = "/gne/compbio/share/blast/matrices";

my $pdbDir = (defined($ENV{PDB_PATH}) ? $ENV{PDB_PATH} : '/gne/compbio/share/pdb/all.ent');
my ($pdb_fh, $pdb_fn) = File::Temp::tempfile(UNLINK => 0, DIR => '../js/jmol/', SUFFIX=>'.pdb');

#this is a list of columns we want in the structures table
my @structures_cols = qw(alias description);

#this is a list of columns we want in the templates table at the top of the page
my @templates_cols = qw(alias descr qstart qstop tstart tstop ident sim gaps eval pct_ident len pct_coverage);

#this is a list of columns we want in the snp table at the bottom of the page
my @snp_cols = qw(wt_aa variant_aa position_in_sequence MIM);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id));

# these files are for the image map
my ($png_fh, $png_fn) = File::Temp::tempfile(DIR => $p->{tmpdir}, SUFFIX => '.png' );
my ($png_urn) = $png_fn =~ m%^$p->{tmproot}(/.+)%;

my $pseq_structure = new Unison::pseq_structure($v->{pseq_id});
$pseq_structure->unison($u);

my $jmol = new Unison::Jmol(800,300);

my %opts = (%Unison::pseq_features::opts, %$v);

try {

    my $structures_ar=$pseq_structure->find_structures();

    $structures_ar = edit_structure_rows($structures_ar);

    $pseq_structure->find_snps($u);#for now this sets templates also, call before find_templates;
    my $templates_ar=$pseq_structure->find_templates($u);

    $p->die("Sorry no structures/templates found\n") if($pseq_structure->{'num_structures'} == 0 and $pseq_structure->{'num_templates'}==0);

    $pseq_structure->load_first_structure();

    $templates_ar = edit_structure_rows($templates_ar,1);

    $p->add_html($jmol->script_header());

    my $ar = edit_snp_rows(\@snp_cols);

    #for structure view
    my ($pdb_id) = substr($pseq_structure->{'loaded_structure'},0,4);
    copy_file("$pdbDir/pdb$pdb_id.ent",$pdb_fn) || $p->die("pseq_structure.pl couldn't copy $pdbDir/pdb$pdb_id.ent to $pdb_fn");

    my $imagemap = generate_imagemap() || $p->die("pseq_structure.pl couldn't generate imagemap");

    print $p->render("Unison:$v->{pseq_id} Structural Features",
		     $p->best_annotation($v->{pseq_id}),
		     $jmol->initialize($pdb_fn,$pseq_structure->{'loaded_structure'},$pseq_structure),
		     $p->group("Structures found for Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@structures_cols,$structures_ar)),
		     '<p>',
		     $p->group("Structural Templates found for Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@templates_cols,$templates_ar)),
		     '<p>',
		     $p->group("Unison:$v->{pseq_id} Features",
			       "<center><img src=\"$png_urn\" usemap=\"#FEATURE_MAP\"></center>",
			       "\n<MAP NAME=\"FEATURE_MAP\">\n", $imagemap, "</MAP>\n" ),
		     '<p>',
		     $p->group("SNPs in Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@snp_cols,$ar))
		     );
} catch Unison::Exception with {
    $p->die($_[0]);
};

#=================================================================================================


sub generate_imagemap {

  my $imagemap;
  $opts{features}{$_}++ foreach qw(hmm mim);
  $opts{view}=1;
  $opts{structure}=$pseq_structure;

  my $panel = Unison::pseq_features::pseq_features_panel($u,%opts);

  # write the png to the temp file
  $png_fh->print( $panel->gd()->png() );
  $png_fh->close();

  # assemble the imagemap as a string
  foreach my $box ( $panel->boxes() ) {
	my ($feature, $x1, $y1, $x2, $y2) = @$box;
	my $attr = $feature->{attributes};
	next unless defined $attr;
	$imagemap .= sprintf('<AREA SHAPE="RECT" COORDS="%d,%d,%d,%d" TOOLTIP="%s" HREF="%s">'."\n",
						$x1,$y1,$x2,$y2, $attr->{tooltip}||'', $attr->{href}||'');
  }

  return $imagemap;

}

sub edit_structure_rows {
  my ($ar,$sh) = @_;
  foreach my $r (@$ar) {
    shift @$r if($sh);
    my ($pdb_fh, $pdb_fn) = File::Temp::tempfile(UNLINK => 0, DIR => '../js/jmol/', SUFFIX=>'.pdb');

    my ($pdb_id,$chain) = (substr($r->[0],0,4),substr($r->[0],3,1));
    copy_file("$pdbDir/pdb$pdb_id.ent",$pdb_fn);
    $chain = ($chain eq '' ? '' : ":$chain");
    $r->[0] = $jmol->changeStructurelink($jmol->load($pdb_fn),$r->[0]);
    foreach my $i(@$r) {$i = "<center>$i</center>";}
  }
  return $ar;
}

sub edit_snp_rows {
  my ($hr) = @_;
  my $href = "http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=";
  my $ar;

  foreach my $r (@{$pseq_structure->{'features'}{'snps'}}) {

    my $snp_lnk = "<a href=\"".$jmol->selectPosition($r->{'start'}, $r->{'wt_aa'})."\">$r->{'wt_aa'}</a>";
    my $mim_lnk = "<a href=\"$href$r->{ref}\">$r->{name}</a>";

    push @$ar, [($snp_lnk,$r->{'var_aa'},$r->{'start'},$mim_lnk)];
  }
  #just to make the data centered in each table cell
  foreach my $r (@$ar) {
    foreach my $i(@$r) {$i = "<center>$i</center>";}
  }
  #just to make the data centered in each col header
  foreach my $i (@$hr) {
    $i = "<center>$i</center>";
  }
  return $ar;
}

sub copy_file {

  my ($file1,$file2) = @_;
  $p->die("Couldn't find $file1") if(!-f $file1);
  system("cp $file1 $file2");
  return 1;
}
