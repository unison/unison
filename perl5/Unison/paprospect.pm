
=head1 NAME

Unison::paprospect -- Unison paprospect table utilities
S<$Id$>

=head1 SYNOPSIS

 use Unison;
 my $u = new Unison;
 my $seq = $u->delete1thread()

=head1 DESCRIPTION

B<> is a

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

my %uf = (
    'raw'       => 'raw_score',
    'svm'       => 'svm_score',
    'zscore'    => 'z_score',
    'mutation'  => 'mutation_score',
    'singleton' => 'singleton_score',
    'pairwise'  => 'pair_score',
    'ssfit'     => 'ssfit_score',
    'gap'       => 'gap_score',
    'nident'    => 'identities',
    'nalign'    => 'align_len',
    'rgyr'      => 'rgyr',
    'start'     => 'qstart',
    'stop'      => 'qend',
);

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## insert_thread()

=pod

=item B<< $u->insert_thread(pseq_id, params_id, Bio::Prospect::ThreadSummary) >>

=item B<< $u->insert_thread(pseq_id, params_id, Bio::Prospect::Thread) >>

inserts 1 Bio::Prospect::Thread object into the database

=cut

sub insert_thread {
    my ( $u, $pseq_id, $params_id, $t ) = @_;

    # check parameters
    if ( !defined $pseq_id or $pseq_id !~ m/^\d+$/ ) {
        throw Unison::BadUsage(
            "insertThread() pseq_id provided is missing or invalid");
    }
    elsif ( !defined $params_id or $params_id !~ m/^\d+$/ ) {
        throw Unison::BadUsage(
            "insertThread() params_id provided is missing or invalid");
    }
    elsif ( !defined $t or ( ref $t !~ m/Bio::Prospect::Thread/ ) ) {
        throw Unison::BadUsage(
            "insertThread() thread provided is missing or invalid");
    }

    # get the model id for the template name given
    my $pmodel_id = $u->get_pmodel_id( $t->tname );
    if ( !defined $pmodel_id or $pmodel_id eq '' ) {
        throw Unison::BadUsage(
            "insertThread() pmodel_id doesn't exist for template name: "
              . $t->name() );
    }

    # build key/values for sql insert
    my @ufs = keys %uf;
    my @k = ( 'pseq_id', 'params_id', 'pmodel_id', @ufs );
    my @v = ( $pseq_id, $params_id, $pmodel_id, map { $t->{ $uf{$_} } } @ufs );

    throw Unison::BadUsage(
        "keys (" . $#k + 1 . ") != values (" . $#v + 1 . ")\n" )
      if $#k != $#v;

    #this needs to be reconsidered : why `NA` values in threading output
    if ( grep { /NA/ } map { $_ if defined $_ } @v ) {
        warn "found value = NA, not inserting thread\n";
        return;
    }

    my $sql =
        'insert into paprospect ('
      . join( ',', @k )
      . ') values ('
      . join( ',', map { '?' } @k ) . ')';
    my $show_sql =
        "insert into paprospect ("
      . join( ',', @k )
      . ") values ("
      . join( ',', map { defined $_ ? $_ : '' } @v ) . ")";
    print "insertThread(): $show_sql\n" if $ENV{'DEBUG'};
    my $sth = $u->prepare_cached($sql);
    $sth->execute(@v);
    $sth->finish();
}

######################################################################
## delete_thread( )

=pod

=item B<< $u->delete_thread(pseq_id, params_id, Bio::Prospect::ThreadSummary) >>

=item B<< $u->delete_thread(pseq_id, params_id, Bio::Prospect::Thread) >>

  deletes the alignment for the given pseq_id, params_id, and model

  BUG/MISFEATURE: This does not reset the run_history!

=cut

sub delete_thread {
    my ( $u, $pseq_id, $params_id, $t ) = @_;

    # check parameters
    if ( !defined $pseq_id or $pseq_id !~ m/^\d+$/ ) {
        throw Unison::BadUsage(
            "delete_thread() pseq_id provided is missing or invalid");
    }
    elsif ( !defined $params_id or $params_id !~ m/^\d+$/ ) {
        throw Unison::BadUsage(
            "delete_thread() params_id provided is missing or invalid");
    }
    elsif ( !defined $t or ( ref $t !~ m/Bio::Prospect::Thread/ ) ) {
        throw Unison::BadUsage(
            "delete_thread() thread provided is missing or invalid");
    }

    # get the model id for the template name given
    my $pmodel_id = $u->get_pmodel_id( $t->tname );
    if ( !defined $pmodel_id or $pmodel_id eq '' ) {
        throw Unison::RuntimeError(
            "deleteThread() pmodel_id doesn't exist for template name: "
              . $t->name() );
    }

    my $sql =
      'delete from paprospect where pseq_id=? and params_id=? and pmodel_id=?';
    my $show_sql =
"delete from paprospect where pseq_id=$pseq_id and params_id=$params_id and pmodel_id=$pmodel_id";
    print "deleteThread(): $show_sql\n" if $ENV{'DEBUG'};

    my $sth = $u->prepare_cached($sql);
    $sth->execute( $pseq_id, $params_id, $pmodel_id );
    $sth->finish();
}

######################################################################
## get_pmodel_id()

=pod

=item B<< $u->get_pmodel_id(C<model name>) >>

retrieves the pmodel_id for a given model name (e.g. template name)

=cut

my %pmodel_id;

sub get_pmodel_id {
    my ( $u, $modn ) = @_;
    if ( not exists $pmodel_id{$modn} ) {
        my $sth =
          $u->prepare_cached('select pmodel_id from pmprospect where acc=?');
        $sth->execute($modn);
        ( $pmodel_id{$modn} ) = $sth->fetchrow_array();
        $sth->finish();
    }
    return $pmodel_id{$modn};
}

#-------------------------------------------------------------------------------

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
