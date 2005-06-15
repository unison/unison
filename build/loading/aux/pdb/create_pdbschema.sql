-- -----------------------------------------------------------------------------
--
-- NAME: create_pdbschema.sql
-- PURPOSE: sql statements for creating pdbschema tables
--
-- ID: q$Id$
--
-- -----------------------------------------------------------------------------
-- Do everything in the pdb schema
SET search_path = pdb;

DROP TABLE summary cascade;
CREATE TABLE summary (
	pdbid text primary key
		constraint summary_pdbid_length_ck check (length(pdbid) = 4),
	method text,
	resolution decimal,
	title text not null,
	header text,
	source text,
	last_modified date
) WITHOUT OIDS;

GRANT INSERT, UPDATE, DELETE ON summary to loader;
GRANT SELECT ON summary to public;

DROP TABLE chain cascade;
CREATE TABLE chain (
	pdbid text not null,
	chainid char,	
	pdbc text primary key
		constraint chain_pdbc_ck check (pdbc = pdbid || coalesce(chainid,'')),
	name text,
	ec text
) WITHOUT OIDS;

ALTER TABLE chain add constraint chain_pdbid_fkey
   FOREIGN KEY (pdbid) references summary(pdbid) on update cascade on delete cascade;

GRANT INSERT, UPDATE, DELETE ON chain to loader;
GRANT SELECT ON chain to public;

DROP TABLE ligand cascade;
CREATE TABLE ligand (
	pdbid text not null,
	code text not null,
	name text not null,
	formula text not null,
	formula_weight decimal not null,
	synonyms text,
	primary key(pdbid,code)
) WITHOUT OIDS;

ALTER TABLE ligand add constraint ligand_pdbid_fkey
	FOREIGN KEY (pdbid) references summary(pdbid) on update cascade on delete cascade;
GRANT INSERT, UPDATE, DELETE ON ligand to loader;
GRANT SELECT ON ligand to public;

DROP TABLE residue cascade;
CREATE TABLE residue (
	pdbc text not null,
	seq_pos integer not null,
	seq_res char not null,
	atom_res char,
	res_id text,
	primary key(pdbc,seq_pos)
) WITHOUT OIDS;

ALTER TABLE residue add constraint residue_pdbc_fkey
	FOREIGN KEY (pdbc) references chain(pdbc) on update cascade on delete cascade;
CREATE unique index residue_res_seq_idx on residue(pdbc,res_id,seq_pos);
CREATE unique index residue_seq_res_idx on residue(pdbc,seq_pos,res_id);
GRANT INSERT, UPDATE, DELETE ON residue to loader;
GRANT SELECT ON residue to public;

COMMENT ON TABLE residue is 'seqres to atom records correspondence in each pdb chain';
COMMENT ON COLUMN residue.res_id is 'residue identifier, null if missing atoms';
COMMENT ON COLUMN residue.atom_res is 'residue from ATOM records, null if missing atoms';
COMMENT ON COLUMN residue.seq_res is 'residue from SEQRES records';

-- trigger to make sure res_id is null if atom_res is null and vice versa
CREATE OR REPLACE FUNCTION residue_atomres_trigger () RETURNS "trigger" AS '
  DECLARE
  BEGIN

	IF new.atom_res IS null or new.atom_res = '''' THEN
		IF new.res_id IS not null or new.res_id != '''' THEN
			RAISE EXCEPTION ''res_id is not null when atom_res is null for pdbc = % and seqpos = %'',new.pdbc,new.seq_pos;
			RETURN NULL;
		END IF;
	END IF;
	IF new.res_id IS null or new.res_id = '''' THEN
		IF new.atom_res IS not null or new.atom_res != '''' THEN
			RAISE EXCEPTION ''atom_res is not null when res_id is null for pdbc = % and seqpos = %'',new.pdbc,new.seq_pos;
			RETURN NULL;
		END IF;
	END IF;
	RETURN new;

  END;' LANGUAGE plpgsql;

CREATE TRIGGER residue_atomres_trigger BEFORE INSERT OR UPDATE ON residue
        FOR EACH ROW
        EXECUTE PROCEDURE residue_atomres_trigger();
