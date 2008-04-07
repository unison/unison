#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq",
  "$FindBin::Bin/../../perl5";

use Unison;
use Unison::Exceptions;
use Unison::SQL;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link text_wrap pseq_summary_link
							maprofile_link genengenes_link
							ncbi_gene_link ncbi_refseq_link);
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
  print $p->render( 'Sequence Set Analysis',
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


  return $p->group( 'Query',
					$p->start_form( -method => 'GET' ),
					'<table border=0 width="100%"><tr>',

					'<td style="vertical-align: top; border-right: thin dotted;" width="50%">',
					'<b>Enter protein accessions or identifiers...</b>',
					$p->textarea(-name => 'aliases', 
								 -default => $p->{aliases} || '',
								 -rows => 5,
								 -columns => 60),
					'<br>',
					$p->note('Whitespace and commas will be
					removed. Identifiers must match exactly.'),
					'</td>',

					'<td style="vertical-align: top;">',
					'<b>Select optional annotations...</b>',
					'<br>(the site of future expansion)',
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

    (SELECT chr||band
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


  FROM palias_v A
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
			   'Go',
			   'Domains',
			 );

  my @rows;
  my %alias_seen;

  foreach my $alias (@aliases) {
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
					 ? join(', ', map {maprofile_link($_)} split(/,/,$r->{probes}))
					 : ''
					),
					'NO DATA YET',
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



#TNFB_HUMAN
#$VAR1 = {
#  'alias' => 'TNFB_HUMAN'
#  'common_annotations' => 'GenenGenes:PRO21836,GenenGenes:PRO272071,GenenGenes:PRO35994,GenenGenes:PRO7,GenenGenes:PRO91831,GenenGenes:PRO91899,UniProtKB/Swiss-Prot:P01374,UniProtKB/Swiss-Prot:TNFB_HUMAN',
#  'cytoband' => '6p21.33',
#  'descr' => 'Lymphotoxin-alpha precursor (LT-alpha) (TNF-beta) (Tumor necrosis factor ligand superfamily member 1).',
#  'domain_digests' => 'SS(1-34;0.859),TM(7-29),TNF(77-205;177;6.3e-50),TNF_1(99-115)',
#  'human_locus' => '6+:31648499-31649444',
#  'origin_id' => '10052',
#  'pg_alias' => 'NP_000586.2',
#  'pg_descr' => 'lymphotoxin alpha precursor [Homo sapiens].',
#  'pg_gene_id' => '4049',
#  'probes' => '',
#  'pros' => 'PRO272071,PRO7,PRO91831,PRO91899',
#  'pseq_id' => '97',
#  'rep_alias' => 'IPI:IPI00001670.1',
#  'rep_pseq_id' => '97',
#  'unqs' => 'UNQ7',
#};






__END__


my $sql = new Unison::SQL;
$sql->columns(qw(origin alias latin descr))->tables('current_annotations_v')
  ->where("pseq_id=$v->{pseq_id}");
if ( not $p->is_public() ) {
    $sql->where("origin_id!=origin_id('Geneseq')");
}

my $ar = $u->selectall_arrayref("$sql");
my @f  = qw( origin alias latin description );

do { $_->[1] = alias_link( $_->[1], $_->[0] ) }
  for @$ar;

# break really log "words" into fragments
do { $_->[2] = text_wrap( $_->[2] ) }
  for @$ar;

print $p->render(
    "Aliases of Unison:$v->{pseq_id}",
    $p->best_annotation( $v->{pseq_id} ),
    $p->group(
        "Aliases of Unison:$v->{pseq_id}",
        Unison::WWW::Table::render( \@f, $ar )
    ),
    $p->sql($sql)
);



##  ,
## '
## </td>
## </tr>
## 
## <tr>
## <td valign="top" width="33%">
## ',
## 			'Desired Annotations',
## 			$p->checkbox(
## 						 -name    => 'a_added',
## 						 -label   => 'date sequence added',
## 						 -checked => $v->{a_added} || $defaults{a_added}
## 						),
## 			'<br>',
## 			$p->checkbox(
## 						 -name    => 'a_locus',
## 						 -label   => 'Human genomic locus',
## 						 -checked => $v->{a_locus} || $defaults{a_locus}
## 						),
## 			'<br>',
## 			$p->checkbox(
## 						 -name    => 'a_best_annotation',
## 						 -label   => '"best" annotation',
## 						 -checked => $v->{a_best_annotation} || $defaults{a_best_annotation}
## 						),
## 			'<br>',
## 			$p->checkbox(
## 						 -name    => 'a_probes',
## 						 -label   => 'microarray probes',
## 						 -checked => $v->{a_probes} || $defaults{a_probes}
## 						),
## '
## </td>
## 
## <td valign="top" width="33%">Genomic Representative Handling:
## <br><span class="note">Genomic representatives
## are sequences from reliable databases that overlap genomically with your queries</span>
## ',
## 			$p->radio_group(
## 							-name   => 'a_locus_rep',
## 							-label  => 'name of best genomic locus representative sequence',
## 							-values => [ 'no', 'yes', 'order', 'distinct' ],
## 							-labels => {
## 										'no'       => "don't display or group by represeentative",
## 										'yes'      => 'show the representative name',
## 										'order'    => 'group results by representative',
## 										'distinct' => 'group representative show only '
## 									   },
## 							-default => $v->{a_locus_rep} || $defaults{a_locus_rep},
## 							-linebreak => 'true'
## 						   ),
## '
## </td>
## <td style="vertical-align: top;">
## Genentech Annotations:
## <br>
## ',
## 			$p->checkbox(
## 						 -name    => 'a_unq',
## 						 -label   => 'UNQ',
## 						 -checked => $v->{a_unq} || $defaults{a_unq}
## 						),
## 			'<br>',
## 			$p->checkbox(
## 						 -name    => 'a_pro',
## 						 -label   => 'PRO',
## 						 -checked => $v->{a_pro} || $defaults{a_pro}
## 						),
## '
## <br>
## </td>
## </tr>
## </table>
## ',
## 			$p->submit( -value => 'submit' ),
## 			$p->end_form(),
## 		   );
## }




# 	my $sth = $u->prepare($sql_t);
# 	my @cols;
# 
# 	foreach my $alias (@aliases) {
# 	  my $ar  = $u->selectrow_hashref($sth,undef,$alias);
# 
# 	  if (not defined @cols) {
# 		@cols = @{ $sth->{NAME} };
# 	  }
# 
# 
# 	  for ( my $i = 0 ; $i <= $#cols ; $i++ ) {
# 		if ( $cols[$i] eq 'pseq_id' ) {
# 		  foreach my $row (@$ar) {
# 			$row->[$i] =
# 			  "<a href=\"pseq_summary.pl?pseq_id=$row->[$i]\">$row->[$i]</a>";
# 		  }
# 		} elsif ( $cols[$i] =~ /^pat/ ) {
# 		  foreach my $row (@$ar) {
# 			$row->[$i] = $row->[$i] ? 'yes' : '';
# 		  }
# 		} elsif ( $cols[$i] =~ /^probes/ ) {
# 		  foreach my $row (@$ar) {
# 			next unless defined $row->[$i];
# 			my @elems = split( /,/, $row->[$i] );
# 			my @links;
# 			for ( my $elems_i = 0 ; $elems_i <= $#elems ; $elems_i++ ) {
# 			  my ( $chip, $probe ) =
# 				$elems[$elems_i] =~ m/(\w+):(\w+)/;
# 			  push( @links,
# 					"<a target=\"_blank\" href=\"http://research/projects/maprofile/bin/secure/maprofile.cgi?probeid=$probe\">$elems[$elems_i]</a>"
# 				  );
# 			}
# 			$row->[$i] = join( '<br>', sort @links );
# 		  }
# 		} elsif ( $cols[$i] =~ /unqs/ ) {
# 		  foreach my $row (@$ar) {
# 			next unless defined $row->[$i];
# 			my @elems = split( /,/, $row->[$i] );
# 			my @links;
# 			for ( my $elems_i = 0 ; $elems_i <= $#elems ; $elems_i++ ) {
# 			  push( @links,
# 					"<a target=\"_blank\" href=\"http://research/projects/gg/jsp/UNQ.jsp?UNQID=$elems[$elems_i]\">$elems[$elems_i]</a>"
# 				  );
# 			}
# 			$row->[$i] = join( '<br>', sort @links );
# 		  }
# 		} elsif ( $cols[$i] =~ /pros/ ) {
# 		  foreach my $row (@$ar) {
# 			next unless defined $row->[$i];
# 			my @elems = split( /,/, $row->[$i] );
# 			my @links;
# 			for ( my $elems_i = 0 ; $elems_i <= $#elems ; $elems_i++ ) {
# 			  push( @links,
# 					"<a target=\"_blank\" href=\"http://research/projects/gg/jsp/PRO.jsp?PROID=$elems[$elems_i]\">$elems[$elems_i]</a>"
# 				  );
# 			}
# 			$row->[$i] = join( '<br>', sort @links );
# 		  }
# 		}
# 	  }
# 
# 	  my @colhdrs = @cols; #map { $p->tooltip( $_, $coldescr{$_} ) } @cols;
# 
# 	  return (
# 			  "<hr>\n",
# 			  $p->group(
# 						Unison::WWW::Table::render( \@colhdrs, $ar )
# 					   ),
# 			  $p->sql("$sql")
# 			 );
# 
# 	}
# 	catch Unison::Exception with {
# 	  $p->die(
# 			  'Timeout : The sql query took more than 4 minutes to complete.',
# 			  $p->sql($sql) )
# 		if ( $_[0] =~ /statement timeout/ );
# 	  $p->die( 'SQL Query Failed', $_[0], $p->sql($sql) );
# 	};
# 
#   }
# }


sub build_query {
  my $params = shift;

  my $sql = Unison::SQL->new();

  $sql->table('palias A')
	->columns(qw(alias origin descr pseq_id))
	->where('A.alias=?');

  $sql->join('pseq_gene_mv PG ON A.pseq_id=PG.pseq_id')
	->columns('PG.*');

  $sql->columns('pseq_locus_human(A.pseq_id)) as locus');

  $sql->columns('representative_pseq_id(A.pseq_id) as rep_pseq_id',
				'best_alias(representative_pseq_id(A.pseq_id)) as rep_alias');

  $sql->join('pseq_sst_v SST ON A.pseq_id=SST.pseq_id')
	->columns("as_set(distinct 'UNQ'||unqid) as unqs",
			  "as_set(distinct 'PRO'||proid) as pross");

  $sql->columns("(select as_set(distinct(chip||':'||probe_id)) from pseq_probe_mv P where P.pseq_id=X.pseq_id and P.params_id= $params->{pmap_params_id} and P.genasm_id=3) as probes");

  $sql->columns('domain_digests(pseq_id)');

  return $sql;
}



