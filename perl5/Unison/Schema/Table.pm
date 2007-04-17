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
	 pkq => undef,
	 pred => [],
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

sub copy_query() {
  my ($self,$ti) = @_;
  my $rc = '0123456789ABCDEFGHIJKLKMNOPQRSTUVWXYZabcdefghijklkmnopqrstuvwxyz';
  my ($tp) = "$self" =~ m/0x(\w+)/;
  my $T = "${tp}_T";
  if (not defined $self->{cq}) {
	my $q = "SELECT $T.* FROM ONLY $self->{st} $T\n";
	my @fks = @{$self->{fks}};
	for(my $i=0; $i<=$#fks; $i++) {
	  my $fk = $fks[$i];
	  next if $fk->{ud} ne 'cc';
	  my $A = "${tp}_J$i";
	  my $pkst = "$fk->{pk_namespace}.$fk->{pk_relation}";
	  my $pkq = $ti->{$pkst}->copy_query($ti);
	  $pkq =~ s/\n/ /g;
	  $q .= sprintf("%sJOIN ($pkq) $A ON $T.%s=$A.%s\n",
					($fk->{fk_notnull} eq 't' ? '' : 'LEFT '),
					$fk->{fk_column}, $fk->{pk_column});
	}
	if (@{$self->{pred}}) {
	  $q .= 'WHERE ' . join(' AND ', map {s/\$T/$T/g; "($_)"} @{$self->{pred}}) . "\n";
	}
	$self->{cq} = $q;
  }
  return $self->{cq};
}

sub pk_query($$) {
  # each table with a PK needs to have a "PK query" -- the query that
  # defines which PK values (and rows) are in the copied table.  Usually,
  # this is just the copy query for the table. 
  my ($self,$ti) = @_;
  return $self->{pkq} || $self->copy_query($ti);
}



1;

