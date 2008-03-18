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
	last_modified date,
	md5 character(32),
	r_factor decimal,
	r_free decimal
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

DROP TABLE descriptor_origin;
CREATE TABLE descriptor_origin (
	descriptor_origin_id serial primary key,
	type text not null,
	origin text not null,
	version text
) WITHOUT OIDS;

alter sequence descriptor_origin_descriptor_origin_id_seq MINVALUE 0;
CREATE unique index descriptor_origin_tov_idx on descriptor_origin(type,origin,version);

GRANT SELECT ON descriptor_origin to public;

DROP TABLE ligand cascade;
CREATE TABLE ligand (
	ligand_id text not null,
	formula text not null,
	formula_weight decimal not null,
	last_modified date not null,
	formal_charge integer not null,
	type text not null,
	primary key(ligand_id)
) WITHOUT OIDS;

GRANT INSERT, UPDATE, DELETE ON ligand to loader;
GRANT SELECT ON ligand to public;

DROP TABLE ligand_atoms cascade;
CREATE TABLE ligand_atoms (
	atom_id text not null,
	ligand_id text not null,
	type_symbol text not null,
	alt_atom_id text not null,
	formal_charge integer not null,
	aromatic boolean not null,
	leaving_atom boolean not null,
	ordinal integer not null,
	stereo_config char not null,
	primary key(atom_id,ligand_id)
)WITHOUT OIDS;


ALTER TABLE ligand_atoms add constraint ligand_atoms_ligand_id_fkey
   FOREIGN KEY (ligand_id) references ligand(ligand_id) on update cascade on delete cascade;

GRANT INSERT, UPDATE, DELETE ON ligand_atoms to loader;
GRANT SELECT ON ligand_atoms to public;

DROP TABLE ligand_bonds cascade;
CREATE TABLE ligand_bonds (
	atom_id_1 text not null,
	atom_id_2 text not null,
	ligand_id text not null,
	bond_order text not null,
	ordinal integer not null,
	aromatic boolean not null,
	stereo_config char not null,
	primary key(atom_id_1,atom_id_2,ligand_id)
)WITHOUT OIDS;


ALTER TABLE ligand_bonds add constraint ligand_bonds_ligand_id_atom_id_1_fkey
   FOREIGN KEY (ligand_id,atom_id_1) references ligand_atoms(ligand_id,atom_id) on update cascade on delete cascade;
ALTER TABLE ligand_bonds add constraint ligand_bonds_ligand_id_atom_id_2_fkey
   FOREIGN KEY (ligand_id,atom_id_2) references ligand_atoms(ligand_id,atom_id) on update cascade on delete cascade;


GRANT INSERT, UPDATE, DELETE ON ligand_bonds to loader;
GRANT SELECT ON ligand_bonds to public;


DROP TABLE ligand_descriptor;
CREATE TABLE ligand_descriptors (
	ligand_id text not null,
	descriptor_origin_id integer not null,
	descriptor text not null
)WITHOUT OIDS;


ALTER TABLE ligand_descriptors add constraint ligand_descriptors_ligand_id_fkey
   FOREIGN KEY (ligand_id) references ligand(ligand_id) on update cascade on delete cascade;

ALTER TABLE ligand_descriptors add constraint ligand_descriptors_origin_id_fkey
   FOREIGN KEY (descriptor_origin_id) references descriptor_origin(descriptor_origin_id) on update cascade on delete cascade;

GRANT INSERT, UPDATE, DELETE ON ligand_descriptor to loader;
GRANT SELECT ON ligand_descriptors to public;

DROP TABLE pdb_ligand;
CREATE TABLE pdb_ligand (
	pdb_id text not null,
	ligand_id text not null,
	primary key(pdb_id,ligand_id)
) WITHOUT OIDS;

ALTER TABLE pdb.pdb_ligand add constraint pdb_ligand_pdbid_fkey
	FOREIGN KEY (pdbid) references summary(pdbid) on update cascade on delete cascade;
ALTER TABLE pdb_ligand add constraint pdb_ligand_id_fkey
	FOREIGN KEY (ligand_id) references ligand(ligand_id) on update cascade on delete set null;
