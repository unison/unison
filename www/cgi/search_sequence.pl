#!/usr/bin/env perl

use warnings;
use strict;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
my $min_len = 15;



if (defined $v->{query} and $v->{query} ne '') {
  $v->{query} = uc($v->{query});

  if ($v->{query} =~ m/([^A-Z0-9%+*^$\.\\])/ ) {
	$p->die('Bad query expression',
			"Your query $v->{query} contains inappropriate characters ($1)");
  }

  if (length $v->{query} < $min_len) {
	$p->die('Query too short',
			'Sequence queries are required to be at ',
			"least $min_len AA long (including wildcards)");
  }
}


print $p->render("Sequence lookup by subsequence" 
				   . (defined $v->{query} ? ": $v->{query}" : ''),

				 $p->tip('SQL wildcards (<code>%,_</code>) and regular expressions are ',
						 'permitted, but use with care!'),

				 $p->start_form(-method=>'GET'),
				 "sequence fragment: ",
				 $p->textfield(-name=>'query',
                               -default=>$v->{query},
                               -size=>50),
				 $p->submit(-value=>'vroom!'),
				 $p->end_form(), "\n",

				 (defined $v->{query} ? do_search($v->{query}) : '')
				);


sub do_search {
  my $q = shift;
  my $results;
  $q = uc($q);
  my $sql = 'select pseq_id,best_annotation(pseq_id) from pseq where seq ~ ? limit 251';

  my @fields = ( 'pseq_id', 'origin:alias (description)' );
  my $ar = $u->selectall_arrayref($sql,undef,$q);

  if ($#$ar > 250) {
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
