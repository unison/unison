=head1 NAME

Unison::pset -- Unison pset table utilities
S<$Id: pseq.pm,v 1.20 2005/05/11 21:53:41 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

my @pseq_ids = $u->pseq_ids_by_pset( 'kinases' );
my @pseq_ids = $u->pseq_ids_by_pset_id( 1050 );

(etc.)

=head1 DESCRIPTION

B<> is a

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use Unison::Utilities::misc;


=pod

=head1 ROUTINES AND METHODS

=over

=cut


######################################################################
## pseq_ids_by_pset

=pod

=item B<< $u->pseq_ids_by_pset( C<set name> ) >>

returns an array of pseq_ids for a given pset name

=cut

sub pseq_ids_by_pset {
  my ($self, $name) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $dbh = $self->{'dbh'};
  my $sth = $dbh->prepare_cached('select pseq_id from pseqset where pset_id=pset_id(?)');
  return map {$_->[0]} @{$dbh->selectall_arrayref($sth,undef,$name)};
}


######################################################################
## pseq_ids_by_pset_id

=pod

=item B<< $u->pseq_ids_by_pset_id( C<pset_id> ) >>

returns an array of pseq_ids for a given pset_id

=cut

sub pseq_ids_by_pset_id {
  my ($self, $name) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $dbh = $self->{'dbh'};
  my $sth = $dbh->prepare_cached('select pseq_id from pseqset where pset_id=?');
  return map {$_->[0]} @{$dbh->selectall_arrayref($sth,undef,$name)};
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
