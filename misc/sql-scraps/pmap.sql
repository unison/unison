-- -----------------------------------------------------------------------------
-- Name: pmap.sql
-- Purpose: sql code for generating tables for storing PMAP results
--
-- $Id$
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Name: pmap_hsp
-- Purpose: store protein-to-dna PMAP HSPs
-- 
DROP TABLE pmap_hsp CASCADE;
CREATE TABLE pmap_hsp (
    pmap_hsp_id serial NOT NULL,
    chr text NOT NULL,
    plus_strand boolean NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    pseq_id integer NOT NULL,
    pstart integer NOT NULL,
    pstop integer NOT NULL
) WITHOUT OIDS;


REVOKE ALL ON TABLE pmap_hsp FROM PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE pmap_hsp TO loader;
GRANT SELECT ON TABLE pmap_hsp TO PUBLIC;

REVOKE ALL ON TABLE pmap_hsp_pmap_hsp_id_seq FROM PUBLIC;
GRANT INSERT,UPDATE ON TABLE pmap_hsp_pmap_hsp_id_seq TO loader;


CREATE UNIQUE INDEX pmap_hsp_unq ON pmap_hsp USING btree (chr, plus_strand, gstart, gstop, pseq_id, pstart, pstop);
CREATE INDEX pmap_hsp_p_lookup ON pmap_hsp USING btree (pseq_id, pstart, pstop);
CREATE INDEX pmap_hsp_g_lookup ON pmap_hsp USING btree (chr, gstart, gstop);


ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT pmap_hsp_id_pkey PRIMARY KEY (pmap_hsp_id);
ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


COMMENT ON TABLE pmap_hsp IS 'protein to dna PMAP HSPs';
COMMENT ON COLUMN pmap_hsp.chr IS 'chromosome (e.g. 1..22,M,U,X,Y for homo sapiens)';
COMMENT ON COLUMN pmap_hsp.plus_strand IS 'located on genomic plus strand (t/f)';
COMMENT ON COLUMN pmap_hsp.gstart IS 'start of HSP on genome (1-based, +1 frame, gstop > gstart)';
COMMENT ON COLUMN pmap_hsp.gstop IS 'stop of HSP on genome (1-based, +1 frame, gstop > gstart)';
COMMENT ON COLUMN pmap_hsp.pstart IS 'start of HSP on protein (1-based)';
COMMENT ON COLUMN pmap_hsp.pstop IS 'stop of HSP on protein (1-based)';
-- -----------------------------------------------------------------------------



-- -----------------------------------------------------------------------------
-- Name: pmap_aln
-- Purpose: store protein-to-dna PMAP alignments
-- 
DROP TABLE pmap_aln CASCADE;
CREATE TABLE pmap_aln (
    pmap_aln_id serial NOT NULL,
    hsp_str text NOT NULL,
    ident integer NOT NULL,
    pgap_cnt integer NOT NULL,
    pgap_bases integer NOT NULL,
    ggap_cnt integer NOT NULL,
    ggap_bases integer NOT NULL,
    params_id integer NOT NULL
) WITHOUT OIDS;

REVOKE ALL ON TABLE pmap_aln FROM PUBLIC;
GRANT SELECT ON TABLE pmap_aln TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE pmap_aln TO loader;

REVOKE ALL ON TABLE pmap_aln_pmap_aln_id_seq FROM PUBLIC;
GRANT INSERT,UPDATE ON TABLE pmap_aln_pmap_aln_id_seq TO loader;

ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT pmap_aln_pkey PRIMARY KEY (pmap_aln_id);
ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;

COMMENT ON TABLE pmap_aln IS 'protein to dna PMAP alignments - groups of PMAP HSPs';
COMMENT ON COLUMN pmap_aln.hsp_str IS 'serialized version of the pmap_hsp_ids in the alignment';
COMMENT ON COLUMN pmap_aln.ident IS 'number of identities in the alignment';
COMMENT ON COLUMN pmap_aln.pgap_cnt IS 'number of query gaps';
COMMENT ON COLUMN pmap_aln.pgap_bases IS 'number of total residues in query gaps';
COMMENT ON COLUMN pmap_aln.ggap_cnt IS 'number of template gaps';
COMMENT ON COLUMN pmap_aln.ggap_bases IS 'number of total residues in template gaps';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- Name: pmap_alnhsp
-- Purpose: associates protein-to-genome PMAP HSPs with alignments
-- 
DROP TABLE pmap_alnhsp CASCADE;
CREATE TABLE pmap_alnhsp (
    pmap_aln_id integer NOT NULL,
    pmap_hsp_id integer NOT NULL
) WITHOUT OIDS;


REVOKE ALL ON TABLE pmap_alnhsp FROM PUBLIC;
GRANT SELECT ON TABLE pmap_alnhsp TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE pmap_alnhsp TO loader;

CREATE UNIQUE INDEX pmap_alnhsp_unq ON pmap_alnhsp USING btree (pmap_aln_id, pmap_hsp_id);

