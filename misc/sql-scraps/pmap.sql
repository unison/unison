-- -----------------------------------------------------------------------------
-- Name: pmap.sql
-- Purpose: sql code for generating tables for storing PMAP results
--
-- $Id: pmap.sql,v 1.2 2005/11/17 17:10:51 mukhyala Exp $
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Name: pmap_hsp
-- Purpose: store protein-to-dna PMAP HSPs
-- 
DROP TABLE pmap_hsp CASCADE;
CREATE TABLE pmap_hsp (
    hsp_id serial NOT NULL,
    chr text NOT NULL,
    plus_strand boolean NOT NULL,
    genasm_id integer NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    pseq_id integer NOT NULL,
    pstart integer NOT NULL,
    pstop integer NOT NULL,
    params_id integer NOT NULL
) WITHOUT OIDS;


REVOKE ALL ON TABLE pmap_hsp FROM PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE pmap_hsp TO loader;
GRANT SELECT ON TABLE pmap_hsp TO PUBLIC;

REVOKE ALL ON TABLE pmap_hsp_hsp_id_seq FROM PUBLIC;
GRANT INSERT,UPDATE ON TABLE pmap_hsp_hsp_id_seq TO loader;

CREATE UNIQUE INDEX pmap_hsp_unq ON pmap_hsp USING btree (params_id,genasm_id, chr, plus_strand, gstart, gstop, pseq_id, pstart, pstop);
CREATE INDEX pmap_hsp_p_lookup ON pmap_hsp USING btree (params_id,pseq_id, pstart, pstop);
CREATE INDEX pmap_hsp_g_lookup ON pmap_hsp USING btree (params_id,genasm_id, chr, plus_strand, gstart, gstop);


ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT pmap_hsp_id_pkey PRIMARY KEY (hsp_id);
ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT hsp_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT hsp_genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id);
ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT hsp_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


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
    aln_id serial NOT NULL,
    hsp_str text NOT NULL,
    ident integer NOT NULL,
    pgap_cnt integer NOT NULL,
    pgap_bases integer NOT NULL,
    ggap_cnt integer NOT NULL,
    ggap_bases integer NOT NULL,
    genasm_id integer NOT NULL,
    pseq_id integer NOT NULL,
    params_id integer NOT NULL
) WITHOUT OIDS;

REVOKE ALL ON TABLE pmap_aln FROM PUBLIC;
GRANT SELECT ON TABLE pmap_aln TO PUBLIC;
GRANT INSERT,UPDATE,DELETE,TRIGGER ON TABLE pmap_aln TO loader;
REVOKE ALL ON TABLE pmap_aln_aln_id_seq FROM PUBLIC;
GRANT INSERT,UPDATE ON TABLE pmap_aln_aln_id_seq TO loader;

CREATE UNIQUE INDEX pmap_hsp_str_idx ON pmap_aln USING btree (hsp_str);

ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT pmap_aln_pkey PRIMARY KEY (aln_id);
ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT aln_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT aln_genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id);
ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT aln_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;

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
    aln_id integer NOT NULL,
    hsp_id integer NOT NULL
) WITHOUT OIDS;


REVOKE ALL ON TABLE pmap_alnhsp FROM PUBLIC;
GRANT SELECT ON TABLE pmap_alnhsp TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE pmap_alnhsp TO loader;

CREATE UNIQUE INDEX pmap_alnhsp_unq ON pmap_alnhsp USING btree (aln_id, hsp_id);

