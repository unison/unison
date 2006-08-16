#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::SQL;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->add_footer_lines('$Id: browse_views.pl,v 1.15 2006/06/26 17:36:37 rkh Exp $ ');

my %cvs = %{ $u->selectall_hashref('select cv_id,name,descr,sql from canned_views where cv_id>0',
								   'cv_id') };

print $p->render('Canned Views',
				 build_form($p),
				 do_search($p)
				);

exit(0);


######################################################################

# It would be much better to get these descriptions from the database
# view column comments...

sub do_search {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

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
				  'tm_prob' => 'TM region prediction probability',
				  'best_annotation' => 'Best annotations are
					   a guess about the most informative and reliable
					   annotation for this sequence from all source
					   databases.'
				 );

  return '' unless defined $v->{cv_id};

  my $cv = $cvs{$v->{cv_id}};

  my $s_sql = Unison::SQL->new()
	->table( "($cv->{sql}) X" )
	->columns('X.*')
	->distinct('X.pseq_id');

  if (exists $v->{r_species}) {
	$s_sql
	  ->join('palias A on X.pseq_id=A.pseq_id' )
	  ->where("A.tax_id=$v->{r_species_sel}");
  }

  if (exists $v->{r_age}) {
	$s_sql
	  ->join('pseq Q on X.pseq_id=Q.pseq_id')
	  ->where("Q.added>=now()-'$v->{r_age_sel}'::interval");
  }

  my $sth = $u->prepare( "$s_sql" );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };

  for (my $i=0; $i<=$#cols; $i++) {
	if ($cols[$i] eq 'pseq_id') {
	  foreach my $row (@$ar) {
		$row->[$i] = "<a href=\"pseq_summary.pl?pseq_id=$row->[$i]\">$row->[$i]</a>";
	  }
	} elsif ($cols[$i] =~ /^pat/) {
	  foreach my $row (@$ar) {
		$row->[$i] = $row->[$i] ? 'yes' : '';
	  }
	}
  }

  my @colhdrs = map {$p->tooltip($_,$coldescr{$_})} @cols;
  return( "<hr>\n",
		  "<b>$cv->{name} (view $cv->{cv_id})</b>: <i>$cv->{descr}</i>",
		  $p->group(sprintf("%s; %d rows",$cv->{name}, $#$ar+1),
					Unison::WWW::Table::render(\@colhdrs,$ar)),
		  $p->sql("$s_sql")
		);
}




sub build_form {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my @cvs = sort {$a<=>$b} keys %cvs;
  my %cvlabels = map {$_ => sprintf("%s (canned view %d)",$cvs{$_}->{name}, $_)} @cvs;

  my %sl = map { $_->[0] => "$_->[1] ($_->[2])" } 
	@{ $u->selectall_arrayref("select tax_id,common,latin from tax.spspec
                               where tax_id in (7955,9606,10090,10116,10117,
                                                9615,9685,7227)
                               order by gs") }; 


  return ( 
		  $p->warn('"Canned" queries on this page may be
				 computationally expensive and take several minutes to
				 complete. Please be patient and click submit only once.'),

		  $p->start_form(-method => 'GET'),
		  '<table>',

		  '<tr><td>show sequences in view</td><td>',
		  $p->popup_menu(-name=>'cv_id',
						 -values => \@cvs,
						 -labels => \%cvlabels,
						 -default => $v->{cv_id}||undef
						),
		  '</td></tr>',

		  '<tr><td colspan=2>where:</td></tr>',

		  '<tr><td>',
		  $p->checkbox(-name => 'r_species',
					   -label => 'species is',
					   -checked => $v->{r_species}||0),'</td><td>',
		  $p->popup_menu(-name => 'r_species_sel',
						 -values => [sort keys %sl],
						 -labels => \%sl,
						 -default => $v->{r_species_sel}||9606
						),
		  '</td></tr>',

		  '<tr><td>',
		  $p->checkbox(-name => 'r_age',
					   -label => 'sequence is less than',
					   -checked => 0),
		  '</td><td>',
		  $p->popup_menu(-name=>'r_age_sel',
						 -values=>[qw(7d 14d 30d 60d 90d 180d 365d)],
						 -default=>$v->{r_age_sel}||'30d'
						),
		  ' old',
		  '</td></tr>',
		  '</table>',

		  $p->submit(-value=>'submit'),
		  $p->end_form(), "\n",
		 )
};
