
=head1 NAME

Unison::Utilities::pseq_features --  functions for displaying pseq_features in Unison

S<$Id$>

=head1 SYNOPSIS

 use Unison;
 use Unison::Utilities::pseq_features;
 my $u = new Unison(...);

=head1 DESCRIPTION

=cut

## FIXME: Many of the feature selections below don't use params_id.  Shame
## shame shame.

## FIXME: put run_history timestamp in track label (or, instead, just
## indicate when it hasn't been run)

## FIXME: ALWAYS check return val for functions like params_id(). When
## they're null/undef, we need to return. When uncaught (eg, in pub web
## site when params doesn't exist), the page barfs.

## BUG: feature tooltips should be html-escaped, but unsure where.


package Unison::Utilities::pseq_features;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT    = ();
our @EXPORT_OK = qw( pseq_features_panel %opts );

use Bio::Graphics;
use Bio::Graphics::Feature;
use Unison::params;
use Unison::run;
use Unison::Utilities::misc qw( warn_deprecated unison_logo elide_sequence context_highlight );
use Unison::Utilities::pseq_structure;

use Data::Dumper;

my @default_panel_features = qw ( antigenic bigpi disprot hmm psipred
  netphos pepcoil prospect regexp signalp tmdetect tmhmm );

# pssm sigcleave

our %opts = (
			 pseq_id     => undef,
			 width       => 750,
			 verbose     => 0,
			 pad         => 10,
			 logo_margin => 10,
			 seq_context_margin => 5, 		# left & right margin for
                                            # feature context

			 # this is the default track length needed for imagemap links
			 def_track_length => 60,
			 synopsis         => 0,
);

=pod

=head1 ROUTINES AND METHODS

=over

=cut

sub new($$%) {
    my $self = bless( {}, shift );
    $self->{panel} = pseq_features_panel(@_);
    return $self;
}

sub as_png() {
    my $self = shift;
    return $self->{panel}->gd()->png();
}

sub imagemap_body($) {
  my $self     = shift;
  my $imagemap = '';
  foreach my $box ( $self->{panel}->boxes() ) {
	my ( $feature, $x1, $y1, $x2, $y2 ) = @$box;
	my $attr = $feature->{attributes};
	next unless defined $attr;
	$imagemap .= "<AREA SHAPE=\"RECT\" COORDS=\"$x1,$y1,$x2,$y2\"";
	$imagemap .= " TOOLTIP=\"$attr->{tooltip}\"" if defined $attr->{tooltip};
	$imagemap .= " HREF=\"$attr->{href}\""       if defined $attr->{href};
	$imagemap .= ">\n";
  }
  return $imagemap;
}

######################################################################
## pseq_features_panel

=pod

=over

=item B<< pseq_features_panel( C<Unison>, C<%opts> ) >>

=back

=cut

