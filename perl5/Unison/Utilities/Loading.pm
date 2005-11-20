package Unison::Utilities::Loading;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = ();
our @EXPORT_OK = qw( fetch_sequences );

use Unison::Exceptions;


sub fetch_sequences ($$$@) {
  # fetch sequences to temp file
  my ($u,$seqfn,$pseq_ids,$optsr) = @_;
  my $nseq = 0;

  my $so = new Bio::SeqIO( -format => 'fasta',
						   -file => ">$seqfn" )
	|| die("! couldn't open $seqfn for writing\n");

  foreach my $pseq_id (@$pseq_ids) {
	if ($u->already_ran($pseq_id,$optsr->{params_id},
						$optsr->{model_porigin_id},$optsr->{pmodelset_id})) {
	  warn("Unison:$pseq_id: already run with these parameters\n");
	  next;
	}
	my $seq = $u->get_sequence_by_pseq_id( $pseq_id );
	if (not defined $seq) {
	  warn("\n! Unison:$pseq_id: No such sequences\n");
	  next;
	}

	if (length($seq) > $optsr->{'max-length'}) {
	  warn("! Unison:$pseq_id: >$optsr->{'max-length'} AA; skipping\n");
	  next;
	}

	$so->write_seq( new Bio::PrimarySeq( -seq => $seq,
										 -id => "Unison:$pseq_id" ) );
	$nseq++;
  }
  $so->close();
  return $nseq;
}



1;

