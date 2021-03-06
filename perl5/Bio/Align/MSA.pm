# $Id$
# @@banner@@

=head1 NAME

Bio::Align::MSA - multiple sequence alignments

S<$Id$>

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

package Bio::Align::MSA;

use strict;
use vars qw($RCSId $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# Loading preface
BEGIN {
    $RCSId = '$Id$ ';
    print( '#', __PACKAGE__, ": $RCSId\n" ) if ( defined $ENV{'DEBUG'} );
}

($VERSION) = $RCSId =~ m/^\$Id: .+,v ([\d\.]+)/;

# uses:
use Carp;
use IO::Scalar;
use Bio::AlignIO;
use Bio::SimpleAlign;
use Data::Dumper;
use Bio::Root::Root;

@ISA = qw( Bio::Root::Root );

# Loading preface
BEGIN {
    $RCSId = '$Id$ ';
    print( '#', __PACKAGE__, ": $RCSId\n" ) if ( defined $ENV{'DEBUG'} );
}

($VERSION) = $RCSId =~ m/^\$Id: .+,v ([\d\.]+)/;

# uses:
use Bio::Structure::IO;
use Bio::Structure::Entry;
use Bio::Symbol::ProteinAlphabet;
use IO::String;
use Data::Dumper;
use strict;
use Carp;

#-------------------------------------------------------------------------------
# new()
#-------------------------------------------------------------------------------

=head2 new()

 Name:       new()
 Purpose:    constructor for Bio::Align::MSA
 Arguments:  Bio::Seq object
 Returns:    Bio::Align::MSA object

=cut

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new(@args);

    $self->{query} = $args[0];

    return $self;
}

#-------------------------------------------------------------------------------
# get_alignment()
#-------------------------------------------------------------------------------

=head2 get_alignment()

 Name:       get_alignment()
 Purpose:    return multiple sequence alignment
 Arguments:  format, array of Bio::SimpleAlign objects
 Returns:    scalar containing alignment

=cut

sub get_alignment {
    my $self   = shift;
    my $format = shift;
    my @align  = @_;

    my $retval = '';

    my @alignio_formats = qw (bl2seq clustalw emboss fasta mase mega meme
      msf nexus pfam phylip prodom psi selex stockholm);
    my $searchme = join( '|', @alignio_formats );

    # get the clustalw alignment if we have not already done so.
    # CACHING ISSUE!!!!
    if ( !defined $self->{'alignment'} ) {
        $self->_align(@align);
    }

    # default is clustalw  because the alignment is internally stored
    # in clustalw format.  utilize Bio::SimpleAln object for other
    # format tyoes
    if ( !defined $format || $format eq 'clustalw' ) {
        $retval = $self->{'alignment'};
    }
    elsif ( $format =~ m/html/i ) {
        my @args;
        push( @args, '-html head' );
        push( @args, '-ruler on  -width 60' );
        push( @args,
            '-coloring consensus -threshold 80 -consensus on -con_coloring any'
        );
        $retval =
`echo \"$self->{'alignment'}\" | mview -in clustalw -alncolor '#BBBBBB' @args`;

        # [rkh] strip the surrounding table tags
        $retval =~ s%</PRE>\n<TABLE BORDER=0.+<TR><TD>\n<PRE>%\n%;
        $retval =~ s%\n</TD></TR></TABLE>\n%%;
        $retval =~ s%^%<!-- BEGIN Bio::Align::MSA output -->\n%;
        $retval =~ s%$%\n<!-- END Bio::Align::MSA output -->\n%;
    }
    elsif ( $format =~ m/$searchme/o ) {
        my $in_fh  = new IO::Scalar;
        my $out_fh = new IO::Scalar;
        $in_fh->open( \$self->{'alignment'} );
        $out_fh->open( \$retval );
        my $in  = Bio::AlignIO->new( -fh => $in_fh,  '-format' => 'clustalw' );
        my $out = Bio::AlignIO->new( -fh => $out_fh, '-format' => $format );

        while ( my $aln = $in->next_aln() ) {
            $out->write_aln($aln);
        }
        $in_fh->close();
        $out_fh->close();
    }
    else {
        $self->throw( "Bio::Align::MSA ERROR: get_alignment() format ($format) "
              . "not supported" );
    }
    return ($retval);
}

#-------------------------------------------------------------------------------
# _align()
#-------------------------------------------------------------------------------

=head2 _align() 

 Name:       _align()
 Purpose:    private method that does the alignment work - called by new().
             Builds a clustalw alignment internally.  use getAlignment() to
             retrieve the alignment in other formats.
 Arguments:  
       -show_ss => 0 | 1 output secondard structure (default: off)
       -show_seq => 0 | 1  output target sequence (default: on)
 Returns:    nothing

=cut

