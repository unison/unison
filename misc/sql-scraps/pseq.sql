\echo =======================================================================
\echo $Id: pseq.sql,v 1.3 2002/12/13 23:27:02 rkh Exp $
-- pseq -- stores UNIQUE sequences

create table pseq (
	pseq_id			serial unique,
	palias_id		integer							default null,
	seq				text			not null,
	len				smallint		not null		default null
	);

create unique index sequence_uniqueness on pseq ( seqhash(seq) );
create index pseq_len_idx on pseq (len);


-- pseq_iu_trigger - insert & update trigger computes md5 and length
create function pseq_iu_trigger () returns trigger as '
	begin
		new.seq := clean_sequence(new.seq);
		new.len := length(new.seq);
		return new;
	end; ' 
	language 'plpgsql';
create trigger pseq_iu_trigger 
	before insert or update 
	on pseq for each row
	execute procedure pseq_iu_trigger();


comment on table  pseq					is 'table of unique protein sequences';
comment on column pseq.seq				is 'protein sequence';
comment on column pseq.pseq_id			is 'unique id for sequence; default is serial number';
comment on column pseq.len				is 'sequence length, computed automatically';
