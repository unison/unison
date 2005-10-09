#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link pseq_summary_link);
use Unison::Utilities::pseq_features;

sub protcomp_info ($);
sub sequence_group ($);
sub aliases_group ($);
sub features_group ($);
sub homologs_group ($);

my $p = new Unison::WWW::Page();
my $v = $p->Vars();

$p->ensure_required_params( qw( pseq_id ) );
$p->add_footer_lines('$Id: pseq_summary.pl,v 1.35 2005/08/08 21:47:18 rkh Exp $ ');
if (defined $v->{plugin_id}) {
  #$p->add_footer_lines('Thanks for using the plugin!');
  print(STDERR "plugin $v->{plugin_id} from $ENV{REMOTE_ADDR}\n");
}



try {
  $p->is_valid_pseq_id($v->{pseq_id});
} catch Unison::Exception with {
  $p->die_with_exception(shift, <<EOT);
You've provided a bogus pseq_id. Please verify the
id an try again, or consider <a href="search_by_alias.pl">searching for it by name</a>.
EOT
};

try {
  print $p->render("Summary of Unison:$v->{pseq_id}",
				   $p->best_annotation($v->{pseq_id}),
				   '<p><b>Protcomp Localization:</b> ',
				       ($p->{unison}->is_public() ? '' : protcomp_info($p)),
				   '<p>', sequence_group($p),
				   '<p>', aliases_group($p),
				   '<p>', features_group($p),
				   '<p>', homologs_group($p),
				  );
} catch Unison::Exception with {
  $p->die_with_exception(shift);
};


exit(0);


############################################################################

sub protcomp_info ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my $sql = qq/select loc,method from v_psprotcomp_reliable where pseq_id=$v->{pseq_id}/;
  my $hr = $u->selectrow_hashref($sql);
  return 'no prediction' unless defined $hr;
  return "$hr->{loc} by $hr->{method}";
}


sub sequence_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my $seq = $u->get_sequence_by_pseq_id($v->{pseq_id});
  my $wrapped_seq = $seq;
  $wrapped_seq =~ s/.{60}/$&\n/g;

  $p->group(sprintf("Sequence (%d&nbsp;AA)", length($seq)),
			"<br><a href=\"get_fasta.pl?pseq_id=$v->{pseq_id}\">download this sequence</a> in FASTA format",
			'<pre>', 
			'&gt;Unison:', $v->{pseq_id}, ' ', $u->best_alias($v->{pseq_id}), "\n",
			$wrapped_seq,
			'</pre>',
			)
}


