=head1 NAME

Unison::pseq -- Unison pseq table utilities
S<$Id: pseq.pm,v 1.2 2003/05/02 06:08:04 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

my $seq = $u->get_sequence_by_pseq_id( 42 );

(etc.)

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;



sub pseq_si_pseq_id
  {
=pod

=over

=item B<::pseq_si_pseq_id( C<sequence> )>

returns the pseq_id for a given sequence, creating it if necessary

=back

=cut
  my ($self, $seq) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $dbh = $self->{'dbh'};
  my $sth = $dbh->prepare_cached("select pseq_si_pseq_id(?)");
  my ($rv) = $dbh->selectrow_array($sth,undef,$seq);
  return $rv;
  }


sub get_sequence_by_pseq_id($)
  {
=pod

=over

=item B<::get_sequence_by_pseq_id( C<pseq_id> )>

fetches a single protein sequence from the pseq table.

=back

=cut
  my ($self,$pseq_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select seq from pseq where pseq_id=?");
  $sth->execute($pseq_id);
  my ($rv) = $sth->fetchrow_array();
  $sth->finish();
  return $rv;
  }


sub best_alias
  {
=pod

=over

=item B<::best_alias( C<pseq_id> )>

return the `best_alias' as determined heuristically by Unison.
Briefly, the best_alias is the one specified by the pseq.palias_id if
not null, or the first preference-ordered list of aliases based on
porigin.ann_pref ranking.  See also best_annotation.

=back

=cut
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one porigin_id needed\n");
  my $sth = $self->prepare_cached("select best_alias(?)");
  $sth->execute(shift);
  my $ba = $sth->fetchrow_array;
  $sth->finish();
  return( $ba );
  }


sub best_annotation
  {
=pod

=over

=item B<::best_annotation( C<pseq_id> )>

return the "best_annotation" as determined heuristically by Unison.
Compare with the C<best_alias> method and see that for a definition of
"best".

=back

=cut
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one porigin_id needed\n");
  my $sth = $self->prepare_cached("select best_annotation(?)");
  $sth->execute(shift);
  my $ba = $sth->fetchrow_array;
  $sth->finish();
  return( $ba );
  }


sub pseq_get_aliases
  {
=pod

=over

=item B<::pseq_get_aliases( C<pseq_id> )>

return a list of <origin>:<alias> annotations for a given pseq_id, ordered
by porigin.ann_pref.

=back

=cut
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one porigin_id needed\n");
  my $pseq_id = shift;
  my $sql = "select origin||':'||alias from palias as a join porigin as o on a.porigin_id=o.porigin_id  where pseq_id=$pseq_id  order by o.ann_pref";
  return( map {@$_} @{ $self->{'dbh'}->selectall_arrayref($sql) } );
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
