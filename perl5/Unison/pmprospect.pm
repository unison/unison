=head1 NAME

Unison::pmprospect2 -- Unison p2params table utilities
S<$Id: pmprospect2.pm,v 1.3 2004/05/04 04:49:18 rkh Exp $>

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
## add_pmprospect2

=pod

=item B<< $u->add_pmprospect2( C<pseq_id,id,len,ncores> ) >>

=cut

sub add_pmprospect2
  {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  my ($pseq_id,$id,$len,$ncores) = @_;
  $self->do( "insert into pmprospect2 (pseq_id,name,len,ncores) "
			 . "values ($pseq_id,'$id',$len,$ncores);" );
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
