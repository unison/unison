#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();


my %cv = %{ $u->selectall_hashref("select cv_id,name,descr,sql from canned_views",
								  'cv_id') };
my @cv = sort {$a<=>$b} keys %cv;
my %cvlabels = map {$_ => sprintf("%s (view %d)",$cv{$_}->{name}, $_)} @cv;

my %coldescr = (
				'pseq_id' => 'Unison unique sequence identifier',
				'#TM' => 'number of transmembrane domains',
				'pat' => 'is this (exact) sequence patented?',
				'pat98' => 'is this sequence within 98% of a patented
                            sequence? (not including the sequence itself)',
				'eval' => 'HMM expectation value',
				'best_annotation' => 'Best annotations are
					   a guess about the most informative and reliable
					   annotation for this sequence from all source
					   databases.'
			   );


print $p->render('Browse Unison Views',

				 $p->warn('Canned queries on this page may be
				 computationally expensive and take several minutes to
				 complete. Please be patient and click vroom! only once.'),

				 $p->start_form(-method => 'GET'),
				 "show sequences in view ",
				 $p->popup_menu(-name=>'cv_id',
								-values => \@cv,
								-labels => \%cvlabels,
								-default => "$v->{cv_id}"),
				 $p->submit(-value=>'vroom!'),
				 $p->end_form(), "\n",

				 do_search($p)
				);




sub do_search {
  my $p = shift;
  my $v = $p->Vars();
  return '' unless (defined $v->{cv_id} and $v->{cv_id} ne '');

  my $sql = $cv{$v->{cv_id}}->{sql};
  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  my @f = map {$p->tooltip($_,$coldescr{$_})} @{ $sth->{NAME} };

  foreach my $row (@$ar) {
	$row->[0] = "<a href=\"pseq_summary.pl?pseq_id=$row->[0]\">$row->[0]</a>";
	$row->[2] = $row->[2] ? 'yes' : '';
	$row->[3] = $row->[3] ? 'yes' : '';
  }

  return( "<hr>\n",
		  $p->group(sprintf("%s; %d rows",$cv{$v->{cv_id}}->{name}, $#$ar+1),
					Unison::WWW::Table::render(\@f,$ar)),
		  $p->sql($sql)
		);
  }
