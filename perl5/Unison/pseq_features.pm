=head1 NAME

Unison::blat -- BLAT-related functions for Unison

S<$Id: pseq_features.pm,v 1.10 2005/02/16 23:43:16 mukhyala Exp $>

=head1 SYNOPSIS

 use Unison;
 use Unison::pseq_features;
 my $u = new Unison(...);

=head1 DESCRIPTION

=cut


package Unison::pseq_features;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = ();
our @EXPORT_OK = qw( pseq_features_panel %opts );

use Bio::Graphics;
use Bio::Graphics::Feature;
use Unison::utilities qw( warn_deprecated );
use Unison::pseq_structure;

my %opts = 
  (
   pseq_id => undef,
   width => 750,
   verbose => 0,
   pad => 10,
   logo_margin=> 10,
   # this is the default track length needed for imagemap links
   def_track_length => 60
  );


sub pseq_features_panel($%);




=pod

=head1 ROUTINES AND METHODS

=over

=cut


######################################################################
## pseq_features_panel

=pod

=over

=item B<< pseq_features_panel( C<Unison>, C<%opts> ) >>

=back

=cut

sub pseq_features_panel($%) {
  my $u = shift;
  my %opts = (%opts, @_);

  my ($tick) = (1);

  my $len = $u->selectrow_array( "select len from pseq where pseq_id=$opts{pseq_id}" );
  if (not defined $len) {
	warn("$0: Unison:$opts{pseq_id} doesn't exist\n");
	return undef;
  }

  if(!defined($opts{features})) {
    $opts{features}{$_}++ foreach qw(ssp_psipred tmdetect signalp sigcleave antigenic regexp pssm hmm prospect2 mim);
  }
  if(defined($opts{track_length})) {
    $opts{features}{$_} = 0 foreach (keys %{$opts{features}});
    $opts{features}{ssp_psipred} = 1;
    $tick = 2;
  }
  else {
    $opts{track_length} = int($len / 100 + 1) * 100;		# round up to nearest thousand
  }

  my $panel = Bio::Graphics::Panel->new( -length => $opts{track_length},
					 -width => $opts{width},
					 -pad_top => $opts{pad},
					 -pad_left => $opts{pad},
					 -pad_right => $opts{pad},
					 -pad_bottom => $opts{pad},
					 -key_style => 'between'
				       );

  $panel->add_track( Bio::Graphics::Feature->new
					 (-start => 1, -end => $len,
					  -name => sprintf("Unison:%d; %d AA; %s",
									   $opts{pseq_id}, $len, $u->best_alias($opts{pseq_id}))),
					 -glyph => 'arrow',
					 -tick => $tick,
					 -fgcolor => 'black',
					 -double => 0,
					 -label => 1, -description=>1
				   );

  add_pfssp_psipred( $u, $panel, $opts{pseq_id}, $len, $opts{track_length}) if($opts{features}{ssp_psipred});
  add_pftmdetect   ( $u, $panel, $opts{pseq_id} ) if($opts{features}{tmdetect});
  add_pfsignalp    ( $u, $panel, $opts{pseq_id} ) if($opts{features}{signalp});
  add_pfsigcleave  ( $u, $panel, $opts{pseq_id} ) if($opts{features}{sigcleave});
  add_pfantigenic  ( $u, $panel, $opts{pseq_id} ) if($opts{features}{antigenic});
  add_pfregexp     ( $u, $panel, $opts{pseq_id} ) if($opts{features}{regexp});
  add_papssm       ( $u, $panel, $opts{pseq_id} ) if($opts{features}{pssm});
  add_pahmm        ( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure} ) if($opts{features}{hmm});
  add_paprospect2  ( $u, $panel, $opts{pseq_id} ) if($opts{features}{prospect2});
  add_pfmim        ( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure} ) if($opts{features}{mim});

  $panel->add_track( ) for 1..2;			# spacing
  $panel->add_track( -key => '$Id: pseq_features.pm,v 1.10 2005/02/16 23:43:16 mukhyala Exp $',
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
				$dw-$sw-$opts{logo_margin},$dh-$sh-$opts{logo_margin},
				0,0,$sw,$sh);
	}
  }
  return $panel;
}



