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

   '<hr><u>Unison host information:</u>',
   '<br>platform: <code>', `uname -a`, '</code>',
   '<br>uptime: <code>', `uptime`, '</code>',
   '<br>running jobs:<br><pre>', 
      `ps --sort=-pcpu r -wopid,ppid,stime,etime,cputime,pcpu,pmem,cmd -ucompbio 2>&1`,
   '</pre>',


   '<hr><u>PostgreSQL information:</u>',
   pg_info(),


   '<hr><u>Unison connection information:</u>',
   (map { "<br><code>$_: "
			. ((defined $p->{unison} and defined $p->{unison}->{$_}) ? $p->{unison}->{$_} : '<i>undef</i>')
			  . "</code>\n" }
	qw(username host dbname)),


   '<hr><u>Kerberos and user information:</u>',
   '<br><pre>', `klist -5`, '</pre>',


   "<hr><u>Perl:</u>\n",
   "<br>perl binary: <code>$^X</code>\n",
   join("\n&nbsp;&nbsp;", '<pre>@INC = (', @INC, ");</pre>\n\n"),

   '<ul>',
   "<li>Unison modules found in:\n",
   '<pre>',(map { sprintf("$_ => $INC{$_}\n") } 
			sort grep {/^Unison/} keys %INC), '</pre>',

   "<li>Bioperl modules found in:\n",
   '<pre>',(map { sprintf("$_ => $INC{$_}\n") } 
			sort grep {/^Bio/} keys %INC), '</pre>',

   "<li>Other modules found in:\n<pre>",
   '<pre>',(map { sprintf("$_ => $INC{$_}\n") } 
			sort grep {not (/^Unison/ or /^Bio/)} keys %INC), '</pre>',
   '</ul>',

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
