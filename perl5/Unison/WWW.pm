package Unison::WWW;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

our $RELEASE = '$Name$';

BEGIN {
  # if this file exists and is writable, then we'll open it for logging.
  # NOTE: the file must be writable by the web server, which DOES NOT run
  # as remote user. Typically, do something like:
  # $ touch /tmp/unison-rkh.log
  # $ chmod a+w /tmp/unison-rkh.log
  # to enable logging.
  # THIS WILL SLOW THINGS DOWN... DON'T FORGET TO DELETE THE LOG!
  my $log_fn = "/tmp/unison-$ENV{REMOTE_USER}.log";
  if (-f $log_fn and -w $log_fn) {
	close(STDERR);
	if (not open(STDERR, ">>$log_fn")) {
	  print("$log_fn: $!\n");
	  exit(0);
	}
	$ENV{DEBUG} = 1;
  }


  # Prepend the full path of ../perl5/ to @INC
  # This facilitates tree relocation / dev trees in user directories.
  # To be safe, it's probably best to load Unison::WWW after non-Unison
  # modules.
  $ENV{SCRIPT_FILENAME} = $0 unless (exists $ENV{SCRIPT_FILENAME});
  my ($dir) = $ENV{SCRIPT_FILENAME} =~ m%^(.*\/)%;
  $dir .= '/../perl5';
  unshift(@INC, $dir) if (-d $dir);
}

1;
