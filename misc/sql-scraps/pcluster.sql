-- -----------------------------------------------------------------------------
-- Name: pcluster.sql
-- Purpose: sql code for generating tables for storing pcluster results
--
-- $Id: pcluster.sql,v 1.6 2004/02/09 21:36:27 cavs Exp $
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Name: pcluster
-- Purpose: store pcluster info
--
DROP TABLE pcluster CASCADE;
CREATE TABLE pcluster (
    pcluster_id serial NOT NULL,
		genasm_id integer NOT NULL,
		gstart integer NOT NULL,
		gstop integer NOT NULL,
		chr text NOT NULL,
		plus_strand boolean NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE pcluster IS 'store pclusters of pseq_ids mapping to same genomic region';

ALTER TABLE ONLY pcluster
    ADD CONSTRAINT pcluster_id_pkey PRIMARY KEY (pcluster_id);
ALTER TABLE ONLY pcluster
    ADD CONSTRAINT genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id);

CREATE UNIQUE INDEX pcluster_unq ON pcluster USING btree (genasm_id,gstart,gstop,chr,plus_strand);

REVOKE ALL ON TABLE pcluster FROM PUBLIC;
GRANT SELECT ON TABLE pcluster TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pcluster TO loader;
GRANT SELECT,INSERT,UPDATE on pcluster_pcluster_id_seq to loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- Name: pcluster_member
-- Purpose: contains list of pseq_id for a given pcluster
--
DROP TABLE pcluster_member CASCADE;
CREATE TABLE pcluster_member (
    pcluster_id integer NOT NULL,
		pseq_id integer NOT NULL,
		gstart integer NOT NULL,
		gstop integer NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE pcluster_member IS 'stores list of pseq_ids for a given pcluster';

ALTER TABLE ONLY pcluster_member
    ADD CONSTRAINT pcluster_id_exists FOREIGN KEY (pcluster_id) REFERENCES pcluster(pcluster_id);
ALTER TABLE ONLY pcluster_member
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id);

CREATE UNIQUE INDEX pcluster_member_unq ON pcluster_member USING btree (pcluster_id,pseq_id,gstart,gstop);

REVOKE ALL ON TABLE pcluster_member FROM PUBLIC;
GRANT SELECT ON TABLE pcluster_member TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pcluster_member TO loader;
-- -----------------------------------------------------------------------------

