#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;
use Unison::WWW::Table;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id p2params_id));


print $p->render("sequence summary for unison:$v->{pseq_id}",
				 $p->start_form(-action=>'p2alignment.pl'),
				 $p->submit(-value=>'align checked'),
				 $p->hidden('pseq_id',$v->{pseq_id}),
				 $p->hidden('p2params_id',$v->{p2params_id}),
				 $p->group('Prospect2 Threadings',
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->submit(-value=>'align checked'),
				 $p->end_form(),
				 '<br><span class="sql">', '<b>SQL query:</b>', $sql, '</span>'
				 );

