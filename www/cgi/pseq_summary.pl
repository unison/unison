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
use Unison::WWW::utilities qw(alias_link pseq_summary_link pdbc_rcsb_link);
use Unison::Utilities::pseq_features;
use Unison::Utilities::misc qw(elide_sequence);


sub protcomp_info ($);
sub summary_group ($);
sub rep_redirect ($);
# TODO: HUGO name

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
<div class="notice">
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

	my ($domain_digest) = $u->selectrow_array('select * from domain_digests(?)',
											undef,$v->{pseq_id});
	if (defined $domain_digest) {
	  $domain_digest =~ s/\),/$& /g;
	} else {
	  $domain_digest = '<i>no data</i>'
	}

	my ($netphos_digest) = $u->selectrow_array('select digest from pseq_features_netphos_v where pseq_id=?',
											 undef,$v->{pseq_id});
	if (defined $netphos_digest) {
	  $netphos_digest =~ s/\),/$& /g;
	} else {
	  $netphos_digest = '<i>no data</i>'
	}

    # locus will only work for human sequences
    my $locus = $u->selectrow_array(
									# FIXME: HARDCODED PARAMS
									'select chr||band from pseq_cytoband_v where pseq_id=? and params_id=48',
									undef, $v->{pseq_id}
								   );

	my $strx = join(', ',
					map { $p->tooltip(pdbc_rcsb_link($_->[0]),
									  sprintf("%s: %s (I:%d%%,C:%d%%)", @$_)) }
					@{$u->selectall_arrayref('select distinct substr(pdbc,1,4),descr,pct_ident,pct_coverage from papseq_pdbcs_mv where q_pseq_id=?',
										   undef, $v->{pseq_id})}
				   );

	# try best human annotation first, otherwise get best annotation for any species
    my $ba = $u->best_annotation( $v->{pseq_id}, 'HUMAN' )
      || $u->best_annotation( $v->{pseq_id} );

	my @GOs = $u->entrez_go_annotations( $v->{pseq_id} );
	@GOs = grep { $_->{evidence} =~ m/IDA|IPI|IPM|IGI|IEP|TAS|IC|ISS|IGC|RCA/ } @GOs;
	my $go_text = '<i>no Go data</i>';
	if (@GOs) {
	  $go_text = join('<br>',
					  # go terms
					  (map {sprintf("%s: %s",$_->{category},$_->{term})}
					  (sort { $a->{category} cmp $b->{category} } @GOs)),

					  # link to functions tab
					  '<span class="note">'
					  . sprintf('See the <a href="pseq_functions.pl?pseq_id=%d">Functions</a> tab for evidence, PubMed references, and NCBI %s.',
								$v->{pseq_id}, $p->tooltip('GeneRIFs',"NCBI's Gene References Into Function"))
					  .'</span>'
					 );
	}

    return $p->group(
					 'Summary',

					 '<table class="summary">',

					 '<tr><th><div>Best Annotation</div></th> <td>',
					 $ba,
					 '</td></tr>',
					 "\n",

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
					 "\n",

					 '<tr><th><div>Common Annotations</div></th> <td>',
					 join(', ', aliases($p)),
					 '<br><span class="note">'
					 . sprintf('See the <a href="pseq_paliases.pl?pseq_id=%d">Aliases</a> tab for all aliases of this sequence.',
							   $v->{pseq_id})
					 .'</span>',
					 '</td></tr>',
					 "\n",

					 '<tr><th><div>Go Annotations</div></th> <td>',
					 $go_text,
					 '</td></tr>',
					 "\n",

					 '<tr><th><div>Protcomp Localization</div></th> <td>',
					 protcomp_info($p),
					 '</td></tr>',
					  "\n",

					 '<tr><th><div>Human Locus</div></th> <td>',
					 $locus || 'N/A',
					 '</td></tr>',
					 "\n",

					 '<tr><th><div>Sequence</div></th> <td>',
					 length($seq), 'AA (<code>'.elide_sequence($seq,15).'</code>)',
					 "<a href=\"get_fasta.pl?pseq_id=$v->{pseq_id}\">download FASTA</a>",
					 "\n",

					 '<tr><th><div>Predicted Domains</div></th> <td>',
					 'Domain Digest: ', $domain_digest,
					 '<br>','Phosphorylation sites (pos;probability): ', $netphos_digest,
					 '</td></tr>', 
					 "\n",

					 '<tr><th><div>Structures</div></th> <td>',
					 $strx,
					 '</td></tr>', 
					 "\n",

					 '<tr><th><div>Domain Structure</div></th> <td>',
					 features_graphic($p),
					  '<span class="note">'
					  . sprintf('See the <a href="pseq_features.pl?pseq_id=%d">Features</a> tab for additional sequence features.',
								$v->{pseq_id})
					  .'</span>',
					 '</td></tr>', 
					 "\n",

					 '</table>',
					 "\n\n",
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

sub aliases ($) {
    my $p   = shift;
	my ($pref_min,$pref_max) = @_;
    my $u   = $p->{unison};
    my $v   = $p->Vars();

    my $sql = qq/select origin,alias,descr from current_annotations_v
			 where pseq_id=$v->{pseq_id} AND ann_pref<=15000/;
    my $ar = $u->selectall_arrayref($sql);

	return map { $_->[0].':'.$p->tooltip( alias_link($_->[1], $_->[0]), $_->[2]) } @$ar;
}

sub features_graphic ($) {
  my $p        = shift;
  my $u        = $p->{unison};
  my $v        = $p->Vars();
  my $imagemap = '';
  my ( $png_fh, $png_fn, $png_urn ) = $p->tempfile( SUFFIX => '.png' );
  my %opts = ( %Unison::Utilities::pseq_features::opts, %$v, width => 600 );
  $opts{features}{$_}++ foreach qw(psipred tmhmm signalp hmm );

  my $panel = new Unison::Utilities::pseq_features( $u, %opts );

  # write the png to the temp file
  $png_fh->print( $panel->as_png() );
  $png_fh->close();

  sprintf(<<EOT, $png_urn, $panel->imagemap_body(), $v->{pseq_id}, $v->{pseq_id} );
<img src="%s" usemap="#FEATURE_MAP">
<MAP NAME="FEATURE_MAP">
%s
</MAP>
EOT
}
