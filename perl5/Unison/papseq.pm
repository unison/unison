=head1 NAME

Unison::papseq -- Unison papseq table utilities
S<$Id: papseq.pm,v 1.1 2003/06/12 22:29:26 cavs Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

(etc.)

=head1 DESCRIPTION

B<> is a

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
    throw Unison::RuntimeError("Nno pseq_id defined for this query sequence: " . 
      $report->query() );
  }
  while(my $sbjct = $report->nextSbjct) {
    my $t_pseq_id = $u->_get_pseq_id_from_name($sbjct->name());
    if ( !defined $t_pseq_id ) {
      warn("Nno pseq_id defined for this target sequence: " . $sbjct->name() . " - skipping\n" );
      next;
    }
    while(my $hsp = $sbjct->nextHSP) {
      $u->insert_hsp( $q_pseq_id, $t_pseq_id, $hsp );
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

  # check parameters!
  if      ( ! defined $u or ( ref $u ne 'Unison' ) ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires Unison object' );
  } elsif ( ! defined $pseq_id ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires query pseq_id as a parameter' );
  } elsif ( ! defined $pmodel_id ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires target pseq_id as a parameter' );
  } elsif ( ! defined $hsp or ( ref $hsp ne 'Bio::Tools::BPlite::HSP' ) ) {
    throw Unison::BadUsage( 'Unison::insert_hsp() requires Bio::Tools::BPlite::HSP object' );
  }
  
  my $sql_start = "insert into papseq " .
    "(pseq_id, start, stop, pmodel_id, mstart, mstop, len, ident, sim, " .
    "gaps,score,eval,pct_ident)";
  my $sql = $sql_start . "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
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
 Purpose:   retrieve pseq_id from a BLAST accession
 Arguments: accession
 Returns:   pseq_id (or undef if not found)

=cut

my %pseq_id_cache;
sub _get_pseq_id_from_name {
  my ($u,$name) = @_;
  my $pseq_id;

  # use cached value if available
  return $pseq_id_cache{ $name } if 
    defined $pseq_id_cache{ $name };

  # if name starts with Unison: expect that numeric
  # identifier following Unison: is the pseq_id.  this
  # is the standard when writing out FASTA files from
  # Unison.  Otherwise, parse the accesion and try
  # to look up the alias.
  if ( $name =~ m/^Unison:(\d+)/ ) {
    $pseq_id=$1;
  } else {
    $name =~ m/^(.*?)\s/;
    $pseq_id = $u->get_pseq_id_from_alias( $1 );
  }

  # store pseq_id (if available) in cache for the specified name
  $pseq_id_cache{ $name } = $pseq_id if defined $pseq_id;
  return $pseq_id;
}


1;
