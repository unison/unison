package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use Carp qw(cluck);


my %already_warned;
sub warn_deprecated() {
  my $dep_routine = (caller(1))[3];
  my $instance = "$dep_routine";
  #my $caller = sprintf("%s (%s:%d)", (caller(2))[3,1,2]);
  #my $instance = "$dep_routine\0$caller";
  cluck("WARNING: deprecated function $dep_routine() called\n") 
	unless $already_warned{$instance}++;
}


# convert an array of ranges to enumerated values
# e.g., range_to_enum(qw(1 2 3..5)) returns (1,2,3,4,5)
sub range_to_enum(@) {
  my $rl = join(',',@_);
  eval "$rl";
}


1;