sub pseq_features_panel($%) {
    my $u    = shift;
    my %opts = ( %opts, @_ );
    my $tick = 1;

    my $len =
      $u->selectrow_array("select len from pseq where pseq_id=$opts{pseq_id}");
    if ( not defined $len ) {
        warn("$0: Unison:$opts{pseq_id} doesn't exist\n");
        return undef;
    }

    if ( not defined( $opts{features} ) ) {
        $opts{features}{$_}++ foreach @default_panel_features;
    }

    if ( defined( $opts{track_length} ) ) {
        # This is an opaque conditional which should be rewritten.
        # Kiran's attempting to say that "when track length is set,
        # we're doing the detailed psipred prediction display and
        # we'll turn off everything but psipred".
        $opts{features}{$_} = 0 foreach ( keys %{ $opts{features} } );
        $opts{features}{psipred} = 1;
        $tick = 2;
    }
    else {
        $opts{track_length} = int( $len / 10 + 1 ) * 10;
    }

    my $ba = (
			     $u->best_alias( $opts{pseq_id}, 'HUMAN' )
			  || $u->best_alias( $opts{pseq_id} )
			 );

    my $panel = Bio::Graphics::Panel->new(
        -spacing    => 10,
        -length     => $opts{track_length},
        -width      => $opts{width},
        -pad_top    => $opts{pad},
        -pad_left   => $opts{pad} * 2,
        -pad_right  => $opts{pad},
        -pad_bottom => $opts{pad},
        -key_style  => 'between'
    );

    $panel->add_track(
        Bio::Graphics::Feature->new(
            -start => 1,
            -end   => $len,
            -name =>
              sprintf( "Unison:%d; %d AA; %s", $opts{pseq_id}, $len, $ba || '' )
        ),
        -glyph       => 'arrow',
        -tick        => $tick,
        -fgcolor     => 'black',
        -double      => 0,
        -label       => 1,
        -description => 1
    );

    add_pftemplate( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure} )
      if ( $opts{features}{template} );

    # sequence composition features
    add_psdisprot( $u, $panel, $opts{pseq_id} ) if ( $opts{features}{disprot} );
    add_pfpsipred( $u, $panel, $opts{pseq_id}, $len, $opts{track_length} )
      if ( $opts{features}{psipred} );
    add_pfseg( $u, $panel, $opts{pseq_id} ) if ( $opts{features}{pfseg} );
    add_pfpepcoil( $u, $panel, $opts{pseq_id} ) if ( $opts{features}{pepcoil} );
    add_pfantigenic( $u, $panel, $opts{pseq_id} )
      if ( $opts{features}{antigenic} );
    add_pfnetphos( $u, $panel, $opts{pseq_id} )
      if ( $opts{features}{netphos} );

    # sequence signals
    add_pfsigcleave( $u, $panel, $opts{pseq_id} )
      if ( $opts{features}{sigcleave} );
    add_pfsignalp( $u, $panel, $opts{pseq_id} ) if ( $opts{features}{signalp} );
    add_pftmhmm( $u, $panel, $opts{pseq_id} ) if ( $opts{features}{tmhmm} );
    add_pftmdetect( $u, $panel, $opts{pseq_id} )
      if ( $opts{features}{tmdetect} );
    add_pfbigpi( $u, $panel, $opts{pseq_id} ) if ( $opts{features}{bigpi} );

    # motifs and domains
    add_pfregexp( $u, $panel, $opts{pseq_id} ) if ( $opts{features}{regexp} );
    add_pahmm( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure} )
      if ( $opts{features}{hmm} );
    add_paprospect( $u, $panel, $opts{pseq_id} )
      if ( $opts{features}{prospect} );

    # additional data
    add_pfsnp( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure} )
      if ( $opts{features}{snp} );
    add_pfuser( $u, $panel, $opts{pseq_id}, $opts{view}, $opts{structure},
        $opts{user_feats} )
      if ( $opts{features}{user} );

    $panel->add_track() for 1 .. 3;    # spacing


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

######################################################################
## add_pftmdetect

=pod

=item B<< add_pfseg( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pftmdetect features to a panel and return the number of features added.

=cut

sub add_pfseg {
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;
    my $track  = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 0,
        -max_score   => 4,
        -sort_order  => 'high_score',
        -bgcolor     => 'blue',
        -key         => 'seg low complexity regions',
        -bump        => +1,
        -label       => 1,
        -fgcolor     => 'black',
        -fontcolor   => 'black',
        -font2color  => 'red',
        -description => 1,
        -height      => 4,
    );
    my $sql = "select start,stop,score from pfseg where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -score      => $r->[2],
                -attributes => { tooltip => _feature_tooltip(
									 $seq, $r->[0],
									 $r->[1], "score=$r->[2]") }
            )
        );
        $nadded++;
    }
    return $nadded;
}

