-- -----------------------------------------------------------------------------
--
-- NAME: create_last_run.sql
-- PURPOSE: sql statements and PL/pgSQL commands for creating a
--          last_run table
--
-- $Id: create_last_run.sql,v 1.1 2003/08/29 18:08:01 cavs Exp $
--
-- -----------------------------------------------------------------------------

\timing

set search_path=unison,public;

DROP TABLE unison.last_run;
CREATE TABLE unison.last_run (
	pseq_id integer not null,
	run_id integer not null,
	lastrun timestamp default now()
)
WITHOUT OIDS;

ALTER TABLE ONLY unison.last_run
	ADD CONSTRAINT pseq_id_fk FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE NO ACTION;

CREATE UNIQUE INDEX last_run_nonredundant ON last_run(pseq_id,run_id);
CREATE INDEX last_run_run_id ON unison.last_run USING btree (run_id);

REVOKE ALL ON TABLE unison.last_run FROM PUBLIC;
GRANT SELECT ON TABLE unison.last_run TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE unison.last_run TO loader;



-- last_run_update updates the last_run timestamp for the given (pseq_id,run_id).
-- If that tuple doesn't exist, it's added.
-- Either way, the new timestamp is returned.
create or replace function last_run_update(integer,integer) returns timestamp without time zone
language plpgsql as '
DECLARE
	q alias for $1;
	r alias for $2;
	rc integer;
	ts timestamp;
BEGIN
	update last_run set last_run=now() where pseq_id=q and run_id=r;
	get diagnostics rc = ROW_COUNT;
	if rc = 0 then
		insert into last_run (pseq_id,run_id) values (q,r);
	end if;
	select into ts last_run from last_run where pseq_id=q and run_id=r;
	return ts;
END;';



-- As of 7.3.4 (and all earlier), PostgreSQL doesn't support FK checks on
-- a family of tables related by inheritance.  This trigger requires that
-- the run_id exists in the run table or a subclass of it.
create or replace function last_run_run_id_exists() returns trigger
language plpgsql as '
BEGIN
	PERFORM * from run R where R.run_id=NEW.run_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION ''foreign key integrity violation: run_id=% is not in run table (or descendants)'', new.run_id;
	END IF;
	RETURN NEW;
END;';

drop trigger last_run_run_id_exists on last_run;
create trigger last_run_run_id_exists
before insert or update
on last_run
for each row execute procedure last_run_run_id_exists();
