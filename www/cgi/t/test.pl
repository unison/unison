#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

#$v->{var1} = 1 unless defined $v->{var1};


print $p->render("Unison testing",
				 '<br>URL1:<code>', $p->make_url({var1=>5}), '</code>',
				 '<br>URL2:<code>', $p->make_url({var1=>5},qw(var2)), '</code>',
				 '<br>URL3:<code>', $p->make_url({var1=>5,var2=>10},qw(var1)), '</code>',

				 '<br>URL1:<code>', $p->make_url(), '</code>',
				 '<br>URL2:<code>', $p->make_url(qw(var2)), '</code>',
				 '<br>URL3:<code>', $p->make_url({var2=>10},qw(var1)), '</code>',
				 );

