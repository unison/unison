package Unison::WWW;

# prepend the full path of ../perl5/ to @INC
# this facilitates tree relocation / dev trees in user directories
# To be safe, it's probably best to load this last.

BEGIN {
  $ENV{SCRIPT_FILENAME} = $0 unless (exists $ENV{SCRIPT_FILENAME});
  my ($dir) = $ENV{SCRIPT_FILENAME} =~ m%^(.*\/)%;
  $dir .= '/../perl5';
  unshift(@INC, $dir) if (-d $dir);
}

1;