sub _align {
    my $self  = shift;
    my @align = @_;

    my $query_len = length( $self->{query}->seq() );

    my ( $query_start, $query_end );
    my $pair_cnt = 0;
    my $cnt      = 0;
    my @query_padded;
    my @target_padded;
    my @target_name;

    # alignment algorithm:
    #   1. pad the target alignment within the SimpleAlign objects with
    #      '-' to make a full-length alignment
    #   2. the ungapped query sequence is the universal coordinate system
    #   3. gaps inserted into the query sequence as a result of
    #      an alignment to a template, must be reflected in the
    #      alignments of the templates

    # pad target sequences
    foreach my $aln (@align) {
        foreach my $seq ( $aln->each_seq() ) {
            if ( $cnt % 2 == 0 ) {
                $query_start = $seq->start();
                $query_end   = $seq->end();
                $query_padded[$pair_cnt] =
                    substr( $self->{query}->seq(), 1, ( $query_start - 1 ) )
                  . $seq->seq()
                  . substr( $self->{query}->seq(),
                    $query_end, ( $query_len - $query_end ) );
            }
            else {
                push @target_name, $seq->display_id();
                $target_padded[$pair_cnt] =
                    '-' x ( $query_start - 1 )
                  . $seq->seq()
                  . '-' x ( $query_len - $query_end );
                if (
                    length( $query_padded[$pair_cnt] ) !=
                    length( $target_padded[$pair_cnt] ) )
                {
                    die("query_padded not the same length as target_padded");
                }
                $pair_cnt++;
            }
            $cnt++;
        }
    }

    my %query_gap
      ; # store the number of gaps inserted by a given alignment and residue number
    my %max_gap
      ;    # store the largest gap in all the alignments prior to each residue
    my @template;

    # store an ungapped alignment
    my @ungapped_query = grep !/-/, split '', $query_padded[0];

    # iterate through each alignment and count the gaps inserted prior
    # to each residue and which template alignment inserted that gap.
    my $res_num = 0;
    for ( my $i = 0 ; $i <= $#query_padded ; $i++ ) {

        # store target sequence
        $template[$i] = [ split '', $target_padded[$i] ];

        $res_num = 0;
        my @query = split //, $query_padded[$i];
        for ( my $j = 0 ; $j <= $#query ; $j++ ) {
            if ( $query[$j] eq '-' ) {    # found gap
                $query_gap{$res_num}{$i}++;
            }
            else {    # if no gap, then increment the residue number
                $res_num++;
            }
        }
    }

    # sanity check on query_res_count using the ungapped query aligment

    # build consensus query sequence by applying the maximium number of gaps
    # prior to each residue
    my $consensus_str = '';
    for ( my $res_num = 0 ; $res_num <= $#ungapped_query ; $res_num++ ) {
        if ( defined $query_gap{$res_num} ) {
            foreach my $t (
                sort { $query_gap{$res_num}{$b} <=> $query_gap{$res_num}{$a} }
                keys %{ $query_gap{$res_num} }
              )
            {
                $max_gap{$res_num} = $query_gap{$res_num}{$t};
                $consensus_str .= ( '-' x $max_gap{$res_num} );
                last;
            }
        }
        $consensus_str .= $ungapped_query[$res_num];
    }

  # Iterate through each template alignment.  Fix the template alignments by
  # inserting the difference between the maximium number of gap inserts for the
  # corresponding query residue and the gap inserts for this template alignment.
    for ( my $i = 0 ; $i <= $#target_padded ; $i++ ) {
        my $res_num       = 0;
        my $gaps_inserted = 0;
        my @query         = split //, $query_padded[$i];
        for ( my $j = 0 ; $j <= $#query ; $j++ ) {
            if ( $query[$j] ne '-' ) {
                my $gap_length =
                  ( defined $query_gap{$res_num}{$i} )
                  ? $max_gap{$res_num} - $query_gap{$res_num}{$i}
                  : $max_gap{$res_num};
                $gap_length = $gap_length || 0;
                if ( $gap_length > 0 ) {

# account for the fact that we have already added some gaps into template and ss
                    my $ins_pos = $j + $gaps_inserted;
                    print STDERR
"insert $gap_length at the $res_num th residue into the $i sequence at the $ins_pos th position\n"
                      if $ENV{'DEBUG'};
                    print STDERR "template:  " . join( '', @{ $template[$i] } ),
                      "\n"
                      if $ENV{'DEBUG'};
                    for ( my $k = 0 ; $k < $gap_length ; $k++ ) {
                        splice( @{ $template[$i] }, $ins_pos, 0, '-' );
                        $gaps_inserted++;
                    }
                    print STDERR "template:  " . join( '', @{ $template[$i] } ),
                      "\n"
                      if $ENV{'DEBUG'};
                }
                elsif ( $gap_length < 0 ) {
                    die(
"error: gap_length is negative: ($max_gap{$res_num} - $query_gap{$res_num}{$i} = $gap_length"
                    );
                }
                $res_num++;
            }
        }
    }

    my @consensus = split //, $consensus_str;
    print STDERR "consensus: " . join( '', @consensus ) . "\n" if $ENV{'DEBUG'};

    # sanity check
    for ( my $i = 0 ; $i <= $#template ; $i++ ) {
        if ( scalar( @{ $template[$i] } != $#consensus + 1 ) ) {
            warn(   "Prospect2::Align.pm ERROR: template length("
                  . scalar( @{ $template[$i] } )
                  . ") != query length ("
                  . ( $#consensus + 1 )
                  . ")\n" );
        }
    }

    # build clustalw alignment
    my $offset = 60;
    my $align  = "CLUSTAL W(1.81) multiple sequence alignment\n\n\n";
    for ( my $start = 0 ; $start <= $#consensus ; $start += ($offset) ) {
        my $end =
          ( $start + $offset - 1 ) < $#consensus
          ? $start + $offset - 1
          : $#consensus;
        $align .= sprintf( "%-22s %s\n",
            "QUERY", join( '', @consensus[ $start .. $end ] ) );
        for ( my $i = 0 ; $i <= $#template ; $i++ ) {
            ( my $id = $target_name[$i] ) =~ s/^(.*?)\s.*$/$1/g;
            $id    .= "-$i-" . $align[$i]->source();
            $align .= sprintf( "%-22s %s\n",
                $id, join( '', @{ $template[$i] }[ $start .. $end ] ) );
        }
        $align .= "\n";
    }

    $self->{'alignment'} = $align;
    return;
}

1;

=head1 SEE ALSO

@@banner@@

=cut
