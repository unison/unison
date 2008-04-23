
=head1 NAME

Unison::papseq -- Unison papseq table utilities
S<$Id$>

=head1 SYNOPSIS

 use Unison;

 my $u = new Unison;
 
 $u->load_blast_report( $ARGV[0] );

=head1 DESCRIPTION

B<Unison::papseq> is a module with methods for loading
BLAST reports into the papseq table in the Unison database.

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Bio::SearchIO;

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## load_blast_report()

=pod

=item B<< load_blast_report( B<BLAST filename> ) >>

load a BLAST report into the UNISON database

=cut

sub load_blast_report {
    my ( $u, $file ) = @_;

    my $report = new Bio::Tools::BPlite( -file => $file );
    my $q_pseq_id = $u->_get_pseq_id_from_FASTA_name( $report->query() );
    if ( !defined $q_pseq_id ) {
        throw Unison::RuntimeError(
            "No pseq_id defined for this query sequence: " . $report->query() );
    }
    while ( my $sbjct = $report->nextSbjct ) {
        my $t_pseq_id = $u->_get_pseq_id_from_FASTA_name( $sbjct->name() );
        throw Unison::RuntimeError(
            "No pseq_id defined for this target sequence: " . $sbjct->name() )
          if ( !defined $t_pseq_id );
        if ( $q_pseq_id == $t_pseq_id ) {
            print "Skipping this target ($t_pseq_id) because it is a self hit\n"
              if $ENV{'DEBUG'};
            next;
        }

        # get the pmodel_id for this sequence
        my $pmodel_id = $u->_get_pmodel_id_from_pseq_id($t_pseq_id);
        if ( !defined $pmodel_id ) {
            throw Unison::RuntimeError(
                "Can't find pmodel_id for pseq_id=$t_pseq_id");
        }

        while ( my $hsp = $sbjct->nextHSP ) {
            $u->insert_hsp( $q_pseq_id, $pmodel_id, $hsp );
        }
    }
}

######################################################################
## insert_hsp()

=pod

=item B<< insert_hsp(query pseq_id, target pmodel_id, Bio::Tools::BPlite::HSP) >>

insert 1 Bio::Tools::BPlite::HSP

=cut

sub insert_hsp {
    my ( $u, $pseq_id, $pmodel_id, $hsp, $params_id ) = @_;

    $u->insert_hsp_swap( $pseq_id, $pmodel_id, $hsp, 0, $params_id );

    return;
}

######################################################################
## new insert_hsp_swap()

=pod

=item B<< insert_hsp_swap(query pseq_id, target pmodel_id, Bio::Tools::BPlite::HSP, swap flag) >>

insert 1 Bio::Tools::BPlite::HSP allow for swapping of query and target
information.

=cut

sub insert_hsp_swap {
    my ( $u, $pseq_id, $pmodel_id, $hsp, $swap, $params_id ) = @_;

    # check parameters!
    if ( !defined $u or ( ref $u ne 'Unison' ) ) {
        throw Unison::BadUsage('Unison::insert_hsp() requires Unison object');
    }
    elsif ( !defined $pseq_id ) {
        throw Unison::BadUsage(
            'Unison::insert_hsp() requires query pseq_id as a parameter');
    }
    elsif ( !defined $pmodel_id ) {
        throw Unison::BadUsage(
            'Unison::insert_hsp() requires pmodel_id as a parameter');
    }
    elsif ( !defined $hsp or ( ref $hsp ne 'Bio::Search::HSP::GenericHSP' ) ) {
        throw Unison::BadUsage(
            'Unison::insert_hsp() requires Bio::Search::HSP::GenericHSP object'
        );
    }elsif ( !defined $params_id ) {
        throw Unison::BadUsage(
            'Unison::insert_hsp() requires params_id as a parameter');
    }
    throw Unison::RuntimeError('Unison connection is not open')
      if !$u->is_open();

    my $sql_start;
    if ($swap) {
        $sql_start =
            "insert into papseq "
          . "(pseq_id, mstart, mstop, pmodel_id, start, stop, len, ident, sim, "
          . "gaps,score,eval,pct_ident, params_id)";
    }
    else {
        $sql_start =
            "insert into papseq "
          . "(pseq_id, start, stop, pmodel_id, mstart, mstop, len, ident, sim, "
          . "gaps,score,eval,pct_ident,params_id)";
    }
    my $sql    = $sql_start . "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    my $sth    = $u->prepare_cached($sql);
    my @values = (
        $pseq_id,            $hsp->query->start,
        $hsp->query->end,    $pmodel_id,
        $hsp->hit->start,    $hsp->hit->end,
        $hsp->hsp_length,    $hsp->num_identical,
        $hsp->num_conserved, $hsp->gaps,
        $hsp->score,         $hsp->evalue,
        sprintf( "%.1f", $hsp->percent_identity ), $params_id
    );
    print "sql: $sql_start values (" . join( ',', @values ) . ")\n"
      if $ENV{'DEBUG'};
    $sth->execute(@values);

    return;
}

######################################################################
## new get_pseq_id_from_FASTA_name()
## XXX: This has no business being here, but I won't move it until
## I understand where Dave used this.

=pod

=item B<< get_pseq_id_from_FASTA_name(B<FASTA header text>) >>

returns pseq_id (or undef if not found)

=cut

sub get_pseq_id_from_FASTA_name {
    my ( $u, $name ) = @_;
    my $pseq_id;

    if ( $name =~ m/^Unison:(\d+)/ ) {
        $pseq_id = $1;
    }
    return $pseq_id;
}

######################################################################
## _get_pmodel_id_from_pseq_id()

=pod

=item B<< _get_pmodel_id_from_pseq_id(pseq_id) >>

Returns pmodel_id for the given pseq_id. Lookups are cached for speed.

=cut

my %pmodel_id_cache;

sub _get_pmodel_id_from_pseq_id {
    my ( $u, $pseq_id ) = @_;

    # use cached value if available
    return $pmodel_id_cache{$pseq_id}
      if defined $pmodel_id_cache{$pseq_id};

    throw Unison::RuntimeError('Unison connection is not open')
      unless $u->is_open();

    my $sql = "select pmodel_id from pmpseq where pseq_id=?";
    my $sth = $u->prepare_cached($sql);
    $sth->execute($pseq_id);
    my $retval = $sth->fetchrow_arrayref();
    $sth->finish();

    # store pmodel_id (if available) in cache for the specified pseq_id
    if ( defined $retval->[0] ) {
        $pmodel_id_cache{$pseq_id} = $retval->[0];
        return $retval->[0];
    }
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
