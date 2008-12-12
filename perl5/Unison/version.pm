package Unison;

use strict;
use warnings;

our $REVISION;

my $revision_fn = "$Unison::UNISON_TOP/.svnversion";

if ( open(F, "<$revision_fn") ) {
  $REVISION = <F>;
  chomp($REVISION);
} else {
  $REVISION = "$revision_fn: $!";
}


1;
