#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW::Page;
use Unison::WWW;
use Unison::WWW::Table;
use Unison::pseq_features;
use Unison::SQL;
use Unison::Exceptions;

my $pdbDir = '/apps/compbio/share/prospect2/pdb';
#my $scopURL = 'http://scop.mrc-lmb.cam.ac.uk/scop';
my $scopURL = 'http://scop.berkeley.edu';
my $scoplinkfmt = "<A HREF=\"$scopURL/search.cgi?sunid=%d\">%s</A>";
my @statevars = qw(pseq_id params_id offset limit sort);

sub scoplink ($$);


my @cols =
  (# HTML col    DB col       order tag  sql order by
   ['aln?',                                              ],
   ['acc',       'acc',       'acc',     'acc'           ],
   ['%IDE', 	 'pct_ident', 'pide',    'pct_ident desc'],
   ['raw',       'raw',       'raw',     'raw'           ],
   ['svm',       'svm',       'svm',     'svm desc'      ],
   ['singleton', 'singleton', 'sing', 	 'singleton'     ],
   ['pairwise',  'pairwise',  'pair',  	 'pairwise'      ],
   ['mutation',  'mutation',  'mut',     'mutation'      ],
   ['gap',       'gap',       'gap',     'gap'           ],
   ['SCOP (sf&nbsp;>&nbsp;dm)',                          ]
  );
my @htmlcols = map { $_->[0] } @cols;
my %order_by = map {$_->[2]=>$_->[3]} grep {defined $_->[2]} @cols;
my %sort_col = map {$_->[2]=>$_->[1]} grep {defined $_->[2]} @cols;


my $p = new Unison::WWW::Page;
my $v = $p->Vars();
$v->{params_id} = 1 unless defined $v->{params_id};
$v->{pmodelset_id} = undef unless defined $v->{params_id};
$v->{offset} = 0 unless defined $v->{offset};
$v->{limit} = 25 unless defined $v->{limit};
$v->{raw_max} = 0 unless defined $v->{raw_max};
$v->{sort} = 'svm' unless defined $v->{sort}; # = "order tag" above
$p->ensure_required_params(qw(pseq_id params_id));
$p->add_footer_lines('$Id: pseq_paprospect2.pl,v 1.17 2004/06/15 00:22:08 rkh Exp $ ');


my $u = $p->{unison};
my $sql = new Unison::SQL;
my $ob = $order_by{$v->{sort}};
my $sc = $sort_col{$v->{sort}};

# construct query
$sql->columns('*')
  ->distinct($sc,($sc eq 'acc'?'':'acc,').'clid,sfid,dmid')
  ->table('v_paprospect2_scop_2')
  ->where("pseq_id=$v->{pseq_id} AND params_id=$v->{params_id}")
  ->order($ob,($sc eq 'acc'?'':'acc,').'clid,sfid,dmid');
if (defined $v->{pmodelset_id}
	and $v->{pmodelset_id} !~ m/\D/) {
  $sql->where("pmodel_id in (select pmodel_id from pmsm_prospect2 where pmodelset_id=$v->{pmodelset_id})");
}

# count number of rows from query
my $N;
my $Nsql = "select count(*) from ($sql) X";
try {
  $N = $u->selectrow_array($Nsql);
} catch Unison::Exception with {
  $p->die($_[0],"$Nsql");
};

# now, limit query appropriately
$sql->offset($v->{offset}) if $v->{offset};
$sql->limit($v->{limit}) if $v->{limit};

my @raw_data;
try {
  my $sth;
  $sth = $u->prepare("$sql");
  $sth->execute();
  while ( my $row = $sth->fetchrow_hashref() ) {
	push(@raw_data,$row);
  }
} catch Unison::Exception with {
  $p->die($_[0],"$sql");
};
my $feats = $u->coalesce_scop( \@raw_data );


