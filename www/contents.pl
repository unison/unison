#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;

my $star = '<span style="color: red;">*</span>';

sub origin_group($);

my $p = new Unison::WWW::Page;

print $p->render(
				 "Data Sources and Prediction Parameters",
				 "$star indicates proprietary methods",
				 origin_group($p),
				 params_group($p),
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
        $ar->[$i][3] = "<a target=\"_blank\" class=\"ext_link\" href=\"$ar->[$i][3]\">$ar->[$i][3]</a>"
          if defined $ar->[$i][3];
    }
    return $p->group( "Data Sources",
					  Unison::WWW::Table::render( \@cols, $ar ) );
}


sub params_group($) {
    my $p = shift;
    my $u = $p->{unison};
    my $sql =
"select params_id,name||(case is_public when false THEN '*' else '' end) as name,descr,commandline from params order by upper(name)";
    my $sth = $u->prepare($sql);
    my $ar  = $u->selectall_arrayref($sth);
    for ( my $i = 0 ; $i <= $#$ar ; $i++ ) {
        $ar->[$i][1] =~ s/\s+/&nbsp;/g;
        $ar->[$i][1] =~ s/\*/$star/;

        if ( defined $ar->[$i][2] ) {

            # rewrite urls to pubmed
            $ar->[$i][2] =~
              s%(http://.+db=pubmed\S+uids=\d+)%[<a target="_blank" class="ext_link" href="$1">PubMed</a>]%g;
            $ar->[$i][2] =~
              s%(?<!href=")(http://[\w/\.~]+)%<a target="_blank" class="ext_link" href="$1">$1</a>%g;
        }

        $ar->[$i][3] = "<code>$ar->[$i][3]</code>";
    }
    my @cols = @{ $sth->{NAME} };
    return $p->group( "Execution Parameters",
					  Unison::WWW::Table::render( \@cols, $ar )
					);
}

