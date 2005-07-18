#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$v->{ident} = 98 unless exists $v->{ident};

$p->add_footer_lines('$Id: pseq_patents.pl,v 1.11 2005/07/18 20:44:55 rkh Exp $ ');


print $p->render("Patents 'near' Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),

				 $p->start_form(-method => 'GET'),
#								-action => $p->make_url()),

				 "show patents within ",
				 $p->popup_menu(-name=>'ident',
								-values => [qw(100 99 98 97 96 95 90 85)],
								-default => 100),
				 " % identity of Unison:",
				 $p->textfield(-name => 'pseq_id',
							   -size => 8,
							   -value => $v->{pseq_id}),

				 $p->submit(-value=>'vroom!'),
				 $p->end_form(), "\n",

				 do_search($p)
				);


sub do_search {
  my $p = shift;
  my $v = $p->Vars();
  return '' unless (defined $v->{pseq_id} and $v->{pseq_id} ne '');

  my $sql = <<EOSQL;
SELECT X1.*,O.origin,AO.alias,AO.descr
FROM (SELECT t_pseq_id AS pseq_id,len,pct_ident
	  FROM v_papseq
	  WHERE q_pseq_id=$v->{pseq_id}
	  UNION
	  SELECT pseq_id,len,100
	  FROM pseq
	  WHERE pseq_id=$v->{pseq_id}) X1
JOIN pseqalias SA on X1.pseq_id=SA.pseq_id
JOIN paliasorigin AO on	AO.palias_id=SA.palias_id
JOIN porigin O on O.porigin_id=AO.porigin_id
WHERE X1.pct_ident>=$v->{ident}
  AND SA.iscurrent=true
  AND AO.porigin_id=porigin_id('geneseq')
ORDER BY X1.len desc,AO.alias
EOSQL

  my $ar = $u->selectall_arrayref($sql);
  my @f = qw( pseq_id len %Id origin alias description );
  return( "<hr>\n",
		  $p->group("Patent Results",
					Unison::WWW::Table::render(\@f,$ar)),
		  $p->sql($sql)
		);
  }
