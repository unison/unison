package Unison;
use strict;
use warnings;
use Bio::Graphics;
use Bio::Graphics::Feature;


my %opts = 
  (
   pseq_id => undef,
   width => 750,
   verbose => 0
  );

sub features_graphic {
  my $u = shift;
  my $q = shift;
  my $w = shift || 750;
  my $logo_margin = 10;

  my $len = $u->selectrow_array( "select len from pseq where pseq_id=$q" );
  if (not defined $len) {
  warn("$0: Unison:$q doesn't exist\n");
  return undef;
  }

  my $plen = int($len / 100 + 1) * 100;    # round up to nearest thousand

  my $panel = Bio::Graphics::Panel->new( -length => $plen,
                     -width => $w,
                     -pad_top => 10,
                     -pad_left => 10,
                     -pad_right => 10,
                     -pad_bottom => 10,
                     -key_style => 'between'
                     );

  $panel->add_track( Bio::Graphics::Feature->new
           (-start => 1, -end => $len,
            -name => sprintf("Unison:%d; %d AA; %s",
                     $q, $len, $u->best_alias($q))),
           -glyph => 'arrow',
           -tick => 1,
           -fgcolor => 'black',
           -double => 0,
           -label => 1, -description=>1
           );

  add_pftmdetect( $u, $panel, $q );
  add_pfsignalp( $u, $panel, $q );
  add_pfsigcleave( $u, $panel, $q );
  add_pfantigenic( $u, $panel, $q );
  add_pfregexp( $u, $panel, $q );
  add_papssm( $u, $panel, $q );
  add_pahmm( $u, $panel, $q );
  add_paprospect2( $u, $panel, $q );

  $panel->add_track( ) for 1..2;         # spacing
  $panel->add_track( -key => '$Id: features.pm,v 1.2 2004/02/25 21:04:35 cavs Exp $',
           -key_font => 'gdSmallFont',
           -bump => +1,
           );

  my $gd = $panel->gd();
  my $unison_fn = '/home/rkh/www/csb/unison/av/unison.xpm';
  if ( -f $unison_fn ) {
  my $ugd = GD::Image->newFromXpm($unison_fn);
  if (defined $ugd) {
    my ($sw,$sh) = $ugd->getBounds();
    my ($dw,$dh) = $gd->getBounds();
    $gd->copy($ugd,
        $dw-$sw-$logo_margin,$dh-$sh-$logo_margin,
        0,0,$sw,$sh);
  }
  }

  return $gd->png();
  }



#-------------------------------------------------------------------------------
# NAME: add_pfsignalp
# PURPOSE: add pfsignalp features to a panel
# ARGUMENTS: Unison object, Bio::Graphics::Feature object, pseq_id
# RETURNS: count of features added
#-------------------------------------------------------------------------------
sub add_pfsignalp {
  my ($u, $panel, $q) = @_;
  my $nadded = 0;
  my ($sql,$featref);
  my $track = $panel->add_track( 
    -glyph => 'graded_segments',
    -min_score => 0,
    -max_score => 1,
    -sort_order => 'high_score',
    -bgcolor => 'cyan',
    -key => 'SignalP',
    -bump => +1,
    -label => 1,
    -fgcolor => 'black',
    -fontcolor => 'black',
    -font2color => 'red',
    -description => 1,
    -height => 4,
  );
  # add pfsignalpnn feature
  $sql = "select start,stop,pftype.name,confidence
           from pfsignalpnn natural join pftype where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  $featref = $u->selectall_arrayref($sql);
  foreach my $r (@$featref) {
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -name => sprintf("NN  (%3.2f)",$r->[3]),
                     -score => $r->[3]
                   ) );
  $nadded++;
  }
                                                                                                                                                                          
  # add pfsignalphmm feature
  $sql = "select start,stop,pftype.name,confidence
           from pfsignalphmm natural join pftype where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  $featref = $u->selectall_arrayref($sql);
  foreach my $r (@$featref) {
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -name => sprintf("HMM (%3.2f)",$r->[3]),
                     -score => $r->[3]
                   ) );
  $nadded++;
  }
  return $nadded;
}



