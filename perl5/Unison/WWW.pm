package Unison::WWW;


# prepend the full path of ../perl5/ to @INC
# this facilitates tree relocation / dev trees in user directories
BEGIN {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
}
use lib $ENV{PWD}."/../perl5";

