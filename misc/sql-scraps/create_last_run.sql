-- -----------------------------------------------------------------------------
--
-- NAME: create_last_run.sql
-- PURPOSE: sql statements and PL/pgSQL commands for creating a
--          last_run table
--
-- $Id: create_last_run.sql,v 1.1 2003/07/14 23:35:29 cavs Exp $
--
-- -----------------------------------------------------------------------------

\timing

set search_path=unison,public;

DROP TABLE unison.last_run;
CREATE TABLE unison.last_run (
	pseq_id integer not null,
	pftype_id integer not null,
	run_id integer not null,
	lastrun timestamp default now()
)
WITHOUT OIDS;

ALTER TABLE ONLY unison.last_run
	ADD CONSTRAINT pseq_id_fk FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE ONLY unison.last_run
	ADD CONSTRAINT pftype_id_fk FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE ONLY unison.last_run
	ADD CONSTRAINT run_id_fk FOREIGN KEY (run_id) REFERENCES run(run_id) ON UPDATE CASCADE ON DELETE NO ACTION;

CREATE UNIQUE INDEX last_run_unq ON unison.last_run USING btree (pseq_id, pftype_id, run_id );
CREATE INDEX last_run_pftype_id ON unison.last_run USING btree (pftype_id);
CREATE INDEX last_run_run_id ON unison.last_run USING btree (run_id);

REVOKE ALL ON TABLE unison.last_run FROM PUBLIC;
GRANT SELECT ON TABLE unison.last_run TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE unison.last_run TO loader;