#-------------------------------------------------------------------------------
# NAME: add_pfpsipred
# PURPOSE: add pfpsipred features to a panel
# ARGUMENTS: Unison object, Bio::Graphics::Feature object, pseq_id
# RETURNS: count of features added
#-------------------------------------------------------------------------------
sub add_pfpsipred {
    my ( $u, $panel, $q, $len, $track_length ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my ($nadded) = (0);
    my ( $sql, $featref );
    my @strands_helices = ();
    @{ $strands_helices[0] } = ();    #initialize for add track

    my $num_tracks = ( $len / $track_length );
    my $href =
      ( $track_length < $len
        ? ''
        : "pseq_features.pl?pseq_id=$q&track_length=$opts{def_track_length}" );

    # get the ssp confidence string
    $sql = "select confidence from psipred where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    $featref = $u->selectall_arrayref($sql);

    my $confidence_string = $$featref[0]->[0];

    # add pfpsipred feature
    $sql = "select start,stop,type from pfpsipred where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    $featref = $u->selectall_arrayref($sql);

    foreach my $r (@$featref) {
        $nadded++;
        my $track_number = int( ( $r->[0] - 1 ) / $track_length );
        my $score = avg_confidence( $r->[0], $r->[1], $confidence_string );
        my $start = $r->[0] - ( $track_length * $track_number );
        my $end   = $r->[1] - ( $track_length * $track_number );
        while ( $end > $track_length ) {
            $end = $track_length;
            push(
                @{ $strands_helices[$track_number] },
                new Bio::Graphics::Feature(
                    -start      => $start,
                    -end        => $end,
                    -type       => $r->[2],
                    -name       => $r->[2],
                    -score      => $score,
                    -attributes => {
                        tooltip => _feature_tooltip($seq, $r->[0], $r->[1],
													sprintf( 'average confidence=%.2f', $score )),
                        href => $href
                    }
                )
            );
            $start = 1;
            $end =
              ( $r->[1] - ( $track_length * $track_number ) ) - $track_length;
            $track_number++;
        }
        push(
            @{ $strands_helices[$track_number] },
            new Bio::Graphics::Feature(
                -start      => $start,
                -end        => $end,
                -type       => $r->[2],
                -name       => $r->[2],
                -score      => $score,
                -attributes => {
                        tooltip => _feature_tooltip($seq, $r->[0], $r->[1],
													sprintf( 'average confidence=%.2f', $score )),
						href => $href
                }
            )
        );
    }

    for ( my $i = 0 ; $i <= $num_tracks ; $i++ ) {
        my $key =
          ( $num_tracks < 1
            ? 'PSIPRED secondary structure prediction'
            : $track_length * $i + 1 );
        my $track = $panel->add_track(
             generic => [ @{ $strands_helices[$i] } ],
            -glyph   => \&glyph_type,
            -key     => $key,
            -bump    => 0,
            -bgcolor => \&glyph_color,
            -fgcolor => \&glyph_color,
            -east    => 1,

            #-arrowstyle => "filled",
            -fontcolor   => 'black',
            -description => 1,
            -min_score   => 0,
            -max_score   => 8,
            -linewidth   => sub {
                my $feat = shift @_;
                return '2' if $feat->type eq 'E';
                return '2' if $feat->type eq 'C';
            },
        ) if ( defined( $strands_helices[$i] ) );
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
    my ( $u, $panel, $q ) = @_;
    my $nadded = 0;
    my ( $sql, $featref );
    my $track = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 0,
        -max_score   => 1,
        -sort_order  => 'high_score',
        -bgcolor     => 'cyan',
        -key         => 'SignalP',
        -bump        => +1,
        -label       => 1,
        -fgcolor     => 'black',
        -fontcolor   => 'black',
        -font2color  => 'red',
        -description => 1,
        -height      => 4,
    );
	my $seq = $u->get_sequence_by_pseq_id($q);

    # add pfsignalpnn feature
    ## REVIEW: 2005-12-06 Reece: pftype join unused
    $sql = "select start,stop,pftype.name,d_score
           from pfsignalpnn natural join pftype where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -name       => sprintf( "NN  (%3.2f)", $r->[3] ),
                -score      => $r->[3],
                -attributes => { tooltip => _feature_tooltip( $seq, $r->[0], $r->[1], '"D" score='.$r->[3]) }
            )
        );
        $nadded++;
    }

    # add pfsignalphmm feature
    ## REVIEW: 2005-12-06 Reece: pftype join unused
    $sql = "select start,stop,pftype.name,sig_peptide_prob
           from pfsignalphmm natural join pftype where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -name       => sprintf( "HMM (%3.2f)", $r->[3] ),
                -score      => $r->[3],
                -attributes => { tooltip => _feature_tooltip( $seq, $r->[0], $r->[1], "signal peptide probability = $r->[3]") }
            )
        );
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
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;
    my $track  = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 0,
        -max_score   => 1,
        -sort_order  => 'high_score',
        -bgcolor     => 'blue',
        -key         => 'tmdetect (may overlap)',
        -bump        => +1,
        -label       => 1,
        -fgcolor     => 'black',
        -fontcolor   => 'black',
        -font2color  => 'red',
        -description => 1,
        -height      => 4,
    );
    my $sql = "select start,stop,type,prob from pftmdetect where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -name       => $r->[2],
                -score      => $r->[3],
                -attributes => { tooltip => _feature_tooltip($seq, $r->[0], $r->[1], "p=$r->[3]") }
            )
        );
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
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;
    my $track  = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 0,
        -max_score   => 1,
        -sort_order  => 'high_score',
        -bgcolor     => 'purple',
        -key         => 'TMHMM (o=out, i=in, N=o->i, M=i->i)',
        -bump        => +1,
        -label       => 1,
        -fgcolor     => 'black',
        -fontcolor   => 'black',
        -font2color  => 'red',
        -description => 1,
        -height      => 4,
    );
    my $sql     = "select start,stop,type from pftmhmm where pseq_id=$q";
    my $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        my $type = 
			  $r->[2] eq 'o' ? 'extracellular (outside)'
			: $r->[2] eq 'i' ? 'intracellular (inside)'
			: $r->[2] eq 'M' ? 'transmembrane outside->inside'
			: $r->[2] eq 'N' ? 'transmembrane inside->outside'
			: 'unknown prediction';
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -name       => $r->[2],
                -score      => $r->[3],
                -attributes => { tooltip => _feature_tooltip($seq,$r->[0],$r->[1],$type) }
            )
        );
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
    my ( $u, $panel, $q, $params_id ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my ( $svm_thr, $topN ) = ( 7, 5 );
    my $nadded = 0;
    my $run_id = $u->preferred_run_id_by_pftype('Prospect');
    $params_id = $u->get_run_params_id($run_id) unless defined $params_id;
    return unless defined $params_id;

    my $params_name = $u->get_params_name_by_params_id($params_id);
    my $z = $u->get_run_timestamp_ymd( $q, $run_id );

    my $sth = $u->prepare(<<EOT);
SELECT *
FROM paprospect_scop_v
WHERE pseq_id=$q AND svm >= $svm_thr and params_id=$params_id
EOT
    $sth->execute();

    my @raw_data;
    while ( my $row = $sth->fetchrow_hashref() ) {
        push @raw_data, $row;
    }
    my $feats = coalesce_scop( $u, \@raw_data );
    my $nfeat = scalar( @{$feats} );
    splice( @{$feats}, $topN ) if $nfeat > $topN;
    my $track = $panel->add_track(
        -glyph   => 'graded_segments',
        -bgcolor => 'green',
        -key     => sprintf(
            'Prospect Threading (%s); top %d hits of %d w/svm>=%s',
            $params_name, ( $#$feats + 1 ),
            $nfeat, $svm_thr
        ),
        -bump        => +1,
        -label       => 1,
        -fgcolor     => 'black',
        -font2color  => 'red',
        -description => 1,
        -height      => 4,
        -bgcolor     => 'green',
        -min_score   => 5,
        -max_score   => 11,
        -sort_order  => 'high_score',
    );
    foreach my $row ( @{$feats} ) {
        my %scopsf;    # superfamily names
        my $scop     = '';    # scop classifications (cl > sf > dm)
        my $scoplink = '';

        my @scops = @{ $row->{scop} };
        for ( my $i = 0 ; $i < $#scops + 1 ; $i++ ) {
            my %scopi = %{ $scops[$i] };
            $scopsf{ $scopi{sfname} }++;
            $scop .= sprintf( "%d-%d: %s > %s > %s\n",
                $row->{start}, $row->{stop}, @scopi{qw(clname sfname dmname)} );
            $scoplink = sprintf( 'http://scop.berkeley.edu/search.cgi?sunid=%d',
                $scopi{dmid} );
        }

        my $name = sprintf( "%s; raw=%s; svm=%s; (%s)",
            $row->{acc}, $row->{raw}, $row->{svm},
            join( ' AND ', sort keys %scopsf ) );
        printf( STDERR " add track: $name\n" ) if $opts{verbose};
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $row->{start},
                -end        => $row->{stop},
                -score      => $row->{svm},
                -name       => $name,
                -attributes => {
                    tooltip => _feature_tooltip($seq,$row->{start}, $row->{stop}, $scop),
                    href    => $scoplink
                }
            )
        );
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
    my ( $u, $featref ) = @_;

    my ( $curr_acc, @scop, @retval, %row );
    my $cnt = 0;
    foreach my $r ( @{$featref} ) {
        $cnt++;
        if ( ( defined $curr_acc ) && ( $r->{acc} ne $curr_acc ) ) {
            $row{scop} = [@scop];

            # don't return sunids
            delete $row{clid};
            delete $row{clname};
            delete $row{sfid};
            delete $row{sfname};
            delete $row{dmid};
            delete $row{dmname};
            push @retval, { map { $_, $row{$_} } keys %row };
            @scop = ();
        }

        # copy key/value pairs from old ($r) to new (%row) hash
        foreach my $k ( keys %{$r} ) {

            # skip the scop info in the $r hashref. this will all
            # go into the scop value of the %row hash
            next
              if ( $k eq 'clid'
                or $k eq 'clname'
                or $k eq 'sfid'
                or $k eq 'sfname'
                or $k eq 'dmid'
                or $k eq 'dmname' );
            $row{$k} = $r->{$k};
        }
        push @scop,
          {
            'clid'   => $r->{clid},
            'clname' => $r->{clname},
            'sfid'   => $r->{sfid},
            'sfname' => $r->{sfname},
            'dmid'   => $r->{dmid},
            'dmname' => $r->{dmname}
          };
        $curr_acc = $row{acc};
        if ( $cnt == scalar(@$featref) ) {
            $row{scop} = [@scop];
            push @retval, \%row;
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
    my ( $u, $panel, $q, $view, $pseq_structure ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my ( $eval_thr, $topN ) = ( 1, 4 );
    my $nadded = 0;
    ## XXX: don't hardwire the following
    my $run_id      = $u->preferred_run_id_by_pftype('HMM');
    my $params_id   = $u->get_run_params_id($run_id);
    my $params_name = $u->get_params_name_by_params_id($params_id);
    my $z           = $u->get_run_timestamp_ymd( $q, $run_id );

    my $sql = <<EOSQL;
SELECT start,stop,score,eval,acc,feature,descr,link_url
FROM pseq_features_pfam_v
WHERE pseq_id=? AND eval<=? ORDER BY start
EOSQL
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref( $sql, undef, $q, $eval_thr );
    my $track = $panel->add_track(
        -glyph      => 'graded_segments',
        -min_score  => 1,
        -max_score  => 25,
        -sort_order => 'high_score',
        -key        => sprintf(
            'HMM (%s); %d w/eval<=%s',
            $params_name, ( $#$featref + 1 ), $eval_thr
        ),
        -bgcolor     => 'blue',
        -bump        => +1,
        -label       => 1,
        -fgcolor     => 'black',
        -fontcolor   => 'black',
        -font2color  => 'red',
        -description => 1,
        -height      => 4,
    );

    foreach my $r (@$featref) {
        next unless defined $r->[0];

        #printf(STDERR "[%d,%d] %s\n", @$r[0,1,2]);
        my $href = (
              $view
            ? $pseq_structure->region_script( $r->[0], $r->[1], $r->[5] )
            : $r->[7]
        );
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -score      => $r->[2],
                -name       => sprintf( "%s; S=%s; E=%s)", @$r[ 5, 2, 3 ] ),
                -attributes => {
                    tooltip => _feature_tooltip($seq, @$r[0,1], 
												sprintf("%s [%s]", @$r[5,6])),
                    href    => $href
                },
            )
        );
        $nadded++;
    }
    return $nadded;
}

######################################################################
## add_pappsm

=pod

=item B<< add_papssm( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pappsm features to a panel and return the number of features added.

=cut

sub add_papssm {
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my ( $eval_thr, $topN ) = ( 5, 4 );
    my $nadded      = 0;
    my $params_id   = $u->preferred_params_id_by_pftype('PSSM');
    my $params_name = $u->get_params_name_by_params_id($params_id);
    my $z           = $u->get_run_timestamp_ymd( $q, $params_id, undef, undef )
      || 'NOT RUN';
    my $sql = <<EOSQL;
SELECT A.start,A.stop,M.acc as "model",A.score,A.eval
  FROM papssm A
  JOIN pmpssm M on A.pmodel_id=M.pmodel_id
 WHERE pseq_id=? AND params_id=? AND eval<=? ORDER BY eval;
EOSQL
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref =
      $u->selectall_arrayref( $sql, undef, $q, $params_id, $eval_thr );
    my $nfeat = $#$featref + 1;
    splice( @$featref, $topN ) if $#$featref > $topN;
    my $track = $panel->add_track(
        -glyph      => 'graded_segments',
        -min_score  => 100,
        -max_score  => 500,
        -sort_order => 'high_score',
        -bgcolor    => 'red',
        -key        => sprintf(
            'PSSM/SBP; top %d hits of %d w/eval<=%s',
            ( $#$featref + 1 ),
            $nfeat, $eval_thr
        ),
        -bump        => +1,
        -label       => 1,
        -fgcolor     => 'black',
        -fontcolor   => 'black',
        -font2color  => 'red',
        -description => 1,
        -height      => 4,
    );

    foreach my $r (@$featref) {
        next unless defined $r->[0];

        #printf(STDERR "[%d,%d] %s\n", @$r[0,1,2]);
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start => $r->[0],
                -end   => $r->[1],
                -score => $r->[3],
                -name =>
                  sprintf( "%s; S=%s; E=%s)", $r->[2], $r->[3], $r->[4] ),
                -attributes => { tooltip => _feature_tooltip($seq,$r->[0],$r->[1]) }
            )
        );
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
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;

    my $r     = $u->preferred_run_id_by_pftype('EMBOSS/antigenic');
    my $p     = $u->get_run_params_id($r);
    my $z     = $u->get_run_timestamp_ymd( $q, $r ) || 'NOT RUN';
    my $track = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 1,
        -max_score   => 1.2,
        -sort_order  => 'high_score',
        -bgcolor     => 'green',
        -key         => "EMBOSS/antigenic (ran on $z)",
        -bump        => +1,
        -label       => 1,
        -description => 1,
        -height      => 4,
    );
    my $sql = <<EOSQL;
  SELECT start,stop,score,subseq
    FROM pfantigenic_v
   WHERE pseq_id=$q
ORDER BY score
   LIMIT 25
EOSQL
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);

    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -score      => $r->[2],
                -name       => sprintf("%.1f",$r->[2]),
                -attributes => { tooltip => _feature_tooltip($seq,$r->[0],$r->[1],"score=$r->[2]") }
            )
        );
        $nadded++;
    }
    return $nadded;
}

