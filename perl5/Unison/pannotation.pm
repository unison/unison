
=head1 NAME

Unison::pannotation -- Unison pannotation table utilities
S<$Id$>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

In Unison, each distinct sequence may derive from one or more databases
(origins) and be associated with zero or more names (aliases) from those
databases. This module provides an interface to the alias and origin data
for Unison sequences.

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Unison::Exceptions;

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## assign_annotation( )

=pod

=item B<< $u->assign_annotation(origin_id, alias, descr, pseq_id, ref_pseq_id, tax_id) >>

Assigns an alias in the specified origin, and the tax_id, to the pseq_id.
The alias is created if necessary.  The new or existing pannotation_id is
returned.  This function is equivalent to the server-side function by the
same name.

=cut

sub assign_annotation($$$$) {
    my $self = shift;
    my ( $pseq_id, $origin_id, $alias, $descr, $tax_id ) = @_;
    my $sth = $self->prepare_cached('select assign_annotation(?,?,?,?,?)');
    return $self->selectrow_array( $sth, undef, $pseq_id, $origin_id, $alias,
        $descr, $tax_id );
}

######################################################################
## get_pseq_id_from_alias( )

=pod

=item B<< $u->get_pseq_id_from_alias(C<text>) >>

returns an array of distinct pseq_ids for the given alias by first trying
for an exact match; if that fails, a case-folded search is performed; if
that fails, a fuzzy search (with ilike) is tried.

If the alias starts with /, ~, ~*, or ^, then only the regular express
search is tried.

=cut

sub get_pseq_id_from_alias {
    my ( $u, $query, $ori ) = @_;
    $u->is_open()
      || throw Unison::RuntimeError("Unison connection not established");
    ( defined $query )
      || throw Unison::RuntimeError("alias not defined");
    my @ids;

    # Unison pseq_ids, qualified by origin
    # this should be extended to other origins
    if ( $query =~ m/Unison:(\d+)/i ) {
        return $1;
    }

    # RefSeq
    if ( $query =~ s/^RefSeq://i or $query =~ m/^[NXZAY]P_\d+/ ) {
       # looks like a RefSeq alias.  This requires special handling because
       # we want to account for versioned identifier
       # official protein sequence prefixes are listed in
       # ftp://ftp.ncbi.nih.gov/refseq/release/release-notes/RefSeq-release4.txt
       # and http://www.ncbi.nih.gov/RefSeq/key.html#accessions
	  (@ids) = $u->get_pseq_id_from_alias_regexp( "^$query", 'RefSeq' );
	  return (@ids);
    }

    # Genentech UNQ, DNA, or PRO ids
    if ( $query =~ m%^(?:GenenGenes:)?(UNQ|DNA|PRO|FAM)(\d+)$%i ) {
        my ( $type, $id ) = ( lc($1), $2 );
        my $sql;

        # Genengenes occasionally has sequences which aren't in Unison,
        # in which case the view returns rows with empty pseq_ids.  This
        # is the origin of the 'and pseq_id is not null' condition.
        if ( $type eq 'PRO' or $type eq 'DNA' or $type eq 'UNQ' ) {
            $sql =
"select distinct pseq_id from pseq_sst_v where ${type}ID=$id and pseq_id is not null";
        }
        elsif ( $type eq 'FAM' ) {
            $sql =
"select distinct pseq_id from gg_famid_pseq_id_v where ${type}ID=$id and pseq_id is not null";
        }
        else {
            throw Unison::Exception( 'Unmatched SST entry type',
                "I don't know what a $type entry is" );
        }

        (@ids) = map { @$_ } @{ $u->selectall_arrayref($sql) };

		# some ids might have been removed from sst; in that case, @ids
		# will be empty and we'll continue with an alias lookup below
        return (@ids) if @ids;
    }


	# FIXME: Some reasonable aliases may be ambiguous (refer to >1
	# sequence).  For example, 'MCL1' is a Cosmic identifier, but a person
	# who searchs for that probably wants MCL1_HUMAN. They're the same
	# gene but have different pseq_ids.

    if ( not $query =~ m%^[~/^]% ) {
	  # doesn't smell like a regexp
	  (@ids) = $u->get_pseq_id_from_alias_casefolded( $query, $ori );
	  return (@ids) if @ids;
    }

    if ( $query =~ /^[~^]/ ) {
        # looks like a regexp OR exact match above failed
        (@ids) = $u->get_pseq_id_from_alias_regexp( $query, $ori );
        return (@ids);
    }

    return;
}

######################################################################
## get_pseq_id_from_alias_exact( )

=pod

=item B<< $u->get_pseq_id_from_alias_exact(C<text>) >>

returns an array of distinct pseq_ids for exact, case-sensitive matches to
the given alias

=cut

