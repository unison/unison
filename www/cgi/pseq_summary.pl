#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link pseq_summary_link);
use Unison::pseq_features;


sub sequence_group ($);
sub aliases_group ($);
sub homologs_group ($);
sub features_group ($);
sub mint_group($);


my $p = new Unison::WWW::Page();
my $v = $p->Vars();

$p->ensure_required_params( qw( pseq_id ) );
$p->add_footer_lines('$Id: pseq_summary.pl,v 1.23 2005/02/16 23:07:05 rkh Exp $ ');

print $p->render("Summary of Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 '<p>', sequence_group($p),
				 '<p>', aliases_group($p),
				 '<p>', homologs_group($p),
				 '<p>', features_group($p),
				 '<p>', mint_group($p),
				);

exit(0);




sub sequence_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my $seq = $u->get_sequence_by_pseq_id($v->{pseq_id});
  my $wrapped_seq = $seq;
  $wrapped_seq =~ s/.{60}/$&\n/g;

  $p->group(sprintf("Sequence (%d&nbsp;AA)", length($seq)),
			'<pre>', 
			'&gt;Unison:', $v->{pseq_id}, ' ', $u->best_alias($v->{pseq_id},1), "\n",
			$wrapped_seq,
			'</pre>',
			"<br>You may also <a href=\"get_fasta.pl?pseq_id=$v->{pseq_id}\">download</a> this sequence in FASTA format",
			)
}


sub aliases_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my $sql = qq/select O.origin,AO.alias,AO.descr from pseqalias SA
      join paliasorigin AO on AO.palias_id=SA.palias_id
      join porigin O on O.porigin_id=AO.porigin_id
      where SA.pseq_id=$v->{pseq_id} and SA.iscurrent=true and O.ann_pref<=10000
      order by O.ann_pref/;
  my $ar = $u->selectall_arrayref($sql);
  do { $_->[1] = alias_link($_->[1],$_->[0]) } for @$ar;
  my @f = qw( origin alias description );

  $p->group(sprintf('%s (%d)',
					$p->tooltip('Aliases', 'Unison stores sequences
						   non-redundantly from many sources. Aliases are
						   all of the known names for this exact
						   sequence.'),
					$#$ar+1),
			'These are the aliases from the most reliable sources only; see also ',
			'<a href="pseq_paliases.pl?pseq_id=', $v->{pseq_id}, '">other aliases</a><p>',
			Unison::WWW::Table::render(\@f,$ar));
}


sub homologene_link {
  sprintf('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene&term=%s">%s</a>',
		  $_[0],$_[0]);
}

sub homologs_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my @col_headings = qw(gene pseq_id species alias);

  my @tax_ids = map {$$_[0]} @{$u->selectall_arrayref("SELECT
  	DISTINCT tax_id FROM palias WHERE pseq_id=$v->{pseq_id} AND tax_id IS NOT NULL")};


  if (not @tax_ids) {
	# There are no tax_ids associated with this sequence.
	my $sql_h = "select gene_symbol, pseq_id2, tax_id2gs(tax_id2), best_annotation(pseq_id2)
  	 from v_homologene where pseq_id1=$v->{pseq_id} order by 1,3";
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
  my $sql_p = "select gene_symbol, pseq_id2, tax_id2gs(tax_id2), best_annotation(pseq_id2)
  	 from v_homologene_paralogs where pseq_id1=$v->{pseq_id} order by 1,3";
  my $pr = $u->selectall_arrayref($sql_p);
  do { $_->[0] = homologene_link($_->[0]) } for @$pr;
  do { $_->[1] = pseq_summary_link($_->[1],$_->[1]) } for @$pr;

  # orthologs:
  my $sql_o = "select gene_symbol, pseq_id2, tax_id2gs(tax_id2), best_annotation(pseq_id2)
  	from v_homologene_orthologs where pseq_id1=$v->{pseq_id} order by 1,3";
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
  my %opts = (%Unison::pseq_features::opts, %$v);

  my $panel = Unison::pseq_features::pseq_features_panel($u,%opts);
  
  # write the png to the temp file
  $png_fh->print( $panel->gd()->png() );
  $png_fh->close();
  
  # assemble the imagemap as a string
  foreach my $box ( $panel->boxes() ) {
	my ($feature, $x1, $y1, $x2, $y2) = @$box;
	my $attr = $feature->{attributes};
	next unless defined $attr;
	$imagemap .= sprintf('<AREA SHAPE="RECT" COORDS="%d,%d,%d,%d" TOOLTIP="%s" HREF="%s">'."\n",
						 $x1,$y1,$x2,$y2, $attr->{tooltip}||'', $attr->{href}||'');
  }

  $p->group($p->tooltip('Features','precomputed results for this
						   sequence. NOTE: Not all sequences have all
						   results precomputed -- see the History tab to
						   determine which analysis have been performed'),
						   "<center><img src=\"$png_urn\" usemap=\"#FEATURE_MAP\"></center>",
						   "\n<MAP NAME=\"FEATURE_MAP\">\n", $imagemap, "</MAP>\n");
}

sub mint_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my $sql = qq/select sprot_a, best_alias(pseq_id_a), sprot_b, pseq_id_b, best_alias(pseq_id_b), count(*)
      from v_mint
      where pseq_id_a=$v->{pseq_id} group by sprot_a, sprot_b, pseq_id_a, pseq_id_b/;

  my $ar = $u->selectall_arrayref($sql);
  do { $_->[0] = alias_link($_->[0],'Mint') } for @$ar;
  do { $_->[2] = alias_link($_->[2],'Mint') } for @$ar;
  do { $_->[3] = pseq_summary_link($_->[3],$_->[3]) } for @$ar;
  my @f = qw ( sprot_a alias_a sprot_b pseq_id_b alias_b count );
  $p->group(sprintf('%s (%d)',
					$p->tooltip('MINT', 'Molecular INTeraction database'),
					$#$ar+1),
			Unison::WWW::Table::render(\@f,$ar));
}
