#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Data::Dumper;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render("Unison Environment",

				 '<hr>Unison connection information:',
				 (map { "<br><code>$_: "
						. (defined $p->{unison}->{$_} ? $p->{unison}->{$_} : '(undef)')
						. "</code>\n" }
				  qw(username host dbname)),

				 '<hr>Kerberos and user information:',
				 (map { "<br><code>$_: $ENV{$_}</code>\n" }
				  qw(REMOTE_USER KRB5CCNAME)),

				 "<hr>perl include paths:\n<pre>\@INC = (\n", 
				 (map {"$_\n"} @INC, ");</pre>\n\n"),

				 "<hr>Unison modules found in:\n<pre>",
				 (map { sprintf("$_ => $INC{$_}\n") } sort grep {/Unison/} keys %INC), "</pre>\n\n",

				);

