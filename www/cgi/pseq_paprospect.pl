#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5", "$FindBin::Bin/../../../perl5";

use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW;
use Unison::WWW::Table;
use Unison::Utilities::pseq_features;
use Unison::SQL;
use Unison::Exceptions;

my $pdbDir = (defined($ENV{PDB_PATH}) ? $ENV{PDB_PATH} : '/gne/compbio/share/pdb/all.ent');
my @statevars = qw(pseq_id params_id offset limit sort pmodelset_id);
#my $scopURL = 'http://scop.mrc-lmb.cam.ac.uk/scop';
my $scopURL = 'http://scop.berkeley.edu';
my $scoplinkfmt = '<A HREF="'.$scopURL.'/search.cgi?sunid=%d" TOOLTIP="%s">%s</A>';
sub scoplink ($$);


my @aln_cols =
  (
   # HTML col    DB col       order tag  sql order by
   ['aln?',                                              ],
   ['acc',       'acc',       'acc',     'acc'           ],
   ['%IDE', 	 'pct_ident', 'pide',    'pct_ident desc'],
   ['raw',       'raw',       'raw',     'raw desc'      ],
  );
my @detail_cols =
  (
   # HTML col    DB col       order tag  sql order by
   ['singleton', 'singleton', 'sing', 	 'singleton'     ],
   ['pairwise',  'pairwise',  'pair',  	 'pairwise'      ],
   ['mutation',  'mutation',  'mut',     'mutation'      ],
   ['gap',       'gap',       'gap',     'gap'           ],
  );
my @scop_cols=
  (
   # HTML col    DB col       order tag  sql order by
   ['svm',       'svm',       'svm',     'svm desc'      ],
   ['SCOP (cl&nbsp;>&nbsp;sf&nbsp;>&nbsp;dm; see mouseovers)',  ]
  );


my $p = new Unison::WWW::Page;
my $v = $p->Vars();
my $u = $p->{unison};

my @ps = $u->get_params_info_by_pftype('prospect2');
my %ps = map { $_->[0] => "$_->[1] (set $_->[0])" } @ps;

$v->{params_id} = 1 unless defined $v->{params_id};
$v->{pmodelset_id} = undef unless defined $v->{params_id};
$v->{offset} = 0 unless defined $v->{offset};
$v->{limit} = 25 unless defined $v->{limit};
$v->{raw_max} = 0 unless defined $v->{raw_max};
$v->{sort} = 'svm' unless defined $v->{sort}; # = "order tag" above
$v->{viewer} = 'jmol' unless defined $v->{viewer};
$v->{details} = 0;

$p->ensure_required_params(qw(pseq_id params_id));
$p->add_footer_lines('$Id: pseq_paprospect2.pl,v 1.27 2005/05/17 01:22:32 rkh Exp $ ');


my @cols;
push(@cols, @aln_cols);
push(@cols, @detail_cols) if ($v->{details});
push(@cols, @scop_cols);

my @htmlcols = map { $_->[0] } @cols;
my %order_by = map {$_->[2]=>$_->[3]} grep {defined $_->[2]} @cols;
my %sort_col = map {$_->[2]=>$_->[1]} grep {defined $_->[2]} @cols;


my $sql = new Unison::SQL;
my $ob = $order_by{$v->{sort}};
my $sc = $sort_col{$v->{sort}};

# construct query
$sql->columns('*')
  ->distinct($sc,($sc eq 'acc'?'':'acc,').'clid,cfid,sfid,dmid')
  ->table('v_paprospect2_scop')
  ->where("pseq_id=$v->{pseq_id} AND params_id=$v->{params_id}")
  ->order($ob,($sc eq 'acc'?'':'acc,').'clid,cfid,sfid,dmid');
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
my $feats = $u->Unison::Utilities::pseq_features::coalesce_scop( \@raw_data );


# build ar array which will store row data
my @ar;

