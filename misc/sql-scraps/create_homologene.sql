-- -----------------------------------------------------------------------------
-- NAME: create_homologene.sql
-- PURPOSE: sql commands to build homologene tables and associated functions
--
-- $Id: create_homologene.sql,v 1.1 2004/04/16 20:57:15 cavs Exp $
-- -----------------------------------------------------------------------------

CREATE TABLE homologene (
    hid integer NOT NULL,
    tax_id integer NOT NULL,
    gene_id integer NOT NULL,
    gene_symbol text NOT NULL,
    gi text NOT NULL,
    acc text NOT NULL,
    pseq_id integer NOT NULL
);
COMMENT ON TABLE homologene IS 'table to store homologene associations';

REVOKE ALL ON TABLE homologene FROM PUBLIC;
GRANT SELECT ON TABLE homologene TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE homologene TO loader;

CREATE UNIQUE INDEX homologene_unq ON homologene USING btree (hid, acc);
ALTER TABLE ONLY homologene
    ADD CONSTRAINT tax_id_exists FOREIGN KEY (tax_id) REFERENCES tax.spspec(tax_id) ON UPDATE CASCADE ON DELETE CASCADE; 
ALTER TABLE ONLY homologene
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE FUNCTION ortholog(integer, integer, integer) RETURNS integer
    AS '
DECLARE
  v_pseq_id ALIAS FOR $1;
  v_tax_id_from ALIAS FOR $2;
  v_tax_id_to ALIAS FOR $3;
  rv integer;
BEGIN
  SELECT b.pseq_id INTO rv FROM homologene a, homologene b WHERE
    a.pseq_id=v_pseq_id AND a.tax_id=v_tax_id_from AND b.hid=a.hid AND
    b.pseq_id!=a.pseq_id AND b.tax_id=v_tax_id_to;
  return rv;
END;'
    LANGUAGE plpgsql;
COMMENT ON FUNCTION ortholog(integer, integer, integer) IS 'returns ortholog pseq_id given pseq_id, tax_id of the given pseq_id, and tax_id of the desired pseq_id';