sub aliases_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my $sql = qq/select origin,alias,descr from v_current_annotations
			 where pseq_id=$v->{pseq_id} AND ann_pref<=10000/;
  my $ar = $u->selectall_arrayref($sql);
  do { $_->[1] = alias_link($_->[1],$_->[0]) } for @$ar;
  my @f = qw( origin alias description );

  $p->group(sprintf('%s (%d)',
					$p->tooltip('Aliases', 'Unison stores sequences
						   non-redundantly from many sources. Aliases are
						   all of the known names for this exact
						   sequence.'),
					$#$ar+1),
			Unison::WWW::Table::render(\@f,$ar),
			'These are the aliases from the most reliable sources only; see also ',
			'<a href="pseq_paliases.pl?pseq_id=', $v->{pseq_id}, '">other aliases</a>'
		   );
}


sub homologene_link {
  sprintf('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene&term=%s">%s</a>',
		  $_[0],$_[0]);
}

sub homologs_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my @col_headings = ('gene', 'pseq_id', 'species', 'best annotation');

  my @tax_ids = map {$$_[0]} @{$u->selectall_arrayref("SELECT
  	DISTINCT tax_id FROM palias WHERE pseq_id=$v->{pseq_id} AND tax_id IS NOT NULL")};


  if (not @tax_ids) {
	# There are no tax_ids associated with this sequence.
	my $sql_h = "select t_gene_symbol, t_pseq_id, tax_id2gs(t_tax_id), best_annotation(t_pseq_id)
  	 from v_homologene where q_pseq_id=$v->{pseq_id} order by 1,3";
	my $hr = $u->selectall_arrayref($sql_h);
	do { $_->[0] = homologene_link($_->[0]) } for @$hr;
	do { $_->[1] = pseq_summary_link($_->[1],$_->[1]) } for @$hr;

	return 
	  $p->group( ('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene">Homologene</a>'
				  . $p->tooltip(' ?',
								"Homologous sequences as determined by NCBI's Homologene project")),

				 '<table width="100%">',
				 '<tr><td style="background: yellow"><b>', $#$hr+1, ' Homologs</b> ',
				 sprintf('There are no taxonomic identifiers associated with this sequence. The
				following are predicted and known homologs (paralogs and orthologs) of this
				sequence:'),
				 '</td></tr>',
				 '<tr><td>', Unison::WWW::Table::render(\@col_headings,$hr), '</td></tr>',
				 '</table>',
				 );
  }


  # since we know this sequence's tax_ids (possibly plural!), we can break
  # the homologs down into para- and orthologs.  Orthologs are selected
  # only from @ortho_gs genus-species.
  my @ortho_gs = qw/HUMAN MOUSE RAT CAEEL DROME BOVIN BRARE RAT YEAST/;
  my $ortho_gs = join(',', map { "gs2tax_id('$_')" } @ortho_gs);

  my $tax_ids = join(',',@tax_ids);
  my @gs = map {$$_[0]} @{$u->selectall_arrayref("SELECT gs from tax.spspec where tax_id in ($tax_ids)")};


  # paralogs:
  my $sql_p = "select t_gene_symbol, t_pseq_id, tax_id2gs(t_tax_id), best_annotation(t_pseq_id)
  	 from v_homologene_paralogs where q_pseq_id=$v->{pseq_id} order by 1,3";
  my $pr = $u->selectall_arrayref($sql_p);
  do { $_->[0] = homologene_link($_->[0]) } for @$pr;
  do { $_->[1] = pseq_summary_link($_->[1],$_->[1]) } for @$pr;

  # orthologs:
  my $sql_o = "select t_gene_symbol, t_pseq_id, tax_id2gs(t_tax_id), best_annotation(t_pseq_id)
  	from v_homologene_orthologs where q_pseq_id=$v->{pseq_id} order by 1,3";
  my $or = $u->selectall_arrayref("$sql_o");
  do { $_->[0] = homologene_link($_->[0]) } for @$or;
  do { $_->[1] = pseq_summary_link($_->[1],$_->[1]) } for @$or;

  $p->group( ('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene">Homologene</a>'
			  . $p->tooltip(' ?',
							"Homologous sequences as determined by NCBI's Homologene project")),

			 '<table width="100%">',
			 '<tr><td style="background: yellow"><b>', $#$pr+1, ' Paralogs</b> ',
			 sprintf('This sequence occurs in %d specie%s (%s). The
				following are predicted and known paralogs of this
				sequence:', $#gs+1, ($#gs+1>1?'s':''), join(',',@gs)),
			 '</td></tr>',
			 '<tr><td>', Unison::WWW::Table::render(\@col_headings,$pr), '</td></tr>',
			 '</table>',

			'<hr>',
			 '<table width="100%">',
			 '<tr><td style="background: yellow"><b>', $#$or+1, ' Orthologs</b> ',
			sprintf("The following are predicted or known orthologs of
            this sequence from %s", join(',',@ortho_gs)),
			 '</td></tr>',
			 '<tr><td>', Unison::WWW::Table::render(\@col_headings,$or), '</td></tr>',
			 '</table>',
		   );
}





sub features_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my $imagemap = '';
  my ($png_fh, $png_fn, $png_urn) = $p->tempfile(SUFFIX => '.png');
  my %opts = (%Unison::Utilities::pseq_features::opts, %$v);
  $opts{features}{$_}++ foreach qw(ssp_psipred signalp hmm );

  my $panel = Unison::Utilities::pseq_features::pseq_features_panel($u,%opts);
  
  # write the png to the temp file
  $png_fh->print( $panel->gd()->png() );
  $png_fh->close();
  
  # assemble the imagemap as a string
  foreach my $box ( $panel->boxes() ) {
	my ($feature, $x1, $y1, $x2, $y2) = @$box;
	my $attr = $feature->{attributes};
	next unless defined $attr;				# if no tooltip or href, then no need for map
	$imagemap .= sprintf("<AREA SHAPE=\"RECT\" COORDS=\"%d,%d,%d,%d\" %s %s>\n",
						 $x1,$y1,$x2,$y2,
						 ($attr->{tooltip} ? "TOOLTIP=\"$attr->{tooltip}\"" : ''),
						 ($attr->{href} ? "HREF=\"$attr->{href}\"" : '') );
  }

  $p->group($p->tooltip('Features','a selection of precomputed results for this sequence.'),
			"<center><img src=\"$png_urn\" usemap=\"#FEATURE_MAP\"></center>",
			"\n<MAP NAME=\"FEATURE_MAP\">\n", $imagemap, "</MAP>\n",
			'See also: <a href="pseq_features.pl?pseq_id=', $v->{pseq_id}, '">a summary of all features</a>',
			' and <a href="pseq_history.pl?pseq_id=', $v->{pseq_id}, '">run history</a>'
		   );
}
