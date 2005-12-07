=head1 NAME

Unison::pmap -- PMAP-related functions for Unison

S<$Id: pmap.pm,v 1.1 2005/11/21 19:22:36 mukhyala Exp $>

=head1 SYNOPSIS

 use Unison;
 use Unison::pmap;
 my $u = new Unison(...);
 $u->get_pmapaln_info( pseq_id params_id)

=head1 DESCRIPTION

B<Unison::pmap> provides PMAP-related methods to the B<Unison::>
namespace.

=cut


package Unison;


=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## get_pmapaln_info

=pod

=item $u->get_pmapaln_info( B<pseq_id>, B<params_id> )

returns an array of <genasm_id,chr,gstart,gstop,pmapaln_id> for a given
B<pseq_id> B<prams_id> from the pmap_v view.

=cut

sub get_pmapaln_info {
  my ($u, $pseq_id, $params_id) = @_;
  my $sql = "select genasm_id,chr,gstart,gstop,aln_id from pmap_v where pseq_id=? and params_id=?";
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my $sth = $u->prepare_cached($sql);
  return @{ $u->selectall_arrayref($sth,undef,$pseq_id,$params_id) };
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
