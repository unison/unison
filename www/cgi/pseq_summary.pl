#!/usr/bin/env perl

use strict;
use warnings;
use lib '/home/rkh/csb-db/unison/perl5';
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utils qw(alias_link pseq_summary_link);
use Unison::pseq_features;
use File::Temp qw(tempfile);


sub sequence_group ($);
sub aliases_group ($);
sub homologs_group ($);
sub features_group ($);


my $p = new Unison::WWW::Page();
my $v = $p->Vars();

$p->ensure_required_params( qw( pseq_id ) );

print $p->render("Summary of Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 '<p>', sequence_group($p),
				 '<p>', aliases_group($p),
				 '<p>', homologs_group($p),
				 '<p>', features_group($p),
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
			'</pre>' )
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


sub homologs_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my @tax_ids = map {$$_[0]} @{$u->selectall_arrayref("SELECT
  	DISTINCT tax_id FROM palias WHERE pseq_id=$v->{pseq_id} AND tax_id IS NOT NULL")};
  my $tax_ids = join(',',@tax_ids);
  my @gs = map {$$_[0]} @{$u->selectall_arrayref("SELECT gs from tax.spspec where tax_id in ($tax_ids)")};

  my @ortho_gs = qw/HUMAN MOUSE RAT CAEEL DROME BOVIN BRARE RAT YEAST/;
  my $ortho_gs = join(',', map { "gs2tax_id('$_')" } @ortho_gs);

  my @col_headings = qw(gene pseq_id alias genus/species);


  # paralogs:
  my $sql_p = "select gene_symbol, pseq_id2, best_annotation(pseq_id2),
  	tax_id2gs(tax_id2) from v_homologene_paralogs where pseq_id1=$v->{pseq_id} order by 1,4";
  my $pr = $u->selectall_arrayref($sql_p);
  do { $_->[0] = sprintf('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene&term=%s&cmd=search">%s</a>',$_->[0],$_->[0]) } for @$pr;
  do { $_->[1] = pseq_summary_link($_->[1],$_->[1]) } for @$pr;

  # orthologs:
  my $sql_o = "select gene_symbol, pseq_id2, best_annotation(pseq_id2),
  	tax_id2gs(tax_id2) from v_homologene_orthologs where pseq_id1=$v->{pseq_id} order by 1,4";
  my $or = $u->selectall_arrayref("$sql_o");
  do { $_->[0] = sprintf('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene&term=%s&cmd=search">%s</a>',$_->[0],$_->[0]) } for @$or;
  do { $_->[1] = pseq_summary_link($_->[1],$_->[1]) } for @$or;

  $p->group( ('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene">Homologene</a>'
			  . $p->tooltip(' ?',
							"Homologous sequences as determined by NCBI's Homologene project")),

			 '<table width="100%">',
			 '<tr><td style="background: yellow"><b>Paralogs</b> ',
			 sprintf('This sequence occurs in %d specie%s (%s). The
				following are predicted and known paralogs of this
				sequence:', $#gs+1, ($#gs+1>1?'s':''), join(',',@gs)),
			 '</td></tr>',
			 '<tr><td>', Unison::WWW::Table::render(\@col_headings,$pr), '</td></tr>',
			 '</table>',

			'<hr>',
			 '<table width="100%">',
			 '<tr><td style="background: yellow"><b>Orthologs</b> ',
			sprintf("The following are predicted or known orthologs of
            this sequence from %s", join(',',@ortho_gs)),
			 '</td></tr>',
			 '<tr><td>', Unison::WWW::Table::render(\@col_headings,$or), '</td></tr>',
			 '</table>',


#			'<hr>',
#			$p->sql("$sql_p"),
#			$p->sql("$sql_o")
		   );
}


sub features_group ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my ($png_fh, $png_fn) = File::Temp::tempfile(DIR => "$ENV{'DOCUMENT_ROOT'}/tmp/pseq-features/",
											   SUFFIX => '.png' );
  my ($urn) = $png_fn =~ m%^$ENV{'DOCUMENT_ROOT'}(.+)%;
  $png_fh->print( $u->features_graphic($v->{pseq_id}) );
  $png_fh->close( );

  $p->group($p->tooltip('Features','precomputed results for this
						   sequence. NOTE: Not all sequences have all
						   results precomputed -- see the History tab to
						   determine which analysis have been performed'),
			"<center><img src=\"$urn\"></center>")
}
