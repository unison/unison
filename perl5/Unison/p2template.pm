=head1 NAME

Unison::p2template -- Unison p2params table utilities
S<$Id: pm,v 1.2 2001/06/12 05:38:24 reece Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;

###############################################################################################
## p2template
sub add_p2template
  {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  my ($pseq_id,$id,$len,$ncores) = @_;
  $self->do( "insert into p2template (pseq_id,name,len,ncores) "
			 . "values ($pseq_id,'$id',$len,$ncores);" );
  return;
=pod

=over

=item B<Unison::add_p2template( C<pseq_id,id,len,ncores> )>

=back

=cut
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


