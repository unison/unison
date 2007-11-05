#!/usr/bin/env perl

BEGIN { unshift( @INC, $ENV{'HOME'} . '/cbc/opt/lib/perl5' ) }

use Prosite::DB;
use Prosite::Record;

$db = new Prosite::DB;
$fn = shift
  || die("missing database\n");
$db->open("$fn")
  || die("$fn: $!\n");
$db->scan();

$r = new Prosite::Record;
$r->parse_block( $db->read_record('PS00011') );
$r->dump;
