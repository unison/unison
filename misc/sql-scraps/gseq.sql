create table genome
	(
	genome_id	serial primary key,
	name		text,
	url			text,
	species		integer
	) without oids;


create table gseq
	(	
	gseq_id		serial primary key,
	seq			text not null,
	len			integer not null,
	md5			character(32) not null,
	added		timestamp not null default now()
	) without oids;
create index gseq_md5_idx on gseq(md5);
create index gseq_len_idx on gseq(len);
create unique index gseq_seqhash on gseq(seqhash(seq));
create or replace function gseq_iu_trigger () returns TRIGGER language plpgsql as '
DECLARE
    oldmd5 text;
BEGIN
    oldmd5 := md5(new.seq);
    new.seq := clean_sequence(new.seq);
    new.md5 := md5(new.seq);
    if oldmd5 != new.md5 then
        raise notice ''gseq_id % modified during insert.'',new.gseq_id;
    end if;
    new.len := length(new.seq);
    return new;
END; ';
CREATE TRIGGER gseq_iu_trigger
    BEFORE INSERT OR UPDATE ON gseq
    FOR EACH ROW
    EXECUTE PROCEDURE gseq_iu_trigger ();


create table locus
	(
	gseq_id		integer not null
					references gseq(gseq_id) on update cascade on delete cascade,
	genome_id	integer not null
					references genome(genome_id) on update cascade on delete cascade,
	start		integer,
	stop		integer,
	chromosome	text,
	locus		text
	) without oids;
create index locus_gseq_id on locus(gseq_id);
create index locus_coordinates_idx on locus(genome_id,start,stop);


create table translation
	(
	gseq_id		integer not null
					references gseq(gseq_id) on update cascade on delete cascade,
	pseq_id		integer not null
					references pseq(pseq_id) on update cascade on delete cascade
	) without oids;
create unique index translation_is_redundant on translation(gseq_id,pseq_id);
create index translation_pseq_id on translation(pseq_id);
