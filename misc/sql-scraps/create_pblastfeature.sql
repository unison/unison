-- -----------------------------------------------------------------------------
--
-- NAME: create_unison.pblastfeature.sql
-- PURPOSE: sql statements and PL/pgSQL commands for creating a
--          blast feature table and associated procedures
--
-- $Id: create_unison.pblastfeature.sql,v 1.2 2003/04/10 16:12:21 cavs Exp $
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
	e_value real NOT NULL,
	p_value real NOT NULL,
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
COMMENT ON COLUMN unison.pblastfeature.e_value IS 'HSP e-value';
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
-- ins_pblastfeature():
--   purpose: create a unison.pblastfeature record
--   arguments: porigin_id, alias, pseq_id, ref_pseq_id
--   returns: pfeature_id
--
CREATE OR REPLACE FUNCTION ins_pblastfeature(integer, integer, integer, integer, integer, integer, real, real, integer, integer, integer)  RETURNS integer AS '
DECLARE
	v_q_pseq_id ALIAS FOR $1;
	v_q_start ALIAS FOR $2;
	v_q_stop ALIAS FOR $3;
	v_t_pseq_id ALIAS FOR $4;
	v_t_start ALIAS FOR $5;
	v_t_stop ALIAS FOR $6;
	v_e_value ALIAS FOR $7;
	v_p_value ALIAS FOR $8;
	v_hsp_length ALIAS FOR $9;
	v_identities ALIAS FOR $10;
	v_similarities ALIAS FOR $11;

	v_pct_identity real;
	v_pct_hsp_coverage real;
	v_pct_coverage real;
	v_pfeature_id integer;
	v_pftype_id integer;
	t_seq_len integer;
	q_seq_len integer;
	pftype_name varchar;
BEGIN
	pftype_name := ''BLAST'';
	select into v_pfeature_id nextval(''pfeature_pfeature_id_seq'');
	select into v_pftype_id pftype_id from pftype where name=pftype_name;

	-- error handling
	IF v_pftype_id is null THEN
		RAISE EXCEPTION ''Unable to retrieve pftype_id for name=%'',pftype_name;
	ELSIF v_hsp_length = 0 THEN
		RAISE EXCEPTION ''hsp_length parameter is 0 - not valid'';
	END IF;

	-- get sequence lengths for derived values;
	select into q_seq_len len from pseq where pseq_id=v_q_pseq_id;
	select into t_seq_len len from pseq where pseq_id=v_t_pseq_id;
	IF    q_seq_len is null or q_seq_len = 0 THEN
		RAISE EXCEPTION ''length for pseq_id=% is null or zero'',v_q_pseq_id;
	ELSIF t_seq_len is null or t_seq_len = 0 THEN
		RAISE EXCEPTION ''length for pseq_id=% is null or zero'',v_t_pseq_id;
	END IF;

	-- calculate derived values
	v_pct_identity := ( v_identities::real / v_hsp_length::real ) * 100.0;
	v_pct_hsp_coverage := ( v_hsp_length::real / q_seq_len::real ) * 100.0;
	v_pct_coverage := ( t_seq_len::real / q_seq_len::real ) * 100.0;

	-- do insert
	insert into unison.pblastfeature ( pfeature_id, pseq_id, pftype_id, start, stop, t_pseq_id, 
	    t_start, t_stop, e_value, p_value, hsp_length, identities, similarities, pct_identity, 
	    pct_hsp_coverage, pct_coverage ) values ( v_pfeature_id, v_q_pseq_id, v_pftype_id, v_q_start,
		v_q_stop, v_t_pseq_id, v_t_start, v_t_stop, v_e_value, v_p_value, v_hsp_length, 
		v_identities, v_similarities, v_pct_identity, v_pct_hsp_coverage, v_pct_coverage );

	return v_pfeature_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION ins_pblastfeature(integer, integer, integer, integer, integer, integer, real, real, integer, integer, integer) IS 'insert a blast feature';
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
