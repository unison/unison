#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Prospect2::Options;
use Prospect2::LocalClient;
use Prospect2::Align;
use Data::Dumper;

my $pdbDir = '/apps/compbio/share/prospect2/pdb';

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id run_id));

$v->{run_id} = 1 unless defined $v->{run_id}; # should be required?
$v->{offset} = 0 unless defined $v->{offset};
$v->{limit} = 25 unless defined $v->{limit};
$v->{raw_max} = 0 unless defined $v->{raw_max};
$v->{sort} = 'svm' unless defined $v->{sort};


#            colname        sort_ob
my @cols = (['aln?',					],
			['acc', 		'acc'		],
			['%ide',		'pide'		],
			['raw', 		'raw'		],
			['svm', 		'svm'		],
			['mutation',				],
			['pairwise',	'pairwise'	],
			['singleton',	'singleton'	],
			['gap',						],
			['SCOP&nbsp;fold/superfamily/family'  ]
		   );
my @f = map { $_->[0] } @cols;
my %colnum = map {$cols[$_]->[1] => $_} grep {defined $cols[$_]->[1]} 0..$#cols;
my $ob = { 
		  acc => 'acc',
		  pide => '"%ide" desc',
		  raw => 'raw desc',
		  svm => 'svm desc',
		  pairwise => 'pairwise',
		  singleton => 'singleton',
		 }->{$v->{sort}};


my $N = $u->selectrow_array("select count(*) from paprospect2 where pseq_id=$v->{pseq_id} and run_id=$v->{run_id}");

my $sql = "select acc,\"%ide\",raw,svm,mutation,pairwise,singleton,gap,\"SCOP fold class / superfamily / family\"   from v_paprospect2_scop where pseq_id=$v->{pseq_id} and run_id=$v->{run_id}  order by $ob  limit $v->{limit} offset $v->{offset}";
my $ar = $u->selectall_arrayref($sql);
for(my $i=0; $i<=$#$ar; $i++)
  {
  my @a = @{$ar->[$i]};
  my $c = ''; 
  #$c = ($a[1]<=-1000 or (defined $a[7] and $a[7]=~m/TNF-like/)) ? ' checked="TRUE"' : '';
  unshift(@a, "<input type=\"checkbox\" name=\"templates\" value=\"$a[0]\"$c>");
  if ( -f "$pdbDir/$a[1].pdb" )
	{ $a[1] = "<a href=\"p2rasmol.pl?pseq_id=$v->{pseq_id};run_id=$v->{run_id};templates=$a[1]\">$a[1]</a>"; }
  $ar->[$i] = \@a;
  }


my $hc;
if (exists $colnum{$v->{sort}}) {
  $hc = $colnum{$v->{sort}};
}

for(my $fi=0; $fi<=$#f; $fi++) {
  next if $fi == $hc;
  next unless defined $cols[$fi]->[1];
  $f[$fi] = sprintf("<a href=\"%s\">%s</a>",
					$p->make_url({sort=>$cols[$fi]->[1]},qw(pseq_id run_id)),
					$f[$fi]);
}


print $p->render("threading summary for unison:$v->{pseq_id} (run_id=$v->{run_id})",
				 sprintf("%d threads returned (%d threads total for this sequence and params)", $#$ar+1, $N),
				 $p->tip('clicking some column headings will dynamically sort by that column'),
				 $p->start_form(-action=>'p2alignment.pl'),
				 $p->submit(-value=>'align checked'),
				 $p->hidden('pseq_id',$v->{pseq_id}),
				 $p->hidden('run_id',$v->{run_id}),
				 $p->group('Prospect2 Threadings',
						   Unison::WWW::Table::render(\@f,$ar,{highlight_column=>$hc})),
				 $p->submit(-value=>'align checked'),
				 $p->end_form(), "\n",
				 $p->sql($sql),
				 );