GRANT INSERT, UPDATE, DELETE ON pdb_ligand to loader;
GRANT SELECT ON pdb_ligand to public;

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

create or replace function descriptor_origin_id(text,text,text) returns integer AS 'DECLARE V_id integer; BEGIN select into V_id descriptor_origin_id from descriptor_origin where type = $1 and upper(origin) = upper($2) and version = $3; IF NOT FOUND THEN RAISE WARNING ''descriptor type ''''%'''' from origin ''''%'''' version ''''%'''' not found'', $1,$2,$3; RETURN NULL; END IF; return V_id; END;' language 'plpgsql';

create or replace function descriptor_origin_id(text, text) returns setof integer AS '
 DECLARE 
	V_id integer;
 BEGIN 
	FOR V_id IN select descriptor_origin_id from descriptor_origin where type = $1 and upper(origin) = upper($2) LOOP 
		return NEXT V_id; 
	END LOOP;
 	RETURN; 
 END;' language 'plpgsql';

create or replace function descriptor_origin_id(text) returns setof integer AS '
 DECLARE 
	V_id integer;
 BEGIN 
	FOR V_id IN select descriptor_origin_id from descriptor_origin where type = $1 LOOP 
		return NEXT V_id; 
	END LOOP;
 	RETURN; 
 END;' language 'plpgsql';



CREATE OR REPLACE FUNCTION descriptor_origin_si_descriptor_origin_id(text,text,text) returns integer AS '
DECLARE
	t alias for $1;
        s alias for $2;                         -- origin
	v alias for $3;
        rv integer;
BEGIN
        select into rv descriptor_origin_id from descriptor_origin where type = t and upper(origin) = upper(s) and version = v;
        if found then return rv; end if;
        insert into descriptor_origin(type,origin,version) values (t,s,v);
        select into rv descriptor_origin_id from descriptor_origin where type = t and origin = s and version = v;
        return rv;
END;' language  plpgsql;
comment on function descriptor_origin_si_descriptor_origin_id(text,text,text) is 'select/insert a descriptor_origin_id from descriptor_origin, returns decsriptor_origin_id';

grant execute on function descriptor_origin_id(text,text,text) to PUBLIC;
grant execute on function descriptor_origin_id(text,text) to PUBLIC;
grant execute on function descriptor_origin_id(text) to PUBLIC;

create unique index ligand_descriptor_ld_origin_id ON pdb.ligand_descriptors USING btree(ligand_id,descriptor_origin_id) where descriptor_origin_id != descriptor_origin_id('synonym','PDB',NULL);

create or replace view pdb.ligand_smiles_oe_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles' and (o.origin='OpenEye OEToolkits' or o.origin='OpenEye/OEToolkits');

create or replace view pdb.ligand_smiles_canon_oe_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles_canonical' and (o.origin='OpenEye OEToolkits' or o.origin='OpenEye/OEToolkits');

create or replace view pdb.ligand_smiles_cactvs_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles' and o.origin='CACTVS';

create or replace view pdb.ligand_smiles_canon_cactvs_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles_canonical' and o.origin='CACTVS';

create or replace view pdb.ligand_smiles_acdlabs_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles' and o.origin='ACDLabs';

create or replace view pdb.ligand_smiles_all_oe_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where (o.origin='OpenEye OEToolkits' or o.origin='OpenEye/OEToolkits')  and (o.type='smiles' or o.type='smiles_canonical');

create or replace view pdb.ligand_smiles_all_cactvs_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.origin='CACTVS' and (o.type='smiles' or o.type='smiles_canonical');

create or replace view pdb.ligand_names_all_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type = 'name' or o.type='synonym' or o.type='systematic name';

create or replace view pdb.ligand_inchi_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='inchi';

create or replace view pdb.ligand_smiles_all_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles' or o.type='smiles_canonical';

create or replace view pdb.ligand_smiles_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles';

create or replace view pdb.ligand_smiles_canon_v as select d.ligand_id,d.descriptor from ligand_descriptors d join descriptor_origin o on o.descriptor_origin_id=d.descriptor_origin_id where o.type='smiles_canonical';

