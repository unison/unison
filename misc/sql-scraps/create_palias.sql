-- -----------------------------------------------------------------------------
--
-- NAME: create_palias.sql
-- PURPOSE: sql statements and PL/pgSQL commands for creating a 
--          palias versioning system
--
-- $Id: create_palias.sql,v 1.2 2003/04/10 23:32:01 cavs Exp $
--
-- -----------------------------------------------------------------------------

\timing

-- -----------------------------------------------------------------------------
--
-- copy the palias table into a backup table so that
-- we can verify the alterations.
--
select * into palias_backup from palias;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- drop the pseq_id, ref_pseq_id, added columns.  they will be represented by
-- the new pseq_alias table (created below)
--
ALTER TABLE palias DROP pseq_id cascade;
ALTER TABLE palias DROP ref_pseq_id;
ALTER TABLE palias DROP added;
ALTER TABLE palias RENAME to paliasorigin;
COMMENT ON TABLE paliasorigin IS 'alias (names) given by a particular origin';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- pseqalias table: stores pseq_id and palias_id relationships
--
DROP TABLE pseqalias;
CREATE TABLE pseqalias (
    palias_id integer NOT NULL,
    pseq_id integer NOT NULL,
    ref_pseq_id integer,
    added timestamp without time zone DEFAULT now() NOT NULL,
	version integer DEFAULT 1 NOT NULL,
	isCurrent boolean DEFAULT true NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE pseqalias IS 'aliases for a given sequence';
COMMENT ON COLUMN pseqalias.palias_id IS 'fk to pseqaliasorigin.palias_id for this alias';
COMMENT ON COLUMN pseqalias.pseq_id IS 'pseq.pseq_id for this alias';
COMMENT ON COLUMN pseqalias.ref_pseq_id IS 'reference to pseq_id for this derived sequence';
COMMENT ON COLUMN pseqalias.version IS 'version number of this pseqalias';
COMMENT ON COLUMN pseqalias.isCurrent IS 'is this pseqalias the current version';

REVOKE ALL ON TABLE pseqalias FROM PUBLIC;
GRANT SELECT ON TABLE pseqalias TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE pseqalias TO rkh;
GRANT INSERT,UPDATE,DELETE ON TABLE pseqalias TO cavs;
GRANT INSERT,UPDATE ON TABLE pseqalias TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- copy data from the palias backup into the new pseqalias table
--
INSERT INTO pseqalias (palias_id, pseq_id, ref_pseq_id, added) select palias_id, pseq_id, ref_pseq_id, added from palias_backup;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- after the insert, create the indices and then vacuum the database
--
CREATE UNIQUE INDEX pseqalias_unq_duple ON pseqalias USING btree (palias_id,version);
CREATE INDEX pseqalias_pseq_id ON pseqalias USING btree (pseq_id);

vacuum analyze pseqalias;
vacuum analyze paliasorigin;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- ins_paliasorigin():
--   purpose: create a new paliasorigin record or return known
--   arguments: porigin_id, alias, descr
--   returns: palias_id
--
CREATE OR REPLACE FUNCTION ins_paliasorigin(integer, text, text) RETURNS integer AS '
DECLARE
	v_porigin_id ALIAS FOR $1;
	v_alias ALIAS FOR $2;
	v_descr ALIAS FOR $3;
	v_palias_id integer;
BEGIN
	-- check whether paliasorigin exists: if yes, then return palias_id, otherwise enter a new record 
	RAISE DEBUG ''select into v_palias_id get_paliasorigin_palias_id( %, % )'', v_porigin_id, v_alias;
	select into v_palias_id get_paliasorigin_palias_id( v_porigin_id, v_alias );
	--IF not found THEN
	IF v_palias_id is null THEN
		select into v_palias_id nextval(''paliasorigin_palias_id_seq'');
		RAISE DEBUG ''executing insert into alias (palias_id, porigin_id, alias, descr) values (%, %, %, %)'',v_palias_id, v_porigin_id, v_alias, v_descr;
		insert into paliasorigin (palias_id, porigin_id, alias, descr) values (v_palias_id, v_porigin_id, v_alias, v_descr);
	ELSE 
		RAISE DEBUG ''record exists for this alias and porigin: %'', v_palias_id;
	END IF;
	return v_palias_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION ins_paliasorigin(integer, text, text) IS 'create a new paliasorigin record or return known palias_id';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- get_paliasorigin_palias_id():
--   purpose: retrieve the palias_id for a given porigin_id and alias
--   arguments: porigin_id, alias
--   returns: palias_id
--
CREATE OR REPLACE FUNCTION get_paliasorigin_palias_id(integer, text) RETURNS integer AS '
DECLARE
    v_porigin_id ALIAS FOR $1;
    v_alias ALIAS FOR $2;
    rec record;
    v_palias_id integer;
BEGIN
    -- check whether paliasorigin exists: if yes, then return palias_id, otherwise return null
    RAISE DEBUG ''select * from pseqaliasorigin where porigin_id=% and alias=%'',v_porigin_id,v_alias;
    select into rec * from paliasorigin where porigin_id=v_porigin_id and alias=v_alias;
    IF found THEN
        RAISE DEBUG ''record exists for this alias and porigin: %'', rec.palias_id;
        v_palias_id := rec.palias_id;
    END IF;
    return v_palias_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION get_paliasorigin_palias_id(integer, text) IS 'retrieve the palias_id for a given porigin_id and alias';
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--
-- assign_alias():
--   purpose: create a pseqalias record for the given paliasorigin and pseq entries
--   arguments: porigin_id, alias, pseq_id, ref_pseq_id
--   returns: palias_id
--
CREATE OR REPLACE FUNCTION assign_alias(integer, text, text, integer, integer) RETURNS integer AS '
DECLARE
	v_porigin_id ALIAS FOR $1;
	v_alias ALIAS FOR $2;
	v_descr ALIAS FOR $3;
	v_pseq_id ALIAS FOR $4;
	v_ref_pseq_id ALIAS FOR $5;
	v_palias_id integer;
	rv integer;
	rec record;
BEGIN
	select into v_palias_id ins_paliasorigin( v_porigin_id, v_alias, v_descr );

	-- check whether there is a pseqalias entry for this palias_id and pseq_id.  
	RAISE DEBUG ''select into rec * from pseqalias where porigin_id=% and palias_id=%'',v_porigin_id, v_palias_id;
	select into rec * from pseqalias where palias_id=v_palias_id and isCurrent;

	-- no entry in pseqalias for this palias_id and pseq_id, create new pseqalias entry
	IF not found THEN
		RAISE DEBUG ''insert into pseqalias ( palias_id, pseq_id, ref_pseq_id ) values ( %, %, % )'', v_palias_id, v_pseq_id, v_ref_pseq_id;
		insert into pseqalias ( palias_id, pseq_id, ref_pseq_id ) values ( v_palias_id, v_pseq_id, v_ref_pseq_id );
	-- entry in pseqalias for this palias_id and pseq_id, if the pseq_id parameter is different then in 
	-- the entry, then create a new version.
	ELSE 
		IF v_pseq_id != rec.pseq_id THEN
			RAISE DEBUG ''different pseq_id, update isCurrent and insert new alias'';
			update pseqalias set isCurrent=false where palias_id = v_palias_id and isCurrent;
			insert into pseqalias ( palias_id, pseq_id, ref_pseq_id, version, isCurrent ) values
				( v_palias_id, v_pseq_id, v_ref_pseq_id, rec.version+1, true );
		END IF;
	END IF;
	return v_palias_id;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION assign_alias(integer, text, text, integer, integer) IS 'create a pseqalias record for the given paliasorigin and pseq entries';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- then create a backwardly compatible view (palias)
--
CREATE VIEW palias as select pa.palias_id, pv.pseq_id, pa.porigin_id, pa.alias, pa.descr, pv.ref_pseq_id, pv.added from
paliasorigin pa, pseqalias pv where pv.palias_id=pa.palias_id and isCurrent=true;
GRANT SELECT ON palias TO PUBLIC;
COMMENT ON VIEW palias IS 'backwardly compatible - joins paliasorigin and pseqalias tables';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- create a rule for inserting into palias
--
CREATE OR REPLACE RULE ins_palias AS ON INSERT TO palias DO INSTEAD
(
select assign_alias( NEW.porigin_id, NEW.alias, NEW.descr, NEW.pseq_id, NEW.ref_pseq_id );
)
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- add table constraints after loading the data, creating the indices, and analyzing
--
ALTER TABLE ONLY pseqalias
    ADD CONSTRAINT palias_fk FOREIGN KEY (palias_id) REFERENCES paliasorigin(palias_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE ONLY pseqalias
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pseqalias
    ADD CONSTRAINT ref_pseq_id_exists FOREIGN KEY (ref_pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE NO ACTION;
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--
-- add back a few views that were dropped with the table alterations. Not sure that this are that useful
--

CREATE VIEW v_pseqsummary AS
    SELECT q.pseq_id, o.origin, a.alias, a.descr, q.len, q.seq FROM ((pseq q FULL JOIN palias a ON ((q.pseq_id = a.pseq_id))) LEFT JOIN porigin o ON ((a.porigin_id = o.porigin_id))) ORDER BY q.pseq_id, o.origin, a.alias;
REVOKE ALL ON TABLE v_pseqsummary FROM PUBLIC;
GRANT SELECT ON TABLE v_pseqsummary TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE v_pseqsummary TO loader;

CREATE VIEW v_palias AS
    SELECT palias.pseq_id, porigin.origin, palias.alias, palias.descr FROM palias, porigin WHERE (palias.porigin_id = porigin.porigin_id) ORDER BY palias.pseq_id;
REVOKE ALL ON TABLE v_palias FROM PUBLIC;
GRANT SELECT ON TABLE v_palias TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE v_palias TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- v2thread_cavs(): view combining thread and scop information
--
drop view v_p2thread_cavs;
create view v_p2thread_cavs as SELECT t.pseq_id, b.name, t.raw, t.svm, t.mutation, t.pairwise, t.singleton, t.gap, 
sf.descr as "SCOP Superfamily", fa.descr as "SCOP Family", dm.descr as "SCOP Protein"
FROM (((((p2thread t JOIN p2template b ON ((t.pmodel_id = b.pmodel_id))) JOIN cla px ON ((px.sunid = b.sunid))) 
JOIN des sf ON ((sf.sunid = px.sf))) JOIN des fa ON ((fa.sunid = px.fa))) JOIN des dm ON ((dm.sunid = px.dm))) ORDER BY t.raw ASC;

grant SELECT on v_p2thread_cavs to public;
-- -----------------------------------------------------------------------------
