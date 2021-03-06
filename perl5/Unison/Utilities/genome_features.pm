
=head1 NAME

Unison::genome_features -- draw genomic features from Unison
S<$Id$>

=head1 SYNOPSIS

 use Unison;

=head1 DESCRIPTION

B<Unison::DBI> provides an object-oriented interface to the Unison
database.  It provides connection defaults for public access.  Unison
objects may be used anywhere that a standard DBI handle can be used.

=cut

package Unison::Utilities::genome_features;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT    = ();
our @EXPORT_OK = qw( genome_features_panel );

use Bio::Graphics;
use Bio::Graphics::Feature;
use Unison::pmap;
use Unison::Utilities::misc qw( unison_logo );

sub genome_features_panel($%);

our %opts = (
			 show_all      => undef,
			 genasm_id     => undef,
			 gstart        => undef,
			 gstop         => undef,
			 chr           => undef,
			 pseq_id       => undef,
			 width         => 750,
			 verbose       => 0,
			 margin        => 20000,
			 logo_margin   => 10,
			 min_pct_ident => 99,
			 min_pct_cov   => 90,
			);

=pod

=head1 ROUTINES & METHODS

=over

=cut

  ######################################################################
  ##  genome_features_panel

=pod

=item $u->genome_features_panel( C<%opts> )

genome_features_panel returns a Bio::Graphics::Panel. This panel may be
used to generate a graphic and or imagemap to depict genomic features.

%opts may contain the following keys:
  pseq_id
  genasm_id
  params_id
  chr, gstart, gstop
  margin
  width
  verbose

You'll have to look at examples or the code to figure out what they're
doing.

=cut

  sub genome_features_panel ($%) {
    my $u    = shift;
    my %opts = @_;
    my $pmap_aln_id;
    my $logo_margin = 10;

    if ( defined $opts{pseq_id} ) {
	  (
	   $opts{genasm_id}, $opts{chr}, $opts{gstart},
	   $opts{gstop},     $pmap_aln_id
	  ) = Unison::get_pmapaln_info( $u, $opts{pseq_id}, $opts{params_id} );
    }

    # expand gstart and gstop to include margin
    $opts{gstart} -= $opts{margin};
    $opts{gstop} += $opts{margin};

    my $len = int( $opts{gstop} - $opts{gstart} );

    my $panel = Bio::Graphics::Panel->new(
										  -length     => $len,
										  -width      => $opts{width},
										  -start      => $opts{gstart},
										  -stop       => $opts{gstop},
										  -grid       => 'true',
										  -gridcolor  => 'gainsboro',
										  -pad_top    => 10,
										  -pad_left   => 10,
										  -pad_right  => 100,
										  -pad_bottom => 10,
										  -key_style  => 'between'
										 );

    $panel->add_track(
					  -key      => "chr$opts{chr}:$opts{gstart}-$opts{gstop}",
					  -key_font => 'gdSmallFont',
					  -bump     => +1,
					 );

    # coordinates
    $panel->add_track(
					  Bio::Graphics::Feature->new(
												  -start => $opts{gstart},
												  -end   => $opts{gstop}
												 ),
					  -glyph       => 'arrow',
					  -tick        => 1,
					  -fgcolor     => 'black',
					  -double      => 0,
					  -label       => 1,
					  -description => 1
					 );

    add_pmaploci( $u, $panel, %opts );

    $panel->add_track( -key => 'Affymetrix and Agilent Probes' );
    $panel->add_track();					# spacing
    $panel->add_track(
					  -key_font => 'gdSmallFont',
					  -bgcolor  => 'green',
					  -bump     => +1,
					  add_probes( $u, $panel, %opts )
					 );

	# Add version string and logo
    my $gd = $panel->gd();
    my ( $dw, $dh ) = $gd->getBounds();
    my $black = $gd->colorResolve( 0, 0, 0 );
    my $IdFont = GD::Font->MediumBold;
    $gd->string(
				$IdFont,
				$opts{logo_margin},
				$dh - $opts{logo_margin} - $IdFont->height,
				'$Id$',
				$black
			   );
    my $ugd = unison_logo();
    if ( defined $ugd ) {
	  my ( $sw, $sh ) = $ugd->getBounds();
	  $gd->copy(
				$ugd,
				$dw - $sw - $opts{logo_margin},
				$dh - $sh - $opts{logo_margin},
				0, 0, $sw, $sh
			   );
    }

    return $panel;
  }

