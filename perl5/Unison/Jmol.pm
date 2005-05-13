#utilities for calling jmol functions
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
	       #-script => {-languange => 'JAVASCRIPT', -src => "$src/JmolUnison.js"}
	      );
    return @ret;
}

sub initialize{
    my ($self,$fn,$name,$pseq_structure) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);
    my $select_chain = ":".uc(substr($name,4,1)).".*";
    $stringio->print($pseq_structure->set_js_vars(1));
    $stringio->print("<center><table border=\"1\" cellpadding=\"5\"><tr><td><script>jmolInitialize(\"../js/jmol/\");");
    $stringio->print("jmolApplet([$self->{'width'}, $self->{'height'}], \"load ../js/Jmol/pdb/all.ent/$fn; set frank off;spacefill off; wireframe off; cartoon on; color cartoon yellow; select $select_chain; restrict selected; center $select_chain;zoom 150;set echo off;set echo top left;font echo 18 serif;color echo white; echo $name;");
    $stringio->print($self->highlights($select_chain)) if(defined($self->{'highlights'}));
    $stringio->print("\");");
    $stringio->print("</script></td>");
    $stringio->print("<td><table><tr><td><script>jmolCheckbox(\"select hetero ; wireframe 0.5;\",\"select not hetero; restrict selected;\",\"show hetero atoms\",false)</script></td></tr>");
    $stringio->print("<tr><td><script>jmolCheckbox(\"select all; cartoon on;\",\"cartoon on; select $select_chain; restrict selected; center $select_chain;zoom 150;\",\"show all chains\")</script><td></tr></table></td>");
    $stringio->print("</tr></table></center>");
    return( $retval );
}

sub initialize_inline {
  my ($self,$coord,$script,$pseq_structure) = @_;
  my ($retval);
  my $c = "\"\"";
  my $stringio = IO::String->new($retval);
  $stringio->print($pseq_structure->set_js_vars(0)) if(defined($pseq_structure));
  $stringio->print("<center><table border=\"1\" cellpadding=\"5\"><tr><td><script>jmolInitialize(\"../js/jmol/\");");

  foreach my $line(split(/\n/,$coord)) {
    if($line =~ /^ATOM/) {
      $c .= "+\"$line\\n\"\n" if($line =~ /CA/);
    }
  }
  $stringio->print("var myPdb = $c;");
  $stringio->print("jmolAppletInline([$self->{'width'}, $self->{'height'}],myPdb,\"$script\");");
  $stringio->print("</script></td>");
  $stringio->print("</tr></table></center>");
  return( $retval );
}

sub load{
    my ($self,$fn,$chain) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);
    my $select_chain = ":".uc($chain).".*";
    my $name = substr($fn,3,4);
    $stringio->print("load ../js/Jmol/pdb/all.ent/$fn; set frank off;spacefill off; wireframe off; cartoon on; color cartoon yellow;select $select_chain; restrict selected; center $select_chain;zoom 150;set echo off;set echo top left;font echo 18 serif;color echo white; echo $name;");
    return( $retval );
}

sub pos_view {
    my ($self,$pos,$chain,$label,$colour) = @_;
    $colour = (defined($colour) ? $colour : 'cpk');

    if($colour =~ /-/) {
      $colour =~ s/-/,/g;
      $colour = "[$colour]";
    }

    my $retval;
    my $stringio = IO::String->new($retval);
    $stringio->print("spacefill off;");
    $stringio->print("select within\(10.0, $pos$chain\);hbonds on;"); 
    $stringio->print("select ".$pos.$chain.";");
    $stringio->print("wireframe 0.5;");
    $stringio->print("color $colour;");
    $stringio->print("select $pos$chain and *.CA;");
    $stringio->print("label $label; color label white;");
    $stringio->print("center $pos$chain; zoom 400; select all;");
    return $retval;
}

sub region_view {
    my ($self,$pos1,$chain1,$pos2,$label,$colour) = @_;
    $colour = (defined($colour) ? $colour : 'cpk');
    if($colour =~ /-/) {
      $colour =~ s/-/,/g;
      $colour = "[$colour]";
    }
    return "select $pos1-$pos2$chain1; color cartoon $colour; select ".int($pos1+($pos2-$pos1)/2)."$chain1 and *.CA; label $label; color label white;";
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
    return( "<form><script>jmolChangeStructureLink(\"$script\",\"$name\");</script></form>" );
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

1;

