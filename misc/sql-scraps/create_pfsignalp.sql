-- -----------------------------------------------------------------------------
-- NAME: create_pfsignalpnn.sql
-- PURPOSE: sql statements to create pfsignalpnnnn and pfsignalpnnhmm tables
--
-- $Id: create_pfsignalpnn.sql,v 1.2 2003/10/17 21:04:27 cavs Exp $
-- -----------------------------------------------------------------------------

--
-- pfsignalphnn stores signalp neural network results
--
DROP TABLE pfsignalpnn;
CREATE TABLE pfsignalpnn (
    pftype_id integer DEFAULT pftype_id_lookup('SignalP-2.0'::text)
)
INHERITS (pfeature) WITHOUT OIDS;
COMMENT ON TABLE pfsignalpnn IS 'neural network output from SignalP';
COMMENT ON COLUMN pfsignalpnn.confidence IS 'mean S value';

-- permissions
REVOKE ALL ON TABLE pfsignalpnn FROM PUBLIC;
GRANT SELECT ON TABLE pfsignalpnn TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pfsignalpnn TO loader;

-- indices
CREATE UNIQUE INDEX pfsignalpnn_sc_exists ON pfsignalpnn USING btree (pseq_id, "start", stop);
CREATE INDEX pfsignalpnn_pseq_id_idx ON pfsignalpnn USING btree (pseq_id);
CREATE INDEX pfsignalpnn_pftype_id_idx ON pfsignalpnn USING btree (pftype_id);
CREATE INDEX pfsignalpnn_start_idx ON pfsignalpnn USING btree ("start");
CREATE INDEX pfsignalpnn_stop_idx ON pfsignalpnn USING btree (stop);
CREATE INDEX pfsignalpnn_quality_idx ON pfsignalpnn USING btree (confidence);

-- foreign keys
ALTER TABLE ONLY pfsignalpnn
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pfsignalpnn
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- pfsignalphmm stores signalp HMM results
--
DROP TABLE pfsignalphmm;
CREATE TABLE pfsignalphmm (
    pftype_id integer DEFAULT pftype_id_lookup('SignalP-2.0'::text),
    siganchor_prob real,
    max_cleavage_prob real
)
INHERITS (pfeature) WITHOUT OIDS;
COMMENT ON TABLE pfsignalphmm IS 'HMM output from SignalP';
COMMENT ON COLUMN pfsignalphmm.confidence IS 'signal sequence probability';
COMMENT ON COLUMN pfsignalphmm.siganchor_prob IS 'signal anchor probability';
COMMENT ON COLUMN pfsignalphmm.max_cleavage_prob IS 'max cleavage site probability';

-- permissions
REVOKE ALL ON TABLE pfsignalphmm FROM PUBLIC;
GRANT SELECT ON TABLE pfsignalphmm TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pfsignalphmm TO loader;

-- indices
CREATE UNIQUE INDEX pfsignalphmm_sc_exists ON pfsignalphmm USING btree (pseq_id, "start", stop);
CREATE INDEX pfsignalphmm_pseq_id_idx ON pfsignalphmm USING btree (pseq_id);
CREATE INDEX pfsignalphmm_pftype_id_idx ON pfsignalphmm USING btree (pftype_id);
CREATE INDEX pfsignalphmm_start_idx ON pfsignalphmm USING btree ("start");
CREATE INDEX pfsignalphmm_stop_idx ON pfsignalphmm USING btree (stop);
CREATE INDEX pfsignalphmm_quality_idx ON pfsignalphmm USING btree (confidence);
CREATE INDEX pfsignalphmm_siganchor_idx ON pfsignalphmm USING btree (siganchor_prob);
CREATE INDEX pfsignalphmm_max_idx ON pfsignalphmm USING btree (max_cleavage_prob);

-- foreign keys
ALTER TABLE ONLY pfsignalphmm
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pfsignalphmm
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;
