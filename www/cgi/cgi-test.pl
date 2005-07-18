#!/usr/bin/env perl
#$Id: test.pl,v 1.2 2005/06/22 18:15:24 mukhyala Exp $

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5", "$FindBin::Bin/../../../perl5";

use Unison;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;

my $p = new Unison::WWW::Page();
my $v = $p->Vars();

$p->ensure_required_params( qw( pseq_id ) );
$p->add_footer_lines('$Id: test.pl,v 1.2 2005/06/22 18:15:24 mukhyala Exp $ ');

my ($test_fh, $test_fn) = $p->tempfile(SUFFIX=>'.tst');
my $cmd = "../t/output_test -q $v->{pseq_id} >> $test_fn";

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


