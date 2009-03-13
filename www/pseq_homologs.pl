#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link pseq_summary_link homologene_link);
use Unison::SQL;

sub homologs_group ($);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

try {
  print $p->render(
				   "Unison:$v->{pseq_id} Homologs",
				   $p->best_annotation( $v->{pseq_id} ),
				   homologs_group($p)
				  );
} catch Unison::Exception with {
  $p->die(shift);
};


exit(0);


############################################################################
## INTERNAL FUNCTIONS

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
                undef,
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
            undef,
            "Homologous sequences as determined by NCBI's Homologene project"
          ),
        '<table class="uwtable" width="100%">',
        '<tr class="highlighted"><td><b>',
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
        '<tr class="highlighted"><td><b>',
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

