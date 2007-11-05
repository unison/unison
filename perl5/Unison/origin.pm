
=head1 NAME

 Unison::origin -- Unison origin table utilities
 $Id$

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

######################################################################
## origin_si_origin_id()

=pod

=item B<< ::origin_si_porgin_id( C<origin> ) >>

=over

ensure that origin is in the origin table, return origin_id

=back

=cut

sub origin_si_origin_id($$) {
    my ( $self, $origin ) = @_;
    $self->is_open()
      || throw Unison::Exception('Unison connection not established');
    ( defined $origin and $origin =~ m/\w/ )
      || throw Unison::Exception("can't lookup a null origin");
    my ($rv) = $self->selectrow_array("select origin_si_origin_id ('$origin')");
    return $rv;
}

######################################################################
## origin_origin_by_origin_id()

=pod

=item B<< ::origin_origin_by_origin_id( C<origin_id> ) >>

=over

=back

=cut

sub origin_origin_by_origin_id($$) {
    my ( $self, $origin_id ) = @_;
    $self->is_open()
      || throw Unison::Exception('Unison connection not established');
    ( defined $origin_id )
      || throw Unison::Exception("can't lookup a null origin_id");
    my ($rv) = $self->selectrow_array(
        "select origin from origin where origin_id=$origin_id");
    return $rv;
}

######################################################################
## origin_origin_id_by_origin

=pod

=item B<< $u->origin_origin_id_by_origin( C<origin_id> ) >>

=over

=back

=cut

sub origin_origin_id_by_origin($) {
    my ( $self, $origin ) = @_;
    $self->is_open()
      || throw Unison::Exception('Unison connection not established');
    ( defined $origin and $origin =~ m/\w/ )
      || throw Unison::Exception("can't lookup a null origin");
    my ($rv) = $self->selectrow_array(
        "select origin_id from origin where upper(origin)=upper('$origin')");
    return $rv;
}

sub get_origin_id_by_origin {
    goto &origin_origin_id_by_origin;
}

######################################################################
## get_origin_name_by_origin_id()

=pod

=item B<< $u->get_origin_name_by_origin_id( C<origin_id> ) >>

Returns name for the given origin_id.

=cut

sub get_origin_name_by_origin_id($$) {
    my ( $self, $origin_id ) = @_;
    $self->is_open()
      || croak("Unison connection not established");
    my (@rv) =
      $self->selectrow_array( 'select origin from origin where origin_id=?',
        undef, $origin_id );
    return @rv ? $rv[0] : undef;
}

######################################################################
## origin_last_updated

=pod

=item B<< ::origin_last_updated( C<origin_id>, [set] ) >>

If the optional second argument is defined (e.g,. origin_last_updated(15,1)), then 
set the last_updated field to now.  In any case, the last_updated value is returned.

=over

=back

=cut

sub origin_last_updated($$) {
    my ( $self, $origin_id ) = @_;
    $self->is_open()
      || croak("Unison connection not established");
    if ( defined $_[2] ) {
        $self->do(
            "update origin set last_updated=now() where origin_id=$origin_id");
    }
    my $sth =
      $self->prepare("select last_updated from origin where origin_id=?");
    $sth->execute($origin_id);
    my ($rv) = $sth->fetchrow_array();
    $sth->finish();
    return $rv;
}

######################################################################
## origin_version

=pod

=item B<< ::origin_version( C<origin_id>) >>

If the optional second argument is defined (e.g,. origin_version(15,17b)), then 
set the version field to it.  In any case, the version value is returned.

=over

=back

=cut

sub origin_version($$) {
    my ( $self, $origin_id ) = @_;
    $self->is_open()
      || croak("Unison connection not established");
    if ( defined $_[2] ) {
        $self->do(
            "update origin set version='$_[2]' where origin_id=$origin_id");
    }
    my $sth = $self->prepare("select version from origin where origin_id=?");
    $sth->execute($origin_id);
    my ($rv) = $sth->fetchrow_array();
    $sth->finish();
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
