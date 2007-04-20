#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

use FindBin;
use lib "$FindBin::RealBin/../../../../perl5";

use Unison;
use Unison::Schema::Schema;
use Unison::Schema::Table;

sub apply_custom_configuration($$$);

our %tables;
our %custom_table_predicates;
our %custom_copy_queries;

do 'pub-rules.pl';


%tables = Unison->new()->get_table_info();
apply_custom_configuration(\%tables,\%custom_table_predicates,\%custom_copy_queries);


foreach my $st (qw( unison.pseq unison.pseqalias unison.pfeature )) {
#  $tables{$st} = Unison::Schema::Table->new( 'st' => $st ) unless exists $tables{$st};
  print("==== $st:\n", $tables{$st}->copy_query(), "\n >>======\n\n");
}



sub apply_custom_configuration($$$) {
  my ($t,$ctp,$ccq) = @_;
  my $st;
  foreach $st (sort keys %$ccq) {
	$t->{$st} = Unison::Schema::Table->new( 'st' => $st ) unless exists $t->{$st};
	$t->{$st}->{cq} = $ccq->{$st};
	$t->{$st}->{restricted}++;
  }
  foreach $st (sort keys %$ctp) {
	$t->{$st} = Unison::Schema::Table->new( 'st' => $st ) unless exists $t->{$st};
	for(my $i=0; $i<=$#{$ctp->{$st}}; $i++) {
	  $t->{$st}->add_pred( $ctp->{$st}->[$i] );
	}
  }
}
