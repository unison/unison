package Unison;

use FindBin;

our $REVISION;

my $revision_fn = "$FindBin::RealBin/../.svnversion";

if (-e $revision_fn) {
  $REVISION = `/usr/bin/head -1 $revision_fn`;
  chomp($REVISION);
} else {
  my @bins = (
			  '/gne/home/rkh/opt/bin',
			  '/gne/research/apps/subversion/prd/x86_64-linux-2.6-sles10/bin',
			  '/usr/bin'
			 );
  foreach my $b (@bins) {
	my $x = "$b/svnversion";
	if ( -x $x ) {
	  if ( open(V,">$revision_fn") ) {
		$REVISION = `$x`;
		chomp($REVISION);
		print(V $REVISION);
		close(V);
	  } else {
		warn("$revision_fn: $!");
	  }
	  last;
	}
  }
}



1;


