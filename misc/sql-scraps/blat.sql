-- -----------------------------------------------------------------------------
-- Name: blat.sql
-- Purpose: sql code for generating tables for storing blat results
--
-- $Id: blat.sql,v 1.4 2004/01/27 22:43:17 cavs Exp $
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Name: genasm
-- Purpose: store genome assembly information
--
DROP TABLE genasm CASCADE;
CREATE TABLE genasm (
    genasm_id serial NOT NULL,
    tax_id integer NOT NULL,
    name text NOT NULL,
    url text,
    released timestamp without time zone DEFAULT now() NOT NULL
) WITHOUT OIDS;
insert into genasm( tax_id, name, released ) values ( 9606, 'NHGD-34', 'July 1 2003');
COMMENT ON TABLE genasm IS 'genome and assembly';
COMMENT ON COLUMN genasm.name IS 'genome assembly name (e.g. NHGD-34)';

ALTER TABLE ONLY genasm
    ADD CONSTRAINT genasm_pkey PRIMARY KEY (genasm_id);
ALTER TABLE ONLY genasm
    ADD CONSTRAINT tax_id_exists FOREIGN KEY (tax_id) REFERENCES tax.spspec(tax_id);

REVOKE ALL ON TABLE genasm FROM PUBLIC;
GRANT SELECT ON TABLE genasm TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE genasm TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- Name: p2gblataln
-- Purpose: store protein-to-dna BLAT alignments
-- 
DROP TABLE p2gblataln CASCADE;
CREATE TABLE p2gblataln (
    p2gblataln_id serial NOT NULL,
    hsp_str text NOT NULL,
    ident integer NOT NULL,
    pgap_cnt integer NOT NULL,
    pgap_bases integer NOT NULL,
    ggap_cnt integer NOT NULL,
    ggap_bases integer NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE p2gblataln IS 'protein to dna BLAT alignments - groups of BLAT HSPs';
COMMENT ON COLUMN p2gblataln.hsp_str IS 'serialized version of the p2gblathsp_ids in the alignment';
COMMENT ON COLUMN p2gblataln.ident IS 'number of identities in the alignment';
COMMENT ON COLUMN p2gblataln.pgap_cnt IS 'number of query gaps';
COMMENT ON COLUMN p2gblataln.pgap_bases IS 'number of total residues in query gaps';
COMMENT ON COLUMN p2gblataln.ggap_cnt IS 'number of template gaps';
COMMENT ON COLUMN p2gblataln.ggap_bases IS 'number of total residues in template gaps';

ALTER TABLE ONLY p2gblataln
    ADD CONSTRAINT p2gblataln_pkey PRIMARY KEY (p2gblataln_id);

REVOKE ALL ON TABLE p2gblataln FROM PUBLIC;
GRANT SELECT ON TABLE p2gblataln TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE p2gblataln TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- Name: p2gblathsp
-- Purpose: store protein-to-dna BLAT HSPs
-- 
DROP TABLE p2gblathsp CASCADE;
CREATE TABLE p2gblathsp (
    p2gblathsp_id serial NOT NULL,
    genasm_id integer NOT NULL,
    chr text NOT NULL,
    plus_strand boolean NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    pseq_id integer NOT NULL,
    pstart integer NOT NULL,
    pstop integer NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE p2gblathsp IS 'protein to dna BLAT HSPs';
COMMENT ON COLUMN p2gblathsp.chr IS 'chromosome (e.g. 1..22,M,U,X,Y for homo sapiens)';
COMMENT ON COLUMN p2gblathsp.plus_strand IS 'located on genomic plus strand (t/f)';
COMMENT ON COLUMN p2gblathsp.pstart IS 'start of HSP on protein (1-based)';
COMMENT ON COLUMN p2gblathsp.pstop IS 'stop of HSP on protein (1-based)';
COMMENT ON COLUMN p2gblathsp.gstart IS 'start of HSP on genome (1-based, +1 frame, gstop > gstart)';
COMMENT ON COLUMN p2gblathsp.gstop IS 'stop of HSP on genome (1-based, +1 frame, gstop > gstart)';

CREATE UNIQUE INDEX p2gblathsp_unq ON p2gblathsp USING btree (genasm_id,chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop);
CREATE INDEX p2gblathsp_p_lookup ON p2gblathsp USING btree (pseq_id,pstart,pstop);
CREATE INDEX p2gblathsp_g_lookup ON p2gblathsp USING btree (genasm_id,chr,gstart,gstop);

ALTER TABLE ONLY p2gblathsp
    ADD CONSTRAINT p2gblathsp_id_pkey PRIMARY KEY (p2gblathsp_id);
ALTER TABLE ONLY p2gblathsp
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id);
ALTER TABLE ONLY p2gblathsp
    ADD CONSTRAINT genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id);

