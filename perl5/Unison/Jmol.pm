#!/usr/bin/env perl
#$ID = q$Id: Jmol.pm,v 1.1 2005/02/17 00:22:35 mukhyala Exp $;
#utilities for calling jmol functions
###########################################################
package Unison::Jmol;

use strict;
use Carp;

use vars qw( $VERSION );
###$VERSION = sprintf( "%d.%02d", q $ =~ /(\d+)\.(\d+)/ );


sub new {
    my ($class,$width,$height) = @_;
    my $self = {};
    bless $self,$class;
    $width = 200 if(!defined($width));
    $height = 200 if(!defined($height));
    $self->{'width'} = $width;
    $self->{'height'} = $height;

    return( $self );
}

sub script_header {
    my $self = shift;
    my @ret = (-script => {-languange => 'JAVASCRIPT', -src => '../js/jmol/Jmol.js'},
	       -script => {-languange => 'JAVASCRIPT', -src => '../js/jmol/JmolUnison.js'}
	      );
    return @ret;
}

sub initialize{

    my ($self,$fn,$name,$pseq_structure) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);

    $stringio->print("<center><form><script LANGUAGE=\"JavaScript\">var seq_str = new Object; var pdbid = \'$name\'; jmolInitialize(\"../js/jmol\");");
    $stringio->print("jmolApplet([$self->{'width'}, $self->{'height'}], \"load $fn; spacefill off; wireframe off; cartoon on; color cartoon yellow\");");
    $stringio->print("</script></form></center>");
    $stringio->print($pseq_structure->set_js_vars());
    return( $retval );
}

sub load{

    my ($self,$fn) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);
    $stringio->print("load $fn; spacefill off; wireframe off; cartoon on; color cartoon yellow;");
    return( $retval );
}

sub snp_view {

    my ($self,$pos,$chain,$label) = @_;
    $chain = ($chain eq '' ? '' : ":$chain");

    my $retval;
    my $stringio = IO::String->new($retval);
    $stringio->print("spacefill off;");
    $stringio->print("select ".$pos.$chain.";");
    $stringio->print("wireframe 0.5;");
    $stringio->print("color blue;");
    $stringio->print("select $pos$chain and *.CA;");
    $stringio->print("label $pos:$label; color label yellow;");
    $stringio->print("center $pos$chain; zoom 400; select all; hbonds on");
    return $retval;
}

sub region_view {

    my ($self,$pos1,$chain1,$pos2,$label) = @_;
    $chain1 = ($chain1 eq '' ? '' : ":$chain1");
    return "select $pos1-$pos2$chain1; color cartoon red; select ".int($pos1+($pos2-$pos1)/2)."$chain1 and *.CA; label $label; color label yellow;";
}


sub link {

    my ($self,$script,$name) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);

    $stringio->print("<form><script>jmolLink(\"$script\",\"$name\");</script></form>");
    return( $retval );
}

sub changeStructurelink {

    my ($self,$script,$name) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);

    $stringio->print("<form><script>jmolChangeStructureLink(\"$script\",\"$name\");</script></form>");
    return( $retval );
}
sub script {

    my ($self,$script) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);

    $stringio->print("javascript:jmolScript(\'$script\');");
    return( $retval );
}

sub selectRegion {

    my ($self,$pos1,$pos2,$label) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);
    $stringio->print("javascript:jmolSelectRegion(\'$pos1\',\'$pos2\',\'$label\');");
    return( $retval );
}

sub selectPosition {

    my ($self,$pos,$label) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);
    $stringio->print("javascript:jmolSelectPosition(\'$pos\',\'$label\');");
    return( $retval );
}

sub selectPositionLink {

    my ($self,$pos,$label,$text) = @_;
    my $retval;
    my $stringio = IO::String->new($retval);
    $stringio->print("<form><script>jmolSelectPositionLink(\'$pos\',\'$label\',\'$text\');</script></form>");
    return( $retval );
}


'Yatv';
