-- -----------------------------------------------------------------------------
-- NAME: create_pfsignalp.sql
-- PURPOSE: sql statements to create pfsignalp table
--
-- $Id: create_pfsignalp.sql,v 1.1 2003/10/16 18:23:07 cavs Exp $
-- -----------------------------------------------------------------------------

DROP TABLE pfsignalp;
CREATE TABLE pfsignalp (
    pftype_id integer DEFAULT pftype_id_lookup('SignalP-2.0'::text),
    siganchor_prob real,
    max_cleavage_prob real
)
INHERITS (pfeature) WITHOUT OIDS;
COMMENT ON TABLE pfsignalp IS 'signal sequence prediction from SignalP';
COMMENT ON COLUMN pfsignalp.confidence IS 'signal sequence probability';
COMMENT ON COLUMN pfsignalp.siganchor_prob IS 'signal anchor probability';
COMMENT ON COLUMN pfsignalp.max_cleavage_prob IS 'max cleavage site probability';

-- permissions
REVOKE ALL ON TABLE pfsignalp FROM PUBLIC;
GRANT SELECT ON TABLE pfsignalp TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pfsignalp TO loader;

-- indices
CREATE UNIQUE INDEX pfsignalp_sc_exists ON pfsignalp USING btree (pseq_id, "start", stop);
CREATE INDEX pfsignalp_pseq_id_idx ON pfsignalp USING btree (pseq_id);
CREATE INDEX pfsignalp_pftype_id_idx ON pfsignalp USING btree (pftype_id);
CREATE INDEX pfsignalp_start_idx ON pfsignalp USING btree ("start");
CREATE INDEX pfsignalp_stop_idx ON pfsignalp USING btree (stop);
CREATE INDEX pfsignalp_quality_idx ON pfsignalp USING btree (confidence);
CREATE INDEX pfsignalp_siganchor_idx ON pfsignalp USING btree (siganchor_prob);
CREATE INDEX pfsignalp_max_idx ON pfsignalp USING btree (max_cleavage_prob);

-- foreign keys
ALTER TABLE ONLY pfsignalp
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pfsignalp
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;
