#!/usr/bin/env perl

use strict;
use warnings;
use Unison::utilities;


sub level2 {
  Unison::warn_deprecated();
}

sub level1 {
  level2();
}


level1();
