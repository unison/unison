# utilities for calling jmol functions
# $Id: Jmol.pm,v 1.13 2006/08/14 21:12:47 mukhyala Exp $
###########################################################

package Unison::Jmol;

use strict;
use Carp;
use vars qw( $VERSION );

sub new {
  my ($class,$width,$height) = @_;
  my $self = {
			  width => $width || 400,
			  height => $height || 400,
			  highlights => undef
			 };
  bless $self,$class;
  return $self;
}

sub script_header {
    my ($self) = @_;
    my @ret = (
			   -script => {
						   -languange => 'JAVASCRIPT',
							-src => "../js/jmol/Jmol.js" 
						  }
			  );
    return @ret;
}

sub initialize {
    my ($self,$fn,$name,$pseq_structure,$structures_ar,$templates_ar) = @_;
    my $select_chain = ":".uc(substr($name,4,1)).".*";
    my $pdb_url = pdb_url($fn);
    my $jmol_menu_arr;
	$jmol_menu_arr  = $self->_get_jmol_menu_scripts($structures_ar,'structures') if (defined($structures_ar));
	$jmol_menu_arr .= $self->_get_jmol_menu_scripts($templates_ar ,'templates' ) if (defined($templates_ar ));

    my $retval = '';
    $retval .= $pseq_structure->set_js_vars(1);
    $retval .= "\n<table border=1><tr><td colspan=3>\n";
    $retval .= "<script>jmolInitialize(\"../js/jmol/\");\n";
    $retval .= "jmolApplet([$self->{'width'}, $self->{'height'}],\"".$self->_load_script("../js/Jmol/pdb/all.ent/$fn",$select_chain,$name);
    $retval .= $self->highlights($select_chain) if (defined($self->{'highlights'}));
    $retval .= "\");\n";
    $retval .= "</script></td></tr>\n";
    $retval .= "<tr><td colspan=3><center>\n";
    $retval .= "<script>jmolMenu([$jmol_menu_arr])</script></center></td></tr>\n";
    $retval .= "<tr><td width=33%><script>jmolCheckbox(\"select hetero ; wireframe 0.5;\",\"select not hetero; restrict selected;\",\"show hetero atoms\",false)</script></td>\n";
    $retval .= "<td width=33%><center><script>jmolButton(\"center $select_chain\", \"center\")</script></center></td>\n";
    $retval .= "<td width=33%><script>jmolCheckbox(\"select all; cartoon on;\",\"cartoon on; select $select_chain; restrict selected; center $select_chain;zoom 150;\",\"show all chains\")</script></td></tr>\n";
    $retval .= "</table>\n";

    return $retval;
}

sub initialize_inline {
  my ($self,$coord,$script,$pseq_structure) = @_;
  my $c = "\"\"";
  my $retval = '';
  $retval .= $pseq_structure->set_js_vars(0) if (defined($pseq_structure));
  $retval .= '<center><table width='.$self->{'width'}.' border="1"><tr><td align="center"><script>jmolInitialize("../js/jmol/");';
  foreach my $line (split(/\n/,$coord)) {
    if ($line =~ /^ATOM/) {
      $c .= "+\"$line\\n\"\n" if ($line =~ /CA/);
    }
  }
  $retval .= "var myPdb = $c;";
  $retval .= "jmolAppletInline([$self->{'width'}, $self->{'height'}],myPdb,\"$script\");";
  $retval .= '</script></td></tr>';
  $retval .= '<tr><td align="center" style="background: black; color: white">Legend: Identities, <font color=blue><b>blue</b></font>; similarities <font color=cyan><b>cyan</b></font>; mismatches <font color=red><b>red</b></font>.<br>All Cysteines are colored <font color=yellow><b>yellow</b></font>; conserved cysteines are spacefilled.<br>Deletions are colored <font color=grey><b>grey</b></font>; insertions are shown as <font color=green><b>&gt;number of insertions&lt;</b></font>.</td></tr>';
  $retval .= '</table></center>';
  return $retval;
}

sub load {
    my ($self,$fn,$chain) = @_;
    my $select_chain = ":".uc($chain).".*";
    my $name = substr($fn,3,4);
    my $pdb_url = pdb_url($fn);
	$self->_load_script($fn,$select_chain,$name);
}

