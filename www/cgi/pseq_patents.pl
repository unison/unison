#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$v->{ident} = 98 unless exists $v->{ident};


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

  my $sql = qq/
	select X1.*,O.origin,AO.alias,AO.descr from (select target as
	pseq_id,len,pct_ident from v_papseq where query=$v->{pseq_id} union select
	pseq_id,len,100 from pseq where pseq_id=$v->{pseq_id}) X1 join
	pseqalias SA on X1.pseq_id=SA.pseq_id join paliasorigin AO on
	AO.palias_id=SA.palias_id join porigin O on O.porigin_id=AO.porigin_id
	where X1.pct_ident>=$v->{ident} and SA.iscurrent=true and
	AO.porigin_id=10031 order by X1.len desc
	/;
  my $ar = $u->selectall_arrayref($sql);
  my @f = qw( pseq_id len %Id origin alias description );
  return( "<hr>\n",
		  $p->group("Patent Results",
					Unison::WWW::Table::render(\@f,$ar)),
		  $p->sql($sql)
		);
  }
