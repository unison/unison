# $Id: blast.pm,v 1.1 2003/06/23 21:39:12 cavs Exp $
#
# BioPerl module for Bio::AlignIO::blast

#  modifed version of Bio::AlignIO::bl2seq
# to work with BLAST reports supported by
# Bio::Tools::BPlite

=head1 NAME

Bio::AlignIO::blast - blast sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the L<Bio::AlignIO> class, as in:

    use Bio::AlignIO;

    $in  = Bio::AlignIO->new(-file => "inputfilename" , '-format' => 'blast');
    $aln = $in->next_aln();

=head1 DESCRIPTION

This object can create L<Bio::SimpleAlign> sequence alignment objects 
from BLAST reports.

It utilizes Bio::Tools::BPlite to parse the BLAST reports.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org               - General discussion
  http://bio.perl.org/MailList.html   - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bugzilla.bioperl.org/

=head1 AUTHOR - David Cavanaugh

Email: cavs@gene.com


=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::AlignIO::blast;
use vars qw(@ISA);
use strict;
# Object preamble - inherits from Bio::Root::Object

use Bio::AlignIO;
use Bio::Tools::BPlite;

@ISA = qw(Bio::AlignIO);

=head2 next_aln

 Title   : next_aln
 Usage   : $aln = $stream->next_aln()
 Function: returns the next alignment in the stream.
 Returns : L<Bio::Align::AlignI> object - returns 0 on end of file
      or on error
 Args    : NONE

=cut

sub next_aln {
    my $self = shift;
    my ($start,$end,$name,$seqname,$seq,$seqchar);
    my $aln =  Bio::SimpleAlign->new(-source => 'blast');
    $self->{'blastobj'} =
      $self->{'blastobj'} || Bio::Tools::BPlite->new(-fh => $self->_fh);
    
    $self->{'subj'} = 
      $self->{'subj'} || $self->{'blastobj'}->nextSbjct(); 
    my $hsp =  $self->{'subj'}->nextHSP();
    # if we run out of hsps for this subject alignment, get
    # the next subject alignment.  if no more subjects
		# then we're done.
    if ( ! defined $hsp ) {
       $self->{'subj'} = $self->{'blastobj'}->nextSbjct();
       return (0) if ! defined $self->{'subj'};
       $hsp = $self->{'subj'}->nextHSP();
    }
    $seqchar = $hsp->querySeq;
    $start = $hsp->query->start;
    $end = $hsp->query->end;
    $seqname = $self->{'blastobj'}->query();

    unless ($seqchar && $start && $end ) {return 0} ;  

    $seq = new Bio::LocatableSeq('-seq'=>$seqchar,
         '-id'=>$seqname,
         '-start'=>$start,
         '-end'=>$end,
         );

    $aln->add_seq($seq);

    $seqchar = $hsp->sbjctSeq;
    $start = $hsp->hit->start;
    $end = $hsp->hit->end;
    $seqname = $self->{'subj'}->name;

    unless ($seqchar && $start && $end  && $seqname) {return 0} ;  

    $seq = new Bio::LocatableSeq('-seq'=>$seqchar,
         '-id'=>$seqname,
         '-start'=>$start,
         '-end'=>$end,
         );

    $aln->add_seq($seq);

    return $aln;
}
  

=head2 write_aln

 Title   : write_aln
 Usage   : $stream->write_aln(@aln)
 Function: writes the $aln object into the stream in blast format
 Returns : 1 for success and 0 for error
 Args    : L<Bio::Align::AlignI> object


=cut

sub write_aln {
    my ($self,@aln) = @_;

    $self->throw("Sorry: writing blast output is not available! /n");
}

1;