sub get_pseq_id_from_alias_exact {
    my ( $u, $query, $ori ) = @_;
    $u->is_open()
      || throw Unison::RuntimeError("Unison connection not established");
    ( defined $query )
      || throw Unison::RuntimeError("alias not defined");
    my $sql = 'select distinct pseq_id from palias where alias = ?';
    $sql .= " AND origin_id=origin_id('$ori')" if defined $ori;
    return ( map { @$_ } @{ $u->selectall_arrayref( $sql, undef, $query ) } );
}

######################################################################
## get_pseq_id_from_alias_casefolded( )

=pod

=item B<< $u->get_pseq_id_from_alias_casefolded(C<text>) >>

returns an array of distinct pseq_ids for exact, case-INsensitive matches
to the given alias

=cut

sub get_pseq_id_from_alias_casefolded {
    my ( $u, $query, $ori ) = @_;
    $u->is_open()
      || throw Unison::RuntimeError("Unison connection not established");
    ( defined $query )
      || throw Unison::RuntimeError("alias not defined");
    my $sql = 'select distinct pseq_id from palias where lower(alias) = ?';
    $sql .= " AND origin_id=origin_id('$ori')" if defined $ori;
    return ( map { @$_ }
          @{ $u->selectall_arrayref( $sql, undef, lc($query) ) } );
}

######################################################################
## get_pseq_id_from_alias_regexp( )

=pod

=item B<< $u->get_pseq_id_from_alias_regexp(C<regexp>) >>

returns an array of distinct pseq_ids by searching for the given alias as
a regular expression.  Regular expression matching by this function is
always case-folded.

=cut

sub get_pseq_id_from_alias_regexp {
    my ( $u, $query, $ori ) = @_;
    $u->is_open()
      || throw Unison::RuntimeError("Unison connection not established");
    ( defined $query )
      || throw Unison::RuntimeError("alias not defined");

    my $sql = "SELECT DISTINCT pseq_id FROM palias WHERE lower(alias) ~ lower(?)";
    $sql .= " AND origin_id=origin_id('$ori')" if defined $ori;
	my $sth = $u->prepare( $sql );
	$sth->{pg_server_prepare} = 0;
    return ( map { @$_ } @{ $u->selectall_arrayref( $sth, undef, $query ) } );
}

######################################################################
## get_pseq_id_from_alias_fuzzy( )

=pod

=item B<< $u->get_pseq_id_from_alias_fuzzy(C<text>) >>

returns an array of distinct pseq_ids by searching for the given alias
expression with ilike.

=cut

sub get_pseq_id_from_alias_fuzzy {
    my ( $u, $query, $ori ) = @_;
    $u->is_open()
      || throw Unison::RuntimeError("Unison connection not established");
    ( defined $query )
      || throw Unison::RuntimeError("alias not defined");
    my $sql = 'select distinct pseq_id from palias where alias ilike ?';
    $sql .= " AND origin_id=origin_id('$ori')" if defined $ori;
    return ( map { @$_ } @{ $u->selectall_arrayref( $sql, undef, $query ) } );
}

#### DEPRECATED FUNCTIONS

######################################################################
## add_palias( )

=pod

=item B<< $u->add_palias( C<pseq_id>,C<origin_id>,C<alias>,C<descr> ) >>

DEPRECATED 2006-09-27 Reece Hart <reece@harts.net>
OBSOLETED 2009-03-12 Reece Hart <reece@harts.net>

adds an alias and description record in the pannotation and pseq_pannotation
tables for the existing origin_id and pseq_id.

=cut

sub __OBSOLETE__add_palias {
    warn_deprecated();

    my ( $self, $pseq_id, $origin_id, $alias, $descr, $tax_id ) = @_;

    $self->is_open()
      || croak("Unison connection not established");

    if ( defined $descr and $descr =~ /\w/ ) {
        $descr =~ s/([\'])/\\$1/g;
        $descr =~ s/^\s+//;
        $descr =~ s/\s+$//;
        $descr =~ s/\s{2,}/ /;
        $descr = "'$descr'";
    }
    else {
        $descr = 'NULL';
    }

    $tax_id = ( defined $tax_id ) ? $tax_id : 'NULL';

    if (   not defined $pseq_id
        or not defined $origin_id
        or not defined $alias
        or not defined $descr )
    {
        die(
            "Assertion failed\n",
            sprintf(
                "<pseq_id,origin_id,alias,descr>=<%s,%s,%s,%s>",
                defined $pseq_id   ? $pseq_id   : 'undef',
                defined $origin_id ? $origin_id : 'undef',
                defined $alias     ? $alias     : 'undef',
                defined $descr     ? $descr     : 'undef'
            )
        );
    }

    my $sql = "insert into palias (pseq_id,origin_id,alias,descr,tax_id) "
      . "values ($pseq_id,$origin_id,'$alias',$descr,$tax_id)";
    print STDERR "sql: $sql\n" if $ENV{DEBUG};
    $self->do( $sql, { PrintError => 1 } );
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
