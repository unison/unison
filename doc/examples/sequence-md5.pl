#!/usr/bin/env perl
# sequence-md5 -- obtain an md5 checksum for a sequence

use strict;
use warnings;
use Unison;
use Unison::Utilities::misc qw(sequence_md5);
use Bio::SeqIO;

my $u              = new Unison();
my $seq_to_md5_sth = $u->prepare('select md5(clean_sequence(?))');

my $in = new Bio::SeqIO(
    -fh     => \*STDIN,
    -format => 'fasta'
);

while ( my $bs = $in->next_seq() ) {
    my $seq = $bs->seq();

    # Ask Unison to compute the authoritative md5
    # it requires a database connection and roundtrip to the db for each md5
    my $unison_md5 = $u->selectrow_array( $seq_to_md5_sth, undef, $seq );

    # Compute the md5 in perl
    # Please read the caveats in perldoc Unison::Utilities::misc
    my $unauthoritative_md5 = sequence_md5($seq);

    printf( "%-20s %32s %32s\n",
        $bs->display_id(), $unison_md5, $unauthoritative_md5 );
}
