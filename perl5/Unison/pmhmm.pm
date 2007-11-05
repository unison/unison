
=head1 NAME

Unison::pmhmm -- Unison pmhmm table utilities
S<$Id$

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

=pod

=head1 ROUTINES AND METHODS

=over

=cut

###############################################################################################
## get_pmodel_id

=pod

=item B<< $u->get_pmodel_id( C<$acc> C<$origin>) >>

=cut

sub get_pmodel_id($$$) {
    my ( $u, $acc, $origin ) = @_;
    $u->is_open()
      || croak("Unison connection not established");

    my $sql = "select pmodel_id(?,?)";
    my $sth = $u->prepare_cached($sql);

    return $u->selectrow_array( $sth, undef, $acc, $origin );
}

######################################################################
## pmhmm_si_pmodel_id()

=pod

=item B<< ::pmhmm_si_pmodel_id( C<pmodel> ) >>

=over

ensure that HMM is in the pmhmm table, return pmodel_id

=back

=cut

sub pmhmm_si_pmodel_id($$$$$$$$$$$$$$$) {
    my (
        $u,   $origin_id, $name,  $acc, $descr,
        $len, $nseq,      $cksum, $gas, $gad,
        $tcs, $tcd,       $ncs,   $ncd
    ) = @_;
    $u->is_open()
      || throw Unison::Exception(
        'U
nison connection not established'
      );
    my $sql = "select pmhmm_si_pmodel_id(?,?,?,?,?,?,?,?,?,?,?,?,?)";
    my $sth = $u->prepare_cached($sql);
    my $rv  = $u->selectrow_array(
        $sth,   undef, $origin_id, $name,  $acc,
        $descr, $len,  $nseq,      $cksum, $gas,
        $gad,   $tcs,  $tcd,       $ncs,   $ncd
    );
    return $rv;
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
