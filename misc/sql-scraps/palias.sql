\echo =======================================================================
\echo $Id: palias.sql,v 1.3 2002/12/10 19:48:11 rkh Exp $
-- palias -- names of pseq entries

create table palias (
	palias_id			serial unique,
	pseq_id				integer		not null,
	porigin_id			integer		not null,
	alias				text		not null,
	descr				text,

	constraint palias_pseq_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade,

	constraint palias_porigin_exists
		foreign key (porigin_id)
		references porigin (porigin_id)
		on delete cascade
		on update cascade,

	constraint palias_unique_in_origin
		unique (porigin_id,alias)
	);


-- additional constraint for circular reference between pseq and palias
alter table pseq
	add constraint pseq_palias_exists
	foreign key (palias_id)
	references palias (palias_id);


--   In retrospect, this seems like a bad idea...
--create function palias_iu_trigger () returns trigger as '
--	BEGIN
--	if NEW.descr is NULL then
--		if TG_OP = ''INSERT'' then
--			new.descr = new.alias;
--		end if;
--	end if;
--	return NEW;
--	END;' 
--	language 'plpgsql';
--create trigger palias_iu_trigger 
--	before insert or update 
--	on palias for each row
--	execute procedure palias_iu_trigger();
