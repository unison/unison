-- -----------------------------------------------------------------------------
--
-- NAME: create_ptmschema.sql
-- PURPOSE: sql statements for creating ptm tables
--
-- ID: q$Id$
--
-- -----------------------------------------------------------------------------
BEGIN;
-- Do everything in the unison_aux schema
SET search_path = unison_aux;

--DROP TABLE ptm_type cascade;
create table ptm_type (
	ptm_type_id serial PRIMARY KEY,
	origin_id integer NOT NULL,
	ptm_type text NOT NULL,
	acc text,
	target text NOT NULL,
	pos_mod_aa text,
	pos_mod_pp text,
	correction_formula text,
	mass_diff_isotopic float,
	mass_diff_avg float,
	cellular_location text,
	keyword text
);

CREATE unique index ptm_type_origin_ptm_type_unq_idx on ptm_type(origin_id,ptm_type);

GRANT SELECT ON ptm_type to PUBLIC;

--DROP TABLE ptm cascade;
create table ptm (
	ptm_type_id integer NOT NULL,
	alias text NOT NULL,
	descr text,
	start integer NOT NULL,
	stop integer,
	expt boolean default 'f' NOT NULL
);

GRANT SELECT ON ptm to public;

ALTER TABLE ptm add constraint ptm_ptm_type_id_fkey
   FOREIGN KEY (ptm_type_id) references ptm_type(ptm_type_id) on update cascade on delete cascade;

CREATE index ptm_seq_alias on ptm(alias);

create or replace function unison_aux.ptm_type_id(text) returns integer AS '
DECLARE V_id integer; 
BEGIN 
	select into V_id ptm_type_id from unison_aux.ptm_type where ptm_type = $1; 
	IF NOT FOUND THEN RAISE WARNING ''ptm type ''''%'''' not found'', $1; 
		RETURN NULL; 
	END IF; 
	return V_id; 
END;' 
language 'plpgsql';

	
COMMIT;
