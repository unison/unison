#!/usr/bin/perl

my $params_id = 39;

while ( my $line = <> ) {
    my @F = split( ' ', $line );
    my $uq = shift(@F);
    my ($q) = $uq =~ m/^Unison:(\d+)/;
    if ( not defined $q ) {
        die(
"$0: line $.: doesn't look like output from temple-disprot.pl:    $_\n"
        );
    }

    my $dps = join( ',', @F );

    print <<EOSQL
begin;
insert into psdisorder (pseq_id,params_id,probs) values ($q,$params_id,'{$dps}');
select upd_run_history($q,$params_id,NULL,NULL,false);
commit;
EOSQL
}
