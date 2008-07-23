#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;

sub meta_group($);

my $p = new Unison::WWW::Page;

print $p->render( 'Unison Statistics', meta_group($p), );

exit(0);

sub meta_group($) {
    my $p    = shift;
    my $u    = $p->{unison};
    my $sql  = 'select * from meta order by 1';
    my $sth  = $u->prepare($sql);
    my $ar   = $u->selectall_arrayref($sth);
    my @cols = @{ $sth->{NAME} };
    return $p->group( "Unison Statistics",
        Unison::WWW::Table::render( \@cols, $ar ) );
}

