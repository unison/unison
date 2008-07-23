#!/usr/bin/env perl
#render the Structure page(tab) in Unison
###########################################################
use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use IO::String;

use Unison::WWW;
use Unison::WWW::EmbPage qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Unison::Jmol;

use Unison::Utilities::pseq_structure;
use Unison::Utilities::pseq_features qw( %opts );


my $p = new Unison::WWW::EmbPage;

my $u = $p->{unison};
my $v = $p->Vars();

$v->{width} = 600 if not defined $v->{width};
$v->{height} = 400 if not defined $v->{height};
$p->ensure_required_params(qw(pseq_id));

# these files are for the image map
my ( $png_fh, $png_fn, $png_urn ) = $p->tempfile( SUFFIX => '.png' );

my $pseq_structure = new Unison::Utilities::pseq_structure( $v->{pseq_id} );
$pseq_structure->unison($u);

my $jmol = new Unison::Jmol( $v->{width},$v->{height});
$pseq_structure->jmol($jmol);

my %opts = ( %Unison::Utilities::pseq_features::opts, %$v );

get_user_specs($jmol);
try {
    my $structures_ar = $pseq_structure->find_structures();
    my $templates_ar  = $pseq_structure->find_templates();
    $p->die("Sorry no structures/templates found\n")
      if (  $pseq_structure->{'num_structures'} == 0
        and $pseq_structure->{'num_templates'} == 0 );

    $pseq_structure->load_first_structure();

    $p->add_html( $jmol->script_header() );

    my ($pdb_id) = substr( $pseq_structure->{'loaded_structure'}, 0, 4 );

    my $imagemap = generate_imagemap()
      || $p->die("pseq_structure.pl couldn't generate imagemap");

    my $parent_url = "pseq_structure.pl?pseq_id=$v->{pseq_id}";
    $parent_url .= "&userfeatures=$v->{userfeatures}" if ( $v->{userfeatures} );
    $parent_url .= "&highlight=$v->{highlight}"       if ( $v->{highlight} );

    print $p->render(
        "<center>",
        (
            defined( $ENV{HTTP_REFERER} ) ? ''
            : "<b>Unison:$v->{pseq_id}: Structural Features"
        ),
        (
            $jmol->initialize(
                "pdb$pdb_id.ent", $pseq_structure->{'loaded_structure'},
                $pseq_structure,  $structures_ar,
                $templates_ar
            )
        ),
        "<img src=\"$png_urn\" usemap=\"#FEATURE_MAP\">",
        "\n<MAP NAME=\"FEATURE_MAP\">\n",
        $imagemap,
        "</MAP>\n",
        (
            defined( $ENV{HTTP_REFERER} ) ? ''
            : "<a href=$parent_url>Unison Main Page</a>"
        ),
        "</center>"
    );
}
catch Unison::Exception with {
    $p->die( $_[0] );
};

#=================================================================================================
sub generate_imagemap {
    my $imagemap;
    $opts{features}{$_}++ foreach qw(template hmm snp user);
    $opts{view}      = 1;
    $opts{structure} = $pseq_structure;

    my $panel =
      Unison::Utilities::pseq_features::pseq_features_panel( $u, %opts );

    # write the png to the temp file
    $png_fh->print( $panel->gd()->png() );
    $png_fh->close();

    # assemble the imagemap as a string
    foreach my $box ( $panel->boxes() ) {
        my ( $feature, $x1, $y1, $x2, $y2 ) = @$box;
        my $attr = $feature->{attributes};
        next unless defined $attr;
        $imagemap .= sprintf(
            '<AREA SHAPE="RECT" COORDS="%d,%d,%d,%d" TOOLTIP="%s" HREF="%s">'
              . "\n",
            $x1, $y1, $x2, $y2,
            $attr->{tooltip} || '',
            $attr->{href}    || ''
        );
    }

    return $imagemap;
}

#=================================================================================================
sub get_user_specs {
    if ( defined( $v->{userfeatures} ) ) {
        foreach ( split( /,/, $v->{userfeatures} ) ) {
            $p->die(
                "wrong userfeatures format expecting :: name@\coord[-coord]\n")
              unless (/(\S+)\@(\S+)/);
            my ( $start, $end ) = split( /-/, $2 );
            $opts{user_feats}{$1}{type}  = 'user';
            $opts{user_feats}{$1}{start} = $start;
            $opts{user_feats}{$1}{end}   = $end;
        }
    }

    if ( defined( $v->{highlight} ) ) {
        foreach ( split( /,/, $v->{highlight} ) ) {
            $p->die(
                "wrong highlight format expecting source:feature[:color]\n")
              unless (/(\S+)\:(\S+)/);
            my @hl = split(/\:/);
            $p->die("Looks like you didn't define $hl[1]\n")
              if ( $hl[0] eq 'user'
                and !defined( $opts{user_feats}{ $hl[1] } ) );
            if ( $hl[0] =~ /hmm/i ) {
                my $ar = $pseq_structure->get_hmm_range( $hl[1] );
                $p->die("Couldn't find $hl[1] domain in PFAM hits")
                  if ( $#{$ar} < 1 );
                (
                    $opts{user_feats}{ $hl[1] }{type},
                    $opts{user_feats}{ $hl[1] }{start},
                    $opts{user_feats}{ $hl[1] }{end}
                ) = ( 'hmm', $ar->[0], $ar->[1] );
            }
            if ( $hl[2] =~ /^\*/ ) {
                $p->die(
                    "$hl[2] 6 digits expected with RGB hexadecimal format\n")
                  if ( length( $hl[2] ) != 7 );
                $hl[2] =
                    hex( substr( $hl[2], 1, 2 ) ) . "-"
                  . hex( substr( $hl[2], 3, 2 ) ) . "-"
                  . hex( substr( $hl[2], 5, 2 ) )
                  || $p->die(
"Something probably wrong with your RGB hexadecimal format\n"
                  );
            }
            $hl[2] =~ s/\[//;
            $hl[2] =~ s/\]//;
            $opts{user_feats}{ $hl[1] }{color} = $hl[2]
              if ( $hl[0] =~ /user/i or $hl[0] =~ /hmm/i );
            $p->die(
"source for the feature to be highlighted must be either user or hmm: you entered $hl[0]"
            ) unless ( $hl[0] =~ /user/i or $hl[0] =~ /hmm/i );
        }
        $jmol->set_highlight_regions( $opts{user_feats} );
    }
}
