#!/usr/bin/env perl

use warnings;
use strict;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render("Sequence lookup by alias"
				    . (defined $v->{seq} ? ": $v->{seq}" : ''),

				 $p->tip("use % for wildcard (but it's slower)"),
				 $p->start_form(-method => 'GET',
								-action => $p->make_url()),
				 "alias: ",
				 $p->textfield(-name=>'alias',
                               -default=>$v->{alias},
                               -size=>50,
                               -maxlength=>50),
				 $p->submit(-value=>'vroom!'),
				 $p->end_form(), "\n",

				 (defined $v->{alias} ? do_search($v->{alias}) : '')
				);


sub do_search {
  my $q = shift;
  my $results;
  my $sql = 'select pseq_id,canonical_oad_fmt(origin,alias,descr) as oad from v_palias';
  if ($q =~ m/%/) {
	$sql .= " where alias ilike ?";
  } else {
	$sql .= " where alias = ?";
  }
  $sql .= ' limit 1001';

  my @fields = ( 'pseq_id', 'origin:alias (description)' );
  my $ar = $u->selectall_arrayref($sql,undef,$q);

  if ($#$ar > 1000) {
	return "<b>Too many results returned ($#$ar); please narrow your query</b>";
  }

  for(my $i=0; $i<=$#$ar; $i++) {
	$ar->[$i][0] = sprintf('<a href="pseq_summary.pl?pseq_id=%d">%d</a>',
						   $ar->[$i][0],$ar->[$i][0]);
  }

  $results = $p->group(sprintf("%d results for %s",$#$ar+1,$q),
					   Unison::WWW::Table::render(\@fields,$ar));
  $results .= $p->sql($sql);
  return $results;
}
