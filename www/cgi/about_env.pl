#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;



my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render
  ("Unison Environment",

   '<hr>Unison host information:',
   '<br>platform: <code>', `uname -a`, '</code>',
   '<br>uptime: <code>', `uptime`, '</code>',
   '<br>running jobs:<br><pre>', 
      `ps --sort=-pcpu r -wopid,ppid,stime,etime,cputime,pcpu,pmem,cmd -ucompbio 2>&1`,
   '</pre>',

   '<hr>PostgreSQL information:',
   pg_info(),

   '<hr>Unison connection information:',
   (map { "<br><code>$_: "
			. ((defined $p->{unison} and defined $p->{unison}->{$_}) ? $p->{unison}->{$_} : '<i>undef</i>')
			  . "</code>\n" }
	qw(username host dbname)),

   '<hr>Kerberos and user information:',
   (map { "<br><code>$_: ".(defined $ENV{$_}?$ENV{$_}:'<i>undef</i>')."</code>\n" }
	qw(REMOTE_USER KRB5CCNAME)),

   "<hr><u>Perl:</u>\n",
   "<br>path: $^X\n",
   join("\n&nbsp;&nbsp;", '<pre>@INC = (', @INC, ");</pre>\n\n"),

   "<hr>Unison modules found in:\n<pre>",
   (map { sprintf("$_ => $INC{$_}\n") } sort grep {/^Unison/} keys %INC), "</pre>\n\n",

   "<hr>Bioperl modules found in:\n<pre>",
   (map { sprintf("$_ => $INC{$_}\n") } sort grep {/^Bio/} keys %INC), "</pre>\n\n",

   "<hr>Other modules found in:\n<pre>",
   (map { sprintf("$_ => $INC{$_}\n") } sort grep {not (/^Unison/ or /^Bio/)} keys %INC), "</pre>\n\n",

  );



sub pg_info {
  my @rv;

  my @settings = qw( effective_cache_size max_connections search_path
  shared_buffers sort_mem );
  my $settings = join(',', map {"'$_'"} @settings);

  return('Not Connected') unless defined $u;

  push( @rv, ['version', $u->selectrow_array('select version()')] );

  push( @rv, map { [$_->[0],$_->[1]] }
				   @{ $u->selectall_arrayref("select name,setting from pg_settings where name in ($settings)") } ); 

  return map { "<br>&nbsp;&nbsp;&nbsp;$_->[0]: <code>$_->[1]</code>\n" } @rv;
  }
