############################################################
# pfpsipred.pm
# Methods for accessing pfpsipred data
# $ID = q$Id: pfpsipred.pm,v 1.1 2005/07/22 22:05:18 mukhyala Exp $
############################################################

package Unison::Utilities::pfpsipred;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT    = ();
our @EXPORT_OK = qw(pfpsipred);

############################################################################
#get secondary structure prediciton from unison based on params_id for pseq_id
sub ssp_phd {

    my ( $params_id, $pseq_id, $u ) = @_;
    my $sql =
"select s.seq,p.confidence,p.h_confidence,p.e_confidence,p.c_confidence from psipred p join pseq s on p.pseq_id=s.pseq_id where p.pseq_id=$pseq_id and params_id=$params_id";
    my $r = $u->selectall_arrayref($sql)->[0];

    if ( not defined($r) ) {
        print STDERR "no rows in psipred\n";
        return undef;
    }
    foreach (@$r) {
        if ( not defined $_ ) {
            print STDERR "null columns in psipred\n";
            return undef;
        }
    }

    if ( not defined($r) ) {
        print STDERR
          "\nCould not fetch secondary structure info from psipred\n";
        return undef;
    }

    my ( $sfh, $sfn ) =
      File::Temp::tempfile( DIR => '/tmp', SUFFIX => ".ssp", UNLINK => 1 );

    my ( $i, $len ) = ( 0, 60 );
    while ( $i < length( $r->[0] ) ) {
        print $sfh "AA  |" . substr( $r->[0], $i, $len ), "|\n";
        print $sfh "Rel |" . substr( $r->[1], $i, $len ), "|\n";
        print $sfh "prH-|" . substr( $r->[2], $i, $len ), "\n";
        print $sfh "prE-|" . substr( $r->[3], $i, $len ), "\n";
        print $sfh "prL-|" . substr( $r->[4], $i, $len ), "\n";
        $i += $len;
    }
    close($sfh);
    return ($sfn);
}

