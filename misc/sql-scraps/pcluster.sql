-- -----------------------------------------------------------------------------
-- Name: pcluster.sql
-- Purpose: sql code for generating tables for storing pcluster results
--
-- $Id: pcluster.sql,v 1.1 2004/03/02 23:11:35 cavs Exp $
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


-- -----------------------------------------------------------------------------
-- Name: pclustersetname
-- Purpose: store pcluster set info
--
DROP TABLE pclustersetname CASCADE;
CREATE TABLE pclustersetname (
  pclustersetname_id serial NOT NULL,
  name text,
  descr text
) WITHOUT OIDS;

REVOKE ALL ON TABLE pclustersetname FROM PUBLIC;
GRANT SELECT ON TABLE pclustersetname TO PUBLIC;

ALTER TABLE pclustersetname
  ADD CONSTRAINT pclustersetname_pkey PRIMARY KEY (pclustersetname_id);
CREATE UNIQUE INDEX pclustersetname_unq ON pclustersetname USING btree (upper(name));
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Name: pclusterset
-- Purpose: store sets of pclusters
--
DROP TABLE pclusterset CASCADE;
CREATE TABLE pclusterset (
  pclustersetname_id integer NOT NULL,
  pcluster_id integer NOT NULL
) WITHOUT OIDS;

ALTER TABLE pclusterset 
  ADD CONSTRAINT pcluster_id_exists FOREIGN KEY (pcluster_id) REFERENCES pcluster(pcluster_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE pclusterset 
  ADD CONSTRAINT pclustersetname_id_exists FOREIGN KEY (pclustersetname_id) REFERENCES pclustersetname(pclustersetname_id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE UNIQUE INDEX pclusterset_unq ON pclusterset USING btree (pclustersetname_id,pcluster_id );

REVOKE ALL ON TABLE pclusterset FROM PUBLIC;
GRANT SELECT ON TABLE pclusterset TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pclusterset TO loader;
-- -----------------------------------------------------------------------------
