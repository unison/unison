#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();


$v->{pset_id} = 5 unless exists $v->{pset_id};
$v->{pmodelset_id} = 2 unless exists $v->{pmodelset_id};

my (@SP) = map { $_->[0] } @{ $u->selectall_arrayref("select pseq_id from pseqset where pset_id=$v->{pset_id}") };
my $nSP = $#SP+1;


my (@hmm_P,@hmm_TP,@hmm_FN,@hmm_UP);
my ($hmm_P,$hmm_TP,$hmm_FN,$hmm_UP) = ('','','','');

my (@pssm_P,@pssm_TP,@pssm_FN,@pssm_UP);
my ($pssm_P,$pssm_TP,$pssm_FN,$pssm_UP) = ('','','','');

my (@p2_P,@p2_TP,@p2_FN,@p2_UP);
my ($p2_P,$p2_TP,$p2_FN,$p2_UP) = ('','','','');

my %P;
my ($I_P,$I_TP,$I_FN,$I_UP) = ('','','','');
my ($U_P,$U_TP,$U_FN,$U_UP) = ('','','','');

if ($v->{submit}) {
  my (@P,$FNr,$UPr,$TPr);

  if (exists $v->{hmm}) {
	@P = _get_hmm_hits();
	$P{$_}++ for @P;
	($FNr,$UPr,$TPr) = acomm(\@SP,\@P);
	$hmm_P  = $#P+1;
	if ($nSP>0) {
	  $hmm_TP = sprintf('%d / %5.1f%%', $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
	  $hmm_FN = sprintf('%d / %5.1f%%', $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	}
	$hmm_UP = $#$UPr+1;
  }

  if (exists $v->{pssm}) {
	@P = _get_pssm_hits();
	$P{$_}++ for @P;
	($FNr,$UPr,$TPr) = acomm(\@SP,\@P);
	$pssm_P  = $#P+1;
	if ($nSP>0) {
	  $pssm_TP = sprintf('%d / %5.1f%%', $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
	  $pssm_FN = sprintf('%d / %5.1f%%', $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	}
	$pssm_UP = $#$UPr+1;
  }

  if (exists $v->{p2}) {
	@P = _get_p2_hits();
	$P{$_}++ for @P;
	($FNr,$UPr,$TPr) = acomm(\@SP,\@P);
	$p2_P  = $#P+1;
	if ($nSP>0) {
	  $p2_TP = sprintf('%d / %5.1f%%', $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
	  $p2_FN = sprintf('%d / %5.1f%%', $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	}
	$p2_UP = $#$UPr+1;
  }

  my $n = (exists $v->{hmm}?1:0) 
	+ (exists $v->{pssm}?1:0) 
	+ (exists $v->{p2}?1:0);
  my @U_P = sort keys %P;
  ($FNr,$UPr,$TPr) = acomm(\@SP,\@U_P);
  $U_P = $#P+1;
  $U_TP = $#$TPr+1;
  $U_FN = $#$FNr+1;
  $U_UP = $#$UPr+1;
  
  my @I_P = grep { $P{$_} = $n } @U_P;
  ($FNr,$UPr,$TPr) = acomm(\@SP,\@I_P);
  $I_P = $#P+1;
  $I_TP = $#$TPr+1;
  $I_FN = $#$FNr+1;
  $I_UP = $#$UPr+1;
}



my %xs = map { $_->[0] => "$_->[1] (set $_->[0])" } 
  @{ $u->selectall_arrayref("select pset_id,name from pset") }; 
my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" }
  @{ $u->selectall_arrayref('select * from pmodelset') };

print $p->render("Sequence Mining",
				 '$Id$',

				 '<p>This page allows you assess sensitivity and
				 specificity of models, methods, and parameters. Select
				 the Model Set you wish to use to select sequences, the
				 set of "known" sequences with which sensitivity and
				 specificity will be assessed, and click
				 "vroom!". Clicking the summary statistics in the hits,
				 TP, FN, and UP columns will show sequences in those
				 sets.',

				 $p->warn('This page is a work-in-progress. ' .
						  'Gnarly searches may take several minutes!'),

				 $p->start_form(-method=>'GET'),

				 '<table border=1 width="100%">', "\n",

				 '<tr>', 
				 '<th colspan=2>',
				 $p->submit(-name=>'submit', -value=>'vroom!'),
				 ,'</th>',
				 '<th align="center" colspan="3">Sequence Set: ',
				 $p->popup_menu(-name => 'pset_id',
								-values => [sort keys %xs],
								-labels => \%xs,
								-default => $v->{pset_id}),

				 '</th>',
				 '</tr>',"\n",

				 '<tr>', 
				 '<th colspan="2">Model set: ',
				 $p->popup_menu(-name => 'modelset_id',
								-values => [keys %ms],
								-labels => \%ms,
								-default => $v->{modelset_id}),
				 '</th>',
				 '<th align="center" colspan="2">SP (',$nSP,' sequences)</th>',
				 '<th></th>',
				 '</tr>',"\n",

				 '<tr>',
				 '<th align="left">method</th>',
				 '<th width="15%">',
				 $p->tooltip('hits','All hits to any of the selected models/methods'),
				 '</th>',
				 '<th width="15%">',
				 $p->tooltip('TP','True Positives -- sequences from the selected set which are correctly matched by the models'),
				 '</th>',
				 '<th width="15%">',
				 $p->tooltip('FN','False Negatives -- sequences from the selected set which are incorrectly missed by the models'),
				 '</th>',
				 '<th width="15%">',
				 $p->tooltip('UP','Unknown Positives -- sequences hit by the models which are not known to belong to the sequence set'),
				 '</th>',
				 '</tr>',"\n",

				 '<tr>',
				 '<td>',
				 $p->checkbox(-name => 'hmm',
							  -label => 'HMM/Pfam ',
							  -checked => 1),
				 '<br>with eval <= ',
				 $p->popup_menu(-name => 'hmm_eval',
								-values => [qw(1e-40 1e-30 1e-20 1e-10 1e-5 1 5 10)],
								-default => '1e-5'),
				 '</td>',
				 '<td align="right">', $hmm_P ,'</td>',
				 '<td align="right">', $hmm_TP,'</td>',
				 '<td align="right">', $hmm_FN,'</td>',
				 '<td align="right">', $hmm_UP,'</td>',
				 '</tr>',"\n",

				 '<tr>',
				 '<td>',
				 $p->checkbox(-name => 'pssm',
							  -label => 'PSSM ',
							  -checked => 1),
				 '<br>with eval <= ',
				 $p->popup_menu(-name => 'pssm_eval',
								-values => [qw(1e-40 1e-30 1e-20 1e-10 1e-5 1 5 10)],
								-default => '1e-5'),
				 '</td>',
				 '<td align="right">', $pssm_P ,'</td>',
				 '<td align="right">', $pssm_TP,'</td>',
				 '<td align="right">', $pssm_FN,'</td>',
				 '<td align="right">', $pssm_UP,'</td>',
				 '</tr>',"\n",

				 '<tr>',
				 '<td>',
				 $p->checkbox(-name => 'p2',
							  -label => 'Prospect2 ',
							  -checked => 1),

				 '<br>Parameter set: ',
				 $p->popup_menu(-name => 'p2_run_id',
								-values => [qw(1)],
								-default => '1'),
				 '<br>with svm >= ',
				 $p->popup_menu(-name => 'p2_svm',
								-values => [qw(13 12 11 10 9 8 7 6 5)],
								-default => '9'),
				 '<br>with raw <= ',
				 $p->popup_menu(-name => 'p2_raw',
								-values => [qw(-2000 -1500 -1000 -500 -250 0 100 250)],
								-default => '-500'),
				 '</td>',
				 '<td align="right">', $p2_P ,'</td>',
				 '<td align="right">', $p2_TP,'</td>',
				 '<td align="right">', $p2_FN,'</td>',
				 '<td align="right">', $p2_UP,'</td>',
				 '</tr>',"\n",

				 '<tr><td colspan=5>&nbsp;</td></tr>',"\n",

				 '<tr>',
				 '<td>',
				 $p->tooltip('Intersection','Sequences which occur in ALL of the selected methods'),
				 '</td>',
				 '<td align="right">', $I_P ,'</td>',
				 '<td align="right">', $I_TP,'</td>',
				 '<td align="right">', $I_FN,'</td>',
				 '<td align="right">', $I_UP,'</td>',
				 '</tr>',"\n",

				 '<tr>',
				 '<td>',
				 $p->tooltip('Union','Sequences which occur in ANY of the selected methods'),
				 '</td>',
				 '<td align="right">', $U_P ,'</td>',
				 '<td align="right">', $U_TP,'</td>',
				 '<td align="right">', $U_FN,'</td>',
				 '<td align="right">', $U_UP,'</td>',
				 '</tr>',"\n",

				 "</table>\n",

				 $p->end_form(), "\n",

				);


#


sub _hmm_sql {
  my @models = sort { $a<=>$b }
	(map { $_->[0] } @{ $u->selectall_arrayref( "select pmodel_id from pmsm_pmhmm where pmodelset_id=$v->{pmodelset_id}" ) });
  my $sql = Unison::SQL->new()
	->table('pahmm A')
	->columns('distinct A.pseq_id')
	->where("A.eval<=$v->{hmm_eval}")
	->where('A.pmodel_id in (' . join(',',@models) . ')');
  return "$sql";
}
sub _get_hmm_hits {
  my $sql = _hmm_sql();
  return map { $_->[0] } @{ $u->selectall_arrayref("$sql") };
}

sub _pssm_sql {
  my @models = sort { $a<=>$b }
	(map { $_->[0] } @{ $u->selectall_arrayref( "select pmodel_id from pmsm_pmpssm where pmodelset_id=$v->{pmodelset_id}" ) });
  my $sql = Unison::SQL->new()
	->table('papssm A')
	->columns('distinct A.pseq_id')
	->where("A.eval<=$v->{pssm_eval}")
	->where("A.run_id=1")
	->where('A.pmodel_id in (' . join(',',@models) . ')');
  return "$sql";
}
sub _get_pssm_hits {
  my $sql = _pssm_sql();
  return map { $_->[0] } @{ $u->selectall_arrayref("$sql") };
}

sub _p2_sql {
  my @models = sort { $a<=>$b }
	(map { $_->[0] } @{ $u->selectall_arrayref( "select pmodel_id from pmsm_prospect2 where pmodelset_id=$v->{pmodelset_id}" ) });
  my $sql = Unison::SQL->new()
	->table('paprospect2 A')
	->columns('distinct A.pseq_id')
	->where("A.svm>=$v->{p2_svm}")
	->where('A.pmodel_id in (' . join(',',@models) . ')');
  return "$sql";
}
sub _get_p2_hits {
  my $sql = _p2_sql();
  return map { $_->[0] } @{ $u->selectall_arrayref("$sql") };
}






# ===========================================================================
# acomm -- array comparison (à la comm(1))
# given two references to arrays, return references to 3 arrays: 
# unique in list 1, unique in list 2, common to both
# for the moment, comparison is via `cmp', which may not be meaningful for 
# some objects (like refs).
# incoming arrays will be alpha sorted (by cmp);
# outbound arrays are similarly sorted
sub acomm
  {
  my ($ar1,$ar2) = @_;
  my (@a1) = sort {$a cmp $b} @$ar1;
  my (@a2) = sort {$a cmp $b} @$ar2;
  my (@u1) = ();							# uniq in 1
  my (@u2) = ();							# uniq in 2
  my (@c) = ();								# common

  while( ($#a1>-1) and ($#a2>-1) )
	{
	my ($c) = $a1[0] cmp $a2[0];			# three cases:
	if ($c<0)								# 1) a1[0] < a2[0]
	  { push(@u1,shift(@a1)) }
	elsif ($c>0)							# 2) a1[0] > a2[0]
	  { push(@u2,shift(@a2)) }
	else									# 3) a1[0] == a2[0]
	  { push(@c,shift(@a1)); shift(@a2); }
	}

  # may have terminated while loop because one list was exhausted; append
  # a1 and a2 to u1 and u2 respectively to pick up any leftovers.
  push(@u1,@a1);
  push(@u2,@a2);

  return(\@u1,\@u2,\@c);
  }
__END__


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
	->where("T.run_id=$v->{al_prospect2_run_id}")
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



