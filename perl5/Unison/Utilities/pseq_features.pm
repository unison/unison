=head1 NAME

Unison::blat -- BLAT-related functions for Unison

S<$Id: pseq_features.pm,v 1.19 2005/12/07 07:27:57 rkh Exp $>

=head1 SYNOPSIS

 use Unison;
 use Unison::pseq_features;
 my $u = new Unison(...);

=head1 DESCRIPTION

=cut


package Unison::Utilities::pseq_features;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = ();
our @EXPORT_OK = qw( pseq_features_panel %opts );

use Bio::Graphics;
use Bio::Graphics::Feature;
use Unison::Utilities::misc qw( warn_deprecated unison_logo );
use Unison::Utilities::pseq_structure;

my @default_panel_features = qw( psipred tmdetect tmhmm signalp sigcleave
  antigenic bigpi regexp pssm hmm prospect );

our %opts = 
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
    $opts{features}{$_}++ foreach @default_panel_features;
  }

  if(defined($opts{track_length})) {
    $opts{features}{$_} = 0 foreach (keys %{$opts{features}});
    $opts{features}{psipred} = 1;
    $tick = 2;
  } else {
    $opts{track_length} = int($len / 100 + 1) * 100;
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

  add_pftemplate   ( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure}) if($opts{features}{template});
  add_pfpsipred    ( $u, $panel, $opts{pseq_id}, $len, $opts{track_length}) if($opts{features}{psipred});
  add_pftmdetect   ( $u, $panel, $opts{pseq_id} ) if($opts{features}{tmdetect});
  add_pftmhmm      ( $u, $panel, $opts{pseq_id} ) if($opts{features}{tmhmm});
  add_pfsignalp    ( $u, $panel, $opts{pseq_id} ) if($opts{features}{signalp});
  add_pfsigcleave  ( $u, $panel, $opts{pseq_id} ) if($opts{features}{sigcleave});
  add_pfantigenic  ( $u, $panel, $opts{pseq_id} ) if($opts{features}{antigenic});
  add_pfbigpi	   ( $u, $panel, $opts{pseq_id} ) if($opts{features}{bigpi});
  add_pfregexp     ( $u, $panel, $opts{pseq_id} ) if($opts{features}{regexp});
  add_papssm       ( $u, $panel, $opts{pseq_id} ) if($opts{features}{pssm});
  add_pahmm        ( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure}) if($opts{features}{hmm});
  add_paprospect   ( $u, $panel, $opts{pseq_id} ) if($opts{features}{prospect});

  add_pfsnp        ( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure}) if($opts{features}{snp});
  add_pfuser       ( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure}, $opts{user_feats}) if($opts{features}{user});


  $panel->add_track( ) for 1..3;			# spacing

  my $gd = $panel->gd();
  my ($dw,$dh) = $gd->getBounds();
  my $black = $gd->colorAllocate(0,0,0);
  my $IdFont = GD::Font->MediumBold;
  $gd->string($IdFont, $opts{logo_margin}, $dh-$opts{logo_margin}-$IdFont->height,
			  '$Id: pseq_features.pm,v 1.19 2005/12/07 07:27:57 rkh Exp $',
			  $black);
  my $ugd = unison_logo();
  if (defined $ugd) {
	my ($sw,$sh) = $ugd->getBounds();
	$gd->copy($ugd,
			  $dw-$sw-$opts{logo_margin},$dh-$sh-$opts{logo_margin},
			  0,0,$sw,$sh);
  }
  return $panel;
}