REVOKE ALL ON TABLE p2gblathsp FROM PUBLIC;
GRANT SELECT ON TABLE p2gblathsp TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE p2gblathsp TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- Name: p2gblatalnhsp
-- Purpose: associates protein-to-genome BLAT HSPs with alignments
-- 
DROP TABLE p2gblatalnhsp CASCADE;
CREATE TABLE p2gblatalnhsp (
    p2gblataln_id integer NOT NULL,
    p2gblathsp_id integer NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE p2gblatalnhsp IS 'groups protein-to-genome BLAT HSPs into alignments';
CREATE UNIQUE INDEX p2gblatalnhsp_unq ON p2gblatalnhsp USING btree (p2gblataln_id,p2gblathsp_id);
ALTER TABLE ONLY p2gblatalnhsp
    ADD CONSTRAINT p2gblathsp_id_exists FOREIGN KEY (p2gblathsp_id) REFERENCES p2gblathsp(p2gblathsp_id);
ALTER TABLE ONLY p2gblatalnhsp
    ADD CONSTRAINT p2gblataln_id_exists FOREIGN KEY (p2gblataln_id) REFERENCES p2gblataln(p2gblataln_id);

-- prevent updates - once defined, alignments don't change
CREATE RULE no_update AS ON UPDATE TO p2gblatalnhsp DO NOTHING;

REVOKE ALL ON TABLE p2gblatalnhsp FROM PUBLIC;
GRANT SELECT ON TABLE p2gblatalnhsp TO PUBLIC;
GRANT INSERT,DELETE ON TABLE p2gblatalnhsp TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- split():
--   purpose: analagous to Perl's split operator
--   arguments: text to split, delimiter
--   returns: array of split text 
--   
--   origin: code found in a posting from Joe Conway
--
CREATE OR REPLACE FUNCTION split(text, text)
RETURNS text[] AS '
  DECLARE
    i int := 0;
    word text;
    result text := ''{'';
    result_arr text[];
  BEGIN
    LOOP
      i := i + 1;
      SELECT INTO word split_part($1, $2, i);
      IF word = '''' THEN
        EXIT;
      END IF;
      IF i > 1 THEN
        result := result || '',"'' || word || ''"'';
      ELSE
        result := result || ''"'' || word || ''"'';
      END IF;
    END LOOP;
    result := result || ''}'';
    result_arr := result;
    RETURN result_arr;
  END
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION split(text, text) IS 'split text into an array - similar to Perl split';


-- -----------------------------------------------------------------------------
-- hsp_str_to_hsp_ids():
--   purpose: deserialize a hsp_str into an array of p2gblathsp_ids
--   argument: text serialization
--   returns: array of p2gblathsp_ids
--
CREATE OR REPLACE FUNCTION hsp_str_to_hsp_ids(text) RETURNS int[] AS '
DECLARE
  hsp_str ALIAS FOR $1;
  hsp_ids int[];
BEGIN
  SELECT INTO hsp_ids split(hsp_str,'':'');
  RETURN hsp_ids;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION hsp_str_to_hsp_ids(text) IS 'deserialize a hsp_str into an array of p2gblathsp_ids';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- hsp_ids_to_hsp_str():
--   purpose: serialize an array of p2gblathsp_ids
--   arguments: array of p2gblathsp_ids
--   returns: text serialization
--
CREATE OR REPLACE FUNCTION hsp_ids_to_hsp_str(int[]) RETURNS text AS '
DECLARE
  hsp_ids ALIAS FOR $1;
  hsp_str text;
  low integer;
  high integer;
BEGIN
  -- get bounds of hsp_ids array for looping
  low  := replace(split_part(array_dims(hsp_ids),'':'',1),''['','''')::int;
  high := replace(split_part(array_dims(hsp_ids),'':'',2),'']'','''')::int;

  hsp_str := hsp_ids[1];
  FOR i IN low+1..high LOOP
    hsp_str := hsp_str || '':'' || hsp_ids[i];
  END LOOP;

  return hsp_str;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION hsp_ids_to_hsp_str(int[]) IS 'serialize an array of p2gblathsp_ids';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- ins_p2gblathsp():
--   purpose: insert protein-to-genome BLAT HSPs
--   arguments: genasm_id,chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop
--   returns: p2gblathsp_id
--
CREATE OR REPLACE FUNCTION ins_p2gblathsp(integer, text, boolean, integer, integer, integer, integer, integer) RETURNS integer AS '
DECLARE
  v_genasm_id ALIAS FOR $1;
  v_chr ALIAS FOR $2;
  v_plus_strand ALIAS FOR $3;
  v_gstart ALIAS FOR $4;
  v_gstop ALIAS FOR $5;
  v_pseq_id ALIAS FOR $6;
  v_pstart ALIAS FOR $7;
  v_pstop ALIAS FOR $8;
  v_p2gblathsp_id integer;
  rec RECORD;
BEGIN
  -- check whether HSP already loaded
  SELECT INTO v_p2gblathsp_id p2gblathsp_id FROM p2gblathsp WHERE 
    genasm_id=v_genasm_id AND
    chr=v_chr AND
    plus_strand=v_plus_strand AND
    gstart=v_gstart AND
    gstop=v_gstop AND
    pseq_id=v_pseq_id AND
    pstart=v_pstart AND
    pstop=v_pstop;
  IF v_p2gblathsp_id is null THEN
    SELECT INTO v_p2gblathsp_id nextval(''unison.p2gblathsp_p2gblathsp_id_seq''::text);
    INSERT INTO p2gblathsp (p2gblathsp_id,genasm_id,chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop) VALUES
      (v_p2gblathsp_id,v_genasm_id,v_chr,v_plus_strand,v_gstart,v_gstop,v_pseq_id,v_pstart,v_pstop);
  END IF;
  return v_p2gblathsp_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION ins_p2gblathsp(integer, text, boolean, integer, integer, integer, integer, integer)
	IS 'insert protein-to-genome BLAT HSPs';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- assign_p2gblataln():
--   purpose: insert protein-to-genome BLAT alignments
--   arguments: hsp_str, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases
--   returns: p2gblataln_id
--
CREATE OR REPLACE FUNCTION assign_p2gblataln(text, integer, integer, integer, integer, integer) RETURNS integer AS '
DECLARE
  v_hsp_str ALIAS FOR $1;
  v_ident ALIAS FOR $2;
  v_pgap_cnt ALIAS FOR $3;
  v_pgap_bases ALIAS FOR $4;
  v_ggap_cnt ALIAS FOR $5;
  v_ggap_bases ALIAS FOR $6;
  v_p2gblataln_id integer;
  v_p2gblataln_ids integer[];
  low integer;
  high integer;
  rec RECORD;
BEGIN
  -- check whether hsp_str is already in the database
  SELECT INTO v_p2gblataln_id p2gblataln_id FROM p2gblataln WHERE hsp_str=v_hsp_str;
  IF v_p2gblataln_id is null THEN
    SELECT INTO v_p2gblataln_id nextval(''unison.p2gblataln_p2gblataln_id_seq''::text);
    INSERT INTO p2gblataln (p2gblataln_id, hsp_str, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases) VALUES
      (v_p2gblataln_id, v_hsp_str, v_ident, v_pgap_cnt, v_pgap_bases, v_ggap_cnt, v_ggap_bases);
  END IF;

  -- insert into p2gblatalnhsp table (let the unique indices deal with redudancies
  SELECT INTO v_p2gblataln_ids hsp_str_to_hsp_ids( v_hsp_str );
  low  := replace(split_part(array_dims(v_p2gblataln_ids),'':'',1),''['','''')::int;
  high := replace(split_part(array_dims(v_p2gblataln_ids),'':'',2),'']'','''')::int;
  FOR i IN low..high LOOP
    INSERT INTO p2gblatalnhsp (p2gblataln_id, p2gblathsp_id) VALUES
      (v_p2gblataln_id, v_p2gblataln_ids[i]);
  END LOOP;

  return v_p2gblataln_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION assign_p2gblataln(text, integer, integer, integer, integer, integer)
	IS 'insert protein-to-genome BLAT alignments';
-- -----------------------------------------------------------------------------
