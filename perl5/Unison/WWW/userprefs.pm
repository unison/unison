
=head1 NAME

Unison::userprefs -- BLAT-related functions for Unison

S<$Id$>

=head1 SYNOPSIS

 use Unison;
 use Unison::userprefs;
 my $u = new Unison(...);
 my $prefs = $u->get_userprefs();

=head1 DESCRIPTION

B<Unison::blat> provides BLAT-related methods to the B<Unison::>
namespace.

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

######################################################################
## get_userprefs

=pod

=item B<< $u->get_userprefs() >>

return user prefs as hashref

=cut

sub get_userprefs {
    my $self = shift;
    my $userprefs;
    $self->is_open()
      || croak("Unison connection not established");

    my $sth =
      $self->prepare(
'select userprefs.* from userprefs  natural join pg_user where usename=?'
      );

    # try for this user
    $userprefs = $self->selectrow_hashref( $sth, undef, $self->{username} );

    # else use PUBLIC user's prefs
    if ( not defined $userprefs ) {
        $userprefs = $self->selectrow_hashref( $sth, undef, 'PUBLIC' );
    }

    # ack! at least return a reasonable guess
    if ( not defined $userprefs ) {
        $userprefs = {
            show_sql  => 1,
            show_tips => 1
        };
    }

    return $userprefs;
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
