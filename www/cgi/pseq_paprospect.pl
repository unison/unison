#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;
use Unison::WWW::Table;
use Prospect2::Options;
use Prospect2::LocalClient;
use Prospect2::Align;

my $pdbDir = '/apps/compbio/share/prospect2/pdb';

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id));

$v->{run_id} = 1 unless defined $v->{run_id}; # should be required?
$v->{offset} = 1 unless defined $v->{offset};
$v->{limit} = 25 unless defined $v->{limit};
$v->{raw_max} = 0 unless defined $v->{raw_max};

my $N = $u->selectrow_array("select count(*) from paprospect2 where pseq_id=$v->{pseq_id} and run_id=$v->{run_id}");

my $sql = "select * from v_paprospect2_scop where pseq_id=$v->{pseq_id} and run_id=$v->{run_id} limit $v->{limit} offset $v->{offset}";
my $ar = $u->selectall_arrayref($sql);
for(my $i=0; $i<=$#$ar; $i++)
  {
  my @a = @{$ar->[$i]};
  splice( @a,0,2 );
  my $c = ($a[1]<=-1000 or (defined $a[7] and $a[7]=~m/TNF-like/)) ? ' checked="TRUE"' : '';
  unshift(@a, "<input type=\"checkbox\" name=\"templates\" value=\"$a[0]\"$c>");
  if ( -f "$pdbDir/$a[1].pdb" )
	{ $a[1] = "<a href=\"p2rasmol.pl?pseq_id=$v->{pseq_id};run_id=$v->{run_id};templates=$a[1]\">$a[1]</a>"; }
  $ar->[$i] = \@a;
  }

my @f = ('aln?','name','raw','svm','mutation',
		 'pairwise','singleton','gap','SCOP fold/superfamily/family');

print $p->render("threading summary for unison:$v->{pseq_id} (run_id=$v->{run_id})",
				 sprintf("%d threads returned (%d threads total for this sequence and params)", $#$ar+1, $N),
				 $p->start_form(-action=>'p2alignment.pl'),
				 $p->submit(-value=>'align checked'),
				 $p->hidden('pseq_id',$v->{pseq_id}),
				 $p->hidden('run_id',$v->{run_id}),
				 $p->group('Prospect2 Threadings',
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->submit(-value=>'align checked'),
				 $p->end_form(),
				 $p->sql($sql)
				 );

