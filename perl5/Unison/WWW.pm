package Unison::WWW;

# prepend the full path of ../perl5/ to @INC
# this facilitates tree relocation / dev trees in user directories
# To be safe, it's probably best to load this last.

BEGIN {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
}
use lib $ENV{PWD}."/../perl5";

1;
