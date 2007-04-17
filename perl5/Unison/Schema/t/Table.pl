#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

use FindBin;
use lib "$FindBin::RealBin/../../../../perl5";

use Unison;
use Unison::Schema::Table;

sub get_table_info($);


my $u = new Unison();

my %tables = get_table_info($u);

foreach my $st (qw(unison.origin unison.params unison.pseqalias unison.pseq)) {
  $tables{$st} = Unison::Schema::Table->new( 'st' => $st ) unless exists $tables{$st};
}

$tables{'unison.origin'}->add_pred('T.is_public = TRUE');
$tables{'unison.params'}->add_pred('T.is_public = TRUE');




#foreach my $st (sort keys %tables) {
foreach my $st (qw(unison.origin unison.paliasorigin unison.pseqalias unison.pseq unison.params unison.pmhmm  )) {
  my @pkst = $tables{$st}->pk_st();
  my $cq = $tables{$st}->copy_query(\%tables);
  $cq =~ s/^/    /mg;
  printf("%-25s: %d {%s}\n$cq", $st, $#pkst+1, join(',', @pkst));
}

exit(0);



sub get_table_info($) {
  my ($u) = @_;
  my %tables;
  my $sth = $u->prepare( q(
				  			SELECT fk_namespace,fk_relation,fk_column,
								   pk_namespace,pk_relation,pk_column,ud
							FROM pgutils.foreign_keys
				            ) );
  $sth->execute();
  my $nfks;
  while( my $row = $sth->fetchrow_hashref() ) {
	$nfks++;
	my $st = "$row->{fk_namespace}.$row->{fk_relation}";
	$tables{$st} = Unison::Schema::Table->new( 'st' => $st ) unless exists $tables{$st};
	my %fk_data = map { $_ => $row->{$_} } qw(fk_column pk_namespace pk_relation pk_column ud);
	$tables{$st}->add_fk( \%fk_data );
  }
  $sth->finish();
  printf(STDERR "# %d FKs in %d tables\n", $nfks, scalar keys %tables);
  return %tables;
}
