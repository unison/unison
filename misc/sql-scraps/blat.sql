--
-- TOC entry 154 (OID 35884438)
-- Name: genome; Type: TABLE; Schema: unison; Owner: unison
--

CREATE TABLE genasm (
    genasm_id serial NOT NULL,
    tax_id integer NOT NULL,
    name text NOT NULL,
    url text,
		released timestamp without time zone DEFAULT now() NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE genasm IS 'genome and assembly';
COMMENT ON COLUMN genasm.name IS 'genome assembly name (e.g. NHGD-34)';

ALTER TABLE ONLY genasm
    ADD CONSTRAINT genasm_pkey PRIMARY KEY (genasm_id);
ALTER TABLE ONLY genasm
    ADD CONSTRAINT tax_id_exists FOREIGN KEY (tax_id) REFERENCES tax.spspec(tax_id);

REVOKE ALL ON TABLE genasm FROM PUBLIC;
GRANT SELECT ON TABLE genasm TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE genasm TO loader;


--
-- TOC entry 277 (OID 35884758)
-- Name: plocus; Type: TABLE; Schema: unison; Owner: unison
--
CREATE TABLE p2dblataln (
		p2dblataln_id serial NOT NULL,
    genasm_id integer NOT NULL,
    pseq_id integer NOT NULL,
    chr text NOT NULL,
		plus_strand boolean NOT NULL,
		ident integer NOT NULL,
		qgap_cnt integer NOT NULL,
		qgap_bases integer NOT NULL,
		tgap_cnt integer NOT NULL,
		tgap_bases integer NOT NULL
) WITHOUT OIDS;
COMMENT ON TABLE p2dblataln IS 'protein to dna BLAT alignments - groups of BLAT HSPs';
COMMENT ON COLUMN p2dblataln.qgap_cnt IS 'number of query gaps';
COMMENT ON COLUMN p2dblataln.qgap_bases IS 'number of total residues in query gaps';
COMMENT ON COLUMN p2dblataln.tgap_cnt IS 'number of template gaps';
COMMENT ON COLUMN p2dblataln.tgap_bases IS 'number of total residues in template gaps';

ALTER TABLE ONLY p2dblataln
    ADD CONSTRAINT p2dblataln_pkey PRIMARY KEY (p2dblataln_id);
ALTER TABLE ONLY p2dblataln
    ADD CONSTRAINT genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id);
ALTER TABLE ONLY p2dblataln
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id);

REVOKE ALL ON TABLE p2dblataln FROM PUBLIC;
GRANT SELECT ON TABLE p2dblataln TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE p2dblataln TO loader;


CREATE TABLE p2dblathsp (
    p2dblataln_id integer NOT NULL,
    pstart integer NOT NULL,
    pstop integer NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    ident integer NOT NULL,
) WITHOUT OIDS;
COMMENT ON TABLE p2dblathsp IS 'protein to dna BLAT HSPs';
COMMENT ON COLUMN p2dblathsp.pstart IS 'start of HSP on protein (1-based)';
COMMENT ON COLUMN p2dblathsp.pstop IS 'stop of HSP on protein (1-based)';
COMMENT ON COLUMN p2dblathsp.tstart IS 'start of HSP on genome (1-based, +1 frame, gstop > gstart)';
COMMENT ON COLUMN p2dblathsp.tstop IS 'stop of HSP on genome (1-based, +1 frame, gstop > gstart)';

ALTER TABLE ONLY p2dblathsp
    ADD CONSTRAINT p2dblataln_id_exists FOREIGN KEY (p2dblataln_id) REFERENCES p2dblataln(p2dblataln_id);

REVOKE ALL ON TABLE p2dblathsp FROM PUBLIC;
GRANT SELECT ON TABLE p2dblathsp TO PUBLIC;
GRANT INSERT,UPDATE,DELETE ON TABLE p2dblathsp TO loader;
