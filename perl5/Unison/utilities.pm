package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);


use strict;
use warnings;
use Carp qw(cluck);


my %already_warned;

sub warn_deprecated() {
  my @caller = caller(1);
  cluck("WARNING: deprecated function $caller[0] called\n") 
	unless $already_warned{$caller[0]}++;
}


1;
