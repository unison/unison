-- -----------------------------------------------------------------------------
--
-- NAME: create_unison.pblastfeature.sql
-- PURPOSE: sql statements and PL/pgSQL commands for creating a
--          blast feature table and associated procedures
--
-- $Id: create_pblastfeature.sql,v 1.3 2003/04/23 17:19:41 cavs Exp $
--
-- -----------------------------------------------------------------------------

\timing

-- -----------------------------------------------------------------------------
--
-- create the unison.pblastfeature table as a subclass of pfeature.  add appropriate
-- indices.
DROP TABLE unison.pblastfeature;
CREATE TABLE unison.pblastfeature (
  t_pseq_id integer NOT NULL,
  t_start integer NOT NULL,
  t_stop integer NOT NULL,
  p_value double precision NOT NULL,
  hsp_length integer NOT NULL,
  identities integer NOT NULL,
  similarities integer NOT NULL,
  pct_identity real NOT NULL,
  pct_hsp_coverage real NOT NULL,
  pct_coverage real NOT NULL
) INHERITS (pfeature) WITHOUT OIDS;
COMMENT ON TABLE unison.pblastfeature IS 'stores BLAST features and derived values';
COMMENT ON COLUMN unison.pblastfeature.pseq_id IS 'query pseq_id';
COMMENT ON COLUMN unison.pblastfeature.start IS 'starting position (1-based) on the query sequence';
COMMENT ON COLUMN unison.pblastfeature.stop IS 'ending position (1-based) on the query sequence';
COMMENT ON COLUMN unison.pblastfeature.t_pseq_id IS 'target pseq_id';
COMMENT ON COLUMN unison.pblastfeature.t_start IS 'starting position (1-based) on the target sequence';
COMMENT ON COLUMN unison.pblastfeature.t_stop IS 'ending position (1-based) on the target sequence';
COMMENT ON COLUMN unison.pblastfeature.p_value IS 'HSP p-value';
COMMENT ON COLUMN unison.pblastfeature.hsp_length IS 'length of HSP including gaps';
COMMENT ON COLUMN unison.pblastfeature.identities IS 'number of identities';
COMMENT ON COLUMN unison.pblastfeature.similarities IS 'number of similarities';
COMMENT ON COLUMN unison.pblastfeature.pct_identity IS 'derived value: identites/hsp_length';
COMMENT ON COLUMN unison.pblastfeature.pct_hsp_coverage IS 'derived value: hsp_length/length of query sequence';
COMMENT ON COLUMN unison.pblastfeature.pct_coverage IS 'derived value: length of target sequence/length of query sequence';

ALTER TABLE ONLY unison.pblastfeature
    ADD CONSTRAINT pseq_id_fk FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE ONLY unison.pblastfeature
    ADD CONSTRAINT t_pseq_id_fk FOREIGN KEY (t_pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE NO ACTION;
CREATE INDEX pblastfeature_pseq_id ON unison.pblastfeature USING btree (pseq_id);
CREATE INDEX pblastfeature_t_pseq_id ON unison.pblastfeature USING btree (t_pseq_id);
CREATE INDEX pblastfeature_pct_identity ON unison.pblastfeature USING btree (pct_identity);
CREATE INDEX pblastfeature_pct_hsp_coverage ON unison.pblastfeature USING btree (pct_hsp_coverage);
CREATE INDEX pblastfeature_hsp_length ON unison.pblastfeature USING btree (hsp_length);


REVOKE ALL ON TABLE unison.pblastfeature FROM PUBLIC;
GRANT SELECT ON TABLE unison.pblastfeature TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE unison.pblastfeature TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- get_identical_seqs():
--   purpose: retrieve a set of pseq_ids of "identical" sequences
--   arguments: pseq_id
--   returns: cursor for fetching the pseq_ids
--
CREATE OR REPLACE FUNCTION get_identical_seqs(integer) RETURNS refcursor AS '
DECLARE
  v_pseq_id ALIAS FOR $1;

  ref refcursor;
  pct_identity_min real;
  pct_hsp_coverage_min real;
  hsp_length_min integer;
BEGIN
  -- define selection criteria
  pct_identity_min := 90.0;
  pct_hsp_coverage_min := 90.0;
  hsp_length_min := 50;

  OPEN ref FOR SELECT t_pseq_id from unison.pblastfeature WHERE pseq_id=v_pseq_id and 
  pct_identity>=pct_identity_min and pct_hsp_coverage >= pct_hsp_coverage_min and 
  hsp_length >= hsp_length_min;

  return ref;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION get_identical_seqs(integer) IS 'retrieve a set of nearly identical sequences';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- pblastfeature_iu_trigger():
--   purpose: calculate pct_identity, pct_hsp_coverage, and pct_coverage for
--            inserts to the pblastfeature table
--
CREATE OR REPLACE FUNCTION pblastfeature_iu_trigger () RETURNS "trigger"
    AS '
  declare
    q_seq_len integer;
    t_seq_len integer;
		shorter_len integer;
		longer_len integer;
  begin

    -- get sequence lengths for derived values
    select into q_seq_len len from pseq where pseq_id=new.pseq_id;
    select into t_seq_len len from pseq where pseq_id=new.t_pseq_id;
    IF    q_seq_len is null or q_seq_len = 0 THEN
      RAISE EXCEPTION ''length for pseq_id=% is null or zero'',new.pseq_id;
    ELSIF t_seq_len is null or t_seq_len = 0 THEN
      RAISE EXCEPTION ''length for pseq_id=% is null or zero'',new.t_pseq_id;
    END IF;

    -- calculate derived values
		IF q_seq_len > t_seq_len THEN
			shorter_len := t_seq_len;
			longer_len := q_seq_len;
		ELSE
			shorter_len := q_seq_len;
			longer_len := t_seq_len;
		END IF;
    new.pct_identity := ( new.identities::real / new.hsp_length::real ) * 100.0;
    new.pct_hsp_coverage := ( new.hsp_length::real / q_seq_len::real ) * 100.0;
    new.pct_coverage := ( shorter_len::real / longer_len::real ) * 100.0;

    return new;
  end; '
    LANGUAGE plpgsql;
COMMENT ON FUNCTION pblastfeature_iu_trigger() IS 'calculate derived values for inserting into pblastfeature';

CREATE TRIGGER pblastfeature_iu_trigger
	BEFORE INSERT OR UPDATE ON pblastfeature
		FOR EACH ROW
			EXECUTE PROCEDURE pblastfeature_iu_trigger ();
-- -----------------------------------------------------------------------------