foreach my $row ( @{$feats} ) {
  # build checkbox for alignment
  my $aln = "<input type=\"checkbox\" name=\"templates\" "
	. "value=\"$row->{acc}\">";

  # build structure link
  my $strxlink = $row->{acc};
  if ( -f "$pdbDir/pdb".substr($row->{acc},0,4).".ent" ) {
    $strxlink = "<a href=\"p2cm.pl?pseq_id=$v->{pseq_id};viewer=$v->{viewer};params_id="
	  . "$v->{params_id};templates=$row->{acc}\" tooltip=\""
	  . "show threading alignment with $v->{viewer}\">$row->{acc}</a>";
  }

  # build scop description
  # pdbids may be associated with 0 or more scop sunids
  # This builds a list of sunid classificiations (e.g., cl>sf>dm),
  # and joins them with '<br>'
  my @scop;

  for (my $i=0; $i<=$#{$row->{scop}}; $i++) {
	my $scopr = $row->{scop}[$i];
	# 2005-02-14: tried to add cfid/cfname, but the coalesce scop
	# function doesn't pass it. Too bad. I'll revisit that horrendous
	# bit of code later. For now, we can't add other SCOP fields easily.
    push(@scop, scoplink( $scopr->{clid}, $scopr->{clname} )
	            . '&nbsp;<b>&gt;</b>&nbsp;' 
		 		. scoplink( $scopr->{sfid}, $scopr->{sfname} )
	            . '&nbsp;<b>&gt;</b>&nbsp;' 
			    . scoplink( $scopr->{dmid}, $scopr->{dmname} ) );
  }
  my $scop = join('<br>',@scop);


  push( @ar, [
			  $aln, $strxlink, 
			  (map { $row->{$_->[1]}  } @cols[2..($#cols-1)]),
#			  (map { $row->{$_->[1]}  } (grep {not m/^(?:acc|aln|SCOP)/} @cols)),
			  $scop 
			 ] 
	  );
}


# determine index of column to highlight
my %colnum = map {$cols[$_]->[2] => $_}
			  grep {defined $cols[$_]->[1]} 0..$#cols;
my $hc = $colnum{$v->{sort}};


# construct click-sort column headings
for(my $fi=0; $fi<=$#htmlcols; $fi++) {
  next if $fi == $hc;
  next unless defined $cols[$fi]->[1];
  $htmlcols[$fi] = sprintf("<a href=\"%s\">%s</a>",
						   $p->make_url({sort=>$cols[$fi]->[2]},
										qw(pseq_id params_id pmodelset_id)),
						   $htmlcols[$fi]);
}




# generate nav tab (e.g.,  |<< < 1-5 of 5 > >>|  )
# This needs to be rethought completely
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
my $b = $v->{offset}+1;
my $e = $v->{offset}+$v->{limit};
$e = $N if $e>$N;
push(@ctl, sprintf("%d-%d of %d</a>", $b, $e, $N) );
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


my @ms = @{ $u->selectall_arrayref('select pmodelset_id,name from pmodelset order by pmodelset_id') };
my %ms = map { $_->[0] => "$_->[1] (set $_->[0])" } @ms;


print $p->render
  ("threading summary for Unison:$v->{pseq_id}",
   $p->best_annotation($v->{pseq_id}),

   '<!-- pseq_prospect2 parameters -->',
   $p->start_form(-method=>'GET'),
   $p->hidden('pseq_id',$v->{pseq_id}),


   '<br>parameters: ', $p->popup_menu(-name => 'params_id',
									  -values => [map {$_->[0]} @ps],
									  -labels => \%ps,
									  -default => "$v->{params_id}"),
   '&nbsp;&nbsp;',
   'models:',  $p->popup_menu(-name => 'pmodelset_id',
							  -values => ['all', map {$_->[0]} @ms],
							  -labels => \%ms,
							  -default => "all"),
   '&nbsp;&nbsp;',

   '<br>viewer: ',$p->radio_group(-name => 'viewer',
								  -values => ['jmol','pymol', 'rasmol'],
								  -default => 'jmol'),
   '&nbsp;&nbsp;',

   $p->submit(-value=>'redisplay'),

   '&nbsp;&nbsp;',
   $p->end_form(), "\n",

   $p->tip('clicking some column headings will dynamically sort by that column'),

   '<!-- thread list and multiple thread alignment -->',
   $p->start_form(-action=>'p2alignment.pl'),
   $p->hidden('pseq_id',$v->{pseq_id}),
   $p->hidden('params_id',$v->{params_id}),
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
  my $sname = length($name) > 20 ? substr($name,0,20).'...' : $name;
  $sname =~ s/\s+/&nbsp;/g;
  return sprintf($scoplinkfmt,$id,$name,$sname);
}