######################################################################
## add_pfnetphos

=pod

=item B<< add_pfnetphos( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pfnetphos features to a panel and return the number of features added.

=cut

sub add_pfnetphos {
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;

    my $r     = $u->preferred_run_id_by_pftype('netphos');
    my $p     = $u->get_run_params_id($r);
    my $z     = $u->get_run_timestamp_ymd( $q, $r ) || 'NOT RUN';
    my $track = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 0.5,
        -max_score   => 1,
        -sort_order  => 'high_score',
        -bgcolor     => 'green',
        -key         => "netphos (ran on $z)",
        -bump        => +1,
        -label       => 1,
        -description => 1,
        -height      => 4,
    );
    my $sql = <<EOSQL;
  SELECT start,score,feature,descr
    FROM pseq_features_netphos_v
   WHERE pseq_id=$q
ORDER BY start
EOSQL
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);

    foreach my $r (@$featref) {
	  my $desc = $r->[3];
	  $desc =~ s/^predicted phospho-\w\w\w; //;
	  $track->add_feature(
						  Bio::Graphics::Feature->new(
													  -start      => $r->[0],
													  -end        => $r->[0],
													  -score      => $r->[1],
													  -name       => ($r->[2] eq 'pSer'
																	  ? 'pS'
																	  : $r->[2] eq 'pThr'
																	  ? 'pT' 
																	  : $r->[2] eq 'pTyr'
																	  ? 'pY'
																	  : '?'
																	 ),
													  -attributes => { tooltip => 
																	   sprintf("%d (<code>%s</code>)<br>max score=%s<br>kinases: %s",
																			   $r->[0],
																			   _feature_context( $seq, $r->[0], $r->[0] ),
																			   $r->[1],
																			   $desc)
																	 }
													 )
						 );
	  $nadded++;
    }
    return $nadded;
}

