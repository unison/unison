#!/usr/bin/env perl

#-------------------------------------------------------------------------------
# NAME: genome_features.pl
# PURPOSE: web script to output pseq aligned to a genome
# USAGE: genome_features.pl?genasm_id=<genasm_id>&[(chr=<chr>&gstart=<gstart>&gstop=<gstop>)||(pseq_id=<pseq_id>)]
# NOTE: web wrapper around the genome-features command-line scripto
#
# $Id$
#-------------------------------------------------------------------------------

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use File::Temp;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

# verify parameters
if ( ! ( defined $v->{genasm_id} && (
  ( defined $v->{chr} && defined $v->{gstart} && defined $v->{gstop} ) ||
  ( defined $v->{pseq_id} ) ) )) { $p->die( &usage ); }

# get tempfiles for the genome-feature png and imagemap
my ($png_fh, $png_fn)   = File::Temp::tempfile(DIR => "$ENV{'DOCUMENT_ROOT'}/tmp/genome-features");
my ($imap_fh, $imap_fn) = File::Temp::tempfile(DIR => "$ENV{'DOCUMENT_ROOT'}/tmp/genome-features");

# run genome-features, pass in temp filenames
my $cmd = "/home/cavs/csb-db/unison/bin/genome-features -dcsb-dev -UPUBLIC -w750 -q$v->{genasm_id} -f$png_fn -i$imap_fn";
if ( defined $v->{pseq_id} ) {
  $cmd .= " -p$v->{pseq_id}";
} else {
  $cmd .= " -c$v->{chr} -b$v->{gstart} -e$v->{gstop}";
}
system($cmd);

open(FP,"$imap_fn") or die("can't open $imap_fn for reading");
my $imap = '';
while(<FP>) { $imap .= $_; }
close(FP);

$png_fn =~ m#^(.*)(/tmp/genome-features/)(.*)$#;
my $fn = "$2$3";
print $p->render("Genome Alignment for Unison:$v->{pseq_id}",
    $p->group( "<center><img src=\"$fn\" usemap=\"#GENOME_MAP\"></center>", $imap ),
  );

#-------------------------------------------------------------------------------
# NAME: usage
# PURPOSE: return usage string
#-------------------------------------------------------------------------------
sub usage {
  return( "USAGE: genome_features.pl ? genasm_id&lt;gensam_id&gt; " .
     "[(chr=&lt;chr&gt; & gstart=&lt;gstart&gt; & gstop=&lt;gstop&gt; " .
     "|| pseq_id=&lt;pseq_id&gt;]" );
}
