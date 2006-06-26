#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->add_footer_lines('$Id: pseq_patents.pl,v 1.17 2005/12/07 23:21:03 rkh Exp $ ');

if ($u->is_public()) {
  $p->die('Patents not available.', <<EOT);
Sorry, patents are not part of the public Unison release. We load
patent data from Derwent Geneseq, and the tools do this yourself are
part of the Unison source code distribution.
EOT
}

$v->{pct_ident} = 98 unless exists $v->{pct_ident};
$v->{pct_coverage} = 98 unless exists $v->{pct_coverage};
$v->{pseq_id} = $p->_infer_pseq_id(); # internal function called. Shame on me.

print $p->render("Patents 'near' Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),

				 $p->start_form(-method => 'GET'),
#								-action => $p->make_url()),

				 "show patents within ",
				 $p->popup_menu(-name=>'pct_ident',
								-values => [qw(100 99 98 97 96 95 90)],
								-default => $v->{pct_ident}),
				 " % identity and ",
				 $p->popup_menu(-name=>'pct_coverage',
								-values => [qw(100 99 98 97 96 95 90)],
								-default => $v->{pct_coverage}),
				 " % coverage of Unison:",
				 $p->textfield(-name => 'pseq_id',
							   -size => 8,
							   -value => $v->{pseq_id}),

				 $p->submit(-value=>'submit'),
				 $p->end_form(), "\n",

				 do_search($p)
				);


sub do_search {
  my $p = shift;
  my $v = $p->Vars();
  return '' unless (defined $v->{pseq_id} and $v->{pseq_id} ne '');

  # substring(AO.descr,'\\\\[PA:\\\\s+\\\\([^\\\\)]+\\\\)\\\\s+([^\\\\s\\\\]]+)') as patent_authority,
  my $sql = <<EOSQL;
SELECT
	X1.*,
	origin_alias_fmt(O.origin,AO.alias),
	T.latin as species,
	substring(AO.descr,'\\\\[DT: (\\\\S+)')::date as patent_date,
	substring(AO.descr,'\\\\[PA:\\\\s+\\\\([^\\\\)]+\\\\)\\\\s+([\\\\w\\\\d\\\\s\\\\.]+)') as patent_authority,
	AO.descr
FROM (SELECT t_pseq_id AS pseq_id,len,pct_ident::smallint,pct_coverage::smallint
	  FROM papseq_v
	  WHERE q_pseq_id=$v->{pseq_id}
		AND pct_ident>=$v->{pct_ident}
		AND pct_coverage>=$v->{pct_coverage}
	  UNION
	  SELECT pseq_id,len,100,100
	  FROM pseq
	  WHERE pseq_id=$v->{pseq_id}
  	) X1
JOIN pseqalias SA on X1.pseq_id=SA.pseq_id
JOIN paliasorigin AO on	AO.palias_id=SA.palias_id
JOIN origin O on O.origin_id=AO.origin_id
JOIN spspec T on AO.tax_id=T.tax_id
WHERE SA.is_current=true
  AND AO.origin_id=origin_id('Geneseq')
ORDER BY pct_coverage desc,pct_ident desc,patent_date,patent_authority,alias
EOSQL

  my $ar = $u->selectall_arrayref($sql);
  my @f = qw( pseq_id len %IDE %COV alias species date authority description );
  return( "<hr>\n",
		  $p->group("Patent Results",
					Unison::WWW::Table::render(\@f,$ar)),
		  $p->sql($sql)
		);
  }
