=head1 NAME

Unison::blat -- BLAT-related functions for Unison

S<$Id: blat.pm,v 1.2 2004/05/10 19:32:15 rkh Exp $>

=head1 SYNOPSIS

 use Unison;
 use Unison::blat;
 my $u = new Unison(...);
 $u->get_p2gblataln_info( pseq_id )
 $u->get_p2gblataln_id( genasm_id, chr, gstart, gstop )

=head1 DESCRIPTION

B<Unison::blat> provides BLAT-related methods to the B<Unison::>
namespace.

=cut


package Unison;

use Unison::utilities qw( warn_deprecated );



=pod

=head1 ROUTINES AND METHODS

=over

=cut


######################################################################
## get_p2gblataln_info

=pod

=item $u->get_p2gblataln_info( B<pseq_id> )

returns an array of <genasm_id,chr,gstart,gstop,p2gblataln_id> for a given
B<pseq_id> from the blatloci table.

=cut

sub get_p2gblataln_info {
  my ($u, $pseq_id) = @_;
  my $sql = "select genasm_id,chr,gstart,gstop,p2gblataln_id from blatloci where pseq_id=?";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $sth = $u->prepare_cached($sql);
  return @{ $u->selectall_arrayref($sth,undef,$pseq_id) };
}




######################################################################
## get_p2gblataln_id

=pod

=item $u->get_p2gblataln_id( B<genasm_id>, B<chr>, B<gstart>, B<gstop> )

returns an array of p2gblataln_ids for a given genomic region.

=cut

sub get_p2gblataln_id {
  my ($u, $genasm_id, $chr, $gstart, $gstop) = @_;
  # Is there are reason we're not using blatloci? 
  #  my $sql = "select ah.p2gblataln_id from p2gblatalnhsp ah, p2gblathsp h where " .
  #    "h.gstart>=? and h.gstop<=? and h.chr=? and h.genasm_id=? " .
  #    "and ah.p2gblathsp_id=h.p2gblathsp_id";
  my $sql = 'SELECT p2gblataln_id FROM blatloci
			 WHERE genasm_id=? AND chr=? AND gstart<=? AND gstop>=?';
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $sth = $u->prepare_cached($sql);
  my @retval = map {$_->[0]} @{ $u->selectall_arrayref($sth,undef,$genasm_id,
													   $chr,$gstart,$gstop) };
  return(@retval);
}



##################################################################################
## DEPRECATED FUNCTIONS

#-------------------------------------------------------------------------------
# NAME: get_blataln
# PURPOSE: retrieve blataln info
#
# WARNING: This function is broken. Paralogous alignments of a single
# pseq_id to several locations in the same genome returns only one hit.
# Furthermore, genasm_id cannot be specified or determined from the
# results, so alignments to multiple genome assemblies is ambiguous.
#
#-------------------------------------------------------------------------------
sub get_blataln {
  my ($u, $pseq_id) = @_;
  warn_deprecated('Use get_p2gblataln_info() instead');

  my $sql = "select chr,gstart,gstop,p2gblataln_id from blatloci where pseq_id=?";

  my $sth = $u->prepare($sql);
  $sth->execute($pseq_id);

  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my @f;
  foreach my $r ($sth->fetchrow_hashref) {
    return $r->{chr},$r->{gstart},$r->{gstop},$r->{p2gblataln_id};
  }
}


#-------------------------------------------------------------------------------
# NAME: get_blataln_id
# PURPOSE: retrieve blataln_ids for a given genomic region
#-------------------------------------------------------------------------------
sub get_blataln_id {
  my ($u, $genasm_id, $chr, $gstart, $gstop) = @_;
  warn_deprecated('Use get_p2gblataln_id() instead');

  my $sql = "select ah.p2gblataln_id from p2gblatalnhsp ah, p2gblathsp h where " .
    "h.gstart>=$gstart and h.gstop<=$gstop and h.chr=$chr and h.genasm_id=$genasm_id " .
    "and ah.p2gblathsp_id=h.p2gblathsp_id";
  my $sth = $u->prepare($sql);
  $sth->execute();
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my @retval;
  while ( my $row = $sth->fetchrow_arrayref() ) {
    push @retval,$row->[0];
  }
  return(@retval);
}


=pod

=head1 SEE ALSO

=over

=item * perldoc Unison

=back

=head1 AUTHOR

see perldoc Unison for contact information

=cut

1;
