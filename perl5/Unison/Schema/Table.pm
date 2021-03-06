package Unison::Schema::Table;

use strict;
use warnings;

use Data::Dumper;

sub new() {
  my $class = shift;
  my $self  = {
			   cq         => undef,
			   fks        => [],
			   namespace  => undef,
			   pkq        => undef,
			   pq         => undef,
			   pred       => [],
			   relation   => undef,
			   restricted => 0,
			   st         => undef,

			   @_
			  };

  if ( defined $self->{st} ) {
	( $self->{namespace}, $self->{relation} ) = split( /\./, $self->{st} );
  }

  $self->{st}  = "$self->{namespace}.$self->{relation}";
  $self->{qst} = "\"$self->{namespace}\".\"$self->{relation}\"";

  bless $self, $class;
}

sub add_fk($$) {
  my $self = shift;
  push( @{ $self->{fks} }, @_ );
}

sub add_pred($$) {
  my $self = shift;
  push( @{ $self->{pred} }, @_ );
  $self->{restricted}++;
}

sub st(@) {
  my $self = shift;
  $self->{st} = $_[0] if @_;
  $self->{st};
}

sub pk_st() {
  my $self = shift;
  map { "$_->{pk_namespace}.$_->{pk_relation}" } @{ $self->{fks} };
}

sub pred_query() {
  # returns a query of the table with local predicates and no external
  # constraints
  my ($self) = @_;
  warn(">> pq($self->{st})\n") if $ENV{DEBUG};
  if ( not defined $self->{pq} ) {
	my $q = sprintf( 'SELECT * FROM ONLY "%s"."%s"',
					 $self->{namespace}, $self->{relation} );
	if ( @{ $self->{pred} } ) {
	  $q .= ' WHERE ' . join( ' AND ', @{ $self->{pred} } );
	}
	$self->{pq} = $q;
  }
  warn("<< pq($self->{st}): $self->{pq}\n") if $ENV{DEBUG};
  return $self->{pq};
}

sub copy_query() {
  # returns a query used to copy data. This restricts the select by the
  # table's predicates as well as all constraints implied by the copy
  # queries of tables reference by FK.
  my ($self) = @_;
  warn(">> cq($self->{st})\n") if $ENV{DEBUG};
  if ( not defined $self->{cq}
	   or ref $self->{cq} eq 'CODE' ) {
	my $cq = $self->_build_copy_query();
	if ( not defined $cq ) {
	  warn("<< cq($self->{st}): undef\n") if $ENV{DEBUG};
	  return $self->pred_query();			# EXPERIMENTAL
	}
	$self->{cq} = $cq;
	warn("== cq($self->{st}) := $self->{cq}\n") if $ENV{DEBUG};
  }
  warn("<< cq($self->{st}): $self->{cq}\n") if $ENV{DEBUG};
  return $self->{cq};
}

## INTERNAL FUNCTIONS
##

sub _table_prefix() {
  # _table_prefix -- used to alias tables with a unique name
  # in this case, the perl ref address
  my $self = shift;
  my ($tp) = "$self" =~ m/(0x\w+)/;
  return "$self->{relation}_$tp";
}

my %recursive_cq_build_st;

sub _build_copy_query() {
  my $self = shift;
  warn(">> bcq($self->{st})\n") if $ENV{DEBUG};
  my $st = $self->{st};
  my $cq;

  if ( exists $recursive_cq_build_st{$st}
	   and $recursive_cq_build_st{$st} > 0 ) {
	warn("<< bcq($self->{st}): undef (recursive)\n") if $ENV{DEBUG};
	return undef;
  }
  $recursive_cq_build_st{$st}++;

  if ( ref $self->{cq} eq 'CODE' ) {
	warn(">> cq CODE ref($self->{st})\n") if $ENV{DEBUG};
	$cq = &{ $self->{cq} };
	warn(">> cq CODE ref($self->{st}): $cq\n") if $ENV{DEBUG};
  } else {
	$cq = $self->_build_copy_query_auto();
  }

  $recursive_cq_build_st{$st}--;
  warn("<< bcq($self->{st}): $cq\n") if $ENV{DEBUG};

  return $cq;
}

sub _build_copy_query_auto() {
  # returns a query for this table that is a projection based on "local"
  # predicates and by those dictated by other tables via FK-PK constraints
  # It has the general form:
  #   pred_query T
  #   JOIN ( pk1 copy query ) J0 ON T.fk1c=J0.pk1c
  #   JOIN ( pk2 copy query ) J1 ON T.fk2c=J1.pk2c
  # etc.

  my $self = shift;
  warn(">> bcqa($self->{st})\n") if $ENV{DEBUG};
  my $tp  = $self->_table_prefix();
  my $T   = "${tp}_T";
  my $q   = sprintf( "SELECT $T.* FROM (%s) $T", $self->pred_query() );
  my @fks = @{ $self->{fks} };
  for ( my $i = 0 ; $i <= $#fks ; $i++ ) {
	my $fk = $fks[$i];

	# skip 'on del set null' constraints
	# these are resolved later by setting FKs to NULL for missing PKs
	next if ( $fk->{ud} =~ 'n$' );

	my $pkt = $fk->{pkt};
	( defined $pkt )
	  || die( "FATAL: pkt is undefined for fk:\n", Dumper($self) );
	my $pkq = $pkt->copy_query();
	if ( not defined $pkq ) {
	  warn("## bcqa: pkq is null; no JOIN\n") if $ENV{DEBUG};
	  next;
	}

	# if the PK column is not restricted, it provides no
	# exclusion of rows
	next unless $pkt->{restricted};			# must be called after c_q()!

	$pkq =~ s/\n/ /g;
	my $A = "${tp}_J$i";
	$q .= sprintf(
				  "\n%sJOIN ($pkq) $A ON $T.%s=$A.%s",
				  ( $fk->{ud} eq 'cc' ? '' : 'LEFT ' ),
				  $fk->{fk_column}, $fk->{pk_column}
				 );

	$self->{restricted}++;
  }
  warn("<< bcqa($self->{st}): $q\n") if $ENV{DEBUG};
  return $q;
}

1;

