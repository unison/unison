#!/usr/bin/env perl
# search_sets.pl -- compare a pset and pmodelset among several methods

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;
use Data::Dumper;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};

my %defaults = 
  ( 
   pset_id => 5,
   pmodelset_id => 2,
   hmm => 0,
   hmm_eval => '1e-5',
   pssm => 0,
   pssm_eval => '1e-5',
   p2 => 0,
   p2_run_id => 1,
   p2_svm => 11,
   p2_raw => -500,
  );

my $v = $p->Vars();
my %v = (%defaults, %$v);
$v = \%v;


my (@SP) = map { $_->[0] } @{ $u->selectall_arrayref("select pseq_id from pseqset where pset_id=$v->{pset_id}") };
my $nSP = $#SP+1;


#my (@hmm_P,@hmm_TP,@hmm_FN,@hmm_UP);
my ($hmm_P,$hmm_TP,$hmm_FN,$hmm_UP) = ('','','','');

#my (@pssm_P,@pssm_TP,@pssm_FN,@pssm_UP);
my ($pssm_P,$pssm_TP,$pssm_FN,$pssm_UP) = ('','','','');

#my (@p2_P,@p2_TP,@p2_FN,@p2_UP);
my ($p2_P,$p2_TP,$p2_FN,$p2_UP) = ('','','','');

my %P;										# counts # of times pseq_id was hit for U_ & I_
my ($I_P,$I_TP,$I_FN,$I_UP) = ('','','','');
my ($U_P,$U_TP,$U_FN,$U_UP) = ('','','','');

my $set;									# pseq_id array ref; if set below, show seq list



## This cgi really has two modes: a summary display and a sequence list
## display.  The summary is shown by default; if $v->{submit} =~
## m/^[IU]_(P|TP|FN|UP)$/, then a sequence list is shown. I/U selects the
## intersection or union, and P, TP, FN, and UP correspond to the positive
## (hits), true positive, false negative, and unknown positives.  If only one
## method is specified, then U_* are the sequence lists for that method, and
## this observation is used to reduce the number of cases I deal with below.
## In schematic:
## - compute hmm_* if needed
## - compute pssm_* if needed
## - compute p2_* if needed
## - compute U_*
## - compute I_ unless we're showing a list of U_*


