#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;
use Data::Dumper;

my (@db_pri) = ('GenenGenes', sort( 'Swiss-Prot', 'ProAnno v1', 'Incyte',
						  'Proteome', 'RefSeq') );
my (@db_sec) = ( 'Curagen', 'Geneseq', 'Ensembl/Human', , 'FANTOM' );


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->add_footer_lines('$Id: search_by_properties.pl,v 1.9 2005/06/18 00:16:46 rkh Exp $ ');


if (not exists $v->{submit}) {
  print $p->render("Property Mining",
				   '$Id: search_by_properties.pl,v 1.9 2005/06/18 00:16:46 rkh Exp $',
				   $p->warn('This page is a work-in-progress. ' .
							'Gnarly searches may take several minutes!'),
				   spit_form($p));
  exit(0);
}



###########################################################
## build SQL statement

my $s_sql = Unison::SQL->new()
  ->table('palias A')
  ->columns('distinct A.pseq_id');

if (exists $v->{o_sel}) {
  my @porigin_id = map { $u->porigin_porigin_id_by_origin($_) } 
	$p->param('o_sel');
  $s_sql->where( 'A.porigin_id in ('
			   . join(',', sort {$a<=>$b} @porigin_id) 
			   . ')' );
}

if (exists $v->{r_species}) {
  $s_sql->where("A.tax_id=$v->{r_species_sel}");
}

if (exists $v->{r_age} or exists $v->{r_len}) {
  $s_sql->join('pseq Q on A.pseq_id=Q.pseq_id');
  if (exists $v->{r_age}) {
	$s_sql->where("Q.added>=now()-'$v->{r_age_sel}'::interval");
  }
  if (exists $v->{r_len_sel}) {
	$s_sql->where("Q.len>=$v->{r_len_min} and Q.len<=$v->{r_len_max}");
  }
}

if (exists $v->{r_sigp}) {
  $s_sql->join('pseqprop P on A.pseq_id=P.pseq_id')
	->where("P.sigpredict>=$v->{r_sigp_sel}::real");
}

if (exists $v->{al_hmm}) {
  $s_sql->join('pahmm H on A.pseq_id=H.pseq_id')
	->where("H.eval<=$v->{al_hmm_eval}")
	->join('pmsm_pmhmm HM on H.pmodel_id=HM.pmodel_id')
	->where("HM.pmodelset_id=$v->{al_ms_sel}");
}

if (exists $v->{al_papssm}) {
  $s_sql->join('papssm P on A.pseq_id=P.pseq_id')
	->where("P.eval<=$v->{al_pssm_eval}")
	->join('pmsm_pmpssm PM on P.pmodel_id=PM.pmodel_id')
	->where("PM.pmodelset_id=$v->{al_ms_sel}");
}

if (exists $v->{al_prospect2}) {
  my @models = map { $_->[0] } @{ $u->selectall_arrayref( "select pmodel_id from pmsm_prospect2 where pmodelset_id=$v->{al_ms_sel}" ) };
  @models = sort { $a<=>$b } @models;
  $s_sql->join('paprospect2 T on A.pseq_id=T.pseq_id')
	->where("T.svm>=$v->{al_prospect2_svm}::real")
	->where("T.params_id=$v->{al_prospect2_params_id}")
	->where('T.pmodel_id in (' . join(',',@models) . ')');

#  $s_sql->join('paprospect2 T on A.pseq_id=T.pseq_id')
#	->where("T.svm>=$v->{al_prospect2_svm}::real")
#	->join('pmsm_prospect2 PT on T.pmodel_id=PT.pmodel_id')
#	->where("PT.pmodelset_id=$v->{al_ms_sel}");
}


my $sql = "$s_sql";
if (exists $v->{x_set}) {
  $sql .= " except select pseq_id from pseqset where pset_id=$v->{x_set_sel}";
}

$sql = "select X1.pseq_id,best_annotation(X1.pseq_id) from ($sql) X1";



