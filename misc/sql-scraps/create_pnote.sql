-- -----------------------------------------------------------------------------
-- NAME: create_pnote.sql
-- PURPOSE: sql commands to build pnote tables and associated functions
--
-- $Id$
-- -----------------------------------------------------------------------------

CREATE TABLE pnote ( 
	pseq_id integer not null, 
	added timestamp, 
	who text, 
	note text
);
ALTER TABLE pnote 
	ADD constraint pseq_id_exists foreign key (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
CREATE INDEX pnote_pseq_id ON pnote USING btree (pseq_id);
REVOKE ALL ON pnote FROM public;
GRANT SELECT ON pnote TO public;
GRANT INSERT,DELETE,UPDATE ON pnote TO loader;

-- set the added and who fields automatically
CREATE OR REPLACE FUNCTION pnote_iu_trigger () RETURNS "trigger" AS '
  DECLARE
  BEGIN
		new.who := current_user;
		new.added := now();
    RETURN new;
  END; '
    LANGUAGE plpgsql;
CREATE TRIGGER pnote_iu_trigger BEFORE INSERT OR UPDATE ON pnote
	FOR EACH ROW
	EXECUTE PROCEDURE pnote_iu_trigger ();
