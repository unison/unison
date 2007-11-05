
=head1 NAME

Unison::SQL -- simplified generation of SQL queries
S<$Id: SQL.pm,v 1.5 2005/01/20 01:05:17 rkh Exp $>

=head1 SYNOPSIS

 use Unison::SQL;
 my $sql = new Unison::SQL;
 $sql->columns(qw(pseq_id len))
     ->tables(pseq)
     ->where('pseq_id<=100');
 if (...) {
   $sql->order('len desc');
 }

 $sql->distinct(...);
 $sql->columns(...);


=head1 DESCRIPTION

B<Unison::SQL> is an object-oriented SQL construction class. The primary
intent is to facilitate the construction of dynamic queries, especially
those which change by more than simple where clause criteria during
runtime.  For example, I commonly build a base query and then
conditionally add other columns (perhaps via joins), "where" criteria,
order specifications, offsets, or limits.

Unison::SQL is not Unison-specific and will be moved elsewhere eventually.

=cut

package Unison::SQL;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use overload '""' => \&stringify;
use Unison::Exceptions;

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## new

=pod

=item B<new( ... )>

Generates a new Unison::SQL object and returns the reference to it.

=cut

sub new {
    my $class = shift;
    bless(
        {
            columns  => [],
            distinct => [],
            limit    => undef,
            tables   => [],
            offset   => undef,
            group    => [],
            order    => [],
            where    => [],
        },
        $class
    );
}

######################################################################
## columns

=pod

=item B<< $sql->columns( C<column spec> [, ...] ) >>

Adds columns to be returned by the query. There is currently no way to
reorder the order of the columns. (If you need to do this, fiddle with the
@{$ref->{columns}} array yourself.)

=cut

sub columns {
    my $self = shift;
    if (@_) {
        if ( defined $_[0] ) {
            push( @{ $self->{columns} }, @_ );
        }
        else {
            $self->{columns} = [];
        }
    }
    return $self;
}

######################################################################
## distinct

=pod

=item B<distinct( C<> )>

=cut

sub distinct {
    my $self = shift;
    if (@_) {
        if ( defined $_[0] ) {
            push( @{ $self->{distinct} }, @_ );
        }
        else {
            $self->{distinct} = [];
        }
    }
    return $self;
}

######################################################################
## table/join

=pod

=item B<join( C<> )>

=item B<table( C<> )>

=cut

sub table  { $_[0]->join( splice( @_, 1 ) ) }
sub tables { $_[0]->join( splice( @_, 1 ) ) }

sub join {
    my $self = shift;
    if (@_) {
        if ( defined $_[0] ) {
            push( @{ $self->{tables} }, @_ );
        }
        else {
            $self->{tables} = [];
        }
    }
    return $self;
}

######################################################################
## where

=pod

=item B<where( C<> )>

=cut

sub where {
    my $self = shift;
    if (@_) {
        if ( defined $_[0] ) {
            push( @{ $self->{where} }, @_ );
        }
        else {
            $self->{where} = [];
        }
    }
    return $self;
}

######################################################################
## order

=pod

=item B<order( C<> )>

=cut

sub order {
    my $self = shift;
    if (@_) {
        if ( defined $_[0] ) {
            push( @{ $self->{order} }, @_ );
        }
        else {
            $self->{order} = [];
        }
    }
    return $self;
}

######################################################################
## group

=pod

=item B<group( C<> )>

=cut

sub group {
    my $self = shift;
    if (@_) {
        if ( defined $_[0] ) {
            push( @{ $self->{group} }, @_ );
        }
        else {
            $self->{group} = [];
        }
    }
    return $self;
}

######################################################################
## limit

=pod

=item B<limit( C<> )>

=cut

sub limit {
    my $self = shift;
    $self->{limit} = $_[0];
    return $self;
}

######################################################################
## offset

=pod

=item B<offset( C<> )>

=cut

sub offset {
    my $self = shift;
    $self->{offset} = $_[0];
    return $self;
}

######################################################################
## sql

=pod

=item B<sql()>

=cut

sub sql {
    my $self = shift;

    ( @{ $self->{columns} } )
      || throw Unison::Exception::RuntimeError(
        'Nothing selected in Unison::SQL object');

    my @sql = 'SELECT';
    push( @sql,
        'DISTINCT ON', '(', CORE::join( ',', @{ $self->{distinct} } ), ')' )
      if @{ $self->{distinct} };
    push( @sql, CORE::join( ',', @{ $self->{columns} } ) );
    push( @sql, 'FROM', CORE::join( "   JOIN ", @{ $self->{tables} } ) )
      if @{ $self->{tables} };
    push( @sql, 'WHERE', CORE::join( '  AND  ', @{ $self->{where} } ) )
      if @{ $self->{where} };
    push( @sql, 'GROUP BY', CORE::join( ',', @{ $self->{group} } ) )
      if @{ $self->{group} };
    push( @sql,
        'ORDER BY',
        CORE::join( ',', @{ $self->{distinct} }, @{ $self->{order} } ) )
      if @{ $self->{distinct} }
          or @{ $self->{order} };
    push( @sql, 'OFFSET', $self->{offset} ) if defined $self->{offset};
    push( @sql, 'LIMIT',  $self->{limit} )  if defined $self->{limit};

    CORE::join( ' ', @sql );
}

sub stringify { $_[0]->sql() }

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
