=head1 NAME

Unison::porigin -- Unison porigin table utilities
S<$Id: porigin.pm,v 1.6 2004/06/04 00:04:31 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;


=pod

=over

=item B<Unison::porigin_si_porgin_id( C<origin> )>

ensure that origin is in the porigin table, return porigin_id

=back

=cut
sub porigin_si_porigin_id {
  my ($self,$origin) = @_;
  $self->is_open()
	|| throw Unison::Exception('Unison connection not established');
  (defined $origin and $origin =~ m/\w/)
	|| throw Unison::Exception("can't lookup a null origin");
  my ($rv) = $self->selectrow_array("select porigin_si_porigin_id ('$origin')");
  return $rv;
}



sub porigin_origin_by_porigin_id {
  my ($self,$porigin_id) = @_;
  $self->is_open()
	|| throw Unison::Exception('Unison connection not established');
  (defined $porigin_id)
	|| throw Unison::Exception("can't lookup a null porigin_id");
  my ($rv) = $self->selectrow_array("select origin from porigin where porigin_id=$porigin_id");
  return $rv;
}

sub porigin_porigin_id_by_origin {
  my ($self,$origin) = @_;
  $self->is_open()
	|| throw Unison::Exception('Unison connection not established');
  (defined $origin and $origin =~ m/\w/)
	|| throw Unison::Exception("can't lookup a null origin");
  my ($rv) = $self->selectrow_array("select porigin_id from porigin where upper(origin)=upper('$origin')");
  return $rv;
}

sub get_porigin_id_by_origin {
  porigin_porigin_id_by_origin(@_);
}




=pod

=over

=item B<::porigin_last_updated( C<porigin_id>, [set] )>

If the optional second argument is defined (e.g,. porigin_last_updated(15,1)), then 
set the last_updated field to now.  In any case, the last_updated value is returned.

=back

=cut
sub porigin_last_updated {
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

=head1 BUGS

=head1 SEE ALSO

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut

1;