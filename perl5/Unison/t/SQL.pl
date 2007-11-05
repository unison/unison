#!/usr/bin/env perl

use strict;
use warnings;

use lib ('..');
use Unison::SQL;

my $sql;

$sql = Unison::SQL->new();
print "$sql\n";

$sql = Unison::SQL->new()->columns('A(76)');
print "$sql\n";

$sql = Unison::SQL->new()->table('tableA A')->columns('A.A_id');
print "$sql\n";

$sql->join('tableB B on A.A_id=B.A_id')->columns('B.B_data');
print "$sql\n";
