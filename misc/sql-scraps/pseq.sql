\echo =======================================================================
\echo $Id$
-- pseq -- stores UNIQUE sequences

create table pseq (
	pseq_id			serial,
	palias_id		integer							default null,
	seq				text			not null,
	md5				char(32)		not null		default null, -- set automatically by
	len				smallint		not null		default null, --   pseq_iu_trigger

	constraint md5_len_uniqueness unique (md5,len)
	);

create index pseq_md5_idx on pseq (md5);
create index pseq_len_idx on pseq (len);


-- pseq_iu_trigger - insert & update trigger computes md5 and length
create function pseq_iu_trigger () returns opaque as '
	declare
		origmd5 text;
	begin
		if new.len is not null then
			raise notice ''ignoring provided sequence length'';
		end if;
		if new.md5 is not null then
			raise notice ''ignoring provided sequence md5'';
		end if;

		origmd5 = md5(new.seq);
		new.seq = clean_sequence(new.seq);
		new.md5 = md5(new.seq);
		new.len = length(new.seq);
		if NOT new.md5 = origmd5 then
			raise notice ''whitespace and/or symbols were removed during insert/update'';
		end if;

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
comment on column pseq.md5				is 'md5 checksum of sequence, computed automatically';
comment on column pseq.len				is 'sequence length, computed automatically';
