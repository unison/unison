# utilities for calling jmol functions
# $Id$
###########################################################

# FIXME: This module is misplaced. Move it to U::W::Jmol.pm

# FIXME: routines need comments badly

package Unison::Jmol;

use strict;
use warnings;

################################################################################
#sets height and width
sub new {
    my ( $class, $width, $height ) = @_;
    my $self = {
        width  => $width  || 400,
        height => $height || 400,
        highlights => undef
    };
    bless $self, $class;
    return $self;
}

################################################################################
#javascript headers
#
sub script_header {
    my ($self) = @_;
    my @ret = (
        -script => {
            -languange => 'JAVASCRIPT',
            -src       => "js/jmol/Jmol.js"
        }
    );
    return @ret;
}

##################################################################################
#handles the initial jmol view
#pseq_structure is an object of Unison::Utilities::pseq_structure (handles seq-str map)
#_ar's contain the results of structural template search hits
sub initialize {
    my ( $self, $pdbfilename, $pdbc, $pseq_structure, $structures_ar, $templates_ar ) =
      @_;
    my $select_chain = ":" . uc( substr( $pdbc, 4, 1 ) ) . ".*";
    my $pdb_url = pdb_url($pdbfilename);

    my $jmol_menu_arr;
    $jmol_menu_arr = $self->_get_jmol_menu_scripts( $structures_ar, 'structures' )
      if ( defined($structures_ar) );
    $jmol_menu_arr .= $self->_get_jmol_menu_scripts( $templates_ar, 'templates' )
      if ( defined($templates_ar) );


    #html/js for jmol
    my $retval = '';

    $retval .= $pseq_structure->set_js_vars(1);
    $retval .= "\n<table width=$self->{width} border=1><tr><td colspan=3>\n";
    $retval .= "<center>";
    $retval .= "<script>jmolInitialize(\"js/jmol/\");\n";
    $retval .=
      "jmolApplet([$self->{'width'}, $self->{'height'}],\""
      . $self->_load_script( "../js/Jmol/pdb/all.ent/$pdbfilename", $select_chain,
        $pdbc );

    #handle user specs
    $retval .= $self->highlights( $select_chain, $pseq_structure, $pdbc )
      if ( defined( $self->{'highlights'} ) );

    $retval .= "\");\n";
    $retval .= "</script></center></td></tr>\n";

    #start of control UI below jmol viewer
    $retval .= "<tr><td colspan=3><center>\n";
    $retval .=
      "<script>jmolMenu([$jmol_menu_arr])</script></center></td></tr>\n";
    $retval .=
"<tr><td width=33%><script>jmolCheckbox(\"select hetero ; wireframe 0.5;\",\"select not hetero; restrict selected;\",\"show hetero atoms\",false)</script></td>\n";
    $retval .=
"<td width=33%><center><script>jmolButton(\"center $select_chain\", \"center\")</script></center></td>\n";
    $retval .=
"<td width=33%><script>jmolCheckbox(\"select all; cartoon on;\",\"cartoon on; select $select_chain; restrict selected; center $select_chain;zoom 100;\",\"show all chains\")</script></td></tr>\n";
    #end of controls

    $retval .= "</table>\n";

    return $retval;
}

#this routine is not used anymore
sub initialize_inline {
    my ( $self, $coord, $script, $pseq_structure ) = @_;

    my $c      = "\"\"";
    foreach my $line ( split( /\n/, $coord ) ) {
        if ( $line =~ /^ATOM/ ) {
            $c .= "+\"$line\\n\"\n" if ( $line =~ /CA/ );
        }
    }

    my $retval = '';
    $retval .= $pseq_structure->set_js_vars(0) if ( defined($pseq_structure) );

    $retval .= <<EOF;
<center>
  <table width=$self->{'width'} border="1">
    <tr>
	  <td align="center">
		<script>
		  jmolInitialize("../js/jmol/");
		  var myPdb = $c;
		  jmolAppletInline([$self->{'width'}, $self->{'height'}],myPdb,"$script");
		</script>
	  </td>
	</tr>
    <tr>
	  <td align="center" style="background: black; color: white">
	    Legend: Identities, <font color=blue><b>blue</b></font>;
	    similarities <font color=cyan><b>cyan</b></font>; mismatches <font
	    color=red><b>red</b></font>.<br>All Cysteines are colored <font
	    color=yellow><b>yellow</b></font>; conserved cysteines are
	    spacefilled.<br>Deletions are colored <font
	    color=grey><b>grey</b></font>; insertions are shown as <font
	    color=green><b>&gt;number of insertions&lt;</b></font>.
	  </td>
	</tr>
  </table>
</center>
EOF

    return $retval;
}

#returns jmol commands to load a structure
sub load {
    my ( $self, $pdbfilename, $chain ) = @_;
    my $select_chain = ":" . uc($chain) . ".*";
    my $name         = substr( $pdbfilename, 3, 4 );
    my $pdb_url      = pdb_url($pdbfilename);
    $self->_load_script( $pdbfilename, $select_chain, $name );
}

#returns jmol commands to show a residue
sub pos_view {
    my ( $self, $pos, $chain, $label, $color ) = @_;
    $color = ( defined($color) ? $color : 'red' );
    if ( $color =~ /-/ ) {
        $color =~ s/-/,/g;
        $color = "[$color]";
    }
    my $retval = '';
    $retval .= "spacefill off;";
    $retval .= "select within\(10.0, $pos$chain\);hbonds on;";
    $retval .= "select " . $pos . $chain . ";";
    $retval .= "wireframe 0.5;";
    $retval .= "color $color;";
    $retval .= "select $pos$chain and *.CA;";
    $retval .= "label $label; color label black;";
    return $retval;

}