######################################################################
## add_pfpepcoil

=pod

=item B<< add_pfpepcoil( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add pfpepcoil features to a panel and return the number of features added.

=cut

sub add_pfpepcoil {
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;

    my $r     = $u->preferred_run_id_by_pftype('EMBOSS/pepcoil');
    my $p     = $u->get_run_params_id($r);
    my $z     = $u->get_run_timestamp_ymd( $q, $r ) || 'NOT RUN';
    my $track = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 0.5,
        -max_score   => 1,
        -sort_order  => 'high_score',
        -bgcolor     => 'purple',
        -key         => "EMBOSS/pepcoil (ran on $z)",
        -bump        => 1,
        -label       => 1,
        -description => 1,
        -height      => 4,
    );
    my $sql = <<EOSQL;
  SELECT F.start,F.stop,F.score,F.prob,substr(Q.seq,F.start,F.stop-F.start+1) as subseq
    FROM pfpepcoil F
    JOIN pseq Q on F.pseq_id=Q.pseq_id
   WHERE F.pseq_id=$q
         AND F.params_id=$p
EOSQL
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);

    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -score      => $r->[3],    # prob!
                -name       => elide_sequence( $r->[4] ),
                -attributes => {
                    tooltip => _feature_tooltip($seq, @$r[0,1],
												"score=$r->[2]; prob=$r->[3]")
                }
            )
        );
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
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;
    my $track  = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 2.5,
        -max_score   => 9,
        -sort_order  => 'high_score',
        -bgcolor     => 'blue',
        -key         => 'EMBOSS/sigcleave',
        -bump        => +1,
        -label       => 1,
        -description => 1,
        -height      => 4,
    );
    my $sql = "select start,stop,score from pfsigcleave where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -score      => $r->[2],
                -name       => $r->[2],
                -attributes => { tooltip => _feature_tooltip($seq,$r->[0],$r->[1]) }
            )
        );
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
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $nadded = 0;
    my $track  = $panel->add_track(
        -glyph       => 'graded_segments',
        -min_score   => 2.5,
        -max_score   => 9,
        -sort_order  => 'high_score',
        -bgcolor     => 'blue',
        -key         => 'BigPI GPI anchor',
        -bump        => +1,
        -label       => 1,
        -description => 1,
        -height      => 4,
    );
    my $sql = "select start,quality from pfbigpi_v where pseq_id=$q";
    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start => $r->[0],
                -end   => $r->[0],
                -score => (
                    $r->[1] == 'A'   ? 4
                    : $r->[1] == 'B' ? 3
                    : $r->[1] == 'C' ? 2
                    : $r->[1] == 'D' ? 1
                    : 0
                ),
                -name => 'GPI @ ' . $r->[0],
            )
        );
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
    my ( $u, $panel, $q ) = @_;
	my $seq = $u->get_sequence_by_pseq_id($q);
    my $subseq_len = 15;
    my $nadded     = 0;
    my $track      = $panel->add_track(
        -glyph       => 'graded_segments',
        -bgcolor     => 'blue',
        -key         => 'Regular Expression Sequence Motifs',
        -bump        => 1,
        -label       => 1,
        -description => 1,
        -height      => 4,
    );
    my $sql = <<EOSQL;
