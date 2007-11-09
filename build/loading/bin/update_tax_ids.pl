#!/usr/bin/env perl
## update_tax_ids -- minimally update paliasorigin with newly-inferred
## tax_ids per infer_tax_id (see infer_tax_id.sql).
## This will do any or all of:
## - assign (current tax_id is null, infer_tax_id says otherwise)
## - reassign (extant tax_id is not null)
## - nullify (current not null, infer_tax_id thinks it should be null)

## NOTE: This works much better when one wants recent additions:
## unison@csb-dev=> insert into paotax select
##   AO.palias_id,AO.tax_id,infer_tax_id(O.origin,AO.alias,AO.descr) from
##   paliasorigin AO join (select * from pseqalias where added>='yesterday')
##   SA on SA.palias_id=AO.palias_id join origin O on
##   O.origin_id=AO.origin_id;
## INSERT 0 111990
## Time: 53411.295 ms

## and this is a huge win for updates:
## => update paliasorigin set tax_id=infer_tax_id from paotax where
##   paotax.palias_id=paliasorigin.palias_id and paotax.tax_id is null and
##   paotax.infer_tax_id is not null;

use strict;
use warnings;
use Unison;
use Getopt::Long qw(:config gnu_getopt);
use Data::Dumper;

my %opts = (
    'increment'        => 1000,
    'update-increment' => 100,
    'palias-id-min'    => undef,
    'palias-id-max'    => undef,

    'drop-paotax'   => 0,
    'create-paotax' => 0,
    'assign'        => 0,
    'reassign'      => 0,
    'nullify'       => 0,

    'origin'    => undef,
    'origin_id' => undef,
);

sub create_paotax ($);
sub assign_tax_ids ($);
sub reassign_tax_ids ($);
sub nullify_tax_ids ($);

select(STDERR);
$|++;
select(STDOUT);
$|++;
print( STDERR '# $Id$ ',
    "\n" );

GetOptions(
    \%opts,
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
    'all|A' => sub {
        $opts{assign}++;
        $opts{reassign}++;
        $opts{nullify}++;
    },
    'assign|a+',
    'reassign|r+',
    'nullify|n+',
) || die("$0: aye, you've got usage issues, mate\n");

if ( $opts{assign} + $opts{reassign} + $opts{nullify} == 0 ) {
    die("$0: You've not indicated which actions to take\n");
}

print( STDERR '# ',
    join(
        ', ',
        grep { $opts{$_} }
            qw(drop-paotax
            create-paotax assign reassign nullify)
    ),
    "\n"
);

my $u = new Unison( dbname => 'csb-dev' );

if ( defined $opts{origin} ) {
    $opts{origin_id}
        = $u->selectrow_array("select origin_id('$opts{origin}')");
    print( STDERR "# origin_id('$opts{origin}') = $opts{origin_id}\n" );
}

if (   not defined $opts{'palias-id-min'}
    or not defined $opts{'palias-id-max'} )
{
    my $sql = 'select min(palias_id),max(palias_id) from paliasorigin';
    $sql .= " WHERE origin_id=$opts{origin_id}"
        if ( defined $opts{origin_id} );
    my ( $b, $e ) = $u->selectrow_array($sql);
    $opts{'palias-id-min'} = $b unless defined $opts{'palias-id-min'};
    $opts{'palias-id-max'} = $e unless defined $opts{'palias-id-max'};
    printf( STDERR "# palias_id range (selection) = [%d,%d]\n",
        $opts{'palias-id-min'}, $opts{'palias-id-max'} );
}

if ( $opts{'create-paotax'} ) {
    create_paotax($u);
    print( STDERR "created paotax table\n" );
}

# set min and max to the empirical min and max from the paotax table
my $sql = 'select min(palias_id),max(palias_id) from paotax';
( $opts{'palias-id-min'}, $opts{'palias-id-max'} )
    = $u->selectrow_array($sql);
printf( STDERR "# palias_id range (empirical) = [%d,%d]\n",
    $opts{'palias-id-min'}, $opts{'palias-id-max'} );

my $nrows_changed = 0;
$nrows_changed += assign_tax_ids($u)   if $opts{'assign'};
$nrows_changed += reassign_tax_ids($u) if $opts{'reassign'};
$nrows_changed += nullify_tax_ids($u)  if $opts{'nullify'};

printf( STDERR "%-57s                   %9d\n",
    "TOTAL (assigned, reassigned, or nulled)",
    $nrows_changed
);