#returns jmol commands to show a region
sub region_view {
    my ( $self, $pos1, $chain1, $pos2, $label, $color ) = @_;
    $color = ( defined($color) ? $color : 'red' );
    if ( $color =~ /-/ ) {
        $color =~ s/-/,/g;
        $color = "[$color]";
    }
    return "select $pos1-$pos2$chain1; color cartoon $color; select "
      . int( $pos1 + ( $pos2 - $pos1 ) / 2 )
      . "$chain1 and *.CA; label $label; color label black;";
}

######################################################################
sub set_highlight_regions {
    my ( $self, $ref ) = @_;
    $self->{'highlights'} = $ref;
}

#returns jmol commands for display user specs
sub highlights {
    my ( $self, $chain, $pseq_str, $pdbid ) = @_;
    my $script = '';
    my $ref    = $self->{'highlights'};
    foreach my $r (
        sort {
            ( $ref->{$b}{end} - $ref->{$b}{start} )
              <=> ( $ref->{$a}{end} - $ref->{$a}{start} )
        }
        keys %{$ref}
      )
    {
        next unless defined( $ref->{$r}{color} );

        #translate query coordinates to structure coordinates ->
        my $str =
          (
            defined $pseq_str->{'templates'}{$pdbid}
            ? $pseq_str->{'templates'}{$pdbid}
            : $pseq_str->{'structures'}{$pdbid} );

        #distance from query start
        my $start = $ref->{$r}{start} - $str->{'qstart'};
        my $end = $ref->{$r}{end} - $str->{'qstart'} if defined $ref->{$r}{end};


	#this is not necessary, unless I forgot this is necessary
        #commenting for now, 07/16/08: mukhyala

        #-> equal to distance from template start(only for ungapped alignments)
        #$ref->{$r}{start} = $str->{'tstart'} + $start;
        #$ref->{$r}{end} = $str->{'tstart'} + $end if defined $end;

	my $stop = defined $end ? $end : $start;
	foreach my $template_pos($str->{'tstart'} + $start .. $str->{'tstart'} + $stop) {
	    $ref->{$r}{start}++ if not defined $pseq_str->{'seq_str_map'}{$pdbid}{$template_pos}{atom_res};
	}

        $script .= (
            defined($ref->{$r}{end})
            ? $self->region_view(
                $ref->{$r}{start}, $chain, $ref->{$r}{end},
                $r,                $ref->{$r}{color}
              )
            : $self->pos_view(
                $ref->{$r}{start},
                $chain, $r, $ref->{$r}{color}
            )
        );
    }
    return $script;
}

#############################################################################
#the following return js functions calls of the same name
sub link {
    my ( $self, $script, $name ) = @_;
    return "<form><script>jmolLink(\"$script\",\"$name\");</script></form>";
}

sub changeStructureLink {
    my ( $self, $script, $name ) = @_;
    my $retval = '';
    $retval .=
      "<script>jmolChangeStructureLink(\"$script\",\"$name\");</script>";
    return $retval;
}

sub changeStructureLoad {
    my ( $self, $script, $name ) = @_;
    return "jmolChangeStructureLoad(\'$script\',\'$name\');";
}

sub script {
    my ( $self, $script ) = @_;
    return "javascript:jmolScript(\'$script\');";
}

sub selectRegion {
    my ( $self, $pos1, $pos2, $label, $color ) = @_;
    return "jmolSelectRegion(\'$pos1\',\'$pos2\',\'$label\',\'$color\');";
}

sub selectPosition {
    my ( $self, $pos, $label, $color ) = @_;
    return "jmolSelectPosition(\'$pos\',\'$label\',\'$color\');";
}

sub selectPositionLink {
    my ( $self, $pos, $label, $text ) = @_;
    return
"<form><script>jmolSelectPositionLink(\'$pos\',\'$label\',\'$text\');</script></form>";
}
#################################################################################


sub _get_jmol_menu_scripts {
    my ( $self, $ar, $type ) = @_;
    my $retval = '';
    if ( $type eq 'structures' ) {
        $retval .= "\n[\""
          . $self->_load_script(
            "../js/Jmol/pdb/all.ent/pdb" . substr( $_->[0], 0, 4 ) . ".ent",
            ":" . uc( substr( $_->[0], 4, 1 ) ) . ".*",
            $_->[0]
          )
          . "\",\""
          . $_->[1] . "\"],"
          for @$ar;
    }
    elsif ( $type eq 'templates' ) {
        $retval .= "\n[\""
          . $self->_load_script(
            "../js/Jmol/pdb/all.ent/pdb" . substr( $_->[1], 0, 4 ) . ".ent",
            ":" . uc( substr( $_->[1], 4, 1 ) ) . ".*",
            $_->[1]
          )
          . "\",\""
          . substr( $_->[13], 0, $self->{width}/20)
          . " ($_->[1],eval=$_->[7],ident=$_->[9])\"],"
          for @$ar;
    }
    return $retval;
}

sub _load_script {
    my ( $self, $pdbfilename, $select_chain, $name ) = @_;
    my $retval  = '';
    my $pdb_url = pdb_url($pdbfilename);
    $retval .=
"background white; load $pdb_url;set frank off;spacefill off; wireframe off; cartoon on; color cartoon lightgrey; select $select_chain; restrict selected; center $select_chain;zoom 100;set echo off;set echo top left;font echo 18 serif;color echo black; echo $name;";
    return $retval;
}

############################################################################
## pdb_url -- return url for PDB file specified by filename or pdb id
sub pdb_url {
    my $fn = shift;
    my $id = ( $fn =~ m/(....)\.ent$/ ) ? $1 : $fn;
    return "nph-pdb-fetch.sh?$id";
}

1;

