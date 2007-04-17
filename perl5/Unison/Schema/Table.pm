package Unison::Schema::Table;

use strict;
use warnings;

use Data::Dumper;


sub new() {
  my $class = shift;
  my $self = 
	{
	 st => undef,
	 fks => [],
	 cq => undef,
	 pq => undef,
	 pkq => undef,
	 pred => [],
	 restricted => 0,
	 @_
	};
  bless $self, $class;
}

sub add_fk($$) {
  my $self = shift;
  push( @{$self->{fks}}, @_ );
}

sub add_pred($$) {
  my $self = shift;
  push( @{$self->{pred}}, @_ );
  $self->{restricted}++;
}

sub st(@) {
  my $self = shift;
  $self->{st} = $_[0] if @_;
  $self->{st};
}

sub pk_st() {
  my $self = shift;
  map { "$_->{pk_namespace}.$_->{pk_relation}" } @{$self->{fks}};
}


sub pred_query() {
  # returns a query of the self table with local predicates (and no
  # external constraints)
  my ($self) = @_;
  my $tp = $self->_table_prefix();
  my $T = "${tp}_T";
  if (not defined $self->{pq}) {
	my $q = "SELECT $T.* FROM ONLY $self->{st} $T\n";
	if (@{$self->{pred}}) {
	  $q .= 'WHERE ' . join(' AND ', map {s/\$T/$T/g; "($_)"} @{$self->{pred}}) . "\n";
	}
	$self->{pq} = $q;
  }
  return $self->{pq}
}


sub copy_query() {
  # returns a query for this table that is a projection based on "local"
  # predicates and by those dictated by other tables via FK-PK constraints
  # It has the general form:
  #   pred_query
  #   JOIN ( pk1 copy query ) PK1 ON X.fk1c=Y.pk1c
  #   JOIN ( pk2 copy query ) PK2 ON X.fk2c=Y.pk2c
  # etc.
  # GOTCHAS:
  # 1. If a fk column is nullable, we need a left join
  # 2. No recursion checking

  my ($self) = @_;

  if ( not (defined $self->{cq} and ref $self->{cq} eq 'SCALAR') ) {
	$self->{cq} = $self->_build_copy_query();
  }

  return $self->{cq};
}



## INTERNAL FUNCTIONS
##

sub _table_prefix() {
  # _table_prefix -- used to alias tables with a unique name
  # in this case, the perl ref address
  my $self = shift;
  my ($tp) = "$self" =~ m/0x(\w+)/;
  return $tp;
}


my %recursive_cq_build_st;
sub _build_copy_query() {
  my $self = shift;
  my $st = $self->{st};

  if (exists $recursive_cq_build_st{$st}) {
	warn("recursive build of query for $st detected\n");
	return $self->pred_query();
  }
  $recursive_cq_build_st{$st}++;

  if (ref $self->{cq} eq 'CODE') {
	$self->{cq} = &{$self->{cq}};
  } else {
	$self->{cq} = $self->_build_copy_query_auto();
  }

  delete $recursive_cq_build_st{$st};
  $self->{cq};
  }

sub _build_copy_query_auto() {
  my $self = shift;
  my $tp = $self->_table_prefix();
  my $T = "${tp}_T";
  my $q = $self->pred_query();
  my @fks = @{$self->{fks}};
  for(my $i=0; $i<=$#fks; $i++) {
	my $fk = $fks[$i];
	my $pkst = "$fk->{pk_namespace}.$fk->{pk_relation}";

	if ($fk->{ud} ne 'cc') {
	  warn(sprintf("! %s(%s)->%s(%s) is type '%s' and not supported\n"
				   . "!  Dump will be inconsistent if PK rows are missing\n",
				   $self->{st}, $fk->{fk_column},
				   $fk->{pk_relation}, $fk->{pk_column},
				   $fk->{ud} ));
	  next;
	}

	my $pkt = $fk->{pkt};
	(defined $pkt) || die("FATAL: pkt is undefined for fk:\n", Dumper($self));
	my $pkq = $pkt->copy_query();
	(defined $pkq) || die("FATAL: pkq is undefined for fk:\n", Dumper($self));

	next unless $pkt->{restricted};			# must be called after c_q()!

	$pkq =~ s/\n/ /g;
	my $A = "${tp}_J$i";
	$q .= sprintf("%sJOIN ($pkq) $A ON $T.%s=$A.%s\n",
				  ($fk->{fk_notnull} ? '' : 'LEFT '),
				  $fk->{fk_column}, $fk->{pk_column});

	$self->{restricted}++;
  }
  return $q;
}


1;