#####################################################################################

sub add_pftmdetect {
  my ($u, $panel, $q) = @_;
  my $nadded = 0;
  my $track = $panel->add_track( -glyph => 'graded_segments',
                 -min_score => 0,
                 -max_score => 1,
                 -sort_order => 'high_score',
                 -bgcolor => 'blue',
                 -key => 'tmdetect',
                 -bump => +1,
                 -label => 1,
                 -fgcolor => 'black',
                 -fontcolor => 'black',
                 -font2color => 'red',
                 -description => 1,
                 -height => 4,
                 );
  my $sql = "select start,stop,pftype.name,confidence 
           from pftmdetect natural join pftype where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref($sql);
  foreach my $r (@$featref) {
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -name => eval {my($x)=$r->[2]=~m%/(\S+)%;$x;},
                     -score => $r->[3]
                   ) );
  $nadded++;
  }
  return $nadded;
}



sub add_paprospect2 {
  my ($u, $panel, $q) = @_;
  my ($svm_thr,$topN) = (7,5);
  my $nadded = 0;
  my $sql =
  'select tmp.*,best_annotation(tmp.pseq_id)
    from (SELECT t.start,t.stop, t.raw, t.svm, b.acc, b.pseq_id, sfdes.descr
        FROM paprospect2 t
      JOIN pmprospect2 b ON t.pmodel_id=b.pmodel_id
          LEFT JOIN cla ON b.sunid = cla.sunid
          LEFT JOIN des sfdes ON sfdes.sunid = cla.sf
          WHERE t.pseq_id='.$q.' and t.svm>'.$svm_thr.' ORDER BY t.svm DESC) tmp';
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref($sql);
  my $nfeat = $#$featref+1;
  splice(@$featref,$topN) if $#$featref>$topN;
  my $track = $panel->add_track( -glyph => 'graded_segments',
                 -bgcolor => 'green',
                 -key => sprintf('prospect (top %d hits of %d w/svm>=%s)',
                         ($#$featref+1),$nfeat,$svm_thr),
                 -bump => +1,
                 -label => 1,
                 -fgcolor => 'black',
                 -font2color => 'red',
                 -description => 1,
                 -height => 4,
                 -bgcolor => 'green',
                 -min_score => 5,
                 -max_score => 11,
                 -sort_order => 'high_score'
                 );
  foreach my $r (@$featref) {
  next unless defined $r->[0];
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -score => $r->[3],
                     -name => sprintf("%s; raw=%s; svm=%s; (%s)",
                              @$r[4,2,3], $r->[6]||'<?>')
                   ) );
  $nadded++;
  }
  return $nadded;
}


sub add_pahmm {
  my ($u, $panel, $q) = @_;
  my ($eval_thr,$topN) = (5,4);
  my $nadded = 0;
  my $sql = 
  'select A.start,A.stop,M.acc as "model",A.mstart,A.mstop,M.len,A.score,A.eval,M.descr
   from pahmm A join pmhmm M on A.pmodel_id=M.pmodel_id
   where params_id=13 and pseq_id='.$q.' and score>1 and eval<=5 order by eval';
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql );
  my $nfeat = $#$featref+1;
  splice(@$featref,$topN) if $#$featref>$topN;
  my $track = $panel->add_track( -glyph => 'graded_segments',
                 -min_score => 1,
                 -max_score => 25,
                 -sort_order => 'high_score',
                 -key => sprintf('HMM (top %d hits of %d w/eval<%s)',
                         ($#$featref+1),$nfeat,$eval_thr),
                 -bgcolor => 'blue',
                 -bump => +1,
                 -label => 1,
                 -fgcolor => 'black',
                 -fontcolor => 'black',
                 -font2color => 'red',
                 -description => 1,
                 -height => 4,
                 );
  foreach my $r (@$featref) {
  next unless defined $r->[0];
  #printf(STDERR "[%d,%d] %s\n", @$r[0,1,2]);
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -score => $r->[6],
                     -name => sprintf("%s; %s%s; S=%s; E=%s; %s)",
                              $r->[2],
                              $r->[0]==1?'[':'.',
                              $r->[1]==$r->[5]?']':'.',
                              $r->[6], $r->[7],$r->[8])
                   ) );
  $nadded++;
  }
  return $nadded;
}