SELECT start,stop,acc,feature,descr,link_url
  FROM pseq_features_prosite_v F
  JOIN pseq Q on F.pseq_id=Q.pseq_id
 WHERE F.pseq_id=$q
EOSQL
    my $featref = $u->selectall_arrayref($sql);
    foreach my $r (@$featref) {
        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[1],
                -name       => $r->[3],
                -attributes => {
                    tooltip => 
						_feature_tooltip($seq,@$r[0,1],
										 sprintf("%s; %s; %s",
												 @{$r}[ 3, 2, 4 ])),
                    href => $r->[6]
                },
            )
        );
        $nadded++;
    }
    return $nadded;
}

######################################################################
## add_psdisprot

=pod

=item B<< add_psdisprot( C<Bio::Graphics::Panel>, C<pseq_id> ) >>

Add disprot protein disorder track

=cut

sub add_psdisprot {
    my ( $u, $panel, $q ) = @_;
    my $nadded = 0;
    my $p;
    my $z;
    my $sql = <<EOSQL;
SELECT array_to_string(probs,',')
  FROM psdisorder
 WHERE pseq_id=$q AND params_id=?
EOSQL
    my @features;

    # NOTE: the following layout is intended to facilitate looping over
    # disorder types (disprot VL3H, dispro, disembl, etc), even though this
    # isn't currently used.

    my $r = $u->preferred_run_id_by_pftype('disorder');
    $p = $u->get_run_params_id($r);
    $z = $u->get_run_timestamp_ymd( $q, $r );
    my ( $pname, $pdesc ) =
      $u->selectrow_array( 'select name,descr from params where params_id=?',
        undef, $p );
    if ( defined $z ) {
        my @pd = split( /,/, $u->selectrow_array( $sql, undef, $p ) );
        my @subfeat = map {
            Bio::Graphics::Feature->new(
                -start => $_ + 1,
                -end   => $_ + 1,
                -score => $pd[$_] * 100
              )
        } 0 .. $#pd;
        push( @features,
            Bio::Graphics::Feature->new( -segments => \@subfeat ) );
        my $track = $panel->add_track(
             \@features,
            -key        => "disorder ($pname)",
            -glyph      => 'xyplot',
            -graph_type => 'line',
            -height     => 50,
            -scale      => 'both',
            -min_score  => 0,
            -max_score  => 100,
            -bgcolor    => 'black',
            -fgcolor    => 'black'
        );
    }

    return $#features + 1;
}

