#!/usr/bin/env perl
#####################################################
# compare_methods.pl -- compare threading methods
#####################################################
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq",
  "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;
use Unison::Exceptions;
use Unison::Utilities::compare_scores;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};

if ( $u->is_public() ) {
    $p->die( 'Prospect threadings not available.', <<EOT);
Sorry, Prospect threading results are not part of the public Unison
release. We load these data using scripts which are part of the <a
href="http://unison-db.sourceforge.net/">Unison source distribution</a> and
our <a href="http://sourceforge.net/projects/prospect-if">Prospect
Interface</a> modules for perl.
EOT
}

#globals, scores: %$scores, %$data for GD::Graph
my ( $scores, $data );

my %defaults = (
    pmodelset_id   => 3,
    pcontrolset_id => 500,
    tag            => '',
);

my $v = $p->Vars();
my %v = ( %defaults, %$v );
$v = \%v;

# get tempfiles for the comparison graph's png files
my ( $png_fh, $png_fn, $png_urn ) = $p->tempfile( SUFFIX => '.png' );

sub main {
    try {
##
## code for submit button
## generates graphs
##

        if ( exists $v->{submit} ) {
            my (@ys);
            foreach my $s ( @{ $p->{score} } ) {
                ($scores) =
                  Unison::Utilities::compare_scores::get_p2_scores( $u, $v,
                    $s );
                my ( $y1, $y2 ) =
                  Unison::Utilities::compare_scores::compute_stats($s);
                push @ys, ( $y1, $y2 ) if ( $y1 != 0 and $y2 != 0 );
            }
            Unison::Utilities::compare_scores::reorganize_stats( $p->{score} );
            if ( scalar keys %$scores < 1 ) { $v->{tag} = "NO DATA"; }
            elsif ( $#ys < 0 ) { $v->{tag} = "NO DATA"; }
            else {
                Unison::Utilities::compare_scores::plot_stats( $p->{score},
                    $png_fh );
                $v->{tag} = sprintf( '<IMG SRC="%s"', $png_urn );
            }
        }

        #get all the pmodels in pmodelset
        my @models = @{
            $u->selectall_arrayref(
                'select pmodelset_id,name from pmodelset order by pmodelset_id')
          };
        my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" } @models;

        #get the control sets in pset
        my @controls = @{
            $u->selectall_arrayref(
                    'select ps.pset_id,ps.name from pset ps where ps.pset_id = '
                  . $v->{pcontrolset_id}
                  . ' order by ps.pset_id'
            )
          };
        my %cs = map { $_->[0] => "$_->[1] (set $_->[0])" } @controls;

        #get params
        my @params = $u->get_params_info_by_pftype('prospect');
        my %params = map { $_->[0] => $_->[1] } @params;

        _render_page( \%ms, \@models, \%cs, \@controls, \%params, \@params );

    }
    catch Unison::Exception with {
        $p->die(shift);
    };
}

##INTERNALS
#############################################################################################
##
sub _render_page {

    my (
        $models_href,   $models_aref, $controls_href,
        $controls_aref, $params_href, $params_aref
    ) = @_;

    #begin page rendering
    print $p->render(
        "Scoring Methods Assessment",
'<p>This page allows you to qualitatively asses the scoring methods that are part of the Threading tools we use, using sensitivity and specificity values.
                                 1) Select the Model Set and choose the Scoring methods,
                                 2) click "submit".',

        $p->start_form( -method => 'GET' ),

        '<table border=1 width="100%">', "\n",
        '<tr>',
        '<th colspan="4">',
        $p->submit( -name => 'submit', -value => 'submit' ),
        '</th>',
        '</tr>',

        '<tr>',
        '<th width=25%>',
        $p->tooltip(
            'Select from the following model sets ',
'Threading scores for the primary sequences of the seleted modelset (\'known members\') will be compared against those of other model sets(\'known non-menbers\') against structure templates from this model set.'
        ),
        '</th>',
        '<th width=25%>',
        $p->tooltip(
            'Select Control Set ',
'Sequences from the selected model set will be deleted from the control set plotting the scores'
        ),
        '</th>',
        '<th width="25%">',
        $p->tooltip(
            'Select Parameters ',
            'Unison currently has data for params_id=1'
        ),
        '</th>',
        '<th width=25%>',
        $p->tooltip(
            'Select from the following scores ',
            'svm and raw score are part of the Prospect threading method'
        ),
        '</th>', '</tr>',
        "\n",

        '<tr>', '<th>',
        $p->popup_menu(
            -name    => 'pmodelset_id',
            -values  => [ map { $_->[0] } @$models_aref ],
            -labels  => $models_href,
            -default => "$v->{pmodelset_id}"
        ),
        '</th>',

        '<th>',
        $p->popup_menu(
            -name    => 'pcontrolset_id',
            -values  => [ map { $_->[0] } @$controls_aref ],
            -labels  => $controls_href,
            -default => "$v->{pcontrolset_id}"
        ),
        '</th>',

        '<th>',
        $p->popup_menu(
            -name    => 'params_id',
            -values  => [ map { $_->[0] } @$params_aref ],
            -labels  => $params_href,
            -default => $v->{params_id} || undef
        ),
        '</th>',

        '<th>',
        $p->checkbox_group(
            -name      => 'score',
            -values    => [ 'svm', 'raw' ],
            -default   => 'svm',
            -linebreak => 'true'
        ),
        '</th>', '</tr>', "\n", '<tr>',
        '<td align="center" colspan="4">',
        $v->{tag},
        '</td>',

        "</table>\n",

        $p->end_form(),
        "\n",
    );    #end page rendering
}

main();
exit(0);