sub add_papssm {
  my ($u, $panel, $q) = @_;
  my ($eval_thr,$topN) = (5,4);
  my $nadded = 0;
  my $sql =
  'select A.start,A.stop,M.acc as "model",A.score,A.eval
   from papssm A join pmpssm M on A.pmodel_id=M.pmodel_id
   where pseq_id='.$q.' and eval<='.$eval_thr.' order by eval';
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql );
  my $nfeat = $#$featref+1;
  splice(@$featref,$topN) if $#$featref>$topN;
  my $track = $panel->add_track( -glyph => 'graded_segments',
                 -min_score => 100,
                 -max_score => 500,
                 -sort_order => 'high_score',
                 -bgcolor => 'red',
                 -key => sprintf('PSSM/SBP (top %d hits of %d w/eval<%s)',
                         ($#$featref+1),$nfeat,$eval_thr),
                 -bump => +1,
                 -label => 1,
                 -fgcolor => 'black',
                 -fontcolor => 'black',
                 -font2color => 'red',
                 -description => 1,
                 -height => 4,
                 );
  foreach my $r (@$featref) {
  next unless defined $r->[0];
  #printf(STDERR "[%d,%d] %s\n", @$r[0,1,2]);
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -score => $r->[3],
                     -name => sprintf("%s; S=%s; E=%s)",
                              $r->[2], $r->[3], $r->[4])
                   ) );
  $nadded++;
  }
  return $nadded;
}



sub add_pfantigenic {
  my ($u, $panel, $q) = @_;
  my $nadded = 0;
  my $track = $panel->add_track( -glyph => 'graded_segments',
                 -min_score => 1,
                 -max_score => 1.2,
                 -sort_order => 'high_score',
                 -bgcolor => 'green',
                 -key => 'EMBOSS/antigenic',
                 -bump => +1,
                 -label => 1,
                 -description => 1,
                 -height => 4,
                 );
  my $sql = "select start,stop,score,subseq from v_pfantigenic where pseq_id=$q limit 10";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql );
  foreach my $r (@$featref) {
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -score => $r->[2],
                     -name => $r->[3]
                   ) );
  $nadded++;
  }
  return $nadded;
}



sub add_pfsigcleave {
  my ($u, $panel, $q) = @_;
  my $nadded = 0;
  my $track = $panel->add_track( -glyph => 'graded_segments',
                 -min_score => 2.5,
                 -max_score => 9,
                 -sort_order => 'high_score',
                 -bgcolor => 'blue',
                 -key => 'EMBOSS/sigcleave',
                 -bump => +1,
                 -label => 1,
                 -description => 1,
                 -height => 4,
                 );
  my $sql = "select start,stop,score from pfsigcleave where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql );
  foreach my $r (@$featref) {
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -score => $r->[2],
                     -name => $r->[2]
                   ) );
  $nadded++;
  }
  return $nadded;
}



sub add_pfregexp {
  my ($u, $panel, $q) = @_;
  my $nadded = 0;
  my $track = $panel->add_track( -glyph => 'graded_segments',
                 -bgcolor => 'blue',
                 -key => 'regexp motif',
                 -bump => +1,
                 -label => 1,
                 -description => 1,
                 -height => 4,
                 );
  my $sql = "select start,stop,acc from pfregexp F  join pmregexp M on F.pmodel_id=M.pmodel_id  where F.pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql );
  foreach my $r (@$featref) {
  $track->add_feature
    ( Bio::Graphics::Feature->new( -start => $r->[0],
                     -end => $r->[1],
                     -name => $r->[2]
                   ) );
  $nadded++;
  }
  return $nadded;
}


1;
