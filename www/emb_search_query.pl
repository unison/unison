#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use Unison::WWW;
use Unison::WWW::EmbPage;
use Unison::WWW::Table;
use Unison::Exceptions;

my $p = new Unison::WWW::EmbPage;

print $p->render( 'Searching for proteins with ...', _feature_query($p) );
exit(0);

sub _feature_query {
    my $p = shift;
    my $u = $p->{unison};
    my $v = $p->Vars();
    my $ret;

    my %feats;
    map {
        my $t = 0;
        my @a = split( /\=/, $_ );
        $t = grep { /$a[0]/ } keys %feats;
        $a[0] .= $t++;
        $feats{ $a[0] } = $a[1]
    } ( split( /\:/, $v->{global_q} ) );

    foreach my $k ( grep { /pfam_sel/ } sort keys %feats ) {
        my $pfam_dom = $u->selectrow_array(
            "select name from pmhmm where pmodel_id=$feats{$k}");
        $ret .= '<p> with pfam domain \'' . $pfam_dom . '\'';
    }

    foreach my $k ( grep { /regexp_sel/ } sort keys %feats ) {
        my $prosite_pat = $u->selectrow_array(
            "select name from pmregexp where pmodel_id=$feats{$k}");
        $ret .= '<p> with Prosite pattern \'' . $prosite_pat . '\'';
    }

    $ret .=
      "<p> based on a coiled coiled region with probability of >= $feats{$_}"
      foreach ( grep { /pepcoil/ } sort keys %feats );
    $ret .= "<p> with accession = '$feats{$_}'"
      foreach ( grep { /alias_sel/ } sort keys %feats );

    foreach my $k ( grep { /protcomp_sel/ } sort keys %feats ) {
        my $loc =
          $u->selectrow_array(
            "select location from psprotcomp_location where psloc_id=$feats{$k}"
          );
        $ret .= "<p> based on $loc localization";
    }

    foreach my $k ( grep { /tax_sel/ } sort keys %feats ) {
        my $species = $u->selectrow_array(
            "select gs from tax.spspec where tax_id=$feats{$k}");
        $ret .= "<p> which belong to $species species";
    }

    foreach my $f ( split( /\:/, $v->{features} ) ) {

        $ret .= '<p> has a N terminal signalp peptide,'  if ( $f eq 'signalp' );
        $ret .= '<p> one or more transmembrane regions,' if ( $f eq 'tmhmm' );
        $ret .= '<p> has a low complexity region,'       if ( $f eq 'seg' );
        $ret .= '<p> has a GPI anchor,'                  if ( $f eq 'bigpi' );
        $ret .= '<p> with solved tertiary structure,'    if ( $f eq 'pdb' );
        $ret .= '<p> with secondary structure pattern,'  if ( $f eq 'psipred' );
        $ret .= '<p> based on genomic location,'         if ( $f eq 'pmap' );
        $ret .= '<p> based on physical properties,' if ( $f eq 'physical' );
    }

    join( '', $ret );
}