# build ar array which will store row data
my @ar;
my $xmol = 'pymol';
foreach my $row ( @{$feats} ) {
  # build checkbox for alignment
  my $aln = "<input type=\"checkbox\" name=\"templates\" "
	. "value=\"$row->{acc}\">";

  # build structure link
  my $strxlink = $row->{acc};
  if ( -f "$pdbDir/$row->{acc}.pdb" ) {
    $strxlink = "<a href=\"p2$xmol.pl?pseq_id=$v->{pseq_id};params_id="
	  . "$v->{params_id};templates=$row->{acc}\" tooltip=\""
	  . "show threading alignment with $xmol\">$row->{acc}</a>";
  }

  # build scop description
  my @scop;
  for (my $i=0; $i<=$#{$row->{scop}}; $i++) {
	my $scopr = $row->{scop}[$i];
    push(@scop, scoplink( $scopr->{sfid}, $scopr->{sfname} )
	            . '&nbsp;&gt;&nbsp;' 
			    . scoplink( $scopr->{dmid}, $scopr->{dmname} ) );
  }
  my $scop = join('<br>',@scop);

  push @ar,[ $aln, $strxlink, (map { $row->{$_->[1]}  } @cols[2..8]), $scop];
}


# determine index of column to highlight
my %colnum = map {$cols[$_]->[1] => $_}
			  grep {defined $cols[$_]->[1]} 0..$#cols;
my $hc = $colnum{$v->{sort}};


# construct click-sort column headings
for(my $fi=0; $fi<=$#htmlcols; $fi++) {
  next if $fi == $hc;
  next unless defined $cols[$fi]->[1];
  $htmlcols[$fi] = sprintf("<a href=\"%s\">%s</a>",
						   $p->make_url({sort=>$cols[$fi]->[1]},
										qw(pseq_id params_id pmodelset_id)),
						   $htmlcols[$fi]);
}




my @ctl;

if ($v->{offset}>0) {
  my $no = $v->{offset}-$v->{limit};
  $no = 0 if $no<0;
  push(@ctl, 
     sprintf("<a href=\"%s\">%s</a>", $p->make_url({offset=>0},@statevars),
			 '<span tooltip="first (full) page" class="button">|&lt;&lt;</span>'),
     sprintf("<a href=\"%s\">%s</a>", $p->make_url({offset=>$no},@statevars), 
			 '<span tooltip="back one page" class="button">&lt;</span>' )
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


my @ps = @{ $u->selectall_arrayref('select params_id,name from params where params_id in (1) order by params_id') };
my %ps = map { $_->[0] => "$_->[1] (set $_->[0])" } @ps;
my @ms = @{ $u->selectall_arrayref('select pmodelset_id,name from pmodelset order by pmodelset_id') };
my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" } @ms;

print $p->render
  ("threading summary for Unison:$v->{pseq_id}",
   $p->best_annotation($v->{pseq_id}),

   '<!-- pseq_prospect2 parameters -->',
   $p->start_form(),
   $p->hidden('pseq_id',$v->{pseq_id}),
   '<br>parameters: ', $p->popup_menu(-name => 'params_id',
									  -values => [map {$_->[0]} @ps],
									  -labels => \%ps,
									  -default => "$v->{params_id}"),
   '&nbsp;&nbsp;',
   'models:',  $p->popup_menu(-name => 'pmodelset_id',
							  -values => ['all', map {$_->[0]} @ms],
							  -labels => \%ms,
							  -default => "$v->{pmodelset_id}"),
   '&nbsp;&nbsp;',
   $p->submit(-value=>'redisplay'),
   $p->end_form(), "\n",

   $p->tip('clicking some column headings will dynamically sort by that column'),

   '<!-- thread list and multiple thread alignment -->',
   $p->start_form(-action=>'p2alignment.pl'),
   $p->hidden('pseq_id',$v->{pseq_id}),
   $p->hidden('params_id',$v->{params_id}),
   '<p>', $p->submit(-value=>'align checked'),

   $p->group(['Prospect2 Threadings',$ctl],
			 Unison::WWW::Table::render(\@htmlcols,\@ar,{highlight_column=>$hc})),
   $p->submit(-value=>'align checked'),
   $p->end_form(), "\n",

   $p->sql($sql),
  );



############################################################################
### INTERNALS

sub scoplink ($$) {
  my ($id,$name) = @_;
  $name =~ s/\s+/&nbsp;/g;
  return sprintf($scoplinkfmt,$id,$name);
}