sub pos_view {
    my ($self,$pos,$chain,$label,$color) = @_;
    $color = (defined($color) ? $color : 'cpk');
    if ($color =~ /-/) {
      $color =~ s/-/,/g;
      $color = "[$color]";
    }
    my $retval = '';
    $retval .= "spacefill off;";
    $retval .= "select within\(10.0, $pos$chain\);hbonds on;"; 
    $retval .= "select ".$pos.$chain.";";
    $retval .= "wireframe 0.5;";
    $retval .= "color $color;";
    $retval .= "select $pos$chain and *.CA;";
    $retval .= "label $label; color label white;";
    $retval .= "center $pos$chain; zoom 400; select all;";
    return $retval;

}

sub region_view {
  my ($self,$pos1,$chain1,$pos2,$label,$color) = @_;
  $color = (defined($color) ? $color : 'cpk');
  if ($color =~ /-/) {
	$color =~ s/-/,/g;
	$color = "[$color]";
  }
  return "select $pos1-$pos2$chain1; color cartoon $color; select "
	.int($pos1+($pos2-$pos1)/2)."$chain1 and *.CA; label $label; color label white;";
}

sub set_highlight_regions {
  my ($self,$ref) = @_;
  $self->{'highlights'} = $ref;
}

sub highlights {
  my $self = shift;
  my $chain = shift;
  my $script = '';
  my $ref = $self->{'highlights'};

  foreach my $r (sort {($ref->{$b}{end} - $ref->{$b}{start}) <=> ($ref->{$a}{end} - $ref->{$a}{start})} 
				 keys %{$ref}) {
	next unless defined($ref->{$r}{color});
	my $end = $ref->{$r}{end};
	$script .= (defined ($end) ?
				$self->region_view($ref->{$r}{start},$chain,$ref->{$r}{end},$r,$ref->{$r}{color}) :
				$self->pos_view($ref->{$r}{start},$chain,$r,$ref->{$r}{color})
			   );
  }
  return $script;
}

sub link {
  my ($self,$script,$name) = @_;
  return "<form><script>jmolLink(\"$script\",\"$name\");</script></form>";
}

sub changeStructureLink {
    my ($self,$script,$name) = @_;
    my $retval = '';
    $retval .= "<script>jmolChangeStructureLink(\"$script\",\"$name\");</script>";
    return $retval;
}

sub changeStructureLoad {
  my ($self,$script,$name) = @_;
  return "jmolChangeStructureLoad(\'$script\',\'$name\');" ;
}

sub script {
  my ($self,$script) = @_;
  return "javascript:jmolScript(\'$script\');" ;
}

sub selectRegion {
  my ($self,$pos1,$pos2,$label,$color) = @_;
  return "jmolSelectRegion(\'$pos1\',\'$pos2\',\'$label\',\'$color\');" ;
}

sub selectPosition {
  my ($self,$pos,$label,$color) = @_;
  return "jmolSelectPosition(\'$pos\',\'$label\',\'$color\');" ;
}

sub selectPositionLink {
  my ($self,$pos,$label,$text) = @_;
  return "<form><script>jmolSelectPositionLink(\'$pos\',\'$label\',\'$text\');</script></form>" ;
}

sub _get_jmol_menu_scripts {
  my ($self,$ar,$type) = @_;
  my $retval = '';
  if ($type eq 'structures') {
	$retval .= "\n[\"".$self->_load_script("../js/Jmol/pdb/all.ent/pdb".substr($_->[0],0,4).".ent", ":".uc(substr($_->[0],4,1)).".*",$_->[0])."\",\"".$_->[1]."\"]," for @$ar;
  } elsif ($type eq 'templates') {
	$retval .= "\n[\"".$self->_load_script("../js/Jmol/pdb/all.ent/pdb".substr($_->[1],0,4).".ent", ":".uc(substr($_->[1],4,1)).".*",$_->[1])."\",\"".substr($_->[13],0,48)." ($_->[1],eval=$_->[7],ident=$_->[9])\"]," for @$ar;
  }
  return $retval;
}

sub _load_script {
  my ($self,$fn,$select_chain,$name) = @_;
  my $retval = '';
  my $pdb_url = pdb_url($fn);
  $retval .= "load $pdb_url;set frank off;spacefill off; wireframe off; cartoon on; color cartoon structure; select $select_chain; restrict selected; center $select_chain;zoom 150;set echo off;set echo top left;font echo 18 serif;color echo white; echo $name;";
  return $retval;
}

############################################################################
## pdb_url -- return url for PDB file specified by filename or pdb id
sub pdb_url {
  my $fn = shift;
  my $id = ($fn =~ m/(....)\.ent$/) ? $1 : $fn;
  return "../cgi/nph-pdb-fetch.sh?$id";
}

1;

