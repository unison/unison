=head1 NAME

Unison::papseq -- Unison papseq table utilities
S<$Id: papseq.pm,v 1.4 2003/06/13 17:11:41 cavs Exp $>

=head1 SYNOPSIS

 use Unison;

 my $u = new Unison;
 
 $u->load_blast_report( $ARGV[0] );

=head1 DESCRIPTION

B<Unison::papseq> is a module with methods for loading
BLAST reports into the papseq table in the Unison database.

=head1 ROUTINES AND METHODS

=cut

package Unison;
use Bio::Tools::BPlite;

#-------------------------------------------------------------------------------
# load_blast_report()
#-------------------------------------------------------------------------------

=head2 load_blast_report()

 Name:      load_blast_report()
 Purpose:   load a BLAST report into the UNISON database
 Arguments: BLAST output file
 Returns:   nada

=cut

sub load_blast_report {
  my($u,$file) = @_;

  my $report = new Bio::Tools::BPlite(-file=>$file);
  my $q_pseq_id = $u->_get_pseq_id_from_name($report->query());
  if ( !defined $q_pseq_id ) {
    throw Unison::RuntimeError("No pseq_id defined for this query sequence: " . 
      $report->query() );
  }
  while(my $sbjct = $report->nextSbjct) {
    my $t_pseq_id = $u->_get_pseq_id_from_name($sbjct->name());
		throw Unison::RuntimeError( "No pseq_id defined for this target sequence: " 
		  . $sbjct->name() ) if ( !defined $t_pseq_id );
		if ( $q_pseq_id == $t_pseq_id ) {
			print "Skipping this target ($t_pseq_id) because it is a self hit\n" if $ENV{'DEBUG'};
			next;
		}
    # get the pmodel_id for this sequence
    my $pmodel_id = $u->_get_pmodel_id_from_pseq_id($t_pseq_id);
		if ( ! defined $pmodel_id ) {
			throw Unison::RuntimeError( "Can't find pmodel_id for pseq_id=$t_pseq_id" );
		}

    while(my $hsp = $sbjct->nextHSP) {
      $u->insert_hsp( $q_pseq_id, $pmodel_id, $hsp );
    }
  }
}


#-------------------------------------------------------------------------------
# insert_hsp()
#-------------------------------------------------------------------------------

=head2 insert_hsp()

 Name:      insert_hsp()
 Purpose:   insert 1 Bio::Tools::BPlite::HSP
 Arguments: query pseq_id, target pmodel_id, Bio::Tools::BPlite::HSP
 Returns:   nada
                                                                                                                                              
=cut

sub insert_hsp {
  my($u,$pseq_id,$pmodel_id,$hsp) = @_;

	$u->insert_hsp_swap($pseq_id,$pmodel_id,$hsp,0);

  return;
}


#-------------------------------------------------------------------------------
# insert_hsp_swap()
#-------------------------------------------------------------------------------

=head2 insert_hsp_swap()

 Name:      insert_hsp_swap()
 Purpose:   insert 1 Bio::Tools::BPlite::HSP allow for swapping of query and
            target information.
 Arguments: query pseq_id, target pmodel_id, Bio::Tools::BPlite::HSP, swap flag
 Returns:   nada

=cut

sub insert_hsp_swap {
  my($u,$pseq_id,$pmodel_id,$hsp,$swap) = @_;

  # check parameters!
  if      ( ! defined $u or ( ref $u ne 'Unison' ) ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires Unison object' );
  } elsif ( ! defined $pseq_id ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires query pseq_id as a parameter' );
  } elsif ( ! defined $pmodel_id ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires pmodel_id as a parameter' );
  } elsif ( ! defined $hsp or ( ref $hsp ne 'Bio::Tools::BPlite::HSP' ) ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires Bio::Tools::BPlite::HSP object' );
  }
  throw Unison::RuntimeError( 'Unison connection is not open' ) if ! $u->is_open();
  
  my $sql_start;
	if ( $swap ) {
		$sql_start = "insert into papseq " .
			"(pseq_id, mstart, mstop, pmodel_id, start, stop, len, ident, sim, " .
			"gaps,score,eval,pct_ident)";
	} else {
		$sql_start = "insert into papseq " .
			"(pseq_id, start, stop, pmodel_id, mstart, mstop, len, ident, sim, " .
			"gaps,score,eval,pct_ident)";
	}
  my $sql = $sql_start . "values (?,?,?,?,?,?,?,?,?,?,?,?,?)";
  my $sth = $u->prepare_cached($sql);
  my @values = ( $pseq_id, $hsp->query->start, $hsp->query->end, $pmodel_id, $hsp->hit->start,
    $hsp->hit->end,  $hsp->length, $hsp->match, $hsp->positive, $hsp->gaps, $hsp->score,
    $hsp->P, $hsp->percent );
  print "sql: $sql_start values (" . join(',',@values) . ")\n" if $ENV{'DEBUG'};
  $sth->execute( @values );

  return;
}


#-------------------------------------------------------------------------------
# _get_pseq_id_from_name()
#-------------------------------------------------------------------------------

=head2 _get_pseq_id_from_name()

 Name:      _get_pseq_id_from_name()
 Purpose:   retrieve pseq_id from a FASTA header
 Arguments: FASTA header
 Returns:   pseq_id (or undef if not found)

=cut

sub _get_pseq_id_from_name {
  my ($u,$name) = @_;
  my $pseq_id;

  if ( $name =~ m/^Unison:(\d+)/ ) {
    $pseq_id=$1;
  }
  return $pseq_id;
}


#-------------------------------------------------------------------------------
# _get_pmodel_id_from_pseq_id()
#-------------------------------------------------------------------------------

=head2 _get_pmodel_id_from_pseq_id()

 Name:      _get_pmodel_id_from_pseq_id()
 Purpose:   retrieve pmodel_id given a pseq_id
 Arguments: pseq_id
 Returns:   pmodel_id (or undef if not found)

=cut

my %pmodel_id_cache;
sub _get_pmodel_id_from_pseq_id {
  my ($u,$pseq_id) = @_;

  # use cached value if available
  return $pmodel_id_cache{ $pseq_id } if 
    defined $pmodel_id_cache{ $pseq_id };

  throw Unison::RuntimeError( 'Unison connection is not open' ) if ! $u->is_open();

  my $sql = "select pmodel_id from pmpseq where pseq_id=?";
  my $sth = $u->prepare_cached($sql);
  $sth->execute( $pseq_id );
  my $retval = $sth->fetchrow_arrayref();
  $sth->finish();

  # store pmodel_id (if available) in cache for the specified pseq_id
  if ( defined  $retval->[0] ) {
    $pmodel_id_cache{ $pseq_id } = $retval->[0];
    return $retval->[0];
  }
  return;
}


1;