if (exists $v->{submit}) {
  my (@P,$FNr,$UPr,$TPr);

  if ($v->{hmm}) {
	my $url = $p->make_url( qw(pset_id pmodelset_id hmm hmm_eval) );
	@P = _get_hmm_hits();
	$P{$_}++ for @P;
	if ($v->{submit} !~ m/^[IU]/) {
	  ($FNr,$UPr,$TPr) = acomm(\@SP,\@P);
	  $hmm_P  = sprintf('<a href="%s;submit=U_P">%d</a>',$url, $#P+1);
	  if ($nSP>0) {
		$hmm_TP = sprintf('<a href="%s;submit=U_TP">%d (%5.1f%%)</a>',
						  $url, $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
		$hmm_FN = sprintf('<a href="%s;submit=U_FN">%d (%5.1f%%)</a>',
						  $url, $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	  }
	  $hmm_UP  = sprintf('<a href="%s;submit=U_UP">%d</a>',
						 $url, $#$UPr+1);
	}
  }

  if ($v->{pssm}) {
	my $url = $p->make_url( qw(pset_id pmodelset_id pssm pssm_eval) );
	@P = _get_pssm_hits();
	$P{$_}++ for @P;
	if ($v->{submit} !~ m/^[IU]/) {
	  ($FNr,$UPr,$TPr) = acomm(\@SP,\@P);
	  $pssm_P  = sprintf('<a href="%s;submit=U_P">%d</a>',$url, $#P+1);
	  if ($nSP>0) {
		$pssm_TP = sprintf('<a href="%s;submit=U_TP">%d (%5.1f%%)</a>',
						  $url, $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
		$pssm_FN = sprintf('<a href="%s;submit=U_FN">%d (%5.1f%%)</a>',
						  $url, $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	  }
	  $pssm_UP  = sprintf('<a href="%s;submit=U_UP">%d</a>',
						 $url, $#$UPr+1);
	}
  }

  if ($v->{p2}) {
	my $url = $p->make_url( qw(pset_id pmodelset_id p2 p2_run_id p2_svm) );
	@P = _get_p2_hits();
	$P{$_}++ for @P;
	if ($v->{submit} !~ m/^[IU]/) {
	  ($FNr,$UPr,$TPr) = acomm(\@SP,\@P);
	  $p2_P  = sprintf('<a href="%s;submit=U_P">%d</a>',$url, $#P+1);
	  if ($nSP>0) {
		$p2_TP = sprintf('<a href="%s;submit=U_TP">%d (%5.1f%%)</a>',
						  $url, $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
		$p2_FN = sprintf('<a href="%s;submit=U_FN">%d (%5.1f%%)</a>',
						  $url, $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	  }
	  $p2_UP  = sprintf('<a href="%s;submit=U_UP">%d</a>',
						 $url, $#$UPr+1);
	}
  }

  # UNION
  my $url = $p->make_url( qw(pset_id pmodelset_id hmm hmm_eval pssm pssm_eval p2 p2_run_id p2_svm) );
  my @U_P = sort keys %P;
  if ($v->{submit} !~ m/^I_/) {
	($FNr,$UPr,$TPr) = acomm(\@SP,\@U_P);
	$U_P  = sprintf('<a href="%s;submit=U_P">%d</a>',$url, $#U_P+1);
	if ($nSP>0) {
		$U_TP = sprintf('<a href="%s;submit=U_TP">%d (%5.1f%%)</a>',
						  $url, $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
		$U_FN = sprintf('<a href="%s;submit=U_FN">%d (%5.1f%%)</a>',
						  $url, $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	  }
	$U_UP  = sprintf('<a href="%s;submit=U_UP">%d</a>',
						 $url, $#$UPr+1);
  }

  if ($v->{submit} eq 'U_P') 
	{ @$set = @U_P; }
  elsif ($v->{submit} eq 'U_TP')
	{ @$set = @$TPr; }
  elsif ($v->{submit} eq 'U_FN')
	{ @$set = @$FNr; }
  elsif ($v->{submit} eq 'U_UP')
	{ @$set = @$UPr; }
  else {
	# INTERSECTION
	my $url = $p->make_url( qw(pset_id pmodelset_id hmm hmm_eval pssm pssm_eval p2 p2_run_id p2_svm) );
	my $n = ($v->{hmm}?1:0) + ($v->{pssm}?1:0) + ($v->{p2}?1:0);
	my @I_P = grep { $P{$_} == $n } @U_P;
	if ($v->{submit} ne 'I_P') {
	  ($FNr,$UPr,$TPr) = acomm(\@SP,\@I_P);
	  $I_P  = sprintf('<a href="%s;submit=I_P">%d</a>',$url, $#I_P+1);
	  if ($nSP>0) {
		$I_TP = sprintf('<a href="%s;submit=I_TP">%d (%5.1f%%)</a>',
						  $url, $#$TPr+1, ($#$TPr+1)/($#SP+1)*100);
		$I_FN = sprintf('<a href="%s;submit=I_FN">%d (%5.1f%%)</a>',
						  $url, $#$FNr+1, ($#$FNr+1)/($#SP+1)*100);
	  }
	  $I_UP  = sprintf('<a href="%s;submit=I_UP">%d</a>',
						 $url, $#$UPr+1);
	}

	if ($v->{submit} eq 'I_P') 
	  { @$set = @I_P; }
	elsif ($v->{submit} eq 'I_TP')
	  { @$set = @$TPr; }
	elsif ($v->{submit} eq 'I_FN')
	  { @$set = @$FNr; }
	elsif ($v->{submit} eq 'I_UP')
	  { @$set = @$UPr; }
  }
}





if ($set) {
  @$set = sort {$a<=>$b} @$set;
  my @rows = map { ["<a href=\"pseq_summary.pl?pseq_id=$_\">$_</a>",$u->best_annotation($_,1)] } @$set;

  print $p->render("Sequence Mining",
				   $p->group(sprintf("%d $v->{submit} results",$#rows+1),
							 Unison::WWW::Table::render(['pseq_id','best_annotation'],\@rows)));
  exit(0);
}



# default case: prepare the form and summary statistics

my %xs = map { $_->[0] => "$_->[1] (set $_->[0])" } 
  @{ $u->selectall_arrayref("select pset_id,name from pset") }; 
my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" }
  @{ $u->selectall_arrayref('select * from pmodelset') };

print $p->render("Sequence Mining",
				 '$Id: search_sets.pl,v 1.2 2003/10/31 22:55:35 rkh Exp $',

				 '<p>This page allows you assess sensitivity and
				 specificity of models, methods, and parameters. Select
				 the Model Set you wish to use to select sequences, the
				 set of "known" sequences with which sensitivity and
				 specificity will be assessed, and click
				 "vroom". Clicking the summary statistics in the hits,
				 TP, FN, and UP columns will show sequences in those
				 sets.',

				 $p->start_form(-method=>'GET'),

				 '<table border=1 width="100%">', "\n",

				 '<tr>', 
				 '<th colspan=2>',
				 $p->submit(-name=>'submit', -value=>'vroom'),
				 ,'</th>',
				 '<th align="center" colspan="3">Sequence Set: ',
				 $p->popup_menu(-name => 'pset_id',
								-values => [sort keys %xs],
								-labels => \%xs,
								-default => "$v->{pset_id}"),

				 '</th>',
				 '</tr>',"\n",

				 '<tr>', 
				 '<th colspan="2">Model set: ',
				 $p->popup_menu(-name => 'pmodelset_id',
								-values => [keys %ms],
								-labels => \%ms,
								-default => "$v->{pmodelset_id}"),
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
							  -checked => $v->{hmm}),
				 '<br>&nbsp;&nbsp;&nbsp;&nbsp;with eval <= ',
				 $p->popup_menu(-name => 'hmm_eval',
								-values => [qw(1e-60 1e-50 1e-40 1e-30 1e-20 1e-10 1e-5 1 5 10)],
								-default => "$v->{hmm_eval}"),
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
							  -checked => $v->{pssm}),
				 '<br>&nbsp;&nbsp;&nbsp;&nbsp;with eval <= ',
				 $p->popup_menu(-name => 'pssm_eval',
								-values => [qw(1e-60 1e-50 1e-40 1e-30 1e-20 1e-10 1e-5 1 5 10)],
								-default => "$v->{pssm_eval}"),
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
							  -checked => $v->{p2}),

				 '<br>&nbsp;&nbsp;&nbsp;&nbsp;Parameter set: ',
				 $p->popup_menu(-name => 'p2_run_id',
								-values => [qw(1)],
								-default => "$v->{p2_run_id}"),
				 '<br>&nbsp;&nbsp;&nbsp;&nbsp;with svm >= ',
				 $p->popup_menu(-name => 'p2_svm',
								-values => [qw(13 12 11 10 9 8 7 6 5)],
								-default => "$v->{p2_svm}"),
#				 '<br>&nbsp;&nbsp;&nbsp;&nbsp;with raw <= ',
#				 $p->popup_menu(-name => 'p2_raw',
#								-values => [qw(-2000 -1500 -1000 -500 -250 0 100 250)],
#								-default => "$v->{p2_raw}"),
				 '</td>',
				 '<td align="right">', $p2_P ,'</td>',
				 '<td align="right">', $p2_TP,'</td>',
				 '<td align="right">', $p2_FN,'</td>',
				 '<td align="right">', $p2_UP,'</td>',
				 '</tr>',"\n",

				 '<tr>',
				 '<td colspan=3></td>',
				 '<td colspan=2 bgcolor="lightgrey" align="center">',
				 $p->tooltip('NOTE (mouseover me)', 'The union of
							 individual FNs above IS NOT equal to the FN
							 set computed from the union of hits.  Ditto
							 for the UP.  The FN and UP below are computed
							 from the union of hits.  This note is your
							 clue that you should not tally vertically in this 
							 column.'),
				 '</td>',
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

				 '<tr>',
				 '<td>',
				 $p->tooltip('Intersection','Sequences which occur in ALL of the selected methods'),
				 '</td>',
				 '<td align="right">', $I_P ,'</td>',
				 '<td align="right">', $I_TP,'</td>',
				 '<td align="right">', $I_FN,'</td>',
				 '<td align="right">', $I_UP,'</td>',
				 '</tr>',"\n",

				 "</table>\n",

				 $p->end_form(), "\n",

#				 '<pre>',Dumper($v),'</pre>',

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
#  print(STDERR "hmm: $sql\n");
  return map { $_->[0] } @{ $u->selectall_arrayref("$sql") };
}

sub _pssm_sql {
  my @models = sort { $a<=>$b }
	(map { $_->[0] } @{ $u->selectall_arrayref( "select pmodel_id from pmsm_pmpssm where pmodelset_id=$v->{pmodelset_id}" ) });
  my $sql = Unison::SQL->new()
	->table('papssm A')
	->columns('distinct A.pseq_id')
	->where("A.eval<=$v->{pssm_eval}")
	->where('A.pmodel_id in (' . join(',',@models) . ')');
  return "$sql";
}
sub _get_pssm_hits {
  my $sql = _pssm_sql();
#  print(STDERR "pssm: $sql\n");
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
#  print(STDERR "p2: $sql\n");
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
exit(0);