if ( $opts{'drop-paotax'} ) {
    $u->do('drop table paotax');
    print( STDERR "dropped paotax table\n" );
}

exit(0);

sub create_paotax ($) {
    ## create a temp table with palias_id, current tax_id, inferred tax_id
    my $u   = shift;
    my $sql = qq/
	INSERT INTO paotax
	SELECT AO.palias_id,AO.tax_id,infer_tax_id(O.origin,AO.alias,AO.descr)
    FROM paliasorigin AO
    JOIN origin O ON AO.origin_id=O.origin_id
    WHERE AO.palias_id>=? and AO.palias_id<?
	/;

    if ( defined $opts{origin_id} ) {
        $sql .= " AND AO.origin_id=$opts{origin_id}";
    }

    my @cond;
    if ( $opts{assign} ) {
        push( @cond,
            'tax_id IS NULL AND infer_tax_id(O.origin,AO.alias,AO.descr) IS NOT NULL'
        );
    }
    if ( $opts{nullify} ) {
        push( @cond,
            'tax_id IS NOT NULL AND infer_tax_id(O.origin,AO.alias,AO.descr) IS NULL'
        );
    }
    if ( $opts{reassign} ) {
        push( @cond, 'tax_id != infer_tax_id(O.origin,AO.alias,AO.descr)' );
    }
    $sql .= ' AND (' . join( ' OR ', map {"($_)"} @cond ) . ')';

    eval { $u->do('drop table paotax') }
        || die("couldn't drop paotax table\n");
    eval {
        $u->do(
            qq/create table paotax (palias_id integer not null,
            tax_id integer, infer_tax_id integer) without oids/
        );
        }
        || die("couldn't drop paotax table\n");
    my $sth = $u->prepare($sql);
    execute_sth( ( caller(0) )[3], $sth, $opts{'increment'} );
    $u->do('create index paotax_palias_id on paotax(palias_id)');
    $u->do('analyze paotax');
}

sub assign_tax_ids ($) {
    ## assign tax_ids which were null but are now not null
    my $u   = shift;
    my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=(SELECT infer_tax_id FROM paotax 
				WHERE paliasorigin.palias_id=paotax.palias_id)
    WHERE palias_id IN (SELECT palias_id FROM paotax
						WHERE palias_id>=? and palias_id<? and
                        tax_id IS NULL AND infer_tax_id IS NOT NULL);
	/;
    my $sth = $u->prepare($sql);
    execute_sth( ( caller(0) )[3], $sth, $opts{'update-increment'} );
}

sub reassign_tax_ids ($) {
    ## reassign tax_ids which have changed
    my $u   = shift;
    my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=(SELECT infer_tax_id FROM paotax
				WHERE paliasorigin.palias_id=paotax.palias_id)
    WHERE palias_id IN (SELECT palias_id FROM paotax
						WHERE palias_id>=? and palias_id<? and
                        tax_id != infer_tax_id);
	/;
    my $sth = $u->prepare($sql);
    execute_sth( ( caller(0) )[3], $sth, $opts{'update-increment'} );
}

sub nullify_tax_ids ($) {
    ## NULLify tax_ids for aliases in which the current tax_id is not null
    ## but the inferred tax_id is NULL
    my $u   = shift;
    my $sql = qq/
	UPDATE paliasorigin
    SET tax_id=NULL
    WHERE palias_id IN (SELECT palias_id FROM paotax
						WHERE palias_id>=? and palias_id<? and
                        	tax_id IS NOT NULL AND infer_tax_id IS NULL);
	/;
    my $sth = $u->prepare($sql);
    execute_sth( ( caller(0) )[3], $sth, $opts{'update-increment'} );
}

sub execute_sth($$$) {
    my ( $fx, $sth, $inc ) = @_;
    my $nr_tot = 0;
    for (
        my $b = $opts{'palias-id-min'};
        $b <= $opts{'palias-id-max'};
        $b += $inc
        )
    {
        my $e = $b + $inc;
        my $nr = $sth->execute( $b, $e );
        $nr_tot += $nr;
        printf( STDERR "\r%-30s [%9d,%9d)    rows:%9d  tot:%9d",
            "$fx(;$inc)", $b, $e, $nr, $nr_tot );
    }
    printf( STDERR "\r%-30s [%9d,%9d]         %9s  tot:%9d",
        "$fx(;$inc)", $opts{'palias-id-min'}, $opts{'palias-id-max'}, '',
        $nr_tot );
    print( STDERR "... done\n" );
    return $nr_tot;
}

