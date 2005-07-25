#!/usr/bin/env perl
#$Id: cgi-test.pl,v 1.3 2005/07/18 20:56:25 rkh Exp $

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page();
my $v = $p->Vars();

$v->{pseq_id} = 76 unless defined $v->{pseq_id};
$p->add_footer_lines('$Id: cgi-test.pl,v 1.3 2005/07/18 20:56:25 rkh Exp $ ');

my ($test_fh, $test_fn) = $p->tempfile(SUFFIX=>'.tst');
my $cmd = "./cgi-test -q $v->{pseq_id} >> $test_fn";

system( $cmd )
  && $p->die("$cmd: $!\n");

my @lines = split(/\n/,`cat $test_fn`);
my (@f,@ar);
foreach my $l (0..$#lines) {
  $lines[$l] =~ s/\.+//;
  $lines[$l] =~ s/://;
  $lines[$l] =~ s/PASSED/\<FONT COLOR="green"\>PASSED\<\/FONT\>/;
  $lines[$l] =~ s/FAILED/\<FONT COLOR="red"\>FAILED\<\/FONT\>/;

  if($l == 0) {
    @ar= (split(/\t+/,$lines[$l]));
  }
  else {
    push @f,[(split(/\t+/,$lines[$l]))];
  }
}

print $p->render("Unison : $v->{pseq_id}",
		 $p->group("Test Results",
			   Unison::WWW::Table::render(\@ar,\@f)),
		);

exit(0);


