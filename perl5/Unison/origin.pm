=head1 NAME

 Unison::porigin -- Unison porigin table utilities
 $Id: porigin.pm,v 1.8 2005/01/20 01:05:17 rkh Exp $

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
## porigin_si_porigin_id()

=pod

=item B<< ::porigin_si_porgin_id( C<origin> ) >>

=over

ensure that origin is in the porigin table, return porigin_id

=back

=cut

sub porigin_si_porigin_id($$) {
  my ($self,$origin) = @_;
  $self->is_open()
	|| throw Unison::Exception('Unison connection not established');
  (defined $origin and $origin =~ m/\w/)
	|| throw Unison::Exception("can't lookup a null origin");
  my ($rv) = $self->selectrow_array("select porigin_si_porigin_id ('$origin')");
  return $rv;
}



######################################################################
## porigin_origin_by_porigin_id()

=pod

=item B<< ::porigin_origin_by_porigin_id( C<porigin_id> ) >>

=over

=back

=cut

sub porigin_origin_by_porigin_id($$) {
  my ($self,$porigin_id) = @_;
  $self->is_open()
	|| throw Unison::Exception('Unison connection not established');
  (defined $porigin_id)
	|| throw Unison::Exception("can't lookup a null porigin_id");
  my ($rv) = $self->selectrow_array("select origin from porigin where porigin_id=$porigin_id");
  return $rv;
}


######################################################################
## porigin_porigin_id_by_origin

=pod

=item B<< $u->porigin_porigin_id_by_origin( C<porigin_id> ) >>

=over

=back

=cut

sub porigin_porigin_id_by_origin($) {
  my ($self,$origin) = @_;
  $self->is_open()
	|| throw Unison::Exception('Unison connection not established');
  (defined $origin and $origin =~ m/\w/)
	|| throw Unison::Exception("can't lookup a null origin");
  my ($rv) = $self->selectrow_array("select porigin_id from porigin where upper(origin)=upper('$origin')");
  return $rv;
}

sub get_porigin_id_by_origin {
  goto &porigin_porigin_id_by_origin;
}




######################################################################
## porigin_last_updated

=pod

=item B<< ::porigin_last_updated( C<porigin_id>, [set] ) >>

If the optional second argument is defined (e.g,. porigin_last_updated(15,1)), then 
set the last_updated field to now.  In any case, the last_updated value is returned.

=over

=back

=cut

sub porigin_last_updated($$) {
  my ($self,$porigin_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  if (defined $_[2]) {
	$self->do("update porigin set last_updated=now() where porigin_id=$porigin_id");
  }
  my $sth = $self->prepare("select last_updated from porigin where porigin_id=?");
  $sth->execute( $porigin_id );
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
