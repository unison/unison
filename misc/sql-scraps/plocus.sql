-- plocus table
-- tblast alignments of protein sequences to genomes


create table unison.plocus (
	pseq_id integer not null
		references pseq(pseq_id) on update cascade on delete cascade,
	pstart integer not null,
	pstop integer not null,

	genome_id integer not null
		references genome(genome_id) on update cascade on delete cascade,
	chr text not null,
	gstart integer not null,
	gstop integer not null,

	ident smallint not null,
	eval double precision not null
	) without oids;

create unique index plocus_nonredundant on plocus(pseq_id,genome_id,pstart,pstop,chr,gstart,gstop);
create index plocus_glocus_idx on plocus(genome_id,chr,gstart,gstop);
create index plocus_ident_idx on plocus(ident);
create index plocus_eval_idx on plocus(eval);

comment on table plocus is 'pseq loci computed by tblastn';
comment on column plocus.pseq_id is 'fk into unison.pseq';
comment on column plocus.pstart is 'pseq starting position of alignment';
comment on column plocus.pstop is 'pseq ending position of alignment';
comment on column plocus.genome_id is 'fk into unison.genome';
comment on column plocus.chr is 'chromosome designation';
comment on column plocus.gstart is 'genomic starting position of alignment';
comment on column plocus.gstop is 'genomic ending position of alignment';
comment on column plocus.ident is 'HSP percent identity';
comment on column plocus.eval is 'HSP evalue';


create or replace view unison.v_plocus as SELECT pseq_id, genome.name, chr, min(pstart) AS
pstart, max(pstop) AS pstop, (max(pstop)-min(pstart)) AS plen, min(gstart) AS gstart,
max(gstop) AS gstop, (max(gstop) - min(gstart)) AS glen, count(*) AS pexons
FROM plocus  natural join genome 
where ident>=99 GROUP BY pseq_id,genome.name,chr ORDER BY chr2locus(chr),pseq_id;
comment on view unison.v_plocus is 'plocus view to facilitate gene localization';

