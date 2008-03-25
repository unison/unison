#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../perl5", "$FindBin::Bin/../../perl5-prereq";

use Unison;
use Unison::Exceptions;
use Unison::pseq;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link pseq_summary_link);
use Unison::Utilities::pseq_features;
use Unison::Utilities::misc qw(elide_sequence);


sub protcomp_info ($);
sub summary_group ($);
sub sequence_group ($);
sub aliases_group ($);
sub features_group ($);
sub rep_redirect ($);

my $p = new Unison::WWW::Page();
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw( pseq_id ));
if ( defined $v->{plugin_id} ) {

    #$p->add_footer_lines('Thanks for using the plugin!');
    print( STDERR "plugin $v->{plugin_id} from $ENV{REMOTE_ADDR}\n" );
}

try {
    $p->is_valid_pseq_id( $v->{pseq_id} );
}
catch Unison::Exception with {
    $p->die( shift, <<EOT);
You\'ve provided a bogus pseq_id. Please verify the
id an try again, or consider <a href="search_alias.pl">searching for it by name</a>.
EOT
};

try {
    print $p->render(
        "Unison:$v->{pseq_id} Summary",
		rep_redirect($p),
        summary_group($p),
        aliases_group($p),
		features_group($p),
		);
}
catch Unison::Exception with {
    $p->die(shift);
};

exit(0);

############################################################################

sub rep_redirect ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my $rep_q = $u->representative_pseq_id($v->{pseq_id});

  return '' if (not defined $rep_q or $rep_q == $v->{pseq_id});

  return sprintf(<<EOF, $u->best_annotation($rep_q));
<div bgcolor="yellow"><font size="-1">
NOTE: This sequence overlaps with <a tooltip="%s"
href="pseq_summary.pl?pseq_id=$rep_q"> Unison:$rep_q</a>, which is likely
to be a more reliable sequence and have more complete precomputed results.
</div>
EOF
}


sub summary_group ($) {
    my $p = shift;
    my $u = $p->{unison};
    my $v = $p->Vars();

    my $seq         = $u->get_sequence_by_pseq_id( $v->{pseq_id} );


    # locus will only work for human sequences
    my $locus = $u->selectrow_array(
									# FIXME: HARDCODED PARAMS
									'select chr||band from pseq_cytoband_v where pseq_id=? and params_id=48',
        undef, $v->{pseq_id}
    );

	# try best human annotation first, otherwise get best annotation for any species
    my $ba = $u->best_annotation( $v->{pseq_id}, 'HUMAN' )
      || $u->best_annotation( $v->{pseq_id} );

	my @GOs = $u->entrez_go_annotations( $v->{pseq_id} );
	@GOs = grep { $_->{evidence} =~ m/IDA|IPI|IPM|IGI|IEP|TAS|IC|ISS|IGC|RCA/ } @GOs;
	my $go_text = '<i>no Go data</i>';
	if (@GOs) {
	  $go_text = join('<br>',
					  # link to functions:
					  sprintf('see <a href="pseq_functions.pl?pseq_id=%d">Functions</a> for evidence, PubMed references, and NCBI %ss',
						 $v->{pseq_id}, $p->tooltip('GeneRIF',"NCBI's Gene References Into Function")),
					  # go terms
					  map {sprintf("%s: %s",$_->{category},$_->{term})}
					  (sort { $a->{category} cmp $b->{category} } @GOs)
					 );
	}

    return $p->group(
        'Summary',

        '<table class="summary">',

        '<tr><th><div>Best Annotation</div></th> <td>', $ba, '</td></tr>', "\n",

        '<tr><th><div>Entrez Annotations</div></th> <td>', "\n",
        join(
            '<br>',
            (
                map {
                    sprintf( "%s %s; %s", @{%$_}{qw(common symbol descr)} )
                      . ( defined $_->{map_loc} ? " ($_->{map_loc})" : '' )
                  } $u->entrez_annotations( $v->{pseq_id} )
            )
        ),
        '</td></tr>', "\n",

        '<tr><th><div>Go Annotations</div></th> <td>', "\n",
					 $go_text,
        '</td></tr>', "\n",

        (
            $p->{unison}->is_public()
            ? ''
            : '<tr><th><div>Protcomp Localization</div></th> <td>',
            protcomp_info($p),
            '</td></tr>', "\n",
        ),

        '<tr><th><div>Human Locus</div></th> <td>',
        $locus || 'N/A',
        '</td></tr>', "\n",

        '<tr><th><div>Sequence</div></th> <td>',
        length($seq), 'AA (', elide_sequence($seq,5), ')',
		"<a href=\"get_fasta.pl?pseq_id=$v->{pseq_id}\">download FASTA</a>",

        '</td></tr>', "\n",


        '</table>', "\n\n",
    );
}



sub protcomp_info ($) {
    my $p = shift;
    my $u = $p->{unison};
    my $v = $p->Vars();
    my $sql =
qq/select loc,method from psprotcomp_reliable_v where pseq_id=$v->{pseq_id}/;
    my $hr = $u->selectrow_hashref($sql);
    return 'no prediction' unless defined $hr;
    return "$hr->{loc} by $hr->{method}";
}

sub aliases_group ($) {
    my $p   = shift;
    my $u   = $p->{unison};
    my $v   = $p->Vars();
    my $sql = qq/select origin,alias,descr from current_annotations_v
			 where pseq_id=$v->{pseq_id} AND ann_pref<=10000/;
    my $ar = $u->selectall_arrayref($sql);
    do { $_->[1] = alias_link( $_->[1], $_->[0] ) }
      for @$ar;
    my @f       = qw( origin alias description );
    my $tooltip = 'Accessions and descriptions for this exact sequence
    from reliable sources. Click the aliases tab to see all aliases from
    all sources.';

    $p->group(
        'Aliases (' . ( $#$ar + 1 ) . ')&nbsp;' . $p->tooltip( '?', $tooltip ),
        Unison::WWW::Table::render( \@f, $ar ),
        'These are the aliases from the most reliable sources only; see also ',
        '<a href="pseq_paliases.pl?pseq_id=',
        $v->{pseq_id},
        '">other aliases</a>'
    );
}

sub features_group ($) {
    my $p        = shift;
    my $u        = $p->{unison};
    my $v        = $p->Vars();
    my $imagemap = '';
    my ( $png_fh, $png_fn, $png_urn ) = $p->tempfile( SUFFIX => '.png' );
    my %opts = ( %Unison::Utilities::pseq_features::opts, %$v );
    $opts{features}{$_}++ foreach qw(psipred tmdetect tmhmm signalp hmm );

    my $panel = new Unison::Utilities::pseq_features( $u, %opts );

    # write the png to the temp file
    $png_fh->print( $panel->as_png() );
    $png_fh->close();

    $p->group(
        'Features&nbsp;'
          . $p->tooltip(
            '?', 'A selection of precomputed features for this
            sequence. Click the Features tab to view all features.'
          ),
        sprintf(
            <<EOT, $png_urn, $panel->imagemap_body(), $v->{pseq_id}, $v->{pseq_id} ) );
<center><img src="%s" usemap="#FEATURE_MAP"></center>
<MAP NAME="FEATURE_MAP">
%s
</MAP>
See also: <a href="pseq_features.pl?pseq_id=%d">a summary of all features</a>
and <a href="pseq_history.pl?pseq_id=%d">run history</a>.
EOT
}
