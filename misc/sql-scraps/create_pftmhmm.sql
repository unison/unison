-- -----------------------------------------------------------------------------
-- NAME: create_pftmhmm.sql
-- PURPOSE: sql statements to create pftmhmm table
--
-- $Id$
-- -----------------------------------------------------------------------------

--
-- pftmhmm stores tmhmm results
--
DROP TABLE pftmhmm;
CREATE TABLE pftmhmm (
    pftype_id integer DEFAULT pftype_id_lookup('tmhmm'::text),
    type char constraint tm_type_ck 
	check (type in ('o', 'O', 'M', 'i'))
)
INHERITS (pfeature) WITHOUT OIDS;
COMMENT ON TABLE pftmhmm IS 'TMHMM output';

-- permissions
REVOKE ALL ON TABLE pftmhmm FROM PUBLIC;
GRANT SELECT ON TABLE pftmhmm TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pftmhmm TO loader;

-- indices
CREATE UNIQUE INDEX pftmhmm_sc_exists ON pftmhmm USING btree (params_id,pseq_id, "start", stop, type);
CREATE INDEX pftmhmm_pseq_id_idx ON pftmhmm USING btree (pseq_id);
CREATE INDEX pftmhmm_pftype_id_idx ON pftmhmm USING btree (pftype_id);
CREATE INDEX pftmhmm_start_idx ON pftmhmm USING btree ("start");
CREATE INDEX pftmhmm_stop_idx ON pftmhmm USING btree (stop);

-- foreign keys
ALTER TABLE ONLY pftmhmm
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pftmhmm
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pftmhmm
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;

