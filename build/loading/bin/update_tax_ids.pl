#!/usr/bin/env perl
## assign_tax_ids -- minimally update paliasorigin with newly-inferred
## tax_ids per infer_tax_id (see infer_tax_id.sql).


use strict;
use warnings;
use Unison;
use Getopt::Long qw(:config gnu_getopt);
use Data::Dumper;

my %opts =
  (
   'increment' => 1000,
   'update-increment' => 100,
   'palias-id-min' => undef,
   'palias-id-max' => undef,

   'drop-paotax' => 0,
   'create-paotax' => 0,
   'assign' => 0,
   'reassign' => 0,
   'nullify' => 0,

   'origin' => undef,
   'porigin_id' => undef,
  );



sub create_paotax ($);
sub assign_tax_ids ($);
sub reassign_tax_ids ($);
sub nullify_tax_ids ($);

select(STDERR); $|++;
select(STDOUT); $|++;
print(STDERR '# $Id: update_tax_ids.pl,v 1.7 2004/04/11 00:41:47 rkh Exp $ ', "\n");



GetOptions(\%opts,
		   'increment|i=i',
		   'update-increment|u=i',

		   # palias_id selection:
		   'origin|o=s',
		   'palias-id-min|b=i',
		   'palias-id-max|e=i',

		   # paotax table handling:
		   'create-paotax|C+',
		   'drop-paotax|D+',

		   # update operations
		   'all|A' => sub { $opts{assign}++;
							$opts{reassign}++;
							$opts{nullify}++; },
		   'assign|a+',
		   'reassign|r+',
		   'nullify|n+',
		   )
  || die("$0: aye, you've got usage issues, mate\n");


if ($opts{assign}+$opts{reassign}+$opts{nullify} == 0) {
  die("$0: You've not indicated which actions to take\n");
}

print(STDERR '# ', join(', ', grep { $opts{$_} } qw(drop-paotax
	  create-paotax assign reassign nullify)), "\n");;


my $u = new Unison;

if (defined $opts{origin}) {
  $opts{porigin_id} = $u->selectrow_array("select porigin_id('$opts{origin}')");
  print(STDERR "# porigin_id('$opts{origin}') = $opts{porigin_id}\n");
}

if (not defined $opts{'palias-id-min'} or not defined $opts{'palias-id-max'}) {
  my $sql = 'select min(palias_id),max(palias_id) from paliasorigin';
  $sql .= " WHERE porigin_id=$opts{porigin_id}" if (defined $opts{porigin_id});
  my ($b,$e) = $u->selectrow_array( $sql );
  $opts{'palias-id-min'} = $b unless defined $opts{'palias-id-min'};
  $opts{'palias-id-max'} = $e unless defined $opts{'palias-id-max'};
  printf(STDERR "# palias_id range = [%d,%d]\n", $opts{'palias-id-min'}, $opts{'palias-id-max'});
}


create_paotax($u)  if $opts{'create-paotax'};

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
	  $b<=$opts{'palias-id-max'};
	  $b+=$inc) {
	my $e = $b+$inc;
	my $nr = $sth->execute($b,$e);
	$nr_tot += $nr;
	printf(STDERR "\r%-30s [%9d,%9d)    rows:%9d  tot:%9d", "$fx(;$inc)",
		   $b, $e, $nr, $nr_tot);
  }
  printf(STDERR "\r%-30s [%9d,%9d]         %9s  tot:%9d", "$fx(;$inc)", 
		 $opts{'palias-id-min'}, $opts{'palias-id-max'}, '', $nr_tot);
  print(STDERR "... done\n");
  return $nr_tot;
}



sub create_paotax ($) {
  ## create a temp table with palias_id, current tax_id, inferred tax_id
  my $u = shift;
  my $sql = qq/
	INSERT INTO paotax
	SELECT AO.palias_id,AO.tax_id,infer_tax_id(O.origin,AO.alias,AO.descr)
    FROM paliasorigin AO
    JOIN porigin O ON AO.porigin_id=O.porigin_id
    WHERE AO.palias_id>=? and AO.palias_id<?
	/;

  if (defined $opts{porigin_id}) {
	$sql .= " AND AO.porigin_id=$opts{porigin_id}";
  }

  my @cond;
  if ($opts{assign}) {
	push(@cond, 'tax_id IS NULL AND infer_tax_id(O.origin,AO.alias,AO.descr) IS NOT NULL');
  }
  if ($opts{nullify}) {
	push(@cond, 'tax_id IS NOT NULL AND infer_tax_id(O.origin,AO.alias,AO.descr) IS NULL');
  }
  if ($opts{reassign}) {
	push(@cond, 'tax_id != infer_tax_id(O.origin,AO.alias,AO.descr)');
  }
  $sql .= ' AND (' . join(' OR ', map {"($_)"} @cond) . ')';


  eval { $u->do('drop table paotax') } if $opts{'drop-paotax'};
  $u->do(qq/create table paotax (palias_id integer not null,
			tax_id integer, infer_tax_id integer) without oids/);
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
