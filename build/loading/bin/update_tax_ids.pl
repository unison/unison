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

my $palias_id_inc = 10000;
my $palias_id_min = 0;
my $palias_id_max = 10000000;

sub create_paotax ($);
sub assign_tax_ids ($);
sub reassign_tax_ids ($);
sub nullify_tax_ids ($);


my $u = new Unison;


select(STDERR); $|++;
select(STDOUT); $|++;

create_paotax($u);
assign_tax_ids($u);
reassign_tax_ids($u);
nullify_tax_ids($u);


exit(0);




sub execute_sth($$;$) {
  my ($fx,$sth,$inc) = @_;
  $inc = $palias_id_inc unless defined $inc;
  for(my $b=$palias_id_min; $b<$palias_id_max; $b+=$inc) {
	my $e = $b+$inc;
	my $nr = $sth->execute($b,$e);
	printf("\r$fx(;$inc) [%9d,%9d) %9d", $b, $e, $nr);
  }
  print("... done\n");
}



sub create_paotax ($) {
  ## create a temp table with palias_id, current tax_id, inferred tax_id
  my $u = shift;
  eval { $u->do('drop table paotax') };
  $u->do('create table paotax (palias_id integer not null, tax_id integer, infer_tax_id integer) without oids');
  my $sql = qq/
	INSERT INTO PAOTAX
	SELECT AO.palias_id,AO.tax_id,infer_tax_id(O.origin,AO.alias,AO.descr)
    FROM paliasorigin AO
    JOIN porigin O ON AO.porigin_id=O.porigin_id
    WHERE palias_id>=? and palias_id<?
	/;
  my $sth = $u->prepare( $sql );
  execute_sth((caller(0))[3], $sth);
  $u->do('create index paotax_palias_id on paotax(palias_id)');
  $u->do('analyze paotax');
}


sub assign_tax_ids ($) {
  ## assign tax_ids which were null but are now not null
  my $u = shift;
  my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=(SELECT infer_tax_id FROM paotax WHERE paliasorigin.palias_id=paotax.palias_id)
    WHERE palias_id IN (SELECT palias_id FROM paotax WHERE palias_id>=? and palias_id<? and
                        tax_id IS NULL AND infer_tax_id IS NOT NULL);
	/;
  my $sth = $u->prepare($sql);
  execute_sth((caller(0))[3], $sth, 100);
}


sub reassign_tax_ids ($) {
  ## reassign tax_ids which have changed
  my $u = shift;
  my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=(SELECT infer_tax_id FROM paotax WHERE paliasorigin.palias_id=paotax.palias_id)
    WHERE palias_id IN (SELECT palias_id FROM paotax WHERE palias_id>=? and palias_id<? and
                        tax_id != infer_tax_id);
	/;
  my $sth = $u->prepare($sql);
  execute_sth((caller(0))[3], $sth, 100);
}


sub nullify_tax_ids ($) {
  ## NULLify tax_ids for aliases in which the current tax_id is not null
  ## but the inferred tax_id is NULL
  my $u = shift;
  my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=NULL
    WHERE palias_id IN (SELECT palias_id FROM paotax WHERE palias_id>=? and palias_id<? and
                        tax_id IS NOT NULL AND infer_tax_id IS NULL);
	/;
  my $sth = $u->prepare($sql);
  execute_sth((caller(0))[3], $sth, 100);
}
