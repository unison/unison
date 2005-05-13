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


my %cv = %{ $u->selectall_hashref(
	'select cv_id,name,descr,sql from canned_views where cv_id>0',
 	'cv_id') };
my @cv = sort {$a<=>$b} keys %cv;
my %cvlabels = map {$_ => sprintf("%s (canned view %d)",$cv{$_}->{name}, $_)} @cv;


# It would be much better to get these descriptions from the database
# view column comments...
my %coldescr = (
				'pseq_id' => 'Unison unique sequence identifier',
				'TM' => 'number of transmembrane domains',
				'pat' => 'is this (exact) sequence patented?',
				'pat98' => 'is this sequence within 98% of a patented
                            sequence? (not including the sequence itself)',
				'eval' => 'HMM expectation value',
				'Ig' => 'start and end of the Ig domain',
				'ITIM' => 'start and end of the ITIM domain',
				'alias' => 'Unison sequence annotation',
				'gs' => 'genus and species',		
				'descr' => 'sequence description',
				'confidence' => 'TM region prediction confidence',
				'best_annotation' => 'Best annotations are
					   a guess about the most informative and reliable
					   annotation for this sequence from all source
					   databases.'
			   );


print $p->render('Browse Unison Canned Views',

				 $p->warn('"Canned" queries on this page may be
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
  my @f = @{ $sth->{NAME} };


  for(my $i=0; $i<=$#f; $i++) {
	if ($f[$i] eq 'pseq_id') {
	  foreach my $row (@$ar) {
		$row->[$i] = "<a href=\"pseq_summary.pl?pseq_id=$row->[$i]\">$row->[$i]</a>";
	  }
	}
	elsif ($f[$i] =~ /^pat/) {
	  foreach my $row (@$ar) {
		$row->[$i] = $row->[$i] ? 'yes' : '';
	  }
	}
  }


  my @colhdrs = map {$p->tooltip($_,$coldescr{$_})} @f;
  return( "<hr>\n",
		  $p->group(sprintf("%s; %d rows",$cv{$v->{cv_id}}->{name}, $#$ar+1),
					Unison::WWW::Table::render(\@colhdrs,$ar)),
		  $p->sql($sql)
		);
  }
