=head1 NAME

Unison::template -- Unison:: module template

S<$Id: WWW.pm,v 1.10 2005/01/18 18:51:16 rkh Exp $>

=head1 SYNOPSIS

 use Unison::template;
 #do something, you fool!

=head1 DESCRIPTION

B<Unison::template> is template for building new perl modules.

=cut


package Unison::WWW;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

our ($RELEASE) = q$Name: rel_1-0-2 $ =~ m/Name:\s+rel_(\S*)\s+/;
$RELEASE =~ s/-/./g;



BEGIN {
  # if this file exists and is writable, then we'll open it for logging.
  # NOTE: the file must be writable by the web server, which DOES NOT run
  # as remote user. Typically, do something like:
  # $ touch /tmp/unison-rkh.log
  # $ chmod a+w /tmp/unison-rkh.log
  # to enable logging.
  # THIS WILL SLOW THINGS DOWN... DON'T FORGET TO DELETE THE LOG!
  if (exists $ENV{REMOTE_USER}) {
	my $log_fn = "/tmp/unison-$ENV{REMOTE_USER}.log";
	if (-f $log_fn and -w $log_fn) {
	  close(STDERR);
	  if (not open(STDERR, ">>$log_fn")) {
		print("$log_fn: $!\n");
		exit(0);
	  }
	  $ENV{DEBUG} = 1;
	}
  }
}

1;