ALTER TABLE ONLY pmap_alnhsp
    ADD CONSTRAINT pmap_aln_id_exists FOREIGN KEY (pmap_aln_id) REFERENCES pmap_aln(pmap_aln_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pmap_alnhsp
    ADD CONSTRAINT pmap_hsp_id_exists FOREIGN KEY (pmap_hsp_id) REFERENCES pmap_hsp(pmap_hsp_id) ON UPDATE CASCADE ON DELETE CASCADE;

COMMENT ON TABLE pmap_alnhsp IS 'groups protein-to-genome PMAP HSPs into alignments';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- ins_pmap_hsp():
--   purpose: insert protein-to-genome PMAP HSPs
--   arguments: chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop
--   returns: pmap_hsp_id
--
CREATE OR REPLACE FUNCTION ins_pmap_hsp(text, boolean, integer, integer, integer, integer, integer) RETURNS integer AS '
DECLARE
  v_chr ALIAS FOR $1;
  v_plus_strand ALIAS FOR $2;
  v_gstart ALIAS FOR $3;
  v_gstop ALIAS FOR $4;
  v_pseq_id ALIAS FOR $5;
  v_pstart ALIAS FOR $6;
  v_pstop ALIAS FOR $7;
  v_pmap_hsp_id integer;
  rec RECORD;
BEGIN
  -- check whether HSP already loaded
  SELECT INTO v_pmap_hsp_id pmap_hsp_id FROM pmap_hsp WHERE 
    chr=v_chr AND
    plus_strand=v_plus_strand AND
    gstart=v_gstart AND
    gstop=v_gstop AND
    pseq_id=v_pseq_id AND
    pstart=v_pstart AND
    pstop=v_pstop;
  IF v_pmap_hsp_id is null THEN
    SELECT INTO v_pmap_hsp_id nextval(''pmap_hsp_pmap_hsp_id_seq''::text);
    INSERT INTO pmap_hsp (pmap_hsp_id,chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop) VALUES
      (v_pmap_hsp_id,v_chr,v_plus_strand,v_gstart,v_gstop,v_pseq_id,v_pstart,v_pstop);
  END IF;
  return v_pmap_hsp_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION ins_pmap_hsp(text, boolean, integer, integer, integer, integer, integer)
	IS 'insert protein-to-genome PMAP HSPs';

-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- assign_pmap_aln():
--   purpose: insert protein-to-genome PMAP alignments
--   arguments: hsp_str, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases
--   returns: pmap_aln_id
--
CREATE OR REPLACE FUNCTION assign_pmap_aln(text, integer, integer, integer, integer, integer, integer) RETURNS integer AS '
DECLARE
  v_hsp_str ALIAS FOR $1;
  v_ident ALIAS FOR $2;
  v_pgap_cnt ALIAS FOR $3;
  v_pgap_bases ALIAS FOR $4;
  v_ggap_cnt ALIAS FOR $5;
  v_ggap_bases ALIAS FOR $6;
  v_params_id ALIAS FOR $7;
  v_pmap_aln_id integer;
  v_pmap_aln_ids integer[];
  low integer;
  high integer;
  rec RECORD;
BEGIN
  -- check whether hsp_str is already in the database
  SELECT INTO v_pmap_aln_id pmap_aln_id FROM pmap_aln WHERE hsp_str=v_hsp_str;
  IF v_pmap_aln_id is null THEN
    SELECT INTO v_pmap_aln_id nextval(''pmap_aln_pmap_aln_id_seq''::text);
    INSERT INTO pmap_aln (pmap_aln_id, hsp_str, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases, params_id) VALUES
      (v_pmap_aln_id, v_hsp_str, v_ident, v_pgap_cnt, v_pgap_bases, v_ggap_cnt, v_ggap_bases, v_params_id);
  END IF;

  -- insert into pmap_alnhsp table (let the unique indices deal with redudancies
  SELECT INTO v_pmap_aln_ids hsp_str_to_hsp_ids( v_hsp_str );
  low  := replace(split_part(array_dims(v_pmap_aln_ids),'':'',1),''['','''')::int;
  high := replace(split_part(array_dims(v_pmap_aln_ids),'':'',2),'']'','''')::int;
  FOR i IN low..high LOOP
    INSERT INTO pmap_alnhsp (pmap_aln_id, pmap_hsp_id) VALUES
      (v_pmap_aln_id, v_pmap_aln_ids[i]);
  END LOOP;

  return v_pmap_aln_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION assign_pmap_aln(text, integer, integer, integer, integer, integer, integer)
	IS 'insert protein-to-genome PMAP alignments';
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Name: v_pmap
-- Purpose: summary of PMAP alignments
-- 

CREATE OR REPLACE VIEW V_PMAP AS
 SELECT ah.pmap_aln_id, h.pseq_id, min(h.pstart) AS pstart, max(h.pstop) AS pstop, count(*) AS exons, sum(h.pstop - h.pstart + 1) AS aln_length, (sum(h.pstop - h.pstart + 1)::double precision / q.len::double precision * 100::double precision)::integer AS pct_cov, a.ident, (a.ident / sum(h.pstop - h.pstart + 1) * 100::double precision)::integer AS pct_ident, h.chr, h.plus_strand, min(h.gstart) AS gstart, max(h.gstop)
AS gstop
   FROM pmap_hsp h
   JOIN pmap_alnhsp ah ON h.pmap_hsp_id = ah.pmap_hsp_id
   JOIN pmap_aln a ON ah.pmap_aln_id = a.pmap_aln_id
   JOIN pseq q ON h.pseq_id = q.pseq_id
  GROUP BY ah.pmap_aln_id, h.pseq_id, h.chr, h.plus_strand, a.ident, q.len
  ORDER BY h.pseq_id, (sum(h.pstop - h.pstart + 1)::double precision / q.len::double precision * 100::double precision)::integer DESC, (a.ident::double precision / sum(h.pstop - h.pstart + 1)::double precision * 100::double precision)::integer DESC;

GRANT SELECT ON V_PMAP TO PUBLIC;