#-------------------------------------------------------------------------------
# NAME: add_pfssp_psipred
# PURPOSE: add pfssp_psipred features to a panel
# ARGUMENTS: Unison object, Bio::Graphics::Feature object, pseq_id
# RETURNS: count of features added
#-------------------------------------------------------------------------------
sub add_pfssp_psipred {
  my ($u, $panel, $q, $len, $track_length) = @_;
  my ($nadded) = (0);
  my ($sql,$featref);
  my @strands_helices= ();
  @{$strands_helices[0]} = (); #initialize the array that is passed to add track

  my $num_tracks = ($len/$track_length);
  my $href = ($track_length < $len ? '' : "pseq_features.pl?pseq_id=$q&track_length=$opts{def_track_length}");

 # get the ssp confidense string
  $sql = "select confidence
           from psipred where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  $featref = $u->selectall_arrayref($sql);

  my $confidence_string = $$featref[0]->[0];

  # add pfssp_psipred feature
  $sql = "select start,stop,type
           from pfssp_psipred where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  $featref = $u->selectall_arrayref($sql); 

  foreach my $r (@$featref) {
      $nadded++;
      my $track_number = int(($r->[0]-1)/$track_length);
      my $score = avg_confidence($r->[0], $r->[1], $confidence_string);
      my $start = $r->[0] - ($track_length * $track_number);
      my $end = $r->[1] - ($track_length * $track_number);
      while ($end > $track_length) {
	$end = $track_length;
	push @{$strands_helices[$track_number]},  new Bio::Graphics::Feature ( -start => $start,
									       -end => $end,
									       -type => $r->[2],
									       -name => $r->[2],
									       -score => $score,
									       -attributes => { tooltip => "$r->[2]: $r->[0] - $r->[1], avgerage confidence=".sprintf("%.2f",$score),
												href => $href }
									     );	
	$start = 1;
	$end = ($r->[1] - ($track_length * $track_number)) - $track_length;
	$track_number++;
      }
      push @{$strands_helices[$track_number]},  new Bio::Graphics::Feature ( -start => $start,
									     -end => $end,
									     -type => $r->[2],
									     -name => $r->[2],
									     -score => $score,
									     -attributes => { tooltip => "$r->[2]: $r->[0] - $r->[1], avgerage confidence=".sprintf("%.2f",$score),
											      href => $href }
									   );
  }

  for(my $i = 0; $i <= $num_tracks; $i++) {
    my $key = ($num_tracks < 1 ? 'PSIPRED secondary structure prediction' : $track_length*$i+1);
    my $track = $panel->add_track(generic=> [@{$strands_helices[$i]}],				
				  -glyph => \&glyph_type,
				  -key => $key,
				  -bump => 0,
				  -bgcolor => \&glyph_colour,
				  -fgcolor => \&glyph_colour,
				  -east => 1,
 				  #-arrowstyle => "filled",
				  -fontcolor => 'black',
				  -description => 1,
				  -min_score => -5,
				  -max_score => 5,
				  -linewidth =>  sub {
				    my $feat = shift @_;
				    return '2' if $feat->type eq 'E';
				  },
				 ) if(defined($strands_helices[$i]));
  }
  return $nadded;
}


######################################################################
## add_pfsignalp

=pod