sub add_pfsnp {
    my ( $u, $panel, $q, $view, $pseq_structure ) = @_;

    my $nadded = 0;

    my $track = $panel->add_track(
        -glyph       => 'graded_segments',
        -bgcolor     => 'lred',
        -key         => 'SNPs',
        -bump        => +1,
        -label       => 1,
        -description => 1,
        -height      => 4
    );

    my $sql = <<EOSQL;
  SELECT start_pos,original_aa,variant_aa,descr
    FROM pseq_sp_var_v
   WHERE pseq_id=$q
EOSQL

    print( STDERR $sql, ";\n\n" ) if $opts{verbose};
    my $featref = $u->selectall_arrayref($sql);

    foreach my $r (@$featref) {

        my $href = (
              $view
            ? $pseq_structure->pos_script( $r->[0], $r->[1] )
            : "pseq_structure.pl?pseq_id=$q"
        );

        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $r->[0],
                -end        => $r->[0],
                -name       => $r->[1] . "->" . $r->[2],
                -attributes => {
                    tooltip => $r->[3],
                    href    => $href
                }
            )
        );
        $nadded++;
    }
    return $nadded;

}

sub add_pfuser {
    my ( $u, $panel, $q, $view, $pseq_structure, $user_feats ) = @_;

    my $nadded = 0;

    my $track = $panel->add_track(
        -glyph       => 'graded_segments',
        -bgcolor     => 'green',
        -key         => 'User Features',
        -bump        => +1,
        -label       => 1,
        -description => 1,
        -height      => 4
    );

    foreach my $r ( sort keys %{$user_feats} ) {

        next if ( $user_feats->{$r}{type} eq 'hmm' );
        my $end = $user_feats->{$r}{end};

        my $href = (
            $view
            ? (
                defined($end)
                ? $pseq_structure->region_script(
                    $user_feats->{$r}{start}, $user_feats->{$r}{end},
                    $r,                       $user_feats->{$r}{color}
                  )
                : $pseq_structure->pos_script(
                    $user_feats->{$r}{start},
                    $r, $user_feats->{$r}{color}
                )
              )
            : "pseq_structure.pl?pseq_id=$q"
        );

        $end = ( $end ? $end : $user_feats->{$r}{start} );

        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $user_feats->{$r}{start},
                -end        => $end,
                -name       => $r,
                -attributes => {
                    tooltip => $r,
                    href    => $href
                }
            )
        );
        $nadded++;
    }
    return $nadded;

}