#############################################################################################
## INTERNAL FUNCTIONS

#-------------------------------------------------------------------------------
# NAME: add_pmaploci_features
# PURPOSE: add pmap loci features to a panel
#-------------------------------------------------------------------------------
sub add_pmaploci {
  my ( $u, $panel, %opts ) = @_;
  my $nadded            = 0;
  my $plus_strand_track = $panel->add_track(
											-glyph       => 'graded_segments',
											-min_score   => 0,
											-max_score   => 1,
											-sort_order  => 'high_score',
											-bgcolor     => 'blue',
											-key         => '+',
											-bump        => +1,
											-label       => 1,
											-fgcolor     => 'black',
											-fontcolor   => 'black',
											-font2color  => 'red',
											-description => 1,
											-height      => 4,
										   );
  my $separator_track = $panel->add_track(
										  Bio::Graphics::Feature->new(
																	  -start   => $opts{gstart},
																	  -end     => $opts{gstop},
																	  -glyph   => 'generic',
																	  -fgcolor => 'black',
																	  -double  => 0,
																	  -label   => 0,
																	 )
										 );
  my $rev_strand_track = $panel->add_track(
										   -glyph       => 'graded_segments',
										   -min_score   => 0,
										   -max_score   => 1,
										   -sort_order  => 'high_score',
										   -bgcolor     => 'red',
										   -key         => '-',
										   -bump        => +1,
										   -label       => 1,
										   -fgcolor     => 'black',
										   -fontcolor   => 'black',
										   -font2color  => 'red',
										   -description => 1,
										   -height      => 4,
										  );

  # if opts{pseq_id} is specified, ensure that it is shown in the panel
  my $q_pred = defined $opts{pseq_id} ? "pseq_id=$opts{pseq_id}" : 'TRUE';

  my $sql = <<EOSQL;
SELECT aln_id,pseq_id,ident,gstart,gstop,strand
FROM pmap_mv
WHERE genasm_id=$opts{genasm_id}
  AND params_id=$opts{params_id}
  AND chr='$opts{chr}' AND gstart>=$opts{gstart} AND gstop<=$opts{gstop}
  AND (pct_ident>=$opts{min_pct_ident} OR $q_pred)
EOSQL
  if ( defined $opts{pseq_id} and not $opts{show_all} ) {
														   $sql .= " and pseq_id=$opts{pseq_id}";
														 }
  print( STDERR $sql, ";\n\n" ) if $opts{verbose};
  my $sth = $u->prepare($sql);
  $sth->execute();

  my $pmap_aln_id = -1;
  my ( $strand, $feat );
  while ( my $r = $sth->fetchrow_hashref ) {

	# new BLAT alignment - create a new feature
	if ( $r->{aln_id} != $pmap_aln_id ) {

	  # if we have a feat defined, then add it to the appropriate strand track
	  if ( defined $feat && $feat->isa('Bio::Graphics::Feature') ) {
		if ( $strand eq '+' ) {
		  $plus_strand_track->add_feature($feat);
		} else {
		  $rev_strand_track->add_feature($feat);
		}
	  }
	  $pmap_aln_id = $r->{aln_id};
	  $strand      = $r->{strand};

	  my $ba =    $u->best_alias( $r->{pseq_id}, 'HUMAN' )
		       || $u->best_alias( $r->{pseq_id} );
	  $feat =
		new Bio::Graphics::Feature->new(
										-name => sprintf( 'Unison:%d (%s)',
														  $r->{pseq_id},
														  $ba||'?' )
									   );
	  print STDERR "Add segment from $r->{gstart} .. $r->{gstop}\n"
		if $opts{verbose};
	  $feat->add_segment(
						 new Bio::Graphics::Feature->new(
														 -start => $r->{gstart},
														 -end   => $r->{gstop}
														)
						);
	}

	# same alignment - add sub features
	else {
	  print STDERR "Add segment from $r->{gstart} .. $r->{gstop}\n"
		if $opts{verbose};
	  $feat->add_segment(
						 new Bio::Graphics::Feature->new(
														 -start => $r->{gstart},
														 -end   => $r->{gstop}
														)
						);
	}
  }

  # add remaining feature
  if ( defined $feat && $feat->isa('Bio::Graphics::Feature') ) {
	if ( $strand eq '+' ) {
	  $plus_strand_track->add_feature($feat);
	} else {
	  $rev_strand_track->add_feature($feat);
	}
	$nadded++;
  }

  return $nadded;
}

