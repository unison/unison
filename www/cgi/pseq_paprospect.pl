#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::pseq_features;

my $pdbDir = '/apps/compbio/share/prospect2/pdb';

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
my @statevars = qw(pseq_id params_id offset limit sort);
my $scopURL = 'http://scop.mrc-lmb.cam.ac.uk/scop/search.cgi?sunid=';

$p->ensure_required_params(qw(pseq_id params_id));

$v->{params_id} = 1 unless defined $v->{params_id}; # should be required?
$v->{offset} = 0 unless defined $v->{offset};
$v->{limit} = 25 unless defined $v->{limit};
$v->{raw_max} = 0 unless defined $v->{raw_max};
$v->{sort} = 'svm' unless defined $v->{sort};


#            colname        sort_ob
my @cols = (['aln?',          ],
      ['acc',     'acc'    ],
      ['pct_ident',    'pide'    ],
      ['raw',     'raw'    ],
      ['svm',     'svm'    ],
      ['singleton',    'singleton'  ],
      ['pairwise',    'pairwise'  ],
      ['mutation',    'mut'    ],
      ['gap',      'gap'    ],
      ['SCOP (sf|dm)',  ]
       );

my @f = map { $_->[0] } @cols;
my %colnum = map {$cols[$_]->[1] => $_} grep {defined $cols[$_]->[1]} 0..$#cols;
my $ob = { 
      acc => 'acc',
      pide => 'pct_ident desc',
      raw => 'raw',
      svm => 'svm desc',
      mut => 'mutation',
      pairwise => 'pairwise',
      singleton => 'singleton',
      gap => 'gap',
      scop => 'sfname,dmname'
     }->{$v->{sort}};


my $N = $u->selectrow_array("select count(*) from paprospect2 where pseq_id=$v->{pseq_id} and params_id=$v->{params_id}");

my $sql = "SELECT * FROM v_paprospect2_scop WHERE pseq_id=$v->{pseq_id} AND params_id=$v->{params_id} " .
  "ORDER BY $ob OFFSET $v->{offset} LIMIT $v->{limit} ";
my $sth = $u->prepare($sql);
$sth->execute();
my @raw_data;
while ( my $row = $sth->fetchrow_hashref() ) { push @raw_data,$row; }
my $feats = $u->coalesce_scop( \@raw_data );
#print Data::Dumper->Dump([$feats],['feats']);

# build ar array which will store row data
my @ar;
foreach my $row ( @{$feats} ) {

  # build checkbox for alignment
  my $aln = "<input type=\"checkbox\" name=\"templates\" value=\"$row->{acc}\">";

  # build rasmol linking
  my $rasmol;
  if ( -f "$pdbDir/$row->{acc}.pdb" ) {
    $rasmol .= "<a href=\"p2rasmol.pl?pseq_id=$v->{pseq_id};params_id=$v->{params_id};templates=$row->{acc}\">$row->{acc}</a>";
  } else {
    $rasmol .= $row->{acc};
  }

  # build scop decription
  my $scop='';
  for (my $i=0;$i<scalar(@{$row->{scop}});$i++) {
    
    $row->{scop}[$i]->{sfname} =~ s/ /&nbsp;/g;
    $row->{scop}[$i]->{dmname} =~ s/ /&nbsp;/g;
      
    $scop .= "<LI><A HREF='$scopURL$row->{scop}[$i]->{sfid}'>$row->{scop}[$i]->{sfname}</A>&nbsp;|&nbsp;" .
      "<A HREF='$scopURL$row->{scop}[$i]->{dmid}'>$row->{scop}[$i]->{dmname}</A>";
  }
  $scop .= '';

  push @ar,[ $aln, $rasmol, (map { $row->{$_}  } @f[2..8]), $scop];
}


my $hc;
if (exists $colnum{$v->{sort}}) {
  $hc = $colnum{$v->{sort}};
}

for(my $fi=0; $fi<=$#f; $fi++) {
  next if $fi == $hc;
  next unless defined $cols[$fi]->[1];
  $f[$fi] = sprintf("<a href=\"%s\">%s</a>",
          $p->make_url({sort=>$cols[$fi]->[1]},qw(pseq_id params_id)),
          $f[$fi]);
}




my @ctl;

if ($v->{offset}>0) {
  my $no = $v->{offset}-$v->{limit};
  $no = 0 if $no<0;
  push(@ctl, 
     sprintf("<a href=\"%s\">%s</a>", $p->make_url({offset=>0},@statevars), '<span tooltip="first (full) page" class="button">|&lt;&lt;</span>'),
     sprintf("<a href=\"%s\">%s</a>", $p->make_url({offset=>$no},@statevars), '<span tooltip="back one page" class="button">&lt;</span>' )
     );
}
push(@ctl,
   sprintf("%d-%d of %d</a>",
       $v->{offset}+1,$v->{offset}+$v->{limit},$N)
  );
if ($N-1-$v->{offset}>0) {
  my $no = $v->{offset}+$v->{limit};
  $no=$N-$v->{limit} if $no>$N-1;
  push(@ctl, 
     sprintf("<a href=\"%s\">%s</a>", $p->make_url({offset=>$no},@statevars), '<span tooltip="ahead one page" class="button">&gt</span>' ),
     sprintf("<a href=\"%s\">%s</a>", $p->make_url({offset=>$N-$v->{limit}},@statevars), '<span tooltip="last (full) page" class="button">&gt;&gt;|</span>')
    );
}

#my $ctl = join(' | ',@ctl)
my $ctl = '<table border=0><tr>' . join('',map {"<td>$_</td>"} @ctl) . '</tr></table>';


print $p->render("threading summary for Unison:$v->{pseq_id} (params_id=$v->{params_id})",
         $p->best_annotation($v->{pseq_id}),

         $p->tip('clicking some column headings will dynamically sort by that column'),
         "<p>\n",
         $p->start_form(-action=>'p2alignment.pl'),
         $p->submit(-value=>'align checked'),
         $p->hidden('pseq_id',$v->{pseq_id}),
         $p->hidden('params_id',$v->{params_id}),
         $p->group(['Prospect2 Threadings',$ctl],
               Unison::WWW::Table::render(\@f,\@ar,{highlight_column=>$hc})),
         $p->submit(-value=>'align checked'),
         $p->end_form(), "\n",
         $p->sql($sql),
         );

