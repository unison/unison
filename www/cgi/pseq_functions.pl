#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq",
  "$FindBin::Bin/../../perl5";

use Unison;
use Unison::Exceptions;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link text_wrap alias_pubmed_link);
use Unison::SQL;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

try {
  print $p->render(
				   "Unison:$v->{pseq_id} Functions",
				   $p->best_annotation( $v->{pseq_id} ),
				   go_group($p),
				   generif_group($p),
				  );
} catch Unison::Exception with {
  $p->die(shift);
};


exit(0);


############################################################################
## INTERNAL FUNCTIONS

sub go_group {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();
  my $go_table = '<i>no data</i>';
  my %go_evidence_explanations = (
								  IDA => 'Inferred from Direct Assay',
								  IPI => 'Inferred from Physical Interaction',
								  IMP => 'Inferred from Mutant Phenotype',
								  IGI => 'Inferred from Genetic Interaction',
								  IEP => 'Inferred from Expression Pattern',
								  ISS => 'Inferred from Sequence or Structural Similarity (Computational Analysis)',
								  IGC => 'Inferred from Genomic Context (Computational Analysis)',
								  RCA => 'Inferred from Reviewed Computational Analysis',
								  TAS => 'Traceable Author Statement',
								  NAS => 'Non-traceable Author Statement',
								  IC => 'Inferred by Curator',
								  ND => 'No biological Data available (Curator Statement)',
								  IEA => 'Inferred from Automatic Electronic Annotation',
								  NR => 'Not Recorded',
								 );


  my @GOs = $u->entrez_go_annotations( $v->{pseq_id} );
  @GOs = grep { $_->{evidence} =~ m/IDA|IPI|IPM|IGI|IEP|TAS|IC|ISS|IGC|RCA/ } @GOs;

  if (@GOs) {
	$go_table = '<table class="summary">';
	foreach my $cat (qw(Function Process Component)) {
	  my @go_trs;
	  foreach my $e (grep { $_->{category} eq $cat } @GOs) {
		my $pm_links = join(',', 
							map { alias_pubmed_link($_) }
							split( /\|/ , $e->{pubmed_id}) );
		push(@go_trs,
			 sprintf("%s (%s; %s; PubMed:%s)",
					 $e->{term},
					 (exists $go_evidence_explanations{$e->{evidence}}
					  ? $p->tooltip($e->{evidence},$go_evidence_explanations{$e->{evidence}})
					  : $e->{evidence}),
					 $e->{go_id},
					 $pm_links || '<i>no references</i>')
			);
	  }
	  if (@go_trs) {
		$go_table .= sprintf('<tr> <th><div>%s</div></th> <td>%s</td> </tr>',
							 $cat,
							 join('<br>',@go_trs)
							);
	  }
	}
	$go_table .= '</table>';
  }

  $p->group('Go Annotations',
			$go_table);
}


sub generif_group {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my $sql = new Unison::SQL;
  $sql->columns(qw(last_update::date generif pubmed_ids))
	->tables('pseq_generif_v')
	  ->where("q_pseq_id=$v->{pseq_id}",
			  "generif !~ 'HuGENet'")		# these are useless
		->order("last_update desc");

  my $sql_s = "$sql";
  $sql_s =~ s/^SELECT/SELECT DISTINCT/i;	# such a hack

  my $ar = $u->selectall_arrayref($sql_s);
  my @f  = qw(last_update generif pubmed_ids);

  for (@$ar) {
	$_->[2] = sprintf('<a href="http://www.ncbi.nlm.nih.gov/pubmed/%s">%s</a>',
					  $_->[2],$_->[2]);
  }

  $p->group(
			"NCBI GeneRIFs &amp; References",
			Unison::WWW::Table::render( ['Last Update','Function','PubMed'], $ar )
		   );
}

