=head1 NAME

Unison::pseq -- Unison pseq table utilities
S<$Id: pseq.pm,v 1.22 2006/06/26 18:05:08 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

my $seq = $u->get_sequence_by_pseq_id( 42 );

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
## pseq_si_pseq_id

=pod

=item B<< $u->pseq_si_pseq_id( C<sequence> ) >>

returns the pseq_id for a given sequence, creating it if necessary

=cut

sub pseq_si_pseq_id {
  my ($self, $seq) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $dbh = $self->{'dbh'};
  my $sth = $dbh->prepare_cached("select pseq_si_pseq_id(?)");
  my ($rv) = $dbh->selectrow_array($sth,undef,$seq);
  return $rv;
}


######################################################################
## get_sequence_by_pseq_id

=pod

=item B<< $u->get_sequence_by_pseq_id( C<pseq_id> ) >>

fetches a single protein sequence from the pseq table.

=cut

sub get_sequence_by_pseq_id ($) {
  my ($self,$pseq_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select seq from pseq where pseq_id=?");
  $sth->execute($pseq_id);
  my ($rv) = $sth->fetchrow_array();
  $sth->finish();
  return $rv;
}



######################################################################
## best_alias

=pod

=item B<< $u->best_alias( C<pseq_id> ) >>

return the `best_alias' as determined heuristically by Unison.
Briefly, the best_alias is the one specified by the pseq.palias_id if
not null, or the first preference-ordered list of aliases based on
origin.ann_pref ranking.  See also best_annotation.

=cut

sub best_alias {
  my $self = shift;
  my $pseq_id = shift;
  # my $from_view = true_or_false( shift );
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached( 'select best_alias(?)' );
  $sth->execute( $pseq_id );
  my $ba = $sth->fetchrow_array();
  $sth->finish();
  return( $ba );
}


######################################################################
## best_annotation

=pod

=item B<< $u->best_annotation( C<pseq_id> ) >>

return the "best_annotation" as determined heuristically by Unison.
Compare with the C<best_alias> method and see that for a definition of
"best".

=cut

sub best_annotation {
  my $self = shift;
  my $pseq_id = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached("select best_annotation(?)");
  $sth->execute( $pseq_id );
  my $ba = $sth->fetchrow_array();
  $sth->finish();
  return( $ba );
}



######################################################################
## entrez_annotations

=pod

=item B<< $u->entrez_annotations( C<pseq_id> ) >>

Return the Entrez Gene annotations.

=cut

sub entrez_annotations {
  my $self = shift;
  my $pseq_id = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  my $sth = $self->prepare_cached(<<EOSQL);
    SELECT distinct T.common,E.symbol,E.map_loc,E.descr
      FROM pseq_gene_v PG
      JOIN ncbi.gene_info E on PG.gene_id=E.gene_id
 LEFT JOIN tax.spspec T on E.tax_id=T.tax_id
     WHERE PG.pseq_id=?
  ORDER BY T.common, E.symbol
EOSQL
  $sth->execute( $pseq_id );
  my @annos;
  while( my $h = $sth->fetchrow_hashref() ) {
	push(@annos, $h);
  }
  $sth->finish();
  return( sort { (($a->{common}||'') cmp ($b->{common}||''))
				   || ($a->{symbol} cmp $b->{symbol})}
		  @annos);
}



######################################################################
## pseq_get_aliases

=pod

=item B<< $u->pseq_get_aliases( C<pseq_id> ) >>

return a list of <origin>:<alias> annotations for a given pseq_id, ordered
by origin.ann_pref.

=cut

sub pseq_get_aliases {
  my ($self,$pseq_id,$ann_pref_max) = @_;
  my $ann_pref_clause = '';
  $self->is_open()
	|| croak("Unison connection not established");
  if (defined $ann_pref_max) {
	$ann_pref_clause = "AND ann_pref<=$ann_pref_max";
  }
  my $sql = <<EOSQL;
SELECT origin||':'||alias
  FROM palias AS a
  JOIN origin AS o ON a.origin_id=o.origin_id
 WHERE pseq_id=$pseq_id $ann_pref_clause
ORDER BY o.ann_pref
EOSQL
  return( map {"@$_"} @{ $self->{'dbh'}->selectall_arrayref($sql) } );
}


######################################################################
## pseq_id_by_md5

=pod

=item B<< $u->pseq_id_by_md5( C<md5> ) >>

return a list of pseq_id for a given md5 checksum

=cut

sub pseq_id_by_md5 {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one md5 needed\n");
  my $md5 = lc(shift);
  my $sql = "select pseq_id from pseq where md5='$md5'";
  return( map {@$_} @{ $self->{'dbh'}->selectall_arrayref($sql) } );
}


######################################################################
## pseq_id_by_sequence

=pod

=item B<< $u->pseq_id_by_sequence( C<sequence> ) >>

return the pseq_id for a given sequence

=cut

sub pseq_id_by_sequence {
  my $self = shift;
  $self->is_open()
	|| croak("Unison connection not established");
  ($#_==0)
	|| croak("exactly one sequence needed\n");
  my $seq = uc(shift);
  my $sth = "select _pseq_seq_lookup(?)";

  return( $self->{'dbh'}->selectrow_array($sth,undef,$seq) );
}





### DEPRECATED FUNCTIONS

sub get_seq {
  warn_deprecated();
  my $self = shift;
  return $self->get_sequence_by_pseq_id(@_);
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
