package Unison;

# I should probably represent the underlying types tables, columns, and
# constraints more accurately.


use strict;
use warnings;

use Data::Dumper;


sub get_table_info($) {
  # get_table_info -- aggregate FK-PK relationships by FK table
  # The primary use of this is to represent the PK dependencies for each
  # table to assemble JOIN restrictions during dumping.

  my $u = shift;
  my %tables;
  my $sth = $u->prepare( q(
				  			SELECT fk_namespace,fk_relation,fk_column,
								   pk_namespace,pk_relation,pk_column,ud,fk_notnull
							FROM pgutils.foreign_keys
				            ) );
  $sth->execute();

  my $nfks;
  while( my $row = $sth->fetchrow_hashref() ) {
	$nfks++;

	my $fkst = "$row->{fk_namespace}.$row->{fk_relation}";
	$tables{$fkst} = Unison::Schema::Table->new( namespace => $row->{fk_namespace},
												 relation => $row->{fk_relation} ) unless exists $tables{$fkst};

	my $pkst = "$row->{pk_namespace}.$row->{pk_relation}";
	$tables{$pkst} = Unison::Schema::Table->new( namespace => $row->{pk_namespace},
												 relation => $row->{pk_relation} ) unless exists $tables{$pkst};

	$tables{$fkst}->add_fk( {
							 %$row,
							 fkst => $fkst,
							 pkst => $pkst,
							 pkt => $tables{$pkst}
							} );
  }
  $sth->finish();

  return %tables;
}


1;