sub add_pftemplate {
    my ( $u, $panel, $q, $view, $pseq_structure ) = @_;
    my ( $nadded, $topN ) = ( 0, 5 );

    return
      unless defined $pseq_structure->{'structure_ids'}
          or defined $pseq_structure->{'template_ids'};
    my @structures = @{ $pseq_structure->{'structure_ids'} }
      if defined $pseq_structure->{'structure_ids'};
    my @templates = @{ $pseq_structure->{'template_ids'} }
      if defined $pseq_structure->{'template_ids'};

    my $nfeat = $#templates + 1 + $#structures + 1;
    splice( @structures, $topN ) if $#structures > $topN;
    splice( @templates, $topN - ( $#structures + 1 ) )
      if $#templates > $topN - ( $#structures + 1 );

    my $track = $panel->add_track(
        -glyph   => 'graded_segments',
        -bgcolor => 'orange',
        -key     => sprintf(
'Structures/Templates (top %d hits of %d, including modeled structures)',
            $#structures + 1 + $#templates + 1, $nfeat
        ),
        -bump        => +1,
        -label       => 1,
        -description => 1,
        -height      => 4
    );

    foreach my $t ( @structures, @templates ) {

        my $type =
          ( ( grep ( /$t/, @structures ) ) ? "structures" : "templates" );
        my $start = $pseq_structure->{$type}{$t}{'qstart'};
        my $end   = $pseq_structure->{$type}{$t}{'qstop'};
        my $descr = $pseq_structure->{$type}{$t}{'descr'};
        my $href =
          (   $view
            ? $pseq_structure->change_structure($t)
            : "pseq_structure.pl?pseq_id=$q" );

        $track->add_feature(
            Bio::Graphics::Feature->new(
                -start      => $start,
                -end        => $end,
                -name       => $t,
                -attributes => {
                    tooltip => $descr,
                    href    => $href
                }
            )
        );
        $nadded++;
    }
    return $nadded;
}

sub glyph_type {
    my $feat = shift(@_);
    return 'sec_str::helix'   if $feat->type eq 'H';
    return 'sec_str::myarrow' if $feat->type eq 'E';
    return 'sec_str::coil'    if $feat->type eq 'C';
}

sub glyph_color {
    my $feat = shift @_;
    return 'red'  if $feat->type eq 'H';
    return 'blue' if $feat->type eq 'E';
    return 'green';
}

sub avg_confidence {
    my ( $start, $end, $string ) = @_;
    my ( $total, $avg );
    for ( my $i = $start ; $i <= $end ; $i++ ) {
        $total += int substr( $string, $i - 1, 1 );
    }
    $avg = $total / ( ( $end - $start ) + 1 );
    return $avg;
}

sub _feature_tooltip {
	my ($seq,$start,$stop,$feature_text) = @_;
	my $ss = $start-1;
	my $l = $stop-$start+1;

	warn("ss ($ss)<0 for $feature_text ($start,$stop)\n") if $ss<0;
	warn("l ($l) >seq len for $feature_text ($start,$stop)\n") if $l>length($seq);

	my $text = sprintf("%d-%d (%s)", $start,$stop,
					   elide_sequence( substr( $seq,$start-1,$stop-$start+1 )));
	$text .= "<br>$feature_text" if defined $feature_text;
	return $text;
}

sub _feature_context {
  my ($seq, $start, $stop) = @_;
  #TODO: html-escape
  return context_highlight($seq,
						   '-<b>', '</b>-',
						   $start, $stop,
						   $opts{seq_context_margin}, $opts{seq_context_margin}
						  );
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
