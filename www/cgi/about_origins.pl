#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;

my $star = '<span style="color: red;">*</span>';

sub origin_group($);

my $p = new Unison::WWW::Page;

print $p->render(
    "Data Sources (Origins)",
    origin_group($p),
);

exit(0);

sub origin_group($) {
    my $p   = shift;
    my $u   = $p->{unison};
    my $sql = new Unison::SQL;
    $sql->columns(
'origin||(case is_public when false THEN \'*\' else \'\' end) as origin',
        'to_char(last_updated,\'YYYY-MM-DD\') as "last updated"',
        'descr',
        'url'
    )->table('origin')->where('ann_pref is not null')->order('origin');
    $sql->where('is_public=TRUE') if $u->is_public_instance();

    my $sth  = $u->prepare("$sql");
    my $ar   = $u->selectall_arrayref($sth);
    my @cols = @{ $sth->{NAME} };
    for ( my $i = 0 ; $i <= $#$ar ; $i++ ) {
        $ar->[$i][0] =~ s/\*/$star/;
        $ar->[$i][3] = "<a target=\"_blank\" class=\"extlink\" href=\"$ar->[$i][3]\">$ar->[$i][3]</a>"
          if defined $ar->[$i][3];
    }
    return $p->group( "Data Sources",
					  "$star indicates proprietary data",
					  Unison::WWW::Table::render( \@cols, $ar ) );
}