my $results = "<p>(SQL only requested -- go back and hit vroom! for results)\n";
if ($v->{submit} !~ m/^sql/) {
  my @fields = ( 'pseq_id', 'origin:alias (description)' );
  my $ar;
  $ar = $u->selectall_arrayref($sql);
  for(my $i=0; $i<=$#$ar; $i++) {
	$ar->[$i][0] = sprintf('<a href="pseq_summary.pl?pseq_id=%d">%d</a>',
						   $ar->[$i][0],$ar->[$i][0]);
  }
  $results = $p->group(sprintf("%d results",$#$ar+1),
					   Unison::WWW::Table::render(\@fields,$ar));
}


print $p->render("Gnarly Search Results",
				 '$Id: search_by_properties.pl,v 1.9 2005/06/18 00:16:46 rkh Exp $',
				 $results,
				 $p->sql( $sql ));





exit(0);


sub spit_form {
  my $p = shift;
  my $r;

  my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" }
	@{ $u->selectall_arrayref('select * from pmodelset') };
  my %go = map { $_->[0] => "$_->[1] (GO:$_->[0])" } 
	@{ $u->selectall_arrayref("select go_id,alias from gong.alias 
                               where alias ilike '%necrosis%'") };
  my %xs = map { $_->[0] => "$_->[1] (set $_->[0])" } 
	@{ $u->selectall_arrayref("select pset_id,name from pset") }; 
  my %sl = map { $_->[0] => "$_->[1] ($_->[2])" } 
	@{ $u->selectall_arrayref("select tax_id,common,latin from tax.spspec
                               where tax_id in (7955,9606,10090,10116,10117,
                                                9615,9685,7227)
                               order by gs") }; 

  join('',
	   $p->start_form(-method=>'GET'),

	   '<table border=0 width="100%">',

	   '<!-- ORIGINS -->',
	   '<tr class="tablesep"><td colspan=2>Select non-redundant sequences from:</td></tr>',
	   '<tr><td>&nbsp;</td><td>',
	   _tablify(5, $p->checkbox_group(-name => 'o_sel', 
									  -values => [@db_pri, @db_sec],
									  -default => \@db_pri )),
	   '</td></tr>',


	   '<!-- RESTRICTIONS -->',
	   '<tr class="tablesep"><td colspan=2>which meet these restrictions:</td></tr>',
	   '<tr><td>&nbsp;</td><td>',
	   $p->checkbox(-name => 'r_species',
					-label => 'species is ',
					-checked => 1),
	   $p->popup_menu(-name => 'r_species_sel',
					  -values => [sort keys %sl],
					  -labels => \%sl,
					  -default => 9606
					 ),
	   '<br>NOTE: selecting species filtering will eliminate sequences whose species is not explicity denoted',

	   '<br>',
	   $p->checkbox(-name => 'r_age',
					-label => 'fewer than ',
					-checked => 0),
	   $p->popup_menu(-name=>'r_age_sel',
					  -values=>[qw(7d 14d 30d 60d 90d 180d 365d)],
					  -default=>'30d'),
	   ' old',
	   '<br>',
	   $p->checkbox(-name => 'r_len',
					-label => 'length is between ',
					-checked => 1),
	   $p->textfield(-name => 'r_len_min', -size => 5, -value => 100),
	   ' and ',
	   $p->textfield(-name => 'r_len_max', -size => 5, -value => 400 ),
	   ' AA',
	   '<br>',
	   $p->checkbox(-name => 'r_sigp',
					-label => 'have signal sequence with sigp >= ',
					-checked => 1),
	   $p->popup_menu(-name => 'r_sigp_sel',
					  -values => [qw(0.9 0.8 0.7 0.6 0.5 0.4)],
					  -default => 0.6),
	   '</td></tr>',


	   '<!-- ALIGNMENTS -->',
	   '<tr class="tablesep"><td colspan=2>and align</td></tr>',
	   '<tr><td>&nbsp;</td><td>',
	   $p->checkbox(-name => 'al_hmm',
					-label => 'by HMM/Pfam ',
					-checked => 0),
	   ' with eval <= ',
	   $p->popup_menu(-name => 'al_hmm_eval',
					  -values => [qw(1e-40 1e-30 1e-20 1e-10 1 5 10)],
					  -default => '1e-10'),
	   '<br>',
	   $p->checkbox(-name => 'al_pssm',
					-label => 'by PSI-BLAST/Structure Based Profiles ',
					-checked => 0),
	   ' with eval <= ',
	   $p->popup_menu(-name => 'al_pssm_eval',
					  -values => [qw(1e-40 1e-30 1e-20 1e-10 1 5 10)],
					  -default => '1e-10'),
	   '<br>',
	   $p->checkbox(-name => 'al_prospect2',
					-label => 'by Prospect2 Profile-Profile/Threading ',
					-checked => 1),
	   ' with svm >= ',
	   $p->popup_menu(-name => 'al_prospect2_svm',
					  -values => [qw(13 12 11 10 9 8 7 6 5)],
					  -default => '9'),
	   ' using parameter set ',
	   $p->popup_menu(-name => 'al_prospect2_params_id',
					  -values => [qw(1)],
					  -default => '1'),
	   '<hr>',
	   $p->checkbox(-name => 'al_ms',
					-label => 'to Genentech-curated sets of ',
					-checked => 0),
	   $p->popup_menu(-name => 'al_ms_sel',
					  -values => [keys %ms],
					  -labels => \%ms,
					  -default => 2),
	   ' models',
	   '<br>  COMING SOON!...<br>',
	   $p->checkbox(-name => 'al_go',
					-label => 'to models associated with ',
					-checked => 0),
	   $p->popup_menu(-name => 'al_go_sel',
					  -values => [sort keys %go],
					  -labels => \%go,
					  -default => 5164),
	   ' in GeneOntology',
	   '</td></tr>',


	   '<!-- EXCEPTIONS -->',
	   '<tr class="tablesep"><td colspan=2>EXCEPT sequences:</td></tr>',
	   '<tr><td>&nbsp;</td><td>',
	   $p->checkbox(-name => 'x_set',
					-label => 'in set ',
					-checked => 0),
	   $p->popup_menu(-name => 'x_set_sel',
					  -values => [sort keys %xs],
					  -labels => \%xs,
					  -default => 5),
	   '</td></tr>',



	   "</table>",

	   $p->submit(-name=>'submit', -value=>'vroom!'),
	   $p->submit(-name=>'submit', -value=>'sql only'),
	   $p->end_form(), "\n",
	  );
}



sub _tablify {
  ## produce a $c-column table of @items
  my ($c,@items) = @_;
  my $rv = '<table width="80%">' . "\n";
  push(@items, '&nbsp;') while ( ($#items+1) % $c != 0 );
  while( @items ) {
	$rv .= '<tr>' 
	  . join('', map {'<td>'.$_.'</td>'} splice(@items,0,$c)) 
	  . '</tr>' 
      . "\n";
  }
  $rv .= '</table>';
  return $rv;
}



