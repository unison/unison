#utilities for calling jmol functions
#$Id$
###########################################################
package Unison::Jmol;

use strict;
use Carp;
use vars qw( $VERSION );


sub new {
  my ($class,$width,$height) = @_;
  my $self = {};
  bless $self,$class;
  $width = 200 if(!defined($width));
  $height = 200 if(!defined($height));
  $self->{'width'} = $width;
  $self->{'height'} = $height;
  $self->{'highlights'} = undef;

  return( $self );
}

sub script_header {
    my ($self) = @_;
    my @ret = (-script => {-languange => 'JAVASCRIPT', -src => "../js/jmol/Jmol.js"}
             );
    return @ret;
}
sub initialize{
    my ($self,$fn,$name,$pseq_structure,$structures_ar,$templates_ar) = @_;
    my $retval = '';

    my $select_chain = ":".uc(substr($name,4,1)).".*";
    my $jmol_menu_arr = $self->_get_jmol_menu_scripts($structures_ar,'structures') if(defined($structures_ar));
    $jmol_menu_arr .= $self->_get_jmol_menu_scripts($templates_ar,'templates') if(defined($templates_ar));
    $retval .= $pseq_structure->set_js_vars(1);
    $retval .= "\n<table border=1><tr><td colspan=3>\n";
    $retval .= "<script>jmolInitialize(\"../js/jmol/\");\n";
    $retval .= "jmolApplet([$self->{'width'}, $self->{'height'}],\"".$self->_load_script("../js/Jmol/pdb/all.ent/$fn",$select_chain,$name);
    $retval .= $self->highlights($select_chain) if(defined($self->{'highlights'}));
    $retval .= "\");\n";
    $retval .= "</script></td></tr>\n";

    $retval .= "<tr><td colspan=3><center>\n";
    $retval .= "<script>jmolMenu([$jmol_menu_arr])</script></center></td></tr>\n";
    $retval .= "<tr><td width=33%><script>jmolCheckbox(\"select hetero ; wireframe 0.5;\",\"select not hetero; restrict selected;\",\"show hetero atoms\",false)</script></td>\n";
    $retval .= "<td width=33%><center><script>jmolButton(\"center $select_chain\", \"center\")</script></center></td>\n";
    $retval .= "<td width=33%><script>jmolCheckbox(\"select all; cartoon on;\",\"cartoon on; select $select_chain; restrict selected; center $select_chain;zoom 150;\",\"show all chains\")</script></td></tr>\n";



    $retval .= "</table>\n";
    return( $retval );
}

sub initialize_inline {
  my ($self,$coord,$script,$pseq_structure) = @_;
  my ($retval);
  my $c = "\"\"";
  
  $retval .= $pseq_structure->set_js_vars(0) if(defined($pseq_structure));
  $retval .= "<center><table border=\"1\" cellpadding=\"5\"><tr><td><script>jmolInitialize(\"../js/jmol/\");";

  foreach my $line (split(/\n/,$coord)) {
    if ($line =~ /^ATOM/) {
      $c .= "+\"$line\\n\"\n" if($line =~ /CA/);
    }
  }
  $retval .= "var myPdb = $c;";
  $retval .= "jmolAppletInline([$self->{'width'}, $self->{'height'}],myPdb,\"$script\");";
  $retval .= "</script></td>";
  $retval .= "</tr></table></center>";
  return( $retval );
}

sub load{
    my ($self,$fn,$chain) = @_;
    my $retval = '';
    
    my $select_chain = ":".uc($chain).".*";
    my $name = substr($fn,3,4);
	# set frank off;
    $retval .= "load ../js/Jmol/pdb/all.ent/$fn; spacefill off; wireframe off; cartoon on; color cartoon structure;select $select_chain; restrict selected; center $select_chain;zoom 150;set echo off;set echo top left;font echo 18 serif;color echo white; echo $name;";
    return( $retval );
}

