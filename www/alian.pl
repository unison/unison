#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::SQL;
use Unison::pseq;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::WWW::utilities qw(
							   alias_link genengenes_link maprofile_link
							   ncbi_gene_link ncbi_refseq_link
							   pseq_functions_link pseq_summary_link
							   text_wrap
							);
use Data::Dumper;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my %defaults = (
				r_species         => 0,
				r_species_sel     => 9606,
				r_age             => 0,
				r_age_sel         => 30,
				a_added           => 0,
				a_locus           => 1,
				a_best_annotation => 1,
				a_probes          => 0,
				a_locus_rep       => 1,
				a_unq             => 1,
				a_pro             => 1,
				a_fam             => 0
			   );


try {
  print $p->render( 'AliAn -- Alias Annotation',
					build_form($p),
					do_search($p)
				  );
} catch Unison::Exception with {
    $p->die(shift);
};

exit(0);



############################################################################
## Internals


sub build_form {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my @species = sort qw(HUMAN ECOLX CHICK HORSE PIG RABIT MOUSE RAT PANTR
  YEAST DANRE CANFA FELCA CAEEL DROEL);
  my $cmd = sprintf('SELECT gs,latin,common FROM tax.spspec WHERE gs IN (%s)',
					join(',', (map {"'$_'"} @species) ));
  my %spinfo = %{ $u->selectall_hashref( $cmd, 'gs' ) };
  my %labels = map { $_ => sprintf("%s (%s)", $spinfo{$_}->{gs}, $spinfo{$_}->{latin}) }
	@species;
  $labels{'none'} = "none (alias much match exactly)";

  return $p->group( 'Query',
					$p->start_form( -method => 'GET' ),
					'<table border=0 width="100%"><tr>',

					'<td style="vertical-align: top;" width="50%">',
					'<b>Enter aliases.</b>',
					'<br>Alieses are identifiers, accessions, or MD5
					sequence checksums from any source database.',
					'<br>',
					$p->textarea(-name => 'aliases', 
								 -default => $p->{aliases} || '',
								 -rows => 5,
								 -columns => 60),
					'<br>',
					$p->note('Whitespace and commas will be
					removed.'),
					'</td>',

					'<td>',
					'<td style="vertical-align: top; border-left: thin dotted;">',

					'<b>Append species identifier.</b>',
					'<br>When the alias does not contain an underscore,
					append the following species:',
					'<br>',
					$p->popup_menu( -name => 'append_species',
									-values => ['none', @species],
									-default => 'none',
									-labels => \%labels,
									),
					'</td>',
					'</tr></table>',
					$p->submit( -name => 'submit',
								-value => 'submit' ),
					$p->end_form()
				  );
}


sub do_search {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my %params = (%defaults, %$v);

  return unless defined $v->{submit};

  my $sql = <<EOSQL;
SELECT DISTINCT
	A.alias,A.origin,A.descr,A.pseq_id,
    best_annotation(A.pseq_id),
	PG.alias as pg_alias,PG.descr as pg_descr,PG.gene_id as pg_gene_id,
    pseq_locus_human(A.pseq_id) as human_locus,
    representative_pseq_id(A.pseq_id) as rep_pseq_id,
    best_alias(representative_pseq_id(A.pseq_id)) as rep_alias,
    domain_digests(A.pseq_id),
    (SELECT as_set(DISTINCT 'UNQ'||unqid) FROM pseq_sst_v SST WHERE SST.pseq_id=A.pseq_id) AS unqs,
    (SELECT as_set(DISTINCT 'PRO'||proid) FROM pseq_sst_v SST WHERE SST.pseq_id=A.pseq_id) AS pros,

    (SELECT as_set(distinct chr||band)
 	   FROM pseq_cytoband_v C
	  WHERE C.pseq_id=A.pseq_id AND C.params_id=48
	) as cytoband,

	(SELECT as_set(distinct(chip||':'||probe_id))
       FROM pseq_probe_mv P
      WHERE P.pseq_id=A.pseq_id AND P.params_id=48 and P.genasm_id=3
	) as probes,

    (SELECT as_set(distinct origin_alias_fmt(origin,alias))
	   FROM current_annotations_v CA
      WHERE CA.pseq_id=A.pseq_id and ann_pref<10000
	) as common_annotations


  FROM current_annotations_v A
LEFT JOIN pseq_gene_mv PG ON A.pseq_id=PG.pseq_id AND PG.tax_id=gs2tax_id('HUMAN')
LEFT JOIN pseq_sst_v SST ON A.pseq_id=SST.pseq_id

 WHERE A.alias = ?
EOSQL

  my $sth = $u->prepare($sql);

  my @aliases = split(/[\s,]+/,$v->{aliases});

  my %missing_aliases;						# hash(aliases)
  my %duplicate_pseq_ids;					# hash(pseq_id) of arrays of aliases


  my @cols = ( 'Query',
			   'Unison pseq_id',
			   'NCBI Gene & RefSeq',
			   'GenenGenes',
			   'Cytoband',
			   'Probes',
			   'GO',
			   'Domains',
			 );

  my @rows;
  my %alias_seen;

  foreach my $alias (@aliases) {
	if ( $alias !~ m/_/ and $v->{append_species} ne 'none') {
	  $alias .= "_$v->{append_species}";
	}

	my $rv = $sth->execute($alias);
	while( my $r = $sth->fetchrow_hashref() ) {
	  $alias_seen{$alias}++;
	  push(@rows, [ join('<br>',
						 $r->{alias},
						 $r->{origin},
						 ($r->{descr}
						  ? $p->tooltip(substr($r->{descr},0,15).'...',$r->{descr})
						  : '')
						),
					$p->tooltip(pseq_summary_link($r->{pseq_id},"Unison:$r->{pseq_id}"),
								$r->{best_annotation},
								),
					join('<br>',
						 ncbi_gene_link($r->{pg_gene_id},"GeneID:$r->{pg_gene_id}"),
						 ncbi_refseq_link($r->{pg_alias},"RefSeq:$r->{pg_alias}")
						),
					join(', ', map( {genengenes_link($_)}
									split(/,/,$r->{unqs}),
									split(/,/,$r->{pros}))
						),
					$r->{cytoband} || 'N/A',
					($r->{probes}
					 ? join('<br>', map {maprofile_link($_)} split(/,/,$r->{probes}))
					 : ''
					),

					go_annotations($u,$r->{pseq_id}),

					join('<br>', split(/,/,$r->{domain_digests}))
				  ]
		   );
	}
  }

  my @aliases_unseen = grep {not exists $alias_seen{$_}} @aliases;

  $p->group("Annotation Results",
			(@aliases_unseen
			 ? $p->warn(sprintf('%d alias%s %s not found: %s',
								$#aliases_unseen+1,
								($#aliases_unseen == 0 ? ('','was') : ('es','were')),
								join(', ', sort @aliases_unseen)))
			 : ''
			),
			'<div style="font-size: 0.8em;">',
			Unison::WWW::Table::render( \@cols, \@rows ),
			'</div>'
		   );
}




sub go_annotations {
  my ($u,$q) = @_;

  my (@GOs) = $u->entrez_go_annotations( $q );
  @GOs = grep { $_->{evidence} =~ m/IDA|IPI|IPM|IGI|IEP|TAS|IC|ISS|IGC|RCA/ } @GOs;

  my $go_text = '<i>no Go data</i>';

  if (@GOs) {
	if ($#GOs+1 > 3) {
	  $go_text = pseq_functions_link($q,sprintf('See all %d functions',$#GOs+1));
	} else {
	  $go_text = join(
					  '<br>',
					  (
					   map { sprintf( "%s: %s", $_->{category}, $_->{term} ) }
					   ( sort { $a->{category} cmp $b->{category} } @GOs )
					  ),
					 );
	}
  }

  return $go_text;
}
