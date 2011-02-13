--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = pdb, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: atom; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE atom (
    atom_name character(4),
    atom_coord real[],
    b_factor real,
    pdbid text
);


ALTER TABLE pdb.atom OWNER TO unison;

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = pdb, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: protein_atom; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE protein_atom (
    res_id text,
    seq_pos integer,
    chain character(1)
)
INHERITS (atom);


ALTER TABLE pdb.protein_atom OWNER TO unison;

--
-- Name: protein_atom_pdb_chain_pos_idx; Type: INDEX; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE INDEX protein_atom_pdb_chain_pos_idx ON protein_atom USING btree (pdbid, chain, seq_pos);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = pdb, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ligand_atom; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE ligand_atom (
    ligand_id text
)
INHERITS (atom);


ALTER TABLE pdb.ligand_atom OWNER TO unison;

--
-- Name: ligand_atom; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_atom FROM PUBLIC;
REVOKE ALL ON TABLE ligand_atom FROM unison;
GRANT ALL ON TABLE ligand_atom TO unison;
GRANT SELECT ON TABLE ligand_atom TO PUBLIC;


--
-- PostgreSQL database dump complete
--

