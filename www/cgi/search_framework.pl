#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use IO::Pipe;

my $cmd = '/gne/compbio/opt/unison/bin/framework-search';
$cmd = '/home/rkh/csb-db/unison/bin/framework-search';

my $p = new Unison::WWW::Page();
my $v = $p->Vars();

print $p->render("Framework Search",
				 (defined $v->{frameworks}
				  ? results($p)
				  : form($p) )
				 );

sub form {
  my $p = shift;
  return (
		  $p->warn('Searches on this page may take several minutes to complete.'),

		  $p->start_form(-method => 'GET',
						 -action => $p->make_url()),
		  'Enter Framework regions, one per line:',
		  '<br>',
		  $p->textarea(-name=>'frameworks',
					   -columns=>80,
					   -rows=>5,
					  ),
		  '<br>',
		  $p->submit(-value=>'vroom!'),
		  $p->end_form(), "\n",
		 );
}


sub results {
  my $p = shift;
  my $v = $p->Vars();
  my (@args) = grep {m/\w/} split(/\s+/m,$v->{frameworks});
  my ($fh,$fn,$urn) = $p->tempfile(SUFFIX=>'.html');

  #$fh->print($cmd, join('<br>', @args), "<br>\n\n");

  my $pipe = new IO::Pipe;
  if (not $pipe->reader($cmd, @args)) {
	$fh->print($!);
  }
  while (my $line = <$pipe>) {
	$fh->print($line);
  }
  $pipe->close();
  $fh->close();
  
  return sprintf(<<EOT,$urn,$urn,$p->warn('Your browser does not support iframes'));
<a href="%s">Click here for unframed results</a>
<br>
<iframe width="100%" height="300" src="%s" title="framework search results">%s</iframe>
EOT
}

