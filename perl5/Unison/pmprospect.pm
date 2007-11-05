
=head1 NAME

Unison::pmprospect -- Unison p2params table utilities
S<$Id: pmprospect.pm,v 1.6 2005/12/07 21:36:38 mukhyala Exp $>

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
## add_pmprospect

=pod

=item B<< $u->add_pmprospect( C<pseq_id,id,len,ncores> ) >>

=cut

sub add_pmprospect {
    my $self = shift;
    $self->is_open()
      || croak("Unison connection not established");
    my ( $origin_id, $pseq_id, $id, $len, $ncores ) = @_;
    $self->do( "insert into pmprospect (origin_id,pseq_id,acc,len,ncores) "
          . "values ($origin_id,$pseq_id,'$id',$len,$ncores);" );
    return;
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
