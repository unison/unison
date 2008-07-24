#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render(
				 'Environment',

				 _conn_info_html($p),
				 _host_info(),
				 _pg_info(),

				 '<hr><u>Environment variables:</u>',
				 '<br><pre>',
				 (
				  map { "$_=" . ( defined $ENV{$_} ? $ENV{$_} : '<i>undef</i>' ) . "\n" }
				  qw(PATH PERL5LIB LD_LIBRARY_PATH)
				 ),
				 '</pre>',

				 "<hr><u>Perl:</u>\n",
				 "<br>perl binary: <code>$^X</code>\n",
				 join( "\n&nbsp;&nbsp;", '<pre>@INC = (', @INC, ");</pre>\n\n" ),
				 
				 "- Unison modules found in:\n",
				 '<pre>',
				 ( map { sprintf("$_ => $INC{$_}\n") } sort grep { /^Unison/ } keys %INC ),
				 '</pre>',
				 
				 "- Bioperl modules found in:\n",
				 '<pre>',
				 ( map { sprintf("$_ => $INC{$_}\n") } sort grep { /^Bio/ } keys %INC ),
				 '</pre>',
				 
				 "- Other modules found in:\n",
				 '<pre>',
				 (
				  map { sprintf("$_ => $INC{$_}\n") }
				  sort grep { not( /^Unison/ or /^Bio/ ) } keys %INC
				 ),
				 '</pre>',
				 
				);

exit(0);

sub _pg_info {
    my @rv;

    my @settings = qw( effective_cache_size max_connections search_path
      shared_buffers sort_mem );
    my $settings = join( ',', map { "'$_'" } @settings );

    return ('Not Connected') unless defined $u;

    push( @rv, [ 'version', $u->selectrow_array('select version()') ] );

    push(
        @rv,
        map { [ $_->[0], $_->[1] ] } @{
            $u->selectall_arrayref(
                "select name,setting from pg_settings where name in ($settings)"
            )
          }
    );

    return(
		   '<hr><u>PostgreSQL information:</u>',
		   (map { "<br>&nbsp;&nbsp;&nbsp;$_->[0]: <code>$_->[1]</code>\n" } @rv),

		   '<hr><u>Unison connection information:</u>',
		   '<br><pre>',
		   (
			map {
			  "$_: "
				. ( ( defined $p->{unison} and defined $p->{unison}->{$_} )
					? $p->{unison}->{$_}
					: '<i>undef</i>' )
				  . "\n"
				} qw(username host dbname)
		   ),
		   (
			( defined $ENV{KRB5CCNAME} )
			? (`klist -5 2>/dev/null`)
			: 'Kerberos authentication is not in use (KRB5CCNAME is undefined)'
		   ),
		   "</pre>\n",
		  );
}



sub _conn_info_html {
    my $p    = shift;
    my $u    = $p->{unison};
    my $info = 'not connected to the Unison database';
	my $dev_str = '<span style="color: red">development</span>';
	my $pub_str = '<span style="color: green">public</span>';

    if ( ref $p and defined $u and $u->is_open() ) {
        my $www_rel = (   ( $p->is_public_instance ? $pub_str : '' )
						. ( $p->is_dev_instance    ? $dev_str : ('('.($Unison::RELEASE || 'no RELEASE tag').')' ) )
					  );
        my $api_rel = $Unison::REVISION || $dev_str;
        my $db_rel = ( $u->is_public_instance ? $pub_str : '' ) . ' '
            . ( $u->release_timestamp() || $dev_str );
        my $www_user
            = ( defined $ENV{REMOTE_USER} )
            ? $ENV{REMOTE_USER}
            : '(unauthenticated)';

        my $db_host
            = $u->{host}
            ? sprintf( "%s:%s", $u->{host}, $u->{port} || '&lt;default&gt;' )
            : 'local';

        $info = <<EOHTML;
<pre>
<b>Unison revision:</b> $Unison::REVISION

<b>web host:</b>    $ENV{SERVER_NAME}
<b>web client:</b>  $ENV{REMOTE_ADDR}
<b>web user:</b>    $www_user

<b>db release:</b>  $db_rel
<b>db host:port:</b> $db_host
<b>db database:</b> $u->{dbname}
<b>db username:</b> $u->{username}
</pre>
EOHTML
    }

    return $info;
}


sub _host_info {
  return(
		 '<hr><u>Unison host information:</u>',
		 '<br>platform: <code>', `uname -a`, '</code>',
		 '<br>uptime: <code>',   `uptime`,   '</code>',
		 '<br>running jobs:<br><pre>',
		 `ps --sort=-pcpu r -wopid,ppid,stime,etime,cputime,pcpu,pmem,cmd 2>&1`,
		 '</pre>',
		);
}
