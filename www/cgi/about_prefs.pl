#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $P = $p->{userprefs};

print $p->render("Unison User Preferences for $u->{username}",
				 "<p>(user preferences are currently read-only)\n",
				 "<pre>\n",
				 (map { "$_: $P->{$_}\n" } sort keys %$P),
				 "</pre>\n"
				);

