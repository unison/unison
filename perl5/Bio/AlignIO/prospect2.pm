# $Id: prospect.pm,v 1.1 2003/06/25 18:59:24 cavs Exp $
#
# BioPerl module for Bio::AlignIO::prospect2

=head1 NAME

Bio::AlignIO::prospect2 - prospect threading input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the L<Bio::AlignIO> class, as in:

    use Bio::AlignIO;

    $in  = Bio::AlignIO->new(-file => "inputfilename" , '-format' => 'prospect');
    $aln = $in->next_aln();

=head1 DESCRIPTION

This object can create L<Bio::SimpleAlign> sequence alignment objects 
from the output of the prospect threading applications.  Utilizes
Prospect2::File for parsing the prospect xml output.

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

See http://www.bioinformaticssolutions.com for more information on prospect.

=cut

# Let the code begin...

package Bio::AlignIO::prospect2;
use vars qw(@ISA);
use strict;

use Prospect2::File;
use IO::Handle;
use IO::File;

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
    my $aln =  Bio::SimpleAlign->new(-source => 'prospect');

		# get Prospect2::File object to parse the prospect xml output
		if ( ! defined $self->{'prospectobj'} ) {
			$self->{'prospectobj'} = new Prospect2::File;
			$self->{'prospectobj'}->fdopen( $self->_fh, "r" );
		}
		my $t = $self->{'prospectobj'}->next_thread();
		return if ! defined $t;
    
    $seqchar = $t->qseq_align();
    $start = $t->target_start;
    $end = $t->target_end;
    $seqname = $t->qname();

    unless ($seqchar && $start && $end ) {return 0} ;  

    $seq = new Bio::LocatableSeq('-seq'=>$seqchar,
         '-id'=>$seqname,
         '-start'=>$start,
         '-end'=>$end,
         );

    $aln->add_seq($seq);

    $seqchar = $t->tseq_align();
    $start = $t->template_start();
    $end = $t->template_end();
    $seqname = $t->tname();

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
 Function: writes the $aln object into the stream in prospect format
 Returns : 1 for success and 0 for error
 Args    : L<Bio::Align::AlignI> object


=cut

sub write_aln {
    my ($self,@aln) = @_;

    $self->throw("Sorry: writing prospect output is not available! /n");
}

1;
