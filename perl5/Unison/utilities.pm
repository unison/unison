package Unison;
use strict;
use warnings;

use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use Carp qw(cluck);


my %already_warned;
sub warn_deprecated() {
  my @caller = caller(1);
  cluck("WARNING: deprecated function $caller[0] called\n") 
	unless $already_warned{$caller[0]}++;
}


# convert an array of ranges to enumerated values
# e.g., range_to_enum(qw(1 2 3..5)) returns (1,2,3,4,5)
sub range_to_enum(@) {
  my $rl = join(',',@_);
  eval "$rl";
}


1;
