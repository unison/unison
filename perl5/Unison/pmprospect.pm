=head1 NAME

Unison::pmprospect2 -- Unison p2params table utilities
S<$Id: pmprospect2.pm,v 1.1 2003/06/30 15:33:50 rkh Exp $>

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



###############################################################################################
## pmprospect2
sub add_pmprospect2
  {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  my ($pseq_id,$id,$len,$ncores) = @_;
  $self->do( "insert into pmprospect2 (pseq_id,name,len,ncores) "
			 . "values ($pseq_id,'$id',$len,$ncores);" );
  return;
=pod

=over

=item B<Unison::add_pmprospect2( C<pseq_id,id,len,ncores> )>

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