#-------------------------------------------------------------------------------
# NAME: add_probes
# PURPOSE: add probe features to a panel
#-------------------------------------------------------------------------------
sub add_probes {
  my ( $u, $panel, %opts ) = @_;
  my $nadded = 0;

  my $plus_strand_track = $panel->add_track(
											-glyph       => 'graded_segments',
											-min_score   => 0,
											-max_score   => 1,
											-sort_order  => 'high_score',
											-bgcolor     => 'green',
											-key         => '+',
											-bump        => +1,
											-label       => 1,
											-fgcolor     => 'black',
											-fontcolor   => 'black',
											-font2color  => 'red',
											-description => 1,
											-height      => 4,
										   );
  my $separator_track = $panel->add_track(
										  Bio::Graphics::Feature->new(
																	  -start  => $opts{gstart},
																	  -end    => $opts{gstop},
																	  -glyph  => 'generic',
																	  -double => 0,
																	  -label  => 0,
																	 )
										 );
  my $rev_strand_track = $panel->add_track(
										   -glyph       => 'graded_segments',
										   -min_score   => 0,
										   -max_score   => 1,
										   -sort_order  => 'high_score',
										   -bgcolor     => 'green',
										   -key         => '-',
										   -bump        => +1,
										   -label       => 1,
										   -fgcolor     => 'black',
										   -fontcolor   => 'black',
										   -font2color  => 'red',
										   -description => 1,
										   -height      => 4,
										  );

  my $sql = <<EOSQL;
SELECT name,probe_id,gstart,gstop,strand
FROM marray.chip_probe_v
WHERE genasm_id=$opts{genasm_id}
  AND chr='$opts{chr}' AND gstart>=$opts{gstart} AND gstop<=$opts{gstop}
EOSQL

  print( STDERR $sql, ";\n\n" ) if $opts{verbose};
  my $sth = $u->prepare($sql);
  $sth->execute();
  my ( $strand, $feat );
  while ( my $r = $sth->fetchrow_hashref ) {

	# if we have a feat defined, then add it to the appropriate strand track
	if ( defined $feat && $feat->isa('Bio::Graphics::Feature') ) {
	  if ( $strand eq '+' ) {
		$plus_strand_track->add_feature($feat);
	  } else {
		$rev_strand_track->add_feature($feat);
	  }
	}
	$strand = $r->{strand};
	print STDERR "Get a new feature\n" if $opts{verbose};
	$feat = new Bio::Graphics::Feature->new(
											-name => sprintf( '%s:%s', $r->{name}, $r->{probe_id} || '?' ) );
	print STDERR "Add segment from $r->{gstart} .. $r->{gstop}\n"
	  if $opts{verbose};
	$feat->add_segment(
					   new Bio::Graphics::Feature->new(
													   -start => $r->{gstart},
													   -end   => $r->{gstop}
													  )
					  );
  }
  return $nadded;
}

#-------------------------------------------------------------------------------
# NAME: add_pmap_aln
# PURPOSE: add blat alignment features to a track given a pmap_aln_id
#-------------------------------------------------------------------------------
sub add_pmap_aln {
  my ( $u, $panel, $pmap_aln_id ) = @_;
  my $nadded = 0;

  my $sql =
	"select * from pmap_alnhsp AH join pmap_hsp H on AH.hsp_id=H.hsp_id where "
      . "AH.aln_id=? order by gstart";

  my $sth = $u->prepare($sql);
  $sth->execute($pmap_aln_id);

  my $track = $panel->add_track(
								-glyph       => 'graded_segments',
								-connector   => 'solid',
								-min_score   => 0,
								-max_score   => 1,
								-sort_order  => 'high_score',
								-bgcolor     => 'green',
								-bump        => +1,
								-label       => 1,
								-fgcolor     => 'black',
								-fontcolor   => 'black',
								-font2color  => 'red',
								-description => 1,
								-height      => 4,
							   );

  print( STDERR $sql, ";\n\n" ) if $opts{verbose};
  my $feat = new Bio::Graphics::Feature->new();
  while ( my $r = $sth->fetchrow_hashref ) {
	$feat->add_segment(
					   new Bio::Graphics::Feature->new(
													   -start => $r->{gstart},
													   -end   => $r->{gstop}
													  )
					  );
	$nadded++;
  }
  $track->add_feature($feat);

  return $nadded;
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