=item B<< add_pfsignalp( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pfsignalp features to a panel and return the number of features added.

=cut

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



######################################################################
## add_pftmdetect

=pod

=item B<< add_pftmdetect( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pftmdetect features to a panel and return the number of features added.

=cut

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



######################################################################
## add_paprospect2

=pod

=item B<< add_paprospect2( C<Bio::Graphics::Panel>, C<pseq_id>, C<params_id> ) >>

Add paprospect2 features to a panel and return the number of features added.

=cut

sub add_paprospect2 {
  my ($u, $panel, $q, $params_id) = @_;
  my ($svm_thr,$topN) = (7,5);
  my $nadded = 0;
  ## XXX: add support for params_id
  my $params_clause = defined $params_id ? " AND params_id=$params_id " : '';
  my $sql = "SELECT * FROM v_paprospect2_scop WHERE pseq_id=$q AND svm >= $svm_thr";
  my $sth = $u->prepare($sql);
  $sth->execute();
  my @raw_data;
  while ( my $row = $sth->fetchrow_hashref() ) {
	push @raw_data,$row;
  }
  my $feats = coalesce_scop( $u,\@raw_data );
  my $nfeat = scalar(@{$feats});
  splice(@{$feats},$topN) if $nfeat>$topN;
  my $track = $panel->add_track( 
								-glyph => 'graded_segments',
								-bgcolor => 'green',
								-key => sprintf('prospect (top %d hits of %d w/svm>=%s)',
												($#$feats+1),$nfeat,$svm_thr),
								-bump => +1,
								-label => 1,
								-fgcolor => 'black',
								-font2color => 'red',
								-description => 1,
								-height => 4,
								-bgcolor => 'green',
								-min_score => 5,
								-max_score => 11,
								-sort_order => 'high_score',
							   );
  foreach my $row ( @{$feats} ) {
    my %scopsf;								# superfamily names
	my $scop = '';							# scop classifications (cl > sf > dm)
	my $scoplink = '';

	my @scops = @{$row->{scop}};
    for ( my $i=0; $i<$#scops+1; $i++ ) {
	  my %scopi = %{$scops[$i]};
	  $scopsf{$scopi{sfname}}++;
	  $scop .= sprintf("%s > %s > %s\n",
					   @scopi{qw(clname sfname dmname)});
	  $scoplink = sprintf('http://scop.berkeley.edu/search.cgi?sunid=%d',$scopi{dmid});
	}

    my $name = sprintf("%s; raw=%s; svm=%s; (%s)",$row->{acc},$row->{raw},$row->{svm},
					   join(' AND ',sort keys %scopsf));
    printf(STDERR " add track: $name\n") if $opts{verbose};
    $track->add_feature( 
						Bio::Graphics::Feature->new( 
													-start => $row->{start},
													-end   => $row->{stop},
													-score => $row->{svm},
													-name  => $name,
													-attributes => { tooltip => $scop, 
																	 href => $scoplink }
												   ));
    $nadded++;
    last if $nadded == $topN;
  }
  return $nadded;
}


######################################################################
## coalesce_scop

=pod

=item B<coalesce_scop( C<aref> )>

aref := arrayref (row) of hashrefs (columns)

Coalesce scop information for duplicate pseq_id and acc hits. handles
the duplicate rows generated from the v_paprospect_scop view

arrayref (new reference) with the scop information coalesced

=cut

sub coalesce_scop {
  my ($u,$featref) = @_;

  my ($curr_acc,@scop,@retval,%row);
  my $cnt=0;
  foreach my $r (@{$featref}) {
    $cnt++;
    if (( defined $curr_acc ) && ( $r->{acc} ne $curr_acc )) {
      $row{scop} = [@scop];
      # don't return sunids
      delete $row{clid}; delete $row{clname}; delete $row{sfid};
      delete $row{sfname}; delete $row{dmid}; delete $row{dmname};
      push @retval,{ map { $_, $row{$_} } keys %row };
      @scop = ();
    }
    # copy key/value pairs from old ($r) to new (%row) hash
    foreach my $k (keys %{$r}) { 
      # skip the scop info in the $r hashref. this will all
      # go into the scop value of the %row hash
      next if ( $k eq 'clid' or $k eq 'clname' or 
				$k eq 'sfid' or $k eq 'sfname' or 
				$k eq 'dmid' or $k eq 'dmname' );
      $row{$k} = $r->{$k};
    }
    push @scop,{ 
				'clid' => $r->{clid}, 'clname' => $r->{clname},
				'sfid' => $r->{sfid}, 'sfname' => $r->{sfname},
				'dmid' => $r->{dmid}, 'dmname' => $r->{dmname}
			   };
    $curr_acc = $row{acc};
    if ( $cnt == scalar(@$featref) ) {
	  $row{scop} = [@scop]; push @retval,\%row;
	}
  }
  return \@retval;
}


######################################################################
## add_pahmm

=pod

=item B<< add_pahmm( C<Bio::Graphics::Panel>, C<pseq_id>, C<params_id> ) >>

Add pahmm features to a panel and return the number of features added.

=cut

sub add_pahmm {
  my ($u, $panel, $q, $view, $pseq_structure) = @_;

  my ($eval_thr,$topN) = (5,4);
  my $nadded = 0;
  ## XXX: don't hardwire the following
  my $params_id = 15;
  my $sql = <<EOSQL;
SELECT start,stop,ends,score,eval,acc,name,descr
FROM v_pahmm
WHERE pseq_id=? AND params_id=$params_id AND eval<=1 ORDER BY start
EOSQL
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql, undef, $q );
  my $track = $panel->add_track( -glyph => 'graded_segments',
								 -min_score => 1,
								 -max_score => 25,
								 -sort_order => 'high_score',
								 -key => sprintf('HMM (%d w/eval<%s)',
												 ($#$featref+1),$eval_thr),
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
	my $href = ($view ? $pseq_structure->region_script($r->[0],$r->[1],$r->[6]):"http://pfam.wustl.edu/cgi-bin/getdesc?name=$r->[6]");	
	$track->add_feature
	  ( Bio::Graphics::Feature->new( -start => $r->[0],
									 -end => $r->[1],
									 -score => $r->[3],
									 -name => sprintf("%s; %s; S=%s; E=%s)",
													  @$r[6,2,3,4]),
									 -attributes => { tooltip => sprintf("%s: %s", @$r[5,7]),
											  href => $href
											}
								   ) );
	 
	$nadded++;
  }
  return $nadded;
}


######################################################################
## add_pappsm

=pod

=item B<< add_pappsm( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pappsm features to a panel and return the number of features added.

=cut

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



######################################################################
## add_pfantigenic

=pod

=item B<< add_pfantigenic( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pfantigenic features to a panel and return the number of features added.

=cut

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



######################################################################
## add_pfsigcleave

=pod

=item B<< add_pfsigcleave( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pfsigcleave features to a panel and return the number of features added.

=cut

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



######################################################################
## add_pfregexp

=pod

=item B<< add_pfregexp( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pfregexp features to a panel and return the number of features added.

=cut

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

sub add_pfmim {

    my ($u, $panel, $q, $view, $pseq_structure) = @_;

    my $nadded = 0;

    my $track = $panel->add_track( -glyph => 'graded_segments',
                                                                 -bgcolor => 'lred',
                                                                 -key => 'MIM',
                                                                 -bump => +1,
                                                                 -label => 1,
                                                                 -description => 1,
                                                                 -height => 4
			       );

    my $sql = "select f.acc_pos,f.original_aa,f.variant_aa,f.pdb_id,f.pdb_pos,f.pdb_chain,m.title from mukhyala.pseq_mim p join mukhyala.fasp_omim f on f.swissprot_id=p.alias join mukhyala.mim m on m.mim_number = p.mim_number where p.pseq_id=$q";
    print(STDERR $sql, ";\n\n") if $opts{verbose};
    my $featref = $u->selectall_arrayref( $sql );

    foreach my $r (@$featref) {

      my $href = ($view ? $pseq_structure->pos_script($r->[0],$r->[1]) : "pseq_structure.pl?pseq_id=$q");

      $track->add_feature
          ( Bio::Graphics::Feature->new( -start => $r->[0],
					 -end => $r->[0],
					 -name => $r->[1]."->".$r->[2],
					 -attributes => { tooltip => $r->[6],
							  href => $href
							}
					 ) );
        $nadded++;
    }
    return $nadded;

}

sub glyph_type {
    my $feat = shift (@_);
    return 'sec_str::helix' if $feat->type eq 'H';
    return 'sec_str::myarrow' if $feat->type eq 'E';
    return 'graded_segments' if $feat->type eq 'C';
}

sub glyph_colour{
  my $feat = shift @_;
  return 'red' if $feat->type eq 'H';
  return 'blue' if $feat->type eq 'E';
  return 'green';
}

sub avg_confidence {

  my ($start, $end, $string) = @_;
  my ($total, $avg);
  for(my $i=$start; $i <= $end; $i++) {
    $total += int substr($string,$i-1,1);
  }
  $avg = $total / (($end - $start) + 1);
  return $avg;
}

package Unison;
use Unison::utilities qw( warn_deprecated );
sub features_graphic($$;$) {
 warn_deprecated();
 my %opts = %Unison::pseq_features::opts;
 $opts{pseq_id} = $_[1];
 $opts{width} = $_[2] if defined $_[2];
 my $panel = Unison::pseq_features::pseq_features_panel($_[0], %opts);
 return $panel->gd->png();
}


=pod

=back

=head1 BUGS

Please report bugs to Reece Hart E<lt>hart.reece@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc Unison

=back

=head1 AUTHOR

see C<perldoc Unison> for contact information

=cut

1;