sub pos_view {
    my ($self,$pos,$chain,$label,$colour) = @_;
	
    $colour = (defined($colour) ? $colour : 'cpk');
    if($colour =~ /-/) {
      $colour =~ s/-/,/g;
      $colour = "[$colour]";
    }
    my $retval = '';
    
    $retval .= "spacefill off;";
    $retval .= "select within\(10.0, $pos$chain\);hbonds on;"; 
    $retval .= "select ".$pos.$chain.";";
    $retval .= "wireframe 0.5;";
    $retval .= "color $colour;";
    $retval .= "select $pos$chain and *.CA;";
    $retval .= "label $label; color label white;";
    $retval .= "center $pos$chain; zoom 400; select all;";
    return $retval;

}

sub region_view {
  my ($self,$pos1,$chain1,$pos2,$label,$colour) = @_;
  $colour = (defined($colour) ? $colour : 'cpk');
  if ($colour =~ /-/) {
	$colour =~ s/-/,/g;
	$colour = "[$colour]";
  }
  return "select $pos1-$pos2$chain1; color cartoon $colour; select "
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
	next unless defined($ref->{$r}{colour});
	my $end = $ref->{$r}{end};
	$script .= (defined ($end) ?
				$self->region_view($ref->{$r}{start},$chain,$ref->{$r}{end},$r,$ref->{$r}{colour}) :
				$self->pos_view($ref->{$r}{start},$chain,$r,$ref->{$r}{colour})
			   );
  }
  return $script;
}

sub link {
  my ($self,$script,$name) = @_;
  return( "<form><script>jmolLink(\"$script\",\"$name\");</script></form>" );
}

sub changeStructureLink {

    my ($self,$script,$name) = @_;

    my $retval = '';
    

    $retval .= "<script>jmolChangeStructureLink(\"$script\",\"$name\");</script>";
    return( $retval );
}

sub changeStructureLoad {
  my ($self,$script,$name) = @_;
  return( "jmolChangeStructureLoad(\'$script\',\'$name\');" );
}

sub script {
  my ($self,$script) = @_;
  return( "javascript:jmolScript(\'$script\');" );
}

sub selectRegion {
  my ($self,$pos1,$pos2,$label,$colour) = @_;
  return( "jmolSelectRegion(\'$pos1\',\'$pos2\',\'$label\',\'$colour\');" );
}

sub selectPosition {
  my ($self,$pos,$label,$colour) = @_;
  return( "jmolSelectPosition(\'$pos\',\'$label\',\'$colour\');" );
}

sub selectPositionLink {
  my ($self,$pos,$label,$text) = @_;
  return( "<form><script>jmolSelectPositionLink(\'$pos\',\'$label\',\'$text\');</script></form>" );
}

sub _get_jmol_menu_scripts {
  my ($self,$ar,$type) = @_;
  my $retval;
  my $stringio = IO::String->new($retval);
  $stringio->print(map {"\n[\"".$self->_load_script("../js/Jmol/pdb/all.ent/pdb".substr($_->[0],0,4).".ent", ":".uc(substr($_->[0],4,1)).".*",$_->[0])."\",\"".$_->[1]."\"],"} @$ar) if($type eq 'structures');

  $stringio->print(map {"\n[\"".$self->_load_script("../js/Jmol/pdb/all.ent/pdb".substr($_->[1],0,4).".ent", ":".uc(substr($_->[1],4,1)).".*",$_->[1])."\",\"".substr($_->[13],0,48)." ($_->[1],eval=$_->[7],ident=$_->[9])\"],"} @$ar) if($type eq 'templates');

  return $retval;
}

sub _load_script {
  my ($self,$fn,$select_chain,$name) = @_;
  my $retval = '';

  $retval .= "load $fn;set frank off;spacefill off; wireframe off; cartoon on; color cartoon structure; select $select_chain; restrict selected; center $select_chain;zoom 150;set echo off;set echo top left;font echo 18 serif;color echo white; echo $name;";
  return $retval;
}

sub pdb_url {
  my $fn = shift;
  my $id = ($fn =~ m%pdb(....).ent%) ? $1 : $fn;
  if ($ENV{REMOTE_USER}) {
	# if secured, then we can't use the one in the Unison cgi/ directory
	# because Jmol doesn't support basic auth. The admin should have copied
	# cgi/nph-pdb-fetch.sh to the site's publicly-accessible /cgi-bin/ directory.
	return "/cgi-bin/nph-pdb-fetch.sh?$id";
  }
  # otherwise, we can...
  return "../cgi/nph-pdb-fetch.sh?$id";
}

1;

