#!/usr/bin/env perl
## assign_tax_ids -- minimally update paliasorigin with newly-inferred
## tax_ids per infer_tax_id (see infer_tax_id.sql).
##
## NOTE: I originally wanted to make this a function. Unfortunately,
## postgresql's pl/pgsql improperly caches select results which involve
## tables created inside functions.


use strict;
use warnings;
use Unison;
use Getopt::Long qw(:config gnu_getopt);
use Data::Dumper;

my %opts =
  (
   'increment' => 1000,
   'update-increment' => 100,
   'palias-id-min' => 0,
   'palias-id-max' => undef,

   'drop-paotax' => 0,
   'create-paotax' => 0,
   'assign' => 0,
   'reassign' => 0,
   'nullify' => 0,

   'origin' => undef,
  );


GetOptions(\%opts,
		   'increment|i=i',
		   'update-increment|u=i',
		   'palias-id-min|b=i',
		   'palias-id-max|e=i',

		   'drop-paotax|D+',
		   'create-paotax|c+',
		   'assign|a+',
		   'reassign|r+',
		   'nullify|n+',

		   'all|A' => sub { $opts{assign}++;
							$opts{reassign}++;
							$opts{nullify}++; },

		   'origin|o=i',
		   )
  || die("$0: aye, you've got usage issues, mate\n");


sub create_paotax ($);
sub assign_tax_ids ($);
sub reassign_tax_ids ($);
sub nullify_tax_ids ($);

select(STDERR); $|++;
select(STDOUT); $|++;


print(STDERR '$Id: update_tax_ids.pl,v 1.4 2004/04/07 21:48:23 rkh Exp $ ', "\n");


my $u = new Unison;

if (not defined $opts{'palias-id-max'}) {
  $opts{'palias-id-max'} = $u->selectrow_array
	('select max(palias_id) from paliasorigin');
}


create_paotax($u) 						if $opts{'create-paotax'};

my $nrows_changed = 0;
$nrows_changed += assign_tax_ids($u)	if $opts{'assign'};
$nrows_changed += reassign_tax_ids($u)	if $opts{'reassign'};
$nrows_changed += nullify_tax_ids($u)	if $opts{'nullify'};

printf(STDERR "%-57s                   %9d\n",
	   "TOTAL (assigned, reassigned, or nulled)",
	   $nrows_changed);

exit(0);





sub execute_sth($$$) {
  my ($fx,$sth,$inc) = @_;
  my $nr_tot = 0;
  for(my $b=$opts{'palias-id-min'};
	  $b<$opts{'palias-id-max'};
	  $b+=$inc) {
	my $e = $b+$inc;
	my $nr = $sth->execute($b,$e);
	$nr_tot += $nr;
	printf(STDERR "\r%-30s [%9d,%9d)    rows:%9d  tot:%9d", "$fx(;$inc)",
		   $b, $e, $nr, $nr_tot);
  }
  printf(STDERR "\r%-30s [%9d,%9d)         %9s  tot:%9d", "$fx(;$inc)", 
		 $opts{'palias-id-min'}, $opts{'palias-id-max'}, '', $nr_tot);
  print(STDERR "... done\n");
  return $nr_tot;
}



sub create_paotax ($) {
  ## create a temp table with palias_id, current tax_id, inferred tax_id
  my $u = shift;
  eval { $u->do('drop table paotax') } if $opts{'drop-paotax'};
  $u->do(qq/create table paotax (palias_id integer not null,
			tax_id integer, infer_tax_id integer) without oids/);
  my $sql = qq/
	INSERT INTO PAOTAX
	SELECT AO.palias_id,AO.tax_id,infer_tax_id(O.origin,AO.alias,AO.descr)
    FROM paliasorigin AO
    JOIN porigin O ON AO.porigin_id=O.porigin_id
    WHERE palias_id>=? and palias_id<?
	/;
  if (defined $opts{origin}) {
	$sql .= "AND porigin_id=$opts{origin}";
  }
  my $sth = $u->prepare( $sql );
  execute_sth((caller(0))[3], $sth, $opts{'increment'});
  $u->do('create index paotax_palias_id on paotax(palias_id)');
  $u->do('analyze paotax');
}


sub assign_tax_ids ($) {
  ## assign tax_ids which were null but are now not null
  my $u = shift;
  my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=(SELECT infer_tax_id FROM paotax 
				WHERE paliasorigin.palias_id=paotax.palias_id)
    WHERE palias_id IN (SELECT palias_id FROM paotax
						WHERE palias_id>=? and palias_id<? and
                        tax_id IS NULL AND infer_tax_id IS NOT NULL);
	/;
  my $sth = $u->prepare($sql);
  execute_sth((caller(0))[3], $sth, $opts{'update-increment'});
}


sub reassign_tax_ids ($) {
  ## reassign tax_ids which have changed
  my $u = shift;
  my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=(SELECT infer_tax_id FROM paotax
				WHERE paliasorigin.palias_id=paotax.palias_id)
    WHERE palias_id IN (SELECT palias_id FROM paotax
						WHERE palias_id>=? and palias_id<? and
                        tax_id != infer_tax_id);
	/;
  my $sth = $u->prepare($sql);
  execute_sth((caller(0))[3], $sth, $opts{'update-increment'});
}


sub nullify_tax_ids ($) {
  ## NULLify tax_ids for aliases in which the current tax_id is not null
  ## but the inferred tax_id is NULL
  my $u = shift;
  my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=NULL
    WHERE palias_id IN (SELECT palias_id FROM paotax
						WHERE palias_id>=? and palias_id<? and
                        	tax_id IS NOT NULL AND infer_tax_id IS NULL);
	/;
  my $sth = $u->prepare($sql);
  execute_sth((caller(0))[3], $sth, $opts{'update-increment'});
}
