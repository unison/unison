=head1 NAME

Unison::pseq -- Unison pseq table utilities
S<$Id: pseq.pm,v 1.17 2004/06/02 23:06:04 rkh Exp $>

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
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;


sub pseq_si_pseq_id {
  my ($self, $seq) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $dbh = $self->{'dbh'};
  my $sth = $dbh->prepare_cached("select pseq_si_pseq_id(?)");
  my ($rv) = $dbh->selectrow_array($sth,undef,$seq);
  return $rv;

=pod

=over

=item B<$u-E<gt>>pseq_si_pseq_id( C<sequence> )

returns the pseq_id for a given sequence, creating it if necessary

=back

=cut
}


sub get_sequence_by_pseq_id ($) {
  my ($self,$pseq_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select seq from pseq where pseq_id=?");
  $sth->execute($pseq_id);
  my ($rv) = $sth->fetchrow_array();
  $sth->finish();
  return $rv;

=pod

=over

=item B<$u-E<gt>>get_sequence_by_pseq_id( C<pseq_id> )

fetches a single protein sequence from the pseq table.

=back

=cut
}



sub best_alias {
  my $self = shift;
  my $pseq_id = shift;
  my $any = shift || 0;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select best_alias(?,?)");
  $sth->execute( $pseq_id, $any?'true':'false' );
  my $ba = $sth->fetchrow_array();
  $sth->finish();
  return( $ba );

=pod

=over

=item B<$u-E<gt>>best_alias( C<pseq_id> )

return the `best_alias' as determined heuristically by Unison.
Briefly, the best_alias is the one specified by the pseq.palias_id if
not null, or the first preference-ordered list of aliases based on
porigin.ann_pref ranking.  See also best_annotation.

=back

=cut
}


sub best_annotation {
  my $self = shift;
  my $pseq_id = shift;
  my $any = shift || 0;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select best_annotation(?,?)");
  $sth->execute( $pseq_id, $any?'true':'false' );
  my $ba = $sth->fetchrow_array();
  $sth->finish();
  return( $ba );

=pod

=over

=item B<$u-E<gt>>best_annotation( C<pseq_id> )

return the "best_annotation" as determined heuristically by Unison.
Compare with the C<best_alias> method and see that for a definition of
"best".

=back

=cut
}


sub pseq_get_aliases {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one porigin_id needed\n");
  my $pseq_id = shift;
  my $sql = "select origin||':'||alias from palias as a join porigin as o on a.porigin_id=o.porigin_id  where pseq_id=$pseq_id  order by o.ann_pref";
  return( map {@$_} @{ $self->{'dbh'}->selectall_arrayref($sql) } );

=pod

=over

=item B<$u-E<gt>>pseq_get_aliases( C<pseq_id> )

return a list of <origin>:<alias> annotations for a given pseq_id, ordered
by porigin.ann_pref.

=back

=cut
}


sub pseq_id_by_md5 {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one md5 needed\n");
  my $md5 = lc(shift);
  my $sql = "select pseq_id from pseq where md5='$md5'";
  return( map {@$_} @{ $self->{'dbh'}->selectall_arrayref($sql) } );

=pod

=over

=item B<$u-E<gt>>pseq_id_by_md5( C<md5> )

return a list of pseq_id for a given md5 checksum

=back

=cut
}


sub pseq_id_by_sequence {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one sequence needed\n");
  my $seq = uc(shift);
  my $sth = "select _pseq_seq_lookup(?)";

  return( $self->{'dbh'}->selectrow_array($sth,undef,$seq) );

=pod

=over

=item B<$u-E<gt>>pseq_id_by_sequence( C<sequence> )

return the pseq_id for a given sequence

=back

=cut
}





### DEPRECATED FUNCTIONS

sub get_seq {
  warn_deprecated();
  my $self = shift;
  return $self->get_sequence_by_pseq_id(@_);
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
