package Unison;

use strict;
use warnings;
use Carp qw(cluck);


my %warned;
sub warn_deprecated($)
  {
  cluck("WARNING: deprecated function $_[0] called\n") 
	unless $warned{$_[0]}++;
  }


sub get_seq
  {
  my $self = shift;
  warn_deprecated((caller(0))[3]);
  return $self->get_sequence_by_pseq_id(@_);
  }

1;