ALTER TABLE ONLY pmap_alnhsp
    ADD CONSTRAINT pmap_aln_id_exists FOREIGN KEY (aln_id) REFERENCES pmap_aln(aln_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pmap_alnhsp
    ADD CONSTRAINT pmap_hsp_id_exists FOREIGN KEY (hsp_id) REFERENCES pmap_hsp(hsp_id) ON UPDATE CASCADE ON DELETE CASCADE;

COMMENT ON TABLE pmap_alnhsp IS 'groups protein-to-genome PMAP HSPs into alignments';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- ins_pmap_hsp():
--   purpose: insert protein-to-genome PMAP HSPs
--   arguments: chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop
--   returns: pmap_hsp_id
--
CREATE OR REPLACE FUNCTION ins_pmap_hsp(integer, text, boolean, integer, integer, integer, integer, integer, integer) RETURNS integer AS '
DECLARE
  v_genasm_id ALIAS FOR $1;	
  v_chr ALIAS FOR $2;
  v_plus_strand ALIAS FOR $3;
  v_gstart ALIAS FOR $4;
  v_gstop ALIAS FOR $5;
  v_pseq_id ALIAS FOR $6;
  v_pstart ALIAS FOR $7;
  v_pstop ALIAS FOR $8;
  v_params_id ALIAS FOR $9;
  v_hsp_id integer;
  rec RECORD;
BEGIN
  -- check whether HSP already loaded
  SELECT INTO v_hsp_id hsp_id FROM pmap_hsp WHERE 
    chr=v_chr AND
    plus_strand=v_plus_strand AND
    gstart=v_gstart AND
    gstop=v_gstop AND
    pseq_id=v_pseq_id AND
    pstart=v_pstart AND
    pstop=v_pstop AND
    genasm_id=v_genasm_id AND
    params_id=v_params_id;
  IF v_hsp_id is null THEN
    SELECT INTO v_hsp_id nextval(''pmap_hsp_hsp_id_seq''::text);
    INSERT INTO pmap_hsp (hsp_id,genasm_id,chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop,params_id) VALUES
      (v_hsp_id,v_genasm_id,v_chr,v_plus_strand,v_gstart,v_gstop,v_pseq_id,v_pstart,v_pstop,v_params_id);	
  END IF;
  RETURN v_hsp_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION ins_pmap_hsp(integer, text, boolean, integer, integer, integer, integer, integer, integer)
	IS 'insert protein-to-genome PMAP HSPs';

-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- ins_pmap_aln():
--   purpose: insert protein-to-genome PMAP alignments
--   arguments: hsp_str, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases
--   returns: pmap_aln_id
--
CREATE OR REPLACE FUNCTION ins_pmap_aln(text,integer, integer, integer, integer, integer, integer, integer, integer) RETURNS integer AS '
DECLARE
  v_hsp_str ALIAS FOR $1;
  v_pseq_id ALIAS FOR $2;
  v_ident ALIAS FOR $3;
  v_pgap_cnt ALIAS FOR $4;
  v_pgap_bases ALIAS FOR $5;
  v_ggap_cnt ALIAS FOR $6;
  v_ggap_bases ALIAS FOR $7;
  v_params_id ALIAS FOR $8;
  v_genasm_id ALIAS FOR $9;
  v_aln_id integer;
  v_hsp_ids integer[];
  low integer;
  high integer;
  rec RECORD;
BEGIN

  IF length(v_hsp_str) = 0 THEN
	RAISE EXCEPTION ''Length hsp_str cannot be 0'';
  END IF;
  -- check whether hsp_str is already in the database
  SELECT INTO v_aln_id aln_id FROM pmap_aln WHERE hsp_str=v_hsp_str;
  IF v_aln_id is null THEN

    SELECT INTO v_aln_id nextval(''pmap_aln_aln_id_seq''::text);

   -- insert into pmap_alnhsp table (let the unique indices deal with redudancies
    SELECT INTO v_hsp_ids hsp_str_to_hsp_ids( v_hsp_str );
    low  := replace(split_part(array_dims(v_hsp_ids),'':'',1),''['','''')::int;
    high := replace(split_part(array_dims(v_hsp_ids),'':'',2),'']'','''')::int;
    FOR i IN low..high LOOP
     INSERT INTO pmap_alnhsp (aln_id, hsp_id) VALUES
    	(v_aln_id, v_hsp_ids[i]);
    END LOOP;

    INSERT INTO pmap_aln (aln_id, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases, params_id, genasm_id, pseq_id) VALUES
      (v_aln_id, v_ident, v_pgap_cnt, v_pgap_bases, v_ggap_cnt, v_ggap_bases, v_params_id, v_genasm_id, v_pseq_id);
  END IF;

  RETURN v_aln_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION ins_pmap_aln(text, integer, integer, integer, integer, integer, integer, integer, integer)
	IS 'insert protein-to-genome PMAP alignments';
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Name: pmap_hsp_str_trigger
-- Purpose: build hsp_str
-- 
CREATE OR REPLACE FUNCTION pmap_hsp_str_trigger() RETURNS "trigger"
    AS '
  declare
	hsp RECORD;
	v_hsp_str text := '''';
  begin
    select into v_hsp_str as_set(hsp_id) from (select hsp_id from pmap_alnhsp where aln_id=new.aln_id order by hsp_id) X;

    IF length(v_hsp_str) = 0 THEN
	RAISE EXCEPTION ''Could not construct hsp_str for %'',new.aln_id;
    END IF;

    new.hsp_str=v_hsp_str;
    return new;
  end; '
    LANGUAGE plpgsql;
COMMENT ON FUNCTION pmap_hsp_str_trigger() IS 'calculate hsp_str before inserting into pmap_aln';
 

CREATE TRIGGER pmap_hsp_str_trigger
	BEFORE INSERT 
	ON pmap_aln
	FOR EACH ROW
	EXECUTE PROCEDURE pmap_hsp_str_trigger();

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Name: pmap_aln_trigger
-- Purpose: Check p,g,q match
-- 
CREATE OR REPLACE FUNCTION pseq_genasm_params_trigger() RETURNS "trigger"
    AS '
  declare
	hsp RECORD;
  begin
    -- get pseq,genasm,params from hps for this alignment
    FOR hsp IN
	select h.genasm_id,h.pseq_id,h.params_id from pmap_hsp h join pmap_alnhsp a on a.hsp_id=h.hsp_id and a.aln_id=new.aln_id
    LOOP
	IF hsp.genasm_id != new.genasm_id OR hsp.pseq_id != new.pseq_id OR hsp.params_id != new.params_id THEN
		RAISE NOTICE ''% % %'',hsp.genasm_id,hsp.pseq_id,hsp.params_id;
		RAISE EXCEPTION ''genasm, pseq params mismatch for aln %'',new.aln_id;
	END IF;
    END LOOP;  
    return new;
  end; '
    LANGUAGE plpgsql;
COMMENT ON FUNCTION pseq_genasm_params_trigger() IS 'makes sure pseq_id, genasm_id and params_id are consistant between aln and hsp';
 

CREATE CONSTRAINT TRIGGER pseq_genasm_params_trigger
	AFTER INSERT 
	ON pmap_aln
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE PROCEDURE pseq_genasm_params_trigger();

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Name: pmap_v
-- Purpose: summary of PMAP alignments
-- 

CREATE OR REPLACE VIEW PMAP_V AS
	SELECT a.params_id, a.genasm_id, h.pseq_id, ah.aln_id, min(h.pstart) AS pstart, max(h.pstop) AS pstop, count(*) AS exons, sum(h.pstop - h.pstart + 1) AS aln_length, (sum(h.pstop - h.pstart + 1)::double precision / q.len::double precision * 100::double precision)::integer AS pct_cov, a.ident, ((a.ident / sum(h.pstop - h.pstart + 1))::double precision * 100::double precision)::integer AS pct_ident, h.chr, h.plus_strand, min(h.gstart) AS gstart, max(h.gstop) AS gstop
   FROM pmap_hsp h
   JOIN pmap_alnhsp ah ON h.hsp_id = ah.hsp_id
   JOIN pmap_aln a ON ah.aln_id = a.aln_id
   JOIN pseq q ON h.pseq_id = q.pseq_id
  GROUP BY a.params_id, a.genasm_id, h.pseq_id, ah.aln_id, h.chr, h.plus_strand, a.ident, q.len
  ORDER BY h.pseq_id, (sum(h.pstop - h.pstart + 1)::double precision / q.len::double precision * 100::double precision)::integer DESC, (a.ident::double precision / sum(h.pstop - h.pstart + 1)::double precision * 100::double precision)::integer DESC;

GRANT SELECT ON PMAP_V TO PUBLIC;

CREATE OR REPLACE VIEW PMAP_ALN_V AS
	SELECT a.params_id, ah.aln_id, h.pseq_id, h.pstart, h.pstop, h.gstart, h.gstop, a.ident, h.genasm_id, h.chr, h.plus_strand
   FROM pmap_hsp h
   JOIN pmap_alnhsp ah ON h.hsp_id = ah.hsp_id
   JOIN pmap_aln a ON ah.aln_id = a.aln_id
  ORDER BY ah.aln_id, h.gstart;

GRANT SELECT ON PMAP_ALN_V TO PUBLIC;
