# IQ = intelligent query

package Unison::IQ;

sub new
  {
  my $class = shift;
  my $self = bless({@_},$class);
  $self->{offset} = undef;
  $self->{limit} = undef;
  $self->{order} = undef;
  return $self;
  }

sub fieldn
  { $_[0]->{fields}[$_[1]]; }

sub _sql
  {
  my $self = shift;
  $self->{sql}
	. (defined $self->{order}  ? " order by $self->{order}"  : ''),
	. (defined $self->{limit}  ? " limit $self->{limit}"     : ''),
	. (defined $self->{offset} ? " order by $self->{offset}" : ''));
  }

