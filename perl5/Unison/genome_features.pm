package Unison::genome_features;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use base 'Exporter';
@EXPORT = ();
@EXPORT_OK = qw( genome_features_panel );

use strict;
use warnings;

use Bio::Graphics;
use Bio::Graphics::Feature;
use Unison::blat;

sub genome_features_panel($%);


our %opts =
  (
   show_all => undef,
   genasm_id => undef,
   gstart => undef,
   gstop => undef,
   chr => undef,
   pseq_id => undef,
   width => 750,
   verbose => 0,
   margin => 0,
   logo_margin => 10
  );



sub genome_features_panel ($%) {
  my $u = shift;
  my %opts = @_;
  my $p2gblataln_id;

  if ( defined $opts{pseq_id}) {
	($opts{chr},$opts{gstart},$opts{gstop},$p2gblataln_id) 
	  = Unison::get_blataln($u,$opts{pseq_id});
  }

  # expand gstart and gstop to include margin
  $opts{gstart} -= $opts{margin};
  $opts{gstop}  += $opts{margin};

  my $len = int( $opts{gstop} - $opts{gstart} );

  my $panel = Bio::Graphics::Panel->new( 
										-length => $len,
										-width => $opts{width},
										-start => $opts{gstart},
										-stop => $opts{gstop},
										-grid => 'true',
										-gridcolor => 'gainsboro',
										-pad_top => 10,
										-pad_left => 10,
										-pad_right => 100,
										-pad_bottom => 10,
										-key_style => 'between'
									   );

  $panel->add_track(
					-key => "Chr$opts{chr} from $opts{gstart} to $opts{gstop}",
					-key_font => 'gdSmallFont',
					-bump => +1,
				   );

  # coordinates
  $panel->add_track( Bio::Graphics::Feature->new
					 (-start => $opts{gstart}, -end => $opts{gstop}),
					 -glyph => 'arrow',
					 -tick => 1,
					 -fgcolor => 'black',
					 -double => 0,
					 -label => 1,
					 -description=>1
				   );


  add_blatloci( $u, $panel, %opts );

  $panel->add_track( ) for 1..2;         # spacing
  $panel->add_track( 
					-key => '$Id: genome-features,v 1.5 2004/03/12 01:07:15 rkh Exp $',
					-key_font => 'gdSmallFont',
					-bump => +1,
				   );

  return $panel;
}





#############################################################################################
## INTERNAL FUNCTIONS

#-------------------------------------------------------------------------------
# NAME: add_blatloci_features
# PURPOSE: add blat loci features to a panel
#-------------------------------------------------------------------------------
sub add_blatloci {
  my ($u, $panel, %opts) = @_;
  my $nadded = 0;
  my $plus_strand_track = $panel->add_track( 
    -glyph => 'graded_segments',
    -min_score => 0,
    -max_score => 1,
    -sort_order => 'high_score',
    -bgcolor => 'blue',
    -key => '+',
    -bump => +1,
    -label => 1,
    -fgcolor => 'black',
    -fontcolor => 'black',
    -font2color => 'red',
    -description => 1,
    -height => 4,
  );
  my $separator_track = $panel->add_track( Bio::Graphics::Feature->new
										   (-start => $opts{gstart},
											-end => $opts{gstop},
										   -glyph => 'generic',
										   -fgcolor => 'black',
										   -double => 0,
										   -label => 0,
										 ));
  my $rev_strand_track = $panel->add_track( 
    -glyph => 'graded_segments',
    -min_score => 0,
    -max_score => 1,
    -sort_order => 'high_score',
    -bgcolor => 'red',
    -key => '-',
    -bump => +1,
    -label => 1,
    -fgcolor => 'black',
    -fontcolor => 'black',
    -font2color => 'red',
    -description => 1,
    -height => 4,
  );

  my $sql = "select p2gblataln_id,pseq_id,ident,gstart,gstop,plus_strand from v_p2gblataln where "
    . "genasm_id=$opts{genasm_id} and "
    . "chr='$opts{chr}' and "
    . "gstart>=$opts{gstart} and "
    . "gstop<=$opts{gstop}";
  if (defined $opts{pseq_id} and not $opts{show_all}) {
	$sql .= " and pseq_id=$opts{pseq_id}";
  }
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $sth = $u->prepare($sql);
  $sth->execute();

  my $p2gblataln_id = -1;
  my ($plus_strand,$feat);
  while( my $r = $sth->fetchrow_hashref ) {
    # new BLAT alignment - create a new feature
    if ( $r->{p2gblataln_id} != $p2gblataln_id ) {
      # if we have a feat defined, then add it to the appropriate strand track
      if ( defined $feat && $feat->isa('Bio::Graphics::Feature') ) {
        if ( $plus_strand ) {
          $plus_strand_track->add_feature($feat);
        } else {
          $rev_strand_track->add_feature($feat);
        }
      }
      $p2gblataln_id = $r->{p2gblataln_id};
      $plus_strand = $r->{plus_strand};
      print STDERR "Get a new feature\n" if $opts{verbose};
      $feat = new Bio::Graphics::Feature->new(-name=>sprintf('Unison:%d (%s)',
															 $r->{pseq_id}, 
															 $u->best_alias($r->{pseq_id})||''));
      print STDERR "Add segment from $r->{gstart} .. $r->{gstop}\n" if $opts{verbose};
      $feat->add_segment( new Bio::Graphics::Feature->new(-start=>$r->{gstart},-end=>$r->{gstop}));
    }

    # same alignment - add sub features
    else {
      print STDERR "Add segment from $r->{gstart} .. $r->{gstop}\n" if $opts{verbose};
      $feat->add_segment( new Bio::Graphics::Feature->new(-start=>$r->{gstart},-end=>$r->{gstop}));
    }
    
  }

  # add remaining feature
  if ( defined $feat && $feat->isa('Bio::Graphics::Feature') ) {
    if ( $plus_strand ) {
      $plus_strand_track->add_feature($feat);
    } else {
      $rev_strand_track->add_feature($feat);
    }
    $nadded++;
  }

  return $nadded;
}


#-------------------------------------------------------------------------------
# NAME: add_p2gblataln
# PURPOSE: add blat alignment features to a track given a p2gblataln_id
#-------------------------------------------------------------------------------
sub add_p2gblataln {
  my ($u, $panel, $p2gblataln_id) = @_;
  my $nadded = 0;

  my $sql = "select * from p2gblatalnhsp natural join p2gblathsp where " .
    "p2gblataln_id=? order by gstart";

  my $sth = $u->prepare($sql);
  $sth->execute($p2gblataln_id);

  my $track = $panel->add_track(
    -glyph => 'graded_segments',
    -connector=>'solid',
    -min_score => 0,
    -max_score => 1,
    -sort_order => 'high_score',
    -bgcolor => 'green',
    -bump => +1,
    -label => 1,
    -fgcolor => 'black',
    -fontcolor => 'black',
    -font2color => 'red',
    -description => 1,
    -height => 4,
    );

  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $feat = new Bio::Graphics::Feature->new();
  while (my $r = $sth->fetchrow_hashref) {
    $feat->add_segment( new Bio::Graphics::Feature->new(-start=>$r->{gstart},-end=>$r->{gstop}));
    $nadded++;
  }
  $track->add_feature($feat);

  return $nadded;
}
