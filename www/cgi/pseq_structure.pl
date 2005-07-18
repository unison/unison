#!/usr/bin/env perl
#$ID = q$Id: pseq_structure.pl,v 1.7 2005/06/21 23:42:04 rkh Exp $;
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

# for running pairwise blast between pdb sequence from atom records 
# and its actual complete sequence
$ENV{'PATH'} = "$ENV{'PATH'}:/gne/compbio/i686-linux-2.6/opt/blast/bin/";
$ENV{'BLASTMAT'} = "/gne/compbio/share/blast/matrices";

my $pdbDir = (defined($ENV{PDB_PATH}) ? $ENV{PDB_PATH} : '/gne/compbio/share/pdb/all.ent');

#this is a list of columns we want in the structures table
my @structures_cols = qw(alias description);

#this is a list of columns we want in the templates table at the top of the page
my @templates_cols = qw(alias descr qstart qstop tstart tstop ident sim gaps eval pct_ident len pct_coverage);

#this is a list of columns we want in the snp table
my @snp_cols = qw(wt_aa variant_aa position_in_sequence Description);

my $p = new Unison::WWW::Page;

my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id));
$p->add_footer_lines('$Id: pseq_structure.pl,v 1.7 2005/06/21 23:42:04 rkh Exp $ ');

# these files are for the image map
my ($png_fh, $png_fn, $png_urn) = $p->tempfile(SUFFIX => '.png' );

my $pseq_structure = new Unison::Utilities::pseq_structure($v->{pseq_id});
$pseq_structure->unison($u);

my $jmol = new Unison::Jmol(600,300);
$pseq_structure->jmol($jmol);

my %opts = (%Unison::Utilities::pseq_features::opts, %$v);

get_user_specs($jmol);

try {
    my $structures_ar=$pseq_structure->find_structures();
    my $templates_ar=$pseq_structure->find_templates();
    $p->die("Sorry no structures/templates found\n") if($pseq_structure->{'num_structures'} == 0 and $pseq_structure->{'num_templates'}==0);

    $pseq_structure->find_snps();
    $structures_ar = edit_structure_rows($structures_ar);
    $templates_ar = edit_structure_rows($templates_ar,1);

    my $snp_ar = edit_snp_rows(\@snp_cols);

    $pseq_structure->load_first_structure();

    $p->add_html($jmol->script_header());

    #for structure view
    my ($pdb_id) = substr($pseq_structure->{'loaded_structure'},0,4);

    my $imagemap = generate_imagemap();

    print $p->render("Unison:$v->{pseq_id} Structural Features",
		     $p->best_annotation($v->{pseq_id}),
		     $jmol->initialize("pdb$pdb_id.ent",$pseq_structure->{'loaded_structure'},$pseq_structure),
			 (defined $imagemap ? '' : $p->warn("no clickable entities for this sequence")),
		     $p->group("Unison:$v->{pseq_id} Features",
			       "<center><img src=\"$png_urn\" usemap=\"#FEATURE_MAP\"></center>",
			       "\n<MAP NAME=\"FEATURE_MAP\">\n", $imagemap, "</MAP>\n" ),
		       '<p>',
		     $p->group("Structures found for Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@structures_cols,$structures_ar)),
		     '<p>',
		     $p->group("Structural Templates found for Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@templates_cols,$templates_ar,{scroll => 1})),
		     $p->group("SNPs in Unison:$v->{pseq_id}",  Unison::WWW::Table::render(\@snp_cols,$snp_ar,{scroll => 1}))
		   );
} catch Unison::Exception with {
    $p->die($_[0]);
};

#=================================================================================================


sub generate_imagemap {
  my $imagemap;
  $opts{features}{$_}++ foreach qw(template hmm snp user);
  $opts{view}=1;
  $opts{structure}=$pseq_structure;

  my $panel = Unison::Utilities::pseq_features::pseq_features_panel($u,%opts);

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
    my ($pdb_id,$chain) = (substr($r->[0],0,4),substr($r->[0],4,1));
    $r->[0] = $jmol->changeStructureLink($jmol->load("pdb$pdb_id.ent",$chain),$r->[0],'link');
    foreach my $i(@$r) {$i = "<center><font size=2>$i</font></center>";}
  }
  return $ar;
}

sub edit_snp_rows {
  my ($hr) = @_;
  my $href = "http://us.expasy.org/cgi-bin/get-sprot-variant.pl?";
  my $ar;
  foreach my $r (@{$pseq_structure->{'features'}{'snps'}}) {
    my $snp_lnk = "<a href=\"javascript:".$jmol->selectPosition($r->{'start'}, $r->{'wt_aa'})."\">$r->{'wt_aa'}</a>";
    my $swiss_lnk = "<a href=\"$href$r->{ref}\">$r->{name}</a>";
    push @$ar, [($snp_lnk,$r->{'var_aa'},$r->{'start'},$swiss_lnk)];
  }
  #just to make the data centered in each table cell
  foreach my $r (@$ar) {
    foreach my $i(@$r) {$i = "<center><font size=2>$i</font></center>";}
  }
  return $ar;
}

sub get_user_specs {
  if(defined($v->{userfeatures})) {
    foreach (split(/,/,$v->{userfeatures})) {
      $p->die("wrong userfeatures format expecting :: name@\coord[-coord]\n") unless (/(\S+)\@(\S+)/);
      my ($start,$end) = split(/-/,$2);
      $opts{user_feats}{$1}{type}='user';
      $opts{user_feats}{$1}{start}=$start;
      $opts{user_feats}{$1}{end}=$end;
    }
  }

  if(defined($v->{highlight})) {
      foreach (split(/,/,$v->{highlight})) {
	  $p->die("wrong highlight format expecting source:feature[:colour]\n") unless (/(\S+)\:(\S+)/);
	  my @hl = split(/\:/);
	  $p->die("Looks like you didn't define $hl[1]\n") if($hl[0] eq 'user' and !defined($opts{user_feats}{$hl[1]}));
	  if($hl[0] =~ /hmm/i) {
	      my $ar = $pseq_structure->get_hmm_range($hl[1]);
	      $p->die("Couldn't find $hl[1] domain in PFAM hits")  if ($#{$ar} <1);
	      ($opts{user_feats}{$hl[1]}{type},$opts{user_feats}{$hl[1]}{start},$opts{user_feats}{$hl[1]}{end}) = ('hmm',$ar->[0],$ar->[1]);
	  }
	  if($hl[2] =~ /^\*/) {
	      $p->die("$hl[2] 6 digits expected with RGB hexadecimal format\n") if(length($hl[2]) != 7);
	      $hl[2] = hex(substr($hl[2],1,2))."-".hex(substr($hl[2],3,2))."-".hex(substr($hl[2],5,2)) || $p->die("Something probably wrong with your RGB hexadecimal format\n");
	  }
	  $hl[2] =~ s/\[//;
	  $hl[2] =~ s/\]//;
	  $opts{user_feats}{$hl[1]}{colour}=$hl[2] if($hl[0] =~ /user/i or $hl[0] =~ /hmm/i);
	  $p->die("source for the feature to be highlighted must be either user or hmm: you entered $hl[0]") unless ($hl[0] =~ /user/i or $hl[0] =~ /hmm/i);
      }
    $jmol->set_highlight_regions($opts{user_feats});
  }
}
