#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Error qw(:try);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql =
qq/select params,modelset,ran_on,commandline from run_history_v where pseq_id=$v->{pseq_id}/;
my $ar;

try {
    $ar = $u->selectall_arrayref($sql);
}
catch Unison::Exception with {
    $p->die( 'SQL Query Failed', $_[0], $p->sql($sql) );
};

my @f = ('params', 'modelset', 'ran on', 'command line');
print $p->render(
    "Run history for Unison:$v->{pseq_id}",
    $p->best_annotation( $v->{pseq_id} ),
    $p->group( "Run History", Unison::WWW::Table::render( \@f, $ar ) ),
    $p->sql($sql)
);

