#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render("Unison perl info",

				 "<hr>perl include paths:\n<pre>\@INC = (\n", 
				 (map {"$_\n"} @INC, ");</pre>\n\n"),

				 "<hr>Unison modules found in:\n<pre>",
				 (map { sprintf("$_ => $INC{$_}\n") } sort grep {/Unison/} keys %INC), "</pre>\n\n",

				);

