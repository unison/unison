#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page();
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render("Sequence lookup by alias"
				 . (defined $v->{alias} ? ": $v->{alias}" : ''),

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
  my @pids = $u->get_pseq_id_from_alias( $q );

  if ($#pids == -1) {
	return( '<b>No results returned</b>'
			. '<br>NOTE: Short regexp queries are silently ignored.');
  }

  if ($#pids >= 100) {
	return('<b>Too many results returned (' .($#pids+1) 
		   .'); please narrow your query (max is 100)</b>');
  }

  my $sth = $u->prepare('select best_oad(?)');
  my @ar = map { [$_, $u->selectrow_array($sth,undef,$_) ] } @pids;
  my @fields = ( 'pseq_id', 'origin:alias (description)' );
  my $ar = \@ar;
  for(my $i=0; $i<=$#$ar; $i++) {
	$ar->[$i][0] = sprintf('<a href="pseq_summary.pl?pseq_id=%d">%d</a>',
						   $ar->[$i][0],$ar->[$i][0]);
  }

  return $p->group(sprintf("%d results for %s",$#$ar+1,$q),
				   Unison::WWW::Table::render(\@fields,$ar));
}