#-------------------------------------------------------------------------------
# NAME: add_pfpsipred
# PURPOSE: add pfpsipred features to a panel
# ARGUMENTS: Unison object, Bio::Graphics::Feature object, pseq_id
# RETURNS: count of features added
#-------------------------------------------------------------------------------
sub add_pfpsipred {
  my ($u, $panel, $q, $len, $track_length) = @_;
  my ($nadded) = (0);
  my ($sql,$featref);
  my @strands_helices= ();
  @{$strands_helices[0]} = (); #initialize the array that is passed to add track

  my $num_tracks = ($len/$track_length);
  my $href = ($track_length < $len ? '' : "pseq_features.pl?pseq_id=$q&track_length=$opts{def_track_length}");

  # get the ssp confidence string
  $sql = "select confidence from psipred where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  $featref = $u->selectall_arrayref($sql);

  my $confidence_string = $$featref[0]->[0];

  # add pfpsipred feature
  $sql = "select start,stop,type from pfpsipred where pseq_id=$q";
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
		push(@{$strands_helices[$track_number]},  
			 new Bio::Graphics::Feature ( -start => $start,
										  -end => $end,
										  -type => $r->[2],
										  -name => $r->[2],
										  -score => $score,
										  -attributes => { tooltip => "$r->[2]: $r->[0] - $r->[1], average confidence=".sprintf("%.2f",$score),
														   href => $href }
										));
		$start = 1;
		$end = ($r->[1] - ($track_length * $track_number)) - $track_length;
		$track_number++;
	  }
	  push(@{$strands_helices[$track_number]},
		   new Bio::Graphics::Feature ( -start => $start,
										-end => $end,
										-type => $r->[2],
										-name => $r->[2],
										-score => $score,
										-attributes => { tooltip => "$r->[2]: $r->[0] - $r->[1], average confidence=".sprintf("%.2f",$score),
														 href => $href }
									  ));
	}
  
  for(my $i = 0; $i <= $num_tracks; $i++) {
    my $key = ($num_tracks < 1 ? 'PSIPRED secondary structure prediction' : $track_length*$i+1);
    my $track = $panel->add_track(generic=> [@{$strands_helices[$i]}],				
				  -glyph => \&glyph_type,
				  -key => $key,
				  -bump => 0,
				  -bgcolor => \&glyph_color,
				  -fgcolor => \&glyph_color,
				  -east => 1,
 				  #-arrowstyle => "filled",
				  -fontcolor => 'black',
				  -description => 1,
				  -min_score => 0,
				  -max_score => 8,
				  -linewidth =>  sub {
				    my $feat = shift @_;
				    return '2' if $feat->type eq 'E';
				    return '2' if $feat->type eq 'C';
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
  ## REVIEW: 2005-12-06 Reece: pftype join unused
  $sql = "select start,stop,pftype.name,d_score
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
  ## REVIEW: 2005-12-06 Reece: pftype join unused
  $sql = "select start,stop,pftype.name,sig_peptide_prob
           from pfsignalphmm natural join pftype where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  $featref = $u->selectall_arrayref($sql);
  foreach my $r (@$featref) {
	$track->add_feature
	  ( Bio::Graphics::Feature->new( -start => $r->[0],
									 -end => $r->[1],
									 -name => sprintf("Pfam HMM (%3.2f)",$r->[3]),
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
  my $sql = "select start,stop,type,prob from pftmdetect where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref($sql);
  foreach my $r (@$featref) {
	$track->add_feature
	  ( Bio::Graphics::Feature->new( -start => $r->[0],
									 -end => $r->[1],
									 -name => $r->[2],
									 -score => $r->[3]
								   ) );
	$nadded++;
  }
  return $nadded;
}


######################################################################
## add_pftmhmm

=pod

=item B<< add_pftmhmm( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pftmhmm features to a panel and return the number of features added.

=cut

sub add_pftmhmm {
  my ($u, $panel, $q) = @_;
  my $nadded = 0;
  my $track = $panel->add_track( -glyph => 'graded_segments',
								 -min_score => 0,
								 -max_score => 1,
								 -sort_order => 'high_score',
								 -bgcolor => 'blue',
								 -key => 'tmhmm',
								 -bump => +1,
								 -label => 1,
								 -fgcolor => 'black',
								 -fontcolor => 'black',
								 -font2color => 'red',
								 -description => 1,
								 -height => 4,
							   );
  my $sql = "select start,stop,type from pftmhmm where pseq_id=$q";
  my $featref = $u->selectall_arrayref($sql);
  foreach my $r (@$featref) {
	$track->add_feature
	  ( Bio::Graphics::Feature->new( -start => $r->[0],
									 -end => $r->[1],
									 -name => $r->[2],
									 -score => $r->[3]
								   ) );
	$nadded++;
  }
  return $nadded;
}

######################################################################
## add_paprospect

=pod

=item B<< add_paprospect( C<Bio::Graphics::Panel>, C<pseq_id>, C<params_id> ) >>

Add paprospect features to a panel and return the number of features added.

=cut

sub add_paprospect {
  my ($u, $panel, $q, $params_id) = @_;
  my ($svm_thr,$topN) = (7,5);
  my $params_name;
  my $nadded = 0;
  $params_id = 1 unless defined $params_id;
  $params_name = $u->get_params_name_by_params_id($params_id);
  my $sth = $u->prepare(<<EOT);
SELECT * FROM paprospect_scop_v WHERE pseq_id=$q AND svm >= $svm_thr and params_id=$params_id
EOT
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
								-key => sprintf('Prospect Threading (%s); top %d hits of %d w/svm>=%s',
												$params_name,($#$feats+1),$nfeat,$svm_thr),
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
the duplicate rows generated from the paprospect_scop_v view

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

  my ($eval_thr,$topN) = (1,4);
  my $nadded = 0;
  ## XXX: don't hardwire the following
  my (@params_info) = $u->get_params_info_by_pftype_id(7);
  my ($params_id,$params_name) = @{$params_info[0]};
  my $sql = <<EOSQL;
SELECT start,stop,ends,score,eval,acc,name,descr
FROM pahmm_v
WHERE pseq_id=? AND params_id=? AND eval<=? ORDER BY start
EOSQL
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql, undef, $q, $params_id, $eval_thr );
  my $track = $panel->add_track( -glyph => 'graded_segments',
								 -min_score => 1,
								 -max_score => 25,
								 -sort_order => 'high_score',
								 -key => sprintf('HMM (%s); %d w/eval<=%s',
												 $params_name, ($#$featref+1),$eval_thr),
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
								 -key => sprintf('PSSM/SBP; top %d hits of %d w/eval<=%s',
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
  my $sql = "select start,stop,score,subseq from pfantigenic_v where pseq_id=$q limit 10";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql );
  foreach my $r (@$featref) {
	$track->add_feature
	  ( Bio::Graphics::Feature->new( -start => $r->[0],
									 -end => $r->[1],
									 -score => $r->[2],
									 -name => $r->[3],
									 -attributes => {}
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
## add_pfsigcleave

=pod

=item B<< add_pfbigpi( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pfbigpi features to a panel and return the number of features added.

=cut

sub add_pfbigpi {
  my ($u, $panel, $q) = @_;
  my $nadded = 0;
  my $track = $panel->add_track( -glyph => 'graded_segments',
								 -min_score => 2.5,
								 -max_score => 9,
								 -sort_order => 'high_score',
								 -bgcolor => 'blue',
								 -key => 'BigPI GPI anchor',
								 -bump => +1,
								 -label => 1,
								 -description => 1,
								 -height => 4,
							   );
  my $sql = "select start,quality from bigpi_v where pseq_id=$q";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $featref = $u->selectall_arrayref( $sql );
  foreach my $r (@$featref) {
	$track->add_feature
	  ( Bio::Graphics::Feature->new( -start => $r->[0],
									 -end => $r->[0],
									 -score => ($r->[1]=='A'?4:$r->[1]=='B'?3:$r->[1]=='C'?2:$r->[1]=='D'?1:0),
									 -name => 'GPI @ ' . $r->[0]
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
								 -key => 'Sequence motif (regexp)',
								 -bump => +1,
								 -label => 1,
								 -description => 1,
								 -height => 4,
							   );
  my $sql = "select start,stop,acc,descr from pfregexp F  join pmregexp M on F.pmodel_id=M.pmodel_id  where F.pseq_id=$q";
  my $featref = $u->selectall_arrayref( $sql );
  foreach my $r (@$featref) {
	my %attr;
	$attr{tooltip} = sprintf("[%d-%d]: %s (%s)", @$r);
	$track->add_feature
	  ( Bio::Graphics::Feature->new( -start => $r->[0],
									 -end => $r->[1],
									 -name => $r->[2],
									 -attributes => \%attr
								   ) );
	$nadded++;
  }
  return $nadded;
}

sub add_pfsnp {
    my ($u, $panel, $q, $view, $pseq_structure) = @_;

    my $nadded = 0;

    my $track = $panel->add_track( -glyph => 'graded_segments',
                                                                 -bgcolor => 'lred',
                                                                 -key => 'SNPs',
                                                                 -bump => +1,
                                                                 -label => 1,
                                                                 -description => 1,
                                                                 -height => 4
			       );

    my $sql = "select start_pos,original_aa,variant_aa,descr from pseq_sp_var_v where pseq_id=$q";

    print(STDERR $sql, ";\n\n") if $opts{verbose};
    my $featref = $u->selectall_arrayref( $sql );

    foreach my $r (@$featref) {

      my $href = ($view 
				  ? $pseq_structure->pos_script($r->[0],$r->[1])
				  : "pseq_structure.pl?pseq_id=$q");

      $track->add_feature
          ( Bio::Graphics::Feature->new( -start => $r->[0],
					 -end => $r->[0],
					 -name => $r->[1]."->".$r->[2],
					 -attributes => { tooltip => $r->[3],
							  href => $href
							}
					 ) );
        $nadded++;
    }
    return $nadded;

}

sub add_pfuser {

    my ($u, $panel, $q, $view, $pseq_structure, $user_feats) = @_;

    my $nadded = 0;

    my $track = $panel->add_track( -glyph => 'graded_segments',
                                                                 -bgcolor => 'green',
                                                                 -key => 'User Features',
                                                                 -bump => +1,
                                                                 -label => 1,
                                                                 -description => 1,
                                                                 -height => 4
			       );

    foreach my $r (sort keys %{$user_feats}) {

      next if($user_feats->{$r}{type} eq 'hmm');
      my $end = $user_feats->{$r}{end};

      my $href = ($view ? (defined ($end) ?
			   $pseq_structure->region_script($user_feats->{$r}{start},$user_feats->{$r}{end},$r,$user_feats->{$r}{color}) :
			   $pseq_structure->pos_script($user_feats->{$r}{start},$r,$user_feats->{$r}{color})) :
		  "pseq_structure.pl?pseq_id=$q");

      $end =  ( $end ? $end : $user_feats->{$r}{start});

      $track->add_feature
          ( Bio::Graphics::Feature->new( -start => $user_feats->{$r}{start},
					 -end => $end,
					 -name => $r,
					 -attributes => { tooltip => $r,
							  href => $href
							}
					 ) );
        $nadded++;
    }
    return $nadded;

}

sub add_pftemplate {
    my ($u, $panel, $q, $view, $pseq_structure) = @_;
    my ($nadded,$topN) = (0,5);

    return unless defined $pseq_structure->{'structure_ids'} or defined $pseq_structure->{'template_ids'};
    my @structures = @{$pseq_structure->{'structure_ids'}} if defined $pseq_structure->{'structure_ids'};
    my @templates  = @{$pseq_structure->{'template_ids'}} if defined $pseq_structure->{'template_ids'};

    my $nfeat = $#templates+1 + $#structures+1;
    splice(@structures,$topN) if $#structures > $topN;
    splice(@templates,$topN - ($#structures+1)) if $#templates > $topN - ($#structures+1);

    my $track = $panel->add_track( -glyph => 'graded_segments',
				   -bgcolor => 'orange',
				   -key => sprintf('Structures/Templates (top %d hits of %d, including modeled structures)',$#structures+1 + $#templates+1,$nfeat),
                                                                 -bump => +1,
                                                                 -label => 1,
                                                                 -description => 1,
                                                                 -height => 4
			       );

    foreach my $t (@structures,@templates) {

      my $type = ((grep (/$t/, @structures)) ? "structures" : "templates");
      my $start = $pseq_structure->{$type}{$t}{'qstart'};
      my $end   = $pseq_structure->{$type}{$t}{'qstop'};
      my $descr = $pseq_structure->{$type}{$t}{'descr'};
      my $href = ($view ? $pseq_structure->change_structure($t) : "pseq_structure.pl?pseq_id=$q");

      $track->add_feature
          ( Bio::Graphics::Feature->new( -start => $start,
					 -end => $end,
					 -name => $t,
					 -attributes => { tooltip => $descr,
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
    return 'sec_str::coil' if $feat->type eq 'C';
}

sub glyph_color{
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
