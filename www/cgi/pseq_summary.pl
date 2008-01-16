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

sub protcomp_info ($);
sub summary_group ($);
sub sequence_group ($);
sub aliases_group ($);
sub features_group ($);
sub homologs_group ($);
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
        "Summary of Unison:$v->{pseq_id}",
		rep_redirect($p),
        summary_group($p),
		sequence_group($p),
        aliases_group($p),
		features_group($p),
        homologs_group($p),
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

    # locus will only work for human sequences
    my $locus = $u->selectrow_array(
'select chr||band from pseq_cytoband_v where pseq_id=? and params_id=48',
        undef, $v->{pseq_id}
    );

	# try best human annotation first, otherwise get best annotation for any species
    my $ba = $u->best_annotation( $v->{pseq_id}, 'HUMAN' )
      || $u->best_annotation( $v->{pseq_id} );

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

        '</table>', "\n\n",
    );
}

sub summary_table ($) {
    my $p = shift;
    my $u = $p->{unison};
    my $v = $p->Vars();

    # locus will only work for human sequences
    my $locus = $u->selectrow_array(
'select chr||band from pseq_cytoband_v where pseq_id=? and params_id=48',
        undef, $v->{pseq_id}
    );

# try best human annotation first, otherwise get best annotation for any species
    my $ba = $u->best_annotation( $v->{pseq_id}, 'HUMAN' )
      || $u->best_annotation( $v->{pseq_id} );

    return (
        '<table class="summary">',

        '<tr><th><div>Best Annotation</div></th> <td>', $ba, '</td></tr>',

        '<tr><th><div>Entrez Annotations</div></th> <td>',
        join(
            '<br>',
            (
                map {
                    sprintf( "%s %s; %s", @{%$_}{qw(common symbol descr)} )
                      . ( defined $_->{map_loc} ? " ($_->{map_loc})" : '' )
                  } $u->entrez_annotations( $v->{pseq_id} )
            )
        ),
        '</td></tr>',

        (
            $p->{unison}->is_public()
            ? ''
            : '<tr><th><div>Protcomp Localization</div></th> <td>',
            protcomp_info($p),
            '</td></tr>'
        ),

        '<tr><th><div>Human Locus</div></th> <td>',
        $locus || 'N/A',
        '</td></tr>',

        '</table>'
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

sub sequence_group ($) {
    my $p = shift;
    my $u = $p->{unison};
    my $v = $p->Vars();

    my $seq         = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
    my $wrapped_seq = $seq;
    $wrapped_seq =~ s/.{10}/$& /g;
    $wrapped_seq =~ s/.{66}/$&\n/g;

    my $ba = $u->best_alias( $v->{pseq_id}, 'HUMAN' )
      || $u->best_alias( $v->{pseq_id} );

    $p->group(
			  sprintf( "Sequence (%d&nbsp;AA)", length($seq) ),
			  '<pre style="display: inline;">',
			  $wrapped_seq,
			  '</pre>',
			  '<br>',
			  "<a href=\"get_fasta.pl?pseq_id=$v->{pseq_id}\">download this sequence</a> in FASTA format"
			 );
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

sub homologene_link {
    sprintf(
'<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene&term=%s">%s</a>',
        $_[0], $_[0] );
}

sub homologs_group ($) {
    my $p            = shift;
    my $u            = $p->{unison};
    my $v            = $p->Vars();
    my @col_headings = ( 'gene', 'pseq_id', 'species', 'best annotation' );

    my @tax_ids = map { $$_[0] } @{
        $u->selectall_arrayref(
            "SELECT
  	DISTINCT tax_id FROM palias WHERE pseq_id=$v->{pseq_id} AND tax_id IS NOT NULL"
        )
      };

    if ( not @tax_ids ) {

        # There are no tax_ids associated with this sequence.
        my $sql_h =
"select t_gene_symbol, t_pseq_id, tax_id2gs(t_tax_id), best_annotation(t_pseq_id,t_tax_id)
  	 from homologene_pairs_v where q_pseq_id=$v->{pseq_id} order by 1,3";
        my $hr = $u->selectall_arrayref($sql_h);
        do { $_->[0] = homologene_link( $_->[0] ) }
          for @$hr;
        do { $_->[1] = pseq_summary_link( $_->[1], $_->[1] ) }
          for @$hr;

        return $p->group(
            'HomoloGene&nbsp'
              . $p->tooltip(
                '?',
"Homologous sequences as determined by NCBI's Homologene project"
              ),
            '<table width="100%">',
            '<tr><td style="background: yellow"><b>',
            $#$hr + 1,
            ' Homologs</b> ',
            sprintf(
'There are no taxonomic identifiers associated with this sequence. The
				following are predicted and known homologs (paralogs and orthologs) of this
				sequence:'
            ),
            '</td></tr>',
            '<tr><td>',
            Unison::WWW::Table::render( \@col_headings, $hr ),
            '</td></tr>',
            '</table>',
        );
    }

    # since we know this sequence's tax_ids (possibly plural!), we can break
    # the homologs down into para- and orthologs.  Orthologs are selected
    # only from @ortho_gs genus-species.
    my @ortho_gs = qw/HUMAN MOUSE RAT CAEEL DROME BOVIN BRARE RAT YEAST/;
    my $ortho_gs = join( ',', map { "gs2tax_id('$_')" } @ortho_gs );

    my $tax_ids = join( ',', @tax_ids );
    my @gs = map { $$_[0] } @{
        $u->selectall_arrayref(
            "SELECT gs from tax.spspec where tax_id in ($tax_ids)")
      };

    # paralogs:
    my $sql_p =
"select t_gene_symbol, t_pseq_id, tax_id2gs(t_tax_id), best_annotation(t_pseq_id,t_tax_id)
  	 from homologene_paralogs_v where q_pseq_id=$v->{pseq_id} order by 1,3";
    my $pr = $u->selectall_arrayref($sql_p);
    do { $_->[0] = homologene_link( $_->[0] ) }
      for @$pr;
    do { $_->[1] = pseq_summary_link( $_->[1], $_->[1] ) }
      for @$pr;

    # orthologs:
    my $sql_o =
"select t_gene_symbol, t_pseq_id, tax_id2gs(t_tax_id), best_annotation(t_pseq_id,t_tax_id)
  	from homologene_orthologs_v where q_pseq_id=$v->{pseq_id} order by 1,3";
    my $or = $u->selectall_arrayref("$sql_o");
    do { $_->[0] = homologene_link( $_->[0] ) }
      for @$or;
    do { $_->[1] = pseq_summary_link( $_->[1], $_->[1] ) }
      for @$or;

    $p->group(
        'HomoloGene&nbsp'
          . $p->tooltip(
            '?',
            "Homologous sequences as determined by NCBI's Homologene project"
          ),
        '<table class="uwtable" width="100%">',
        '<tr><td style="background: #F5CC06"><b>',
        $#$pr + 1,
        ' Paralogs</b> ',
        sprintf(
            'This sequence occurs in %d specie%s (%s). The
				following are predicted and known paralogs of this
				sequence:', $#gs + 1, ( $#gs + 1 > 1 ? 's' : '' ), join( ',', @gs )
        ),
        '</td></tr>',
        '<tr><td>',
        Unison::WWW::Table::render( \@col_headings, $pr ),
        '</td></tr>',
        '</table>',

        '<hr>',
        '<table class="uwtable" width="100%">',
        '<tr><td style="background: #F5CC06"><b>',
        $#$or + 1,
        ' Orthologs</b> ',
        sprintf(
            "The following are predicted or known orthologs of
            this sequence from %s", join( ',', @ortho_gs )
        ),
        '</td></tr>',
        '<tr><td>',
        Unison::WWW::Table::render( \@col_headings, $or ),
        '</td></tr>',
        '</table>',
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
