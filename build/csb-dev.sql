--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: go; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA go;


ALTER SCHEMA go OWNER TO unison;

--
-- Name: gong; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA gong;


ALTER SCHEMA gong OWNER TO unison;

--
-- Name: SCHEMA gong; Type: COMMENT; Schema: -; Owner: unison
--

COMMENT ON SCHEMA gong IS 'Gene Ontology next generation -- simplified GO access';


--
-- Name: marray; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA marray;


ALTER SCHEMA marray OWNER TO unison;

--
-- Name: ncbi; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA ncbi;


ALTER SCHEMA ncbi OWNER TO unison;

--
-- Name: pdb; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA pdb;


ALTER SCHEMA pdb OWNER TO unison;

--
-- Name: pgutils; Type: SCHEMA; Schema: -; Owner: rkh
--

CREATE SCHEMA pgutils;


ALTER SCHEMA pgutils OWNER TO rkh;

--
-- Name: scop; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA scop;


ALTER SCHEMA scop OWNER TO unison;

--
-- Name: SCHEMA scop; Type: COMMENT; Schema: -; Owner: unison
--

COMMENT ON SCHEMA scop IS 'Structural Classification of Proteins v1.61 (http://scop.berkeley.edu/)';


--
-- Name: sst; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA sst;


ALTER SCHEMA sst OWNER TO unison;

--
-- Name: tax; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA tax;


ALTER SCHEMA tax OWNER TO unison;

--
-- Name: taxonomy; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA taxonomy;


ALTER SCHEMA taxonomy OWNER TO unison;

--
-- Name: unison; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA unison;


ALTER SCHEMA unison OWNER TO unison;

--
-- Name: SCHEMA unison; Type: COMMENT; Schema: -; Owner: unison
--

COMMENT ON SCHEMA unison IS 'integrated proteomic annotation database';


--
-- Name: unison_aux; Type: SCHEMA; Schema: -; Owner: unison
--

CREATE SCHEMA unison_aux;


ALTER SCHEMA unison_aux OWNER TO unison;

SET search_path = unison, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: p2gblataln; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE p2gblataln (
    p2gblataln_id integer NOT NULL,
    hsp_str text NOT NULL,
    ident integer NOT NULL,
    pgap_cnt integer NOT NULL,
    pgap_bases integer NOT NULL,
    ggap_cnt integer NOT NULL,
    ggap_bases integer NOT NULL
);


ALTER TABLE unison.p2gblataln OWNER TO unison;

--
-- Name: TABLE p2gblataln; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE p2gblataln IS 'protein to dna BLAT alignments - groups of BLAT HSPs';


--
-- Name: COLUMN p2gblataln.hsp_str; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln.hsp_str IS 'serialized version of the p2gblathsp_ids in the alignment';


--
-- Name: COLUMN p2gblataln.ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln.ident IS 'number of identities in the alignment';


--
-- Name: COLUMN p2gblataln.pgap_cnt; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln.pgap_cnt IS 'number of query gaps';


--
-- Name: COLUMN p2gblataln.pgap_bases; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln.pgap_bases IS 'number of total residues in query gaps';


--
-- Name: COLUMN p2gblataln.ggap_cnt; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln.ggap_cnt IS 'number of template gaps';


--
-- Name: COLUMN p2gblataln.ggap_bases; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln.ggap_bases IS 'number of total residues in template gaps';


--
-- Name: p2gblatalnhsp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE p2gblatalnhsp (
    p2gblataln_id integer NOT NULL,
    p2gblathsp_id integer NOT NULL
);


ALTER TABLE unison.p2gblatalnhsp OWNER TO unison;

--
-- Name: TABLE p2gblatalnhsp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE p2gblatalnhsp IS 'groups protein-to-genome BLAT HSPs into alignments';


--
-- Name: p2gblathsp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE p2gblathsp (
    p2gblathsp_id integer NOT NULL,
    genasm_id integer NOT NULL,
    chr text NOT NULL,
    plus_strand boolean NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    pseq_id integer NOT NULL,
    pstart integer NOT NULL,
    pstop integer NOT NULL
);


ALTER TABLE unison.p2gblathsp OWNER TO unison;

--
-- Name: TABLE p2gblathsp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE p2gblathsp IS 'protein to dna BLAT HSPs';


--
-- Name: COLUMN p2gblathsp.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN p2gblathsp.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.chr IS 'chromosome (e.g. 1..22,M,U,X,Y for homo sapiens)';


--
-- Name: COLUMN p2gblathsp.plus_strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.plus_strand IS 'located on genomic plus strand (t/f)';


--
-- Name: COLUMN p2gblathsp.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.gstart IS 'start of HSP on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: COLUMN p2gblathsp.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.gstop IS 'stop of HSP on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: COLUMN p2gblathsp.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN p2gblathsp.pstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.pstart IS 'start of HSP on protein (1-based)';


--
-- Name: COLUMN p2gblathsp.pstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblathsp.pstop IS 'stop of HSP on protein (1-based)';


--
-- Name: pseq; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pseq (
    pseq_id integer NOT NULL,
    seq text NOT NULL,
    len integer NOT NULL,
    md5 character(32) NOT NULL,
    added timestamp with time zone DEFAULT timenow() NOT NULL
);


ALTER TABLE unison.pseq OWNER TO unison;

--
-- Name: TABLE pseq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pseq IS 'table of unique protein sequences';


--
-- Name: COLUMN pseq.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq.pseq_id IS 'unique id for sequence; default is serial number';


--
-- Name: COLUMN pseq.seq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq.seq IS 'protein sequence';


--
-- Name: COLUMN pseq.len; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq.len IS 'sequence length, computed automatically';


--
-- Name: COLUMN pseq.md5; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq.md5 IS 'md5 for sequence, computed automatically';


--
-- Name: COLUMN pseq.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq.added IS 'timestamp at which sequence was added (automatic)';


--
-- Name: _legacy_best_alias(integer, boolean); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _legacy_best_alias(integer, boolean) RETURNS text
    AS $_$
BEGIN
	perform warn('best_alias(integer,boolean) is deprecated; use best_alias(integer) instead.');
	return best_alias($1);
END;
$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison._legacy_best_alias(integer, boolean) OWNER TO unison;

--
-- Name: FUNCTION _legacy_best_alias(integer, boolean); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION _legacy_best_alias(integer, boolean) IS 'same as best_OA';


--
-- Name: pftype_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pftype_id(text) RETURNS integer
    AS $_$DECLARE V_id integer; BEGIN select into V_id pftype_id from pftype where upper(name)=upper($1); IF NOT FOUND THEN RAISE WARNING 'pftype ''%'' not found', $1; RETURN NULL; END IF; return V_id; END;$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.pftype_id(text) OWNER TO unison;

--
-- Name: pfeature; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfeature (
    pfeature_id integer NOT NULL,
    pseq_id integer NOT NULL,
    pftype_id integer NOT NULL,
    start integer NOT NULL,
    stop integer NOT NULL,
    params_id integer NOT NULL
);


ALTER TABLE unison.pfeature OWNER TO unison;

--
-- Name: TABLE pfeature; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfeature IS 'parent table of all features; inherited by "subclass" feature tables';


--
-- Name: COLUMN pfeature.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfeature.pfeature_id IS 'unique identifier for this feature';


--
-- Name: COLUMN pfeature.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfeature.pseq_id IS 'pseq_id on which this feature applies';


--
-- Name: COLUMN pfeature.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfeature.pftype_id IS 'type of feature, from pftype table';


--
-- Name: COLUMN pfeature.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfeature.start IS 'starting position (1-based) for feature';


--
-- Name: COLUMN pfeature.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfeature.stop IS 'ending position (1-based) for feature';


--
-- Name: COLUMN pfeature.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfeature.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: pfeature_pfeature_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pfeature_pfeature_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pfeature_pfeature_id_seq OWNER TO unison;

--
-- Name: pfeature_pfeature_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pfeature_pfeature_id_seq OWNED BY pfeature.pfeature_id;


--
-- Name: palignment; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE palignment (
    start integer,
    stop integer,
    params_id integer,
    pmodel_id integer NOT NULL,
    mstart smallint NOT NULL,
    mstop smallint NOT NULL,
    ident smallint,
    sim smallint,
    gaps smallint NOT NULL,
    qgaps smallint,
    tgaps smallint,
    score integer NOT NULL,
    eval double precision NOT NULL,
    len smallint
)
INHERITS (pfeature);


ALTER TABLE unison.palignment OWNER TO unison;

--
-- Name: TABLE palignment; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE palignment IS 'superclass table of sequence-model alignments';


--
-- Name: COLUMN palignment.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN palignment.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN palignment.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN palignment.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN palignment.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN palignment.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN palignment.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN palignment.mstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.mstart IS 'start of match /in model/';


--
-- Name: COLUMN palignment.mstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.mstop IS 'stop of match /in model/';


--
-- Name: COLUMN palignment.qgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.qgaps IS 'number of gaps in query sequence';


--
-- Name: COLUMN palignment.tgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.tgaps IS 'number of gaps in target sequence';


--
-- Name: COLUMN palignment.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.score IS 'algorithm-specific score';


--
-- Name: COLUMN palignment.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.eval IS 'expectation value';


--
-- Name: COLUMN palignment.len; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palignment.len IS 'length of alignment, including gaps';


--
-- Name: pahmm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pahmm (
    pftype_id integer DEFAULT pftype_id('HMM'::text),
    qgaps smallint NOT NULL,
    tgaps smallint NOT NULL
)
INHERITS (palignment);


ALTER TABLE unison.pahmm OWNER TO unison;

--
-- Name: TABLE pahmm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pahmm IS 'HMM alignments; inherits palignment';


--
-- Name: COLUMN pahmm.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.pfeature_id IS 'unique feature id';


--
-- Name: COLUMN pahmm.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pahmm.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pahmm.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pahmm.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pahmm.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pahmm.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pahmm.mstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.mstart IS 'start of match /in model/';


--
-- Name: COLUMN pahmm.mstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.mstop IS 'stop of match /in model/';


--
-- Name: COLUMN pahmm.qgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.qgaps IS 'number of gaps in query sequence';


--
-- Name: COLUMN pahmm.tgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.tgaps IS 'number of gaps in target sequence';


--
-- Name: COLUMN pahmm.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.score IS '(single) domain score; this is not the "sequence classification score"';


--
-- Name: COLUMN pahmm.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pahmm.eval IS 'expecation eval (from domain score)';


--
-- Name: pfregexp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfregexp (
    pftype_id integer DEFAULT pftype_id('regexp'::text),
    start integer,
    stop integer,
    params_id integer,
    pmodel_id integer NOT NULL
)
INHERITS (pfeature);


ALTER TABLE unison.pfregexp OWNER TO unison;

--
-- Name: TABLE pfregexp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfregexp IS 'regular expression features based on pmregexp motifs';


--
-- Name: COLUMN pfregexp.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfregexp.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfregexp.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfregexp.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfregexp.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfregexp.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfregexp.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfregexp.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfregexp.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfregexp.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfregexp.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfregexp.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfregexp.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfregexp.pmodel_id IS 'unique protein model identifier';


--
-- Name: pftmdetect; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pftmdetect (
    pftype_id integer DEFAULT pftype_id('tmdetect'::text),
    prob real NOT NULL,
    type character(1) NOT NULL,
    CONSTRAINT pftmdetect_type_is_m_n_or_s CHECK ((((type = 'M'::bpchar) OR (type = 'N'::bpchar)) OR (type = 'S'::bpchar)))
)
INHERITS (pfeature);


ALTER TABLE unison.pftmdetect OWNER TO unison;

--
-- Name: TABLE pftmdetect; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pftmdetect IS 'signal and transmembrane predictions';


--
-- Name: COLUMN pftmdetect.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmdetect.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pftmdetect.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmdetect.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pftmdetect.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmdetect.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pftmdetect.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmdetect.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pftmdetect.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmdetect.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pftmdetect.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmdetect.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: paprospect; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE paprospect (
    pftype_id integer DEFAULT pftype_id('Prospect'::text),
    start integer,
    stop integer,
    params_id integer,
    pmodel_id integer NOT NULL,
    nident integer NOT NULL,
    nalign integer NOT NULL,
    raw real NOT NULL,
    mutation real NOT NULL,
    singleton real NOT NULL,
    pairwise real NOT NULL,
    gap real NOT NULL,
    ssfit real NOT NULL,
    zscore real,
    svm real NOT NULL,
    rgyr real NOT NULL
)
INHERITS (pfeature);


ALTER TABLE unison.paprospect OWNER TO unison;

--
-- Name: TABLE paprospect; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE paprospect IS 'single Prospect threading alignment (unique <pseq_id,params_id,pmprospect pmodel_id>)';


--
-- Name: COLUMN paprospect.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN paprospect.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN paprospect.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN paprospect.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN paprospect.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN paprospect.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN paprospect.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN paprospect.nident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.nident IS 'number of identical residues';


--
-- Name: COLUMN paprospect.nalign; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.nalign IS 'number of aligned residues';


--
-- Name: COLUMN paprospect.raw; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.raw IS 'Prospect ''raw'' score ';


--
-- Name: COLUMN paprospect.singleton; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.singleton IS 'Prospect ''singleton'' score ';


--
-- Name: COLUMN paprospect.ssfit; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.ssfit IS 'Prospect secondary structure compatibility score ';


--
-- Name: COLUMN paprospect.zscore; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.zscore IS 'Prospect Z-score based on 50 iterations';


--
-- Name: COLUMN paprospect.svm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect.svm IS 'Prospect ''svm'' score ';


--
-- Name: pmsm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmsm (
    pmodelset_id integer NOT NULL,
    pmodel_id integer NOT NULL
);


ALTER TABLE unison.pmsm OWNER TO unison;

--
-- Name: TABLE pmsm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmsm IS '"protein modelset model" -- defines membership of models in sets';


--
-- Name: COLUMN pmsm.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmsm.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm.pmodel_id IS 'unique protein model identifier';


--
-- Name: pmsm_pmprospect; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmsm_pmprospect (
)
INHERITS (pmsm);


ALTER TABLE unison.pmsm_pmprospect OWNER TO unison;

--
-- Name: TABLE pmsm_pmprospect; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmsm_pmprospect IS 'pmsm for pmprospect (inherits from pmsm, which see)';


--
-- Name: COLUMN pmsm_pmprospect.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmprospect.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmsm_pmprospect.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmprospect.pmodel_id IS 'unique protein model identifier';


SET search_path = scop, pg_catalog;

--
-- Name: des; Type: TABLE; Schema: scop; Owner: unison; Tablespace: 
--

CREATE TABLE des (
    sunid integer NOT NULL,
    level text NOT NULL,
    sccs text NOT NULL,
    sname text,
    descr text NOT NULL
);


ALTER TABLE scop.des OWNER TO unison;

--
-- Name: TABLE des; Type: COMMENT; Schema: scop; Owner: unison
--

COMMENT ON TABLE des IS 'SCOP domain descriptions (http://scop.berkeley.edu/)';


SET search_path = unison, pg_catalog;

--
-- Name: pmprospect_scop_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmprospect_scop_mv (
    pmodel_id integer,
    sunid integer
);


ALTER TABLE unison.pmprospect_scop_mv OWNER TO unison;

--
-- Name: TABLE pmprospect_scop_mv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmprospect_scop_mv IS 'materialized view of Prospect model <-> scop sunid mapping';


--
-- Name: COLUMN pmprospect_scop_mv.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect_scop_mv.pmodel_id IS 'unique protein model identifier';


--
-- Name: pmodel; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmodel (
    pmodel_id integer NOT NULL,
    origin_id integer,
    acc text,
    added timestamp with time zone DEFAULT timenow(),
    descr text,
    is_current boolean DEFAULT true
);


ALTER TABLE unison.pmodel OWNER TO unison;

--
-- Name: TABLE pmodel; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmodel IS 'generic protein model information';


--
-- Name: COLUMN pmodel.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodel.pmodel_id IS 'unique id for protein model';


--
-- Name: COLUMN pmodel.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodel.origin_id IS 'origin of protein model';


--
-- Name: COLUMN pmodel.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodel.acc IS 'protein model name (perhaps an identifier in origin)';


--
-- Name: COLUMN pmodel.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodel.added IS 'when this data was created';


--
-- Name: COLUMN pmodel.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodel.descr IS 'model description';


--
-- Name: pmodel_pmodel_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pmodel_pmodel_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pmodel_pmodel_id_seq OWNER TO unison;

--
-- Name: pmodel_pmodel_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pmodel_pmodel_id_seq OWNED BY pmodel.pmodel_id;


--
-- Name: pmhmm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmhmm (
    origin_id integer NOT NULL,
    acc text NOT NULL,
    descr text NOT NULL,
    name text NOT NULL,
    len smallint NOT NULL,
    nseq smallint NOT NULL,
    cksum smallint NOT NULL,
    ga_seq real,
    ga_dom real,
    tc_seq real,
    tc_dom real,
    nc_seq real,
    nc_dom real
)
INHERITS (pmodel);


ALTER TABLE unison.pmhmm OWNER TO unison;

--
-- Name: TABLE pmhmm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmhmm IS 'hidden Markov models (mostly from Pfam); inherts pmodel';


--
-- Name: COLUMN pmhmm.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pmhmm.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN pmhmm.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.acc IS 'model accession from source database';


--
-- Name: COLUMN pmhmm.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.added IS 'when this data was created';


--
-- Name: COLUMN pmhmm.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.descr IS 'HMM description';


--
-- Name: COLUMN pmhmm.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.name IS 'HMM name';


--
-- Name: COLUMN pmhmm.nseq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.nseq IS 'number of sequences in alignment used to build HMM';


--
-- Name: COLUMN pmhmm.ga_seq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.ga_seq IS 'sequence gathering cutoff used to build full alignment; expect no FP above this';


--
-- Name: COLUMN pmhmm.ga_dom; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.ga_dom IS 'domain gathering cutoff used to build full alignment; expect no FP above this';


--
-- Name: COLUMN pmhmm.tc_seq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.tc_seq IS 'trusted cutoff for sequence -- lowest sequence score of sequence in full alignment';


--
-- Name: COLUMN pmhmm.tc_dom; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.tc_dom IS 'trusted cutoff for domain -- lowest domain score of sequence in full alignment';


--
-- Name: COLUMN pmhmm.nc_seq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.nc_seq IS 'noise cutoff for sequence -- highest sequence score of sequence NOT in full alignment';


--
-- Name: COLUMN pmhmm.nc_dom; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmhmm.nc_dom IS 'noise cutoff for domain -- highest domain score of sequence NOT in full alignment';


--
-- Name: pseqset; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pseqset (
    pset_id integer,
    pseq_id integer
);


ALTER TABLE unison.pseqset OWNER TO unison;

--
-- Name: TABLE pseqset; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pseqset IS 'links pset and pseq instances (many-many)';


--
-- Name: COLUMN pseqset.pset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqset.pset_id IS 'pset.pset_id';


--
-- Name: COLUMN pseqset.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqset.pseq_id IS 'pseq.pseq_id';


--
-- Name: pset; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pset (
    pset_id integer NOT NULL,
    name text NOT NULL,
    descr text,
    def text
);


ALTER TABLE unison.pset OWNER TO unison;

--
-- Name: TABLE pset; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pset IS 'set name and id for sets of sequences';


--
-- Name: COLUMN pset.pset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset.pset_id IS 'unique identifier for set; <0 are for special uses';


--
-- Name: COLUMN pset.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset.name IS 'unique name for this sequence set';


--
-- Name: COLUMN pset.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset.descr IS 'freetext description of this set';


--
-- Name: paliasorigin; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE paliasorigin (
    palias_id integer NOT NULL,
    origin_id integer NOT NULL,
    alias text NOT NULL,
    descr text,
    tax_id integer,
    added timestamp with time zone DEFAULT timenow() NOT NULL
);
ALTER TABLE ONLY paliasorigin ALTER COLUMN alias SET STATISTICS 1000;


ALTER TABLE unison.paliasorigin OWNER TO unison;

--
-- Name: TABLE paliasorigin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE paliasorigin IS 'alias (names) given by a particular origin';


--
-- Name: COLUMN paliasorigin.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paliasorigin.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN paliasorigin.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paliasorigin.origin_id IS 'origin.origin_id for this alias';


--
-- Name: COLUMN paliasorigin.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paliasorigin.alias IS 'alias text; this should be the unique identifier (may be more than 1) for this sequence from this origin';


--
-- Name: COLUMN paliasorigin.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paliasorigin.descr IS 'descriptive text, typically derived from the corresponding origin';


--
-- Name: COLUMN paliasorigin.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paliasorigin.tax_id IS 'swissprot species id; see tax.spspec';


--
-- Name: COLUMN paliasorigin.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paliasorigin.added IS 'date that this alias was created';


--
-- Name: pseqalias; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pseqalias (
    palias_id integer NOT NULL,
    pseq_id integer NOT NULL,
    ref_pseq_id integer,
    added timestamp with time zone DEFAULT timenow() NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    is_current boolean DEFAULT true NOT NULL
);


ALTER TABLE unison.pseqalias OWNER TO unison;

--
-- Name: TABLE pseqalias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pseqalias IS 'aliases for a given sequence';


--
-- Name: COLUMN pseqalias.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqalias.palias_id IS 'fk to pseqaliasorigin.palias_id for this alias';


--
-- Name: COLUMN pseqalias.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqalias.pseq_id IS 'pseq.pseq_id for this alias';


--
-- Name: COLUMN pseqalias.ref_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqalias.ref_pseq_id IS 'reference to pseq_id for this derived sequence';


--
-- Name: COLUMN pseqalias.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqalias.added IS 'date that this sequence was assigned this alias';


--
-- Name: COLUMN pseqalias.version; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqalias.version IS 'version number of this pseqalias';


--
-- Name: COLUMN pseqalias.is_current; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqalias.is_current IS 'is this pseqalias the current version';


--
-- Name: palias; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW palias AS
    SELECT pa.palias_id, pv.pseq_id, pa.origin_id, pa.alias, pa.descr, pa.tax_id, pv.ref_pseq_id, pv.added FROM paliasorigin pa, pseqalias pv WHERE ((pv.palias_id = pa.palias_id) AND (pv.is_current = true));


ALTER TABLE unison.palias OWNER TO unison;

--
-- Name: VIEW palias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW palias IS 'backwardly compatible - joins paliasorigin and pseqalias tables';


--
-- Name: COLUMN palias.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN palias.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN palias.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN palias.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias.alias IS 'alias for the sequence';


--
-- Name: COLUMN palias.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias.descr IS 'sequence description';


--
-- Name: COLUMN palias.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN palias.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias.added IS 'date that this sequence was assigned this alias';


SET search_path = go, pg_catalog;

--
-- Name: association; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE association (
    id integer DEFAULT nextval(('association_id_seq'::text)::regclass) NOT NULL,
    term_id integer DEFAULT 0 NOT NULL,
    gene_product_id integer DEFAULT 0 NOT NULL,
    is_not integer,
    role_group integer,
    assocdate integer,
    source_db_id integer
);


ALTER TABLE go.association OWNER TO unison;

--
-- Name: db; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE db (
    id integer DEFAULT nextval(('db_id_seq'::text)::regclass) NOT NULL,
    name character varying(55),
    fullname character varying(255),
    datatype character varying(255),
    generic_url character varying(255),
    url_syntax character varying(255)
);


ALTER TABLE go.db OWNER TO unison;

--
-- Name: dbxref; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE dbxref (
    id integer DEFAULT nextval(('dbxref_id_seq'::text)::regclass) NOT NULL,
    xref_key character varying(255) DEFAULT ''::character varying NOT NULL,
    xref_keytype character varying(32),
    xref_dbname character varying(55) DEFAULT ''::character varying NOT NULL,
    xref_desc character varying(255)
);


ALTER TABLE go.dbxref OWNER TO unison;

--
-- Name: evidence; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE evidence (
    id integer DEFAULT nextval(('evidence_id_seq'::text)::regclass) NOT NULL,
    code character varying(8) DEFAULT ''::character varying NOT NULL,
    association_id integer DEFAULT 0 NOT NULL,
    dbxref_id integer DEFAULT 0 NOT NULL,
    seq_acc character varying(255)
);


ALTER TABLE go.evidence OWNER TO unison;

--
-- Name: evidence_dbxref; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE evidence_dbxref (
    evidence_id integer DEFAULT 0 NOT NULL,
    dbxref_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.evidence_dbxref OWNER TO unison;

--
-- Name: gene_product; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE gene_product (
    id integer DEFAULT nextval(('gene_product_id_seq'::text)::regclass) NOT NULL,
    symbol character varying(128) DEFAULT ''::character varying NOT NULL,
    dbxref_id integer DEFAULT 0 NOT NULL,
    species_id integer,
    type_id integer,
    full_name text
);


ALTER TABLE go.gene_product OWNER TO unison;

--
-- Name: gene_product_count; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE gene_product_count (
    term_id integer DEFAULT 0 NOT NULL,
    code character varying(8),
    speciesdbname character varying(55) DEFAULT ''::character varying NOT NULL,
    product_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.gene_product_count OWNER TO unison;

--
-- Name: gene_product_property; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE gene_product_property (
    gene_product_id integer DEFAULT 0 NOT NULL,
    property_key character varying(64) DEFAULT ''::character varying NOT NULL,
    property_val character varying(255)
);


ALTER TABLE go.gene_product_property OWNER TO unison;

--
-- Name: gene_product_seq; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE gene_product_seq (
    gene_product_id integer DEFAULT 0 NOT NULL,
    seq_id integer DEFAULT 0 NOT NULL,
    is_primary_seq integer
);


ALTER TABLE go.gene_product_seq OWNER TO unison;

--
-- Name: gene_product_synonym; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE gene_product_synonym (
    gene_product_id integer DEFAULT 0 NOT NULL,
    product_synonym character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE go.gene_product_synonym OWNER TO unison;

--
-- Name: graph_path; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE graph_path (
    id integer DEFAULT nextval(('graph_path_id_seq'::text)::regclass) NOT NULL,
    term1_id integer DEFAULT 0 NOT NULL,
    term2_id integer DEFAULT 0 NOT NULL,
    distance integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.graph_path OWNER TO unison;

--
-- Name: graph_path2term; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE graph_path2term (
    graph_path_id integer DEFAULT 0 NOT NULL,
    term_id integer DEFAULT 0 NOT NULL,
    rank integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.graph_path2term OWNER TO unison;

--
-- Name: instance_data; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE instance_data (
    release_name character varying(255),
    release_type character varying(255),
    release_notes text
);


ALTER TABLE go.instance_data OWNER TO unison;

--
-- Name: seq; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE seq (
    id integer DEFAULT nextval(('seq_id_seq'::text)::regclass) NOT NULL,
    display_id character varying(64),
    description character varying(255),
    seq text,
    seq_len integer,
    md5checksum character varying(32),
    moltype character varying(25),
    "timestamp" integer
);


ALTER TABLE go.seq OWNER TO unison;

--
-- Name: seq_dbxref; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE seq_dbxref (
    seq_id integer DEFAULT 0 NOT NULL,
    dbxref_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.seq_dbxref OWNER TO unison;

--
-- Name: seq_property; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE seq_property (
    id integer DEFAULT nextval(('seq_property_id_seq'::text)::regclass) NOT NULL,
    seq_id integer DEFAULT 0 NOT NULL,
    property_key character varying(64) DEFAULT ''::character varying NOT NULL,
    property_val character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE go.seq_property OWNER TO unison;

--
-- Name: source_audit; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE source_audit (
    source_path character varying(255),
    source_type character varying(255),
    source_mtime integer
);


ALTER TABLE go.source_audit OWNER TO unison;

--
-- Name: species; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE species (
    id integer DEFAULT nextval(('species_id_seq'::text)::regclass) NOT NULL,
    ncbi_taxa_id integer,
    common_name character varying(255),
    lineage_string text,
    genus character varying(55),
    species character varying(55)
);


ALTER TABLE go.species OWNER TO unison;

--
-- Name: term; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE term (
    id integer DEFAULT nextval(('term_id_seq'::text)::regclass) NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    term_type character varying(55) DEFAULT ''::character varying NOT NULL,
    acc character varying(32) DEFAULT ''::character varying NOT NULL,
    is_obsolete integer DEFAULT 0 NOT NULL,
    is_root integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.term OWNER TO unison;

--
-- Name: term2term; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE term2term (
    id integer DEFAULT nextval(('term2term_id_seq'::text)::regclass) NOT NULL,
    relationship_type_id integer DEFAULT 0 NOT NULL,
    term1_id integer DEFAULT 0 NOT NULL,
    term2_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.term2term OWNER TO unison;

--
-- Name: term_audit; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE term_audit (
    term_id integer DEFAULT 0 NOT NULL,
    term_loadtime integer
);


ALTER TABLE go.term_audit OWNER TO unison;

--
-- Name: term_dbxref; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE term_dbxref (
    term_id integer DEFAULT 0 NOT NULL,
    dbxref_id integer DEFAULT 0 NOT NULL,
    is_for_definition integer DEFAULT 0 NOT NULL
);


ALTER TABLE go.term_dbxref OWNER TO unison;

--
-- Name: term_definition; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE term_definition (
    term_id integer DEFAULT 0 NOT NULL,
    term_definition text DEFAULT ''::text NOT NULL,
    dbxref_id integer,
    term_comment text,
    reference character varying(255)
);


ALTER TABLE go.term_definition OWNER TO unison;

--
-- Name: term_synonym; Type: TABLE; Schema: go; Owner: unison; Tablespace: 
--

CREATE TABLE term_synonym (
    term_id integer DEFAULT 0 NOT NULL,
    term_synonym character varying(255),
    acc_synonym integer
);


ALTER TABLE go.term_synonym OWNER TO unison;

SET search_path = gong, pg_catalog;

--
-- Name: alias; Type: TABLE; Schema: gong; Owner: unison; Tablespace: 
--

CREATE TABLE alias (
    alias_id integer NOT NULL,
    alias text NOT NULL,
    go_id integer NOT NULL
);


ALTER TABLE gong.alias OWNER TO unison;

--
-- Name: TABLE alias; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON TABLE alias IS 'GO names and synonyms';


--
-- Name: evidence_code; Type: TABLE; Schema: gong; Owner: unison; Tablespace: 
--

CREATE TABLE evidence_code (
    evidence_code text NOT NULL,
    abbr_exp text NOT NULL,
    descr text NOT NULL
);


ALTER TABLE gong.evidence_code OWNER TO unison;

--
-- Name: TABLE evidence_code; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON TABLE evidence_code IS 'GO evidence codes, meanings, and descriptions';


--
-- Name: COLUMN evidence_code.evidence_code; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON COLUMN evidence_code.evidence_code IS 'GO 2- or 3- letter evidence code';


--
-- Name: COLUMN evidence_code.abbr_exp; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON COLUMN evidence_code.abbr_exp IS 'code abbreviation expansion';


--
-- Name: COLUMN evidence_code.descr; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON COLUMN evidence_code.descr IS 'usage summary for code';


--
-- Name: is_a; Type: TABLE; Schema: gong; Owner: unison; Tablespace: 
--

CREATE TABLE is_a (
    go_id1 integer NOT NULL,
    go_id2 integer NOT NULL
);


ALTER TABLE gong.is_a OWNER TO unison;

--
-- Name: TABLE is_a; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON TABLE is_a IS 'GO is_a relationships';


--
-- Name: node; Type: TABLE; Schema: gong; Owner: unison; Tablespace: 
--

CREATE TABLE node (
    go_id integer NOT NULL,
    is_obsolete boolean DEFAULT false,
    alias_id integer,
    definition text,
    comment text
);


ALTER TABLE gong.node OWNER TO unison;

--
-- Name: TABLE node; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON TABLE node IS 'GO nodes, indexed by their GO id (integer, wo/''GO:'')';


--
-- Name: part_of; Type: TABLE; Schema: gong; Owner: unison; Tablespace: 
--

CREATE TABLE part_of (
    go_id1 integer NOT NULL,
    go_id2 integer NOT NULL
);


ALTER TABLE gong.part_of OWNER TO unison;

--
-- Name: TABLE part_of; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON TABLE part_of IS 'GO part_of relationships';


--
-- Name: term; Type: VIEW; Schema: gong; Owner: unison
--

CREATE VIEW term AS
    SELECT n.go_id, a.alias, n.definition, n.is_obsolete FROM (node n LEFT JOIN alias a ON ((a.alias_id = n.alias_id))) ORDER BY n.is_obsolete, n.go_id;


ALTER TABLE gong.term OWNER TO unison;

--
-- Name: VIEW term; Type: COMMENT; Schema: gong; Owner: unison
--

COMMENT ON VIEW term IS 'simple view of GO nodes';


SET search_path = marray, pg_catalog;

--
-- Name: chip; Type: TABLE; Schema: marray; Owner: unison; Tablespace: 
--

CREATE TABLE chip (
    chip_id integer NOT NULL,
    name text NOT NULL,
    current_origin_id integer
);


ALTER TABLE marray.chip OWNER TO unison;

--
-- Name: TABLE chip; Type: COMMENT; Schema: marray; Owner: unison
--

COMMENT ON TABLE chip IS 'chip details';


--
-- Name: COLUMN chip.name; Type: COMMENT; Schema: marray; Owner: unison
--

COMMENT ON COLUMN chip.name IS 'chip name';


--
-- Name: probe; Type: TABLE; Schema: marray; Owner: unison; Tablespace: 
--

CREATE TABLE probe (
    probe_id text NOT NULL,
    chip_id integer NOT NULL,
    chr text NOT NULL,
    strand character(1) NOT NULL,
    genasm_id integer NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    origin_id integer NOT NULL,
    md5 character(32) NOT NULL
);


ALTER TABLE marray.probe OWNER TO unison;

--
-- Name: TABLE probe; Type: COMMENT; Schema: marray; Owner: unison
--

COMMENT ON TABLE probe IS 'probe details';


--
-- Name: COLUMN probe.chr; Type: COMMENT; Schema: marray; Owner: unison
--

COMMENT ON COLUMN probe.chr IS 'chromosome (e.g. 1..22,M,U,X,Y for homo sapiens)';


--
-- Name: COLUMN probe.strand; Type: COMMENT; Schema: marray; Owner: unison
--

COMMENT ON COLUMN probe.strand IS 'genomic strand(+/-)';


--
-- Name: COLUMN probe.gstart; Type: COMMENT; Schema: marray; Owner: unison
--

COMMENT ON COLUMN probe.gstart IS 'start of probe on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: COLUMN probe.gstop; Type: COMMENT; Schema: marray; Owner: unison
--

COMMENT ON COLUMN probe.gstop IS 'stop of probe on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: chip_probe_v; Type: VIEW; Schema: marray; Owner: unison
--

CREATE VIEW chip_probe_v AS
    SELECT c.name, p.probe_id, p.chip_id, p.chr, p.strand, p.genasm_id, p.gstart, p.gstop, p.origin_id, p.md5 FROM (probe p JOIN chip c ON ((p.chip_id = c.chip_id)));


ALTER TABLE marray.chip_probe_v OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: origin_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION origin_id(text) RETURNS integer
    AS $_$DECLARE V_id integer; BEGIN select into V_id origin_id from origin where upper(origin)=upper($1); IF NOT FOUND THEN RAISE WARNING 'origin ''%'' not found', $1; RETURN NULL; END IF; return V_id; END;$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.origin_id(text) OWNER TO unison;

--
-- Name: FUNCTION origin_id(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION origin_id(text) IS 'return origin_id for given origin (case insensitive)';


SET search_path = ncbi, pg_catalog;

--
-- Name: homologene; Type: TABLE; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE TABLE homologene (
    hid integer NOT NULL,
    tax_id integer NOT NULL,
    gene_id integer NOT NULL,
    gene_symbol text NOT NULL,
    gi text NOT NULL,
    acc text NOT NULL
);


ALTER TABLE ncbi.homologene OWNER TO unison;

--
-- Name: TABLE homologene; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON TABLE homologene IS 'NCBI HomoloGene';


SET search_path = unison, pg_catalog;

--
-- Name: homologene_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW homologene_v AS
    SELECT h.hid, h.tax_id, h.gene_id, h.gene_symbol, h.gi, h.acc, sa.pseq_id FROM ((ncbi.homologene h JOIN paliasorigin oa ON (((h.acc = oa.alias) AND (oa.origin_id = origin_id('RefSeq'::text))))) JOIN pseqalias sa ON ((oa.palias_id = sa.palias_id)));


ALTER TABLE unison.homologene_v OWNER TO unison;

--
-- Name: VIEW homologene_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW homologene_v IS 'view of ncbi.homologene with pseq_ids. WARNING: omits entries not in Unison';


--
-- Name: COLUMN homologene_v.hid; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_v.hid IS 'homologene gene family identifier';


--
-- Name: COLUMN homologene_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN homologene_v.gene_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_v.gene_id IS 'NCBI Entrez Gene gene_id';


--
-- Name: COLUMN homologene_v.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_v.acc IS 'sequence accession';


--
-- Name: COLUMN homologene_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: homologene_pairs_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW homologene_pairs_v AS
    SELECT q.hid, q.pseq_id AS q_pseq_id, q.acc AS q_acc, q.tax_id AS q_tax_id, q.gene_symbol AS q_gene_symbol, t.pseq_id AS t_pseq_id, t.acc AS t_acc, t.tax_id AS t_tax_id, t.gene_symbol AS t_gene_symbol FROM (homologene_v q JOIN homologene_v t ON (((q.hid = t.hid) AND ((q.pseq_id <> t.pseq_id) OR (q.tax_id <> t.tax_id)))));


ALTER TABLE unison.homologene_pairs_v OWNER TO unison;

--
-- Name: VIEW homologene_pairs_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW homologene_pairs_v IS 'pairs of sequences from HomoloGene, with pseq_ids';


--
-- Name: COLUMN homologene_pairs_v.hid; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_pairs_v.hid IS 'homologene gene family identifier';


--
-- Name: COLUMN homologene_pairs_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_pairs_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN homologene_pairs_v.q_tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_pairs_v.q_tax_id IS 'tax_id of q_pseq_id';


--
-- Name: COLUMN homologene_pairs_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_pairs_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN homologene_pairs_v.t_tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_pairs_v.t_tax_id IS 'tax_id of target pseq_id';


--
-- Name: COLUMN homologene_pairs_v.t_gene_symbol; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_pairs_v.t_gene_symbol IS 'target sequence Entrez Gene symbol';


--
-- Name: homologene_orthologs_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW homologene_orthologs_v AS
    SELECT homologene_pairs_v.hid, homologene_pairs_v.q_pseq_id, homologene_pairs_v.q_acc, homologene_pairs_v.q_tax_id, homologene_pairs_v.q_gene_symbol, homologene_pairs_v.t_pseq_id, homologene_pairs_v.t_acc, homologene_pairs_v.t_tax_id, homologene_pairs_v.t_gene_symbol FROM homologene_pairs_v homologene_pairs_v WHERE (homologene_pairs_v.q_tax_id <> homologene_pairs_v.t_tax_id);


ALTER TABLE unison.homologene_orthologs_v OWNER TO unison;

--
-- Name: VIEW homologene_orthologs_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW homologene_orthologs_v IS 'orthologs from homologene_pairs_v';


--
-- Name: COLUMN homologene_orthologs_v.hid; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_orthologs_v.hid IS 'homologene gene family identifier';


--
-- Name: COLUMN homologene_orthologs_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_orthologs_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN homologene_orthologs_v.q_tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_orthologs_v.q_tax_id IS 'tax_id of q_pseq_id';


--
-- Name: COLUMN homologene_orthologs_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_orthologs_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN homologene_orthologs_v.t_tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_orthologs_v.t_tax_id IS 'tax_id of target pseq_id';


--
-- Name: COLUMN homologene_orthologs_v.t_gene_symbol; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_orthologs_v.t_gene_symbol IS 'target sequence Entrez Gene symbol';


--
-- Name: origin; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE origin (
    origin_id integer NOT NULL,
    origin text NOT NULL,
    url text,
    descr text,
    ann_pref integer,
    last_updated timestamp with time zone,
    data_url text,
    is_public boolean DEFAULT false NOT NULL,
    link_url text,
    version text
);


ALTER TABLE unison.origin OWNER TO unison;

--
-- Name: TABLE origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE origin IS 'origin (database or algorithm) of protein alias (sequence)';


--
-- Name: COLUMN origin.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.origin_id IS 'unique id for origin; default is serial number';


--
-- Name: COLUMN origin.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.origin IS 'origin name (freetext)';


--
-- Name: COLUMN origin.url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.url IS 'URL for external reference; %s is placeholder for accession';


--
-- Name: COLUMN origin.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.descr IS 'origin description';


--
-- Name: COLUMN origin.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.ann_pref IS 'preference order for selecting annotation information (lower = higher preference)';


--
-- Name: COLUMN origin.last_updated; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.last_updated IS 'timestamp for last update of this origin';


--
-- Name: COLUMN origin.data_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.data_url IS 'URL for source data loaded into Unison';


--
-- Name: COLUMN origin.is_public; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.is_public IS 'true if this data source or algorithm is publicly distributable';


--
-- Name: COLUMN origin.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN origin.link_url IS 'URL to source data';


--
-- Name: pmodelset; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmodelset (
    pmodelset_id integer NOT NULL,
    name text,
    descr text,
    pmsm_table text,
    def text,
    locked boolean DEFAULT true,
    last_updated timestamp without time zone DEFAULT now(),
    data_url text
);


ALTER TABLE unison.pmodelset OWNER TO unison;

--
-- Name: TABLE pmodelset; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmodelset IS 'set of protein models (possibly heterogeneous); see pmsm_* for linking';


--
-- Name: COLUMN pmodelset.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmodelset.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset.name IS 'modelset name';


--
-- Name: COLUMN pmodelset.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset.descr IS 'model description';


--
-- Name: COLUMN pmodelset.pmsm_table; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset.pmsm_table IS 'table name that contains pmodel_ids of this set';


--
-- Name: COLUMN pmodelset.def; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset.def IS 'sql to retrive models in this set';


--
-- Name: COLUMN pmodelset.locked; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset.locked IS 'boolean value specifies if modelset can be updated';


--
-- Name: COLUMN pmodelset.last_updated; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset.last_updated IS 'date last updated';


--
-- Name: pmregexp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmregexp (
    acc text NOT NULL,
    descr text NOT NULL,
    regexp text NOT NULL,
    name text NOT NULL
)
INHERITS (pmodel);


ALTER TABLE unison.pmregexp OWNER TO unison;

--
-- Name: TABLE pmregexp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmregexp IS 'regular expression models (e.g., PROSITE and other simple motifs)';


--
-- Name: COLUMN pmregexp.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmregexp.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pmregexp.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmregexp.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN pmregexp.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmregexp.acc IS 'model accession from source database';


--
-- Name: COLUMN pmregexp.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmregexp.added IS 'when this data was created';


--
-- Name: COLUMN pmregexp.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmregexp.descr IS 'model description';


--
-- Name: COLUMN pmregexp.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmregexp.name IS 'regular expression name';


--
-- Name: pmsm_pmhmm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmsm_pmhmm (
)
INHERITS (pmsm);


ALTER TABLE unison.pmsm_pmhmm OWNER TO unison;

--
-- Name: TABLE pmsm_pmhmm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmsm_pmhmm IS 'pmsm for pmhmms (inherits from pmsm, which see)';


--
-- Name: COLUMN pmsm_pmhmm.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmhmm.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmsm_pmhmm.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmhmm.pmodel_id IS 'unique protein model identifier';


--
-- Name: pmsm_pmregexp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmsm_pmregexp (
)
INHERITS (pmsm);


ALTER TABLE unison.pmsm_pmregexp OWNER TO unison;

--
-- Name: TABLE pmsm_pmregexp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmsm_pmregexp IS 'pmsm for pmregexp (inherits from pmsm, which see)';


--
-- Name: COLUMN pmsm_pmregexp.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmregexp.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmsm_pmregexp.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmregexp.pmodel_id IS 'unique protein model identifier';


SET search_path = scop, pg_catalog;

--
-- Name: cla; Type: TABLE; Schema: scop; Owner: unison; Tablespace: 
--

CREATE TABLE cla (
    sunid integer NOT NULL,
    sid text NOT NULL,
    pdb character(4) NOT NULL,
    def text NOT NULL,
    sccs text NOT NULL,
    cl integer NOT NULL,
    cf integer NOT NULL,
    sf integer NOT NULL,
    fa integer NOT NULL,
    dm integer NOT NULL,
    sp integer NOT NULL
);


ALTER TABLE scop.cla OWNER TO unison;

--
-- Name: TABLE cla; Type: COMMENT; Schema: scop; Owner: unison
--

COMMENT ON TABLE cla IS 'SCOP domain classification (http://scop.berkeley.edu/)';


SET search_path = tax, pg_catalog;

--
-- Name: spspec; Type: TABLE; Schema: tax; Owner: unison; Tablespace: 
--

CREATE TABLE spspec (
    tax_id integer NOT NULL,
    k character(1) NOT NULL,
    gs text NOT NULL,
    latin text NOT NULL,
    common text,
    synonyms text
);


ALTER TABLE tax.spspec OWNER TO unison;

--
-- Name: TABLE spspec; Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON TABLE spspec IS 'Swiss-Prot Species from ftp://us.expasy.org/databases/swiss-prot/release/speclist.txt';


--
-- Name: COLUMN spspec.tax_id; Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON COLUMN spspec.tax_id IS 'NCBI taxonomy identifier (same used by Swiss-Prot)';


--
-- Name: COLUMN spspec.k; Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON COLUMN spspec.k IS 'kingdom (A=archea, B=bacteria, E=eukaryota, V=viridae)';


--
-- Name: COLUMN spspec.gs; Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON COLUMN spspec.gs IS 'Swiss-Prot 5-letter genus+species code (typically GENus+SPecies = GENSP, with exceptions)';


--
-- Name: COLUMN spspec.latin; Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON COLUMN spspec.latin IS 'Latin genus and species';


--
-- Name: COLUMN spspec.common; Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON COLUMN spspec.common IS 'common name';


--
-- Name: COLUMN spspec.synonyms; Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON COLUMN spspec.synonyms IS 'synonyms, "; " separated';


SET search_path = unison, pg_catalog;

--
-- Name: current_annotations_unsorted_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW current_annotations_unsorted_v AS
    SELECT a.pseq_id, a.origin_id, o.origin, o.ann_pref, a.palias_id, a.tax_id, t.k, t.gs, t.latin, t.common, a.alias, a.descr, a.added, replace(o.link_url, '%s'::text, a.alias) AS link_url FROM ((palias a JOIN origin o ON ((a.origin_id = o.origin_id))) LEFT JOIN tax.spspec t ON ((a.tax_id = t.tax_id)));


ALTER TABLE unison.current_annotations_unsorted_v OWNER TO unison;

--
-- Name: COLUMN current_annotations_unsorted_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN current_annotations_unsorted_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN current_annotations_unsorted_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN current_annotations_unsorted_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN current_annotations_unsorted_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN current_annotations_unsorted_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN current_annotations_unsorted_v.k; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.k IS 'Swiss-Prot kingdom code (A=archea; B=bacteria; E=eukaryota; V=viruses)';


--
-- Name: COLUMN current_annotations_unsorted_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN current_annotations_unsorted_v.latin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.latin IS 'Latin genus and species';


--
-- Name: COLUMN current_annotations_unsorted_v.common; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.common IS 'common taxonomic name';


--
-- Name: COLUMN current_annotations_unsorted_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN current_annotations_unsorted_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.descr IS 'sequence description';


--
-- Name: COLUMN current_annotations_unsorted_v.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.added IS 'date that this sequence was assigned this alias';


--
-- Name: COLUMN current_annotations_unsorted_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_unsorted_v.link_url IS 'URL to source data';


--
-- Name: pset_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pset_id(text) RETURNS integer
    AS $_$DECLARE V_id integer; BEGIN select into V_id pset_id from pset where upper(name)=upper($1); IF NOT FOUND THEN RAISE WARNING 'pset ''%'' not found', $1; RETURN NULL; END IF; return V_id; END;$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.pset_id(text) OWNER TO unison;

--
-- Name: ensembl_unambiguous_overlaps_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE ensembl_unambiguous_overlaps_mv (
    genome text,
    chr text,
    strand text,
    q_pseq_id integer,
    q_gstart text,
    q_gstop text,
    t_pseq_id integer,
    t_gstart text,
    t_gstop text
);


ALTER TABLE unison.ensembl_unambiguous_overlaps_mv OWNER TO unison;

--
-- Name: COLUMN ensembl_unambiguous_overlaps_mv.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_mv.chr IS 'chromosome';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_mv.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_mv.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_mv.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_mv.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_mv.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_mv.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_mv.t_gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_mv.t_gstart IS 'genomic start of target sequence';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_mv.t_gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_mv.t_gstop IS 'genomic stop of target sequence';


SET search_path = pdb, pg_catalog;

--
-- Name: descriptor_origin; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE descriptor_origin (
    descriptor_origin_id integer NOT NULL,
    type text NOT NULL,
    origin text NOT NULL,
    version text
);


ALTER TABLE pdb.descriptor_origin OWNER TO unison;

--
-- Name: ligand_descriptors; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE ligand_descriptors (
    ligand_id text NOT NULL,
    descriptor_origin_id integer NOT NULL,
    descriptor text NOT NULL
);


ALTER TABLE pdb.ligand_descriptors OWNER TO unison;

--
-- Name: descriptor_origin_id(text, text); Type: FUNCTION; Schema: pdb; Owner: unison
--

CREATE FUNCTION descriptor_origin_id(text, text) RETURNS SETOF integer
    AS $_$
 DECLARE 
	V_id integer;
 BEGIN 
	FOR V_id IN select descriptor_origin_id from descriptor_origin where type = $1 and upper(origin) = upper($2) LOOP 
		return NEXT V_id; 
	END LOOP;
 	RETURN; 
 END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION pdb.descriptor_origin_id(text, text) OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: pahmm_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pahmm_v AS
    SELECT a.params_id, a.pseq_id, a.start, a.stop, a.mstart, a.mstop, ((SELECT CASE WHEN (a.mstart = 1) THEN '['::text ELSE '.'::text END AS "case") || (SELECT CASE WHEN (a.mstop = m.len) THEN ']'::text ELSE '.'::text END AS "case")) AS ends, round((((((a.mstop - a.mstart) + 1))::double precision / (m.len)::double precision) * (100)::double precision)) AS pct_cov, a.score, a.eval, m.origin_id, a.pmodel_id, m.acc, m.name, m.descr FROM (pahmm a JOIN pmhmm m ON ((m.pmodel_id = a.pmodel_id))) ORDER BY a.eval;


ALTER TABLE unison.pahmm_v OWNER TO unison;

--
-- Name: VIEW pahmm_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pahmm_v IS 'HMM alignments with origin_id, acc, model, and descr';


--
-- Name: papseq; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE papseq (
    pftype_id integer DEFAULT pftype_id('BLAST'::text),
    params_id integer,
    ident smallint NOT NULL,
    sim smallint NOT NULL,
    len smallint NOT NULL,
    pct_ident real NOT NULL,
    pct_hsp_coverage real NOT NULL,
    pct_coverage real NOT NULL
)
INHERITS (palignment);


ALTER TABLE unison.papseq OWNER TO unison;

--
-- Name: TABLE papseq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE papseq IS 'BLAST pseq-pseq alignments (via pmpseq); inherits palignment';


--
-- Name: COLUMN papseq.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN papseq.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN papseq.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN papseq.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN papseq.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN papseq.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN papseq.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN papseq.mstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.mstart IS 'start of match /in model/';


--
-- Name: COLUMN papseq.mstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.mstop IS 'stop of match /in model/';


--
-- Name: COLUMN papseq.qgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.qgaps IS 'number of gaps in query sequence';


--
-- Name: COLUMN papseq.tgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.tgaps IS 'number of gaps in target sequence';


--
-- Name: COLUMN papseq.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.score IS 'algorithm-specific score';


--
-- Name: COLUMN papseq.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.eval IS 'expectation value';


--
-- Name: COLUMN papseq.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.pct_ident IS 'derived value: ident/len';


--
-- Name: COLUMN papseq.pct_hsp_coverage; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.pct_hsp_coverage IS 'derived value: len/length of query sequence';


--
-- Name: COLUMN papseq.pct_coverage; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq.pct_coverage IS 'derived value: length of shorter sequence/length of longer sequence';


--
-- Name: pmpseq; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmpseq (
    pseq_id integer NOT NULL
)
INHERITS (pmodel);


ALTER TABLE unison.pmpseq OWNER TO unison;

--
-- Name: TABLE pmpseq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmpseq IS 'models used for papseq alignments';


--
-- Name: COLUMN pmpseq.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpseq.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pmpseq.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpseq.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN pmpseq.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpseq.acc IS 'model accession from source database';


--
-- Name: COLUMN pmpseq.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpseq.added IS 'when this data was created';


--
-- Name: COLUMN pmpseq.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpseq.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: papseq_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW papseq_v AS
    SELECT a.pfeature_id, a.pseq_id AS q_pseq_id, a.start AS q_start, a.stop AS q_stop, b.pseq_id AS t_pseq_id, a.mstart AS t_start, a.mstop AS t_stop, a.ident, a.sim, a.gaps, a.qgaps, a.tgaps, a.score, a.eval, a.len, a.pct_ident, a.pct_hsp_coverage, a.pct_coverage FROM (papseq a JOIN pmpseq b ON ((a.pmodel_id = b.pmodel_id))) UNION ALL SELECT a.pfeature_id, b.pseq_id AS q_pseq_id, a.mstart AS q_start, a.mstop AS q_stop, a.pseq_id AS t_pseq_id, a.start AS t_start, a.stop AS t_stop, a.ident, a.sim, a.gaps, a.qgaps, a.tgaps, a.score, a.eval, a.len, a.pct_ident, a.pct_hsp_coverage, a.pct_coverage FROM (papseq a JOIN pmpseq b ON ((a.pmodel_id = b.pmodel_id)));


ALTER TABLE unison.papseq_v OWNER TO unison;

--
-- Name: VIEW papseq_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW papseq_v IS 'BLAST sequence-sequence alignments';


--
-- Name: COLUMN papseq_v.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN papseq_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN papseq_v.q_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.q_start IS 'start position in q_pseq_id';


--
-- Name: COLUMN papseq_v.q_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.q_stop IS 'stop position in q_pseq_id';


--
-- Name: COLUMN papseq_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN papseq_v.t_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.t_start IS 'start position in target pseq_id';


--
-- Name: COLUMN papseq_v.t_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.t_stop IS 'stop position in target pseq_id';


--
-- Name: COLUMN papseq_v.qgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.qgaps IS 'number of gaps in query sequence';


--
-- Name: COLUMN papseq_v.tgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.tgaps IS 'number of gaps in target sequence';


--
-- Name: COLUMN papseq_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.score IS 'algorithm-specific score';


--
-- Name: COLUMN papseq_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.eval IS 'expectation value';


--
-- Name: COLUMN papseq_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.pct_ident IS 'percent identity';


--
-- Name: COLUMN papseq_v.pct_coverage; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_v.pct_coverage IS 'percent coverage';


SET search_path = scop, pg_catalog;

--
-- Name: dom; Type: TABLE; Schema: scop; Owner: unison; Tablespace: 
--

CREATE TABLE dom (
    sid text NOT NULL,
    pdb character(4) NOT NULL,
    chain character(1) NOT NULL,
    start integer,
    stop integer
);


ALTER TABLE scop.dom OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: papseq_pdbcs_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE papseq_pdbcs_mv (
    q_pseq_id integer,
    q_start integer,
    q_stop integer,
    t_pseq_id integer,
    t_start integer,
    t_stop integer,
    pdbc text,
    descr text,
    tax_id integer,
    ident smallint,
    sim smallint,
    gaps smallint,
    q_gaps smallint,
    t_gaps smallint,
    score integer,
    eval double precision,
    len smallint,
    pct_ident real,
    pct_coverage real
);


ALTER TABLE unison.papseq_pdbcs_mv OWNER TO unison;

SET search_path = pdb, pg_catalog;

--
-- Name: chain; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE chain (
    pdbid text NOT NULL,
    chainid character(1),
    pdbc text NOT NULL,
    name text,
    ec text,
    CONSTRAINT chain_pdbc_ck CHECK ((pdbc = (pdbid || (COALESCE(chainid, ''::bpchar))::text)))
);


ALTER TABLE pdb.chain OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: domain_digest(integer, integer, text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text) RETURNS text
    AS $$
BEGIN
	-- 12-23:Ig(56,1e-5)
	-- SELECT INTO digest pstart || '-' || pstop || ':' || name || COALESCE('('||NULLIF(note,'')||')','');

	SELECT INTO digest name || '(' || pstart || '-' || pstop || COALESCE(';'||NULLIF(note,''),'') || ')';
END;
$$
    LANGUAGE plpgsql IMMUTABLE;


ALTER FUNCTION unison.domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text) OWNER TO unison;

--
-- Name: FUNCTION domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text) IS 'formatted domain summary, like start-stop:domain(note)';


--
-- Name: preferred_run_id_by_pftype(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION preferred_run_id_by_pftype(text) RETURNS integer
    AS $_$select preferred_run_id from pftype where pftype_id=pftype_id($1)$_$
    LANGUAGE sql STABLE;


ALTER FUNCTION unison.preferred_run_id_by_pftype(text) OWNER TO unison;

--
-- Name: FUNCTION preferred_run_id_by_pftype(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION preferred_run_id_by_pftype(text) IS 'return preferred run_id for a given pftype';


--
-- Name: params; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE params (
    params_id integer NOT NULL,
    name text NOT NULL,
    commandline text NOT NULL,
    added timestamp with time zone DEFAULT timenow(),
    pftype_id integer,
    is_public boolean DEFAULT false NOT NULL,
    descr text
);


ALTER TABLE unison.params OWNER TO unison;

--
-- Name: TABLE params; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE params IS 'table of run parameters and dates; inherited by r* tables';


--
-- Name: COLUMN params.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params.params_id IS 'unique identifier for these parameters';


--
-- Name: COLUMN params.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params.name IS 'parameter set name';


--
-- Name: COLUMN params.commandline; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params.commandline IS 'command line used to generate results';


--
-- Name: COLUMN params.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params.added IS 'date parameters were defined';


--
-- Name: COLUMN params.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params.pftype_id IS 'pftype_id for results of this type';


--
-- Name: COLUMN params.is_public; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params.is_public IS 'whether these results are distributable';


--
-- Name: COLUMN params.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params.descr IS 'description of this parameter set';


--
-- Name: pfsignalpnn; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfsignalpnn (
    pftype_id integer DEFAULT pftype_id('SignalP'::text),
    start integer DEFAULT 1,
    d_score real NOT NULL,
    signal_peptide boolean NOT NULL
)
INHERITS (pfeature);


ALTER TABLE unison.pfsignalpnn OWNER TO unison;

--
-- Name: TABLE pfsignalpnn; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfsignalpnn IS 'neural network output from SignalP';


--
-- Name: COLUMN pfsignalpnn.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalpnn.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfsignalpnn.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalpnn.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfsignalpnn.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalpnn.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfsignalpnn.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalpnn.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfsignalpnn.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalpnn.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfsignalpnn.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalpnn.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfsignalpnn.signal_peptide; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalpnn.signal_peptide IS 'd_score>0.430';


--
-- Name: pftmhmm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pftmhmm (
    pftype_id integer DEFAULT pftype_id('TMHMM'::text),
    type character(1) NOT NULL,
    CONSTRAINT tm_type_ck CHECK (((((type = 'o'::bpchar) OR (type = 'i'::bpchar)) OR (type = 'M'::bpchar)) OR (type = 'N'::bpchar)))
)
INHERITS (pfeature);


ALTER TABLE unison.pftmhmm OWNER TO unison;

--
-- Name: TABLE pftmhmm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pftmhmm IS 'TMHMM output';


--
-- Name: COLUMN pftmhmm.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pftmhmm.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pftmhmm.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pftmhmm.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pftmhmm.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pftmhmm.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pftmhmm.type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm.type IS 'S=signal; M=in->out TM; N=out->in TM';


--
-- Name: pftype; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pftype (
    pftype_id integer NOT NULL,
    name text,
    descr text,
    preferred_run_id integer
);


ALTER TABLE unison.pftype OWNER TO unison;

--
-- Name: TABLE pftype; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pftype IS 'enumeration of feature types';


--
-- Name: COLUMN pftype.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftype.pftype_id IS 'unique identifier for this feature type';


--
-- Name: COLUMN pftype.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftype.name IS 'short descriptive name of this feature type';


--
-- Name: COLUMN pftype.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftype.descr IS 'feature type description';


--
-- Name: COLUMN pftype.preferred_run_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftype.preferred_run_id IS 'preferred/current parameter/model set identifer for this feature type';


--
-- Name: run; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE run (
    run_id integer NOT NULL,
    params_id integer NOT NULL,
    pmodelset_id integer
);


ALTER TABLE unison.run OWNER TO unison;

--
-- Name: TABLE run; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE run IS 'table of run characteristics like params and modelsets';


--
-- Name: COLUMN run.run_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN run.run_id IS 'unison identifier for a run';


--
-- Name: COLUMN run.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN run.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN run.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN run.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: pseq_features_signalpnn_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_signalpnn_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.start, f.stop, f.d_score AS score, NULL::double precision AS eval, NULL::integer AS origin_id, NULL::text AS origin, NULL::integer AS pmodel_id, 'SS'::text AS feature, NULL::text AS acc, 'signal sequence'::text AS descr, NULL::text AS details, domain_digest(f.start, f.stop, 'SS'::text, (f.d_score)::text) AS digest, NULL::text AS link_url FROM (((pfsignalpnn f JOIN params p ON ((f.params_id = p.params_id))) JOIN run r ON ((r.params_id = p.params_id))) JOIN pftype ft ON ((ft.preferred_run_id = r.run_id))) WHERE ((ft.name = 'SignalP'::text) AND (f.signal_peptide = true));


ALTER TABLE unison.pseq_features_signalpnn_v OWNER TO unison;

--
-- Name: VIEW pseq_features_signalpnn_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_features_signalpnn_v IS 'current SignalP neural net features';


--
-- Name: COLUMN pseq_features_signalpnn_v.feature_type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.feature_type IS 'type of features (always ''SignalP'')';


--
-- Name: COLUMN pseq_features_signalpnn_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pseq_features_signalpnn_v.params_name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.params_name IS 'parameter set name -- see params(name)';


--
-- Name: COLUMN pseq_features_signalpnn_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pseq_features_signalpnn_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_signalpnn_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_signalpnn_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.score IS 'algorithm-specific score';


--
-- Name: COLUMN pseq_features_signalpnn_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.eval IS 'expectation value';


--
-- Name: COLUMN pseq_features_signalpnn_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pseq_features_signalpnn_v.feature; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.feature IS 'name of feature (always ''SS'')';


--
-- Name: COLUMN pseq_features_signalpnn_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.descr IS 'unused';


--
-- Name: COLUMN pseq_features_signalpnn_v.details; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.details IS 'prediction details';


--
-- Name: COLUMN pseq_features_signalpnn_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_signalpnn_v.link_url IS 'URL to source data';


--
-- Name: pseq_features_tmhmm_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_tmhmm_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.start, f.stop, NULL::smallint AS score, NULL::double precision AS eval, NULL::integer AS origin_id, NULL::text AS origin, NULL::integer AS pmodel_id, 'TM'::text AS feature, NULL::text AS acc, 'transmembrane domain'::text AS descr, NULL::text AS details, domain_digest(f.start, f.stop, 'TM'::text, NULL::text) AS digest, NULL::text AS link_url FROM (((pftmhmm f JOIN params p ON ((f.params_id = p.params_id))) JOIN run r ON ((r.params_id = p.params_id))) JOIN pftype ft ON ((ft.preferred_run_id = r.run_id))) WHERE ((ft.name = 'TMHMM'::text) AND ((f.type = 'M'::bpchar) OR (f.type = 'N'::bpchar)));


ALTER TABLE unison.pseq_features_tmhmm_v OWNER TO unison;

--
-- Name: VIEW pseq_features_tmhmm_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_features_tmhmm_v IS 'current TMHMM features';


--
-- Name: COLUMN pseq_features_tmhmm_v.feature_type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.feature_type IS 'type of features (always ''TMHMM'')';


--
-- Name: COLUMN pseq_features_tmhmm_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pseq_features_tmhmm_v.params_name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.params_name IS 'parameter set name -- see params(name)';


--
-- Name: COLUMN pseq_features_tmhmm_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pseq_features_tmhmm_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_tmhmm_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_tmhmm_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.score IS 'algorithm-specific score';


--
-- Name: COLUMN pseq_features_tmhmm_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.eval IS 'expectation value';


--
-- Name: COLUMN pseq_features_tmhmm_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pseq_features_tmhmm_v.feature; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.feature IS 'name of feature (always ''TM'')';


--
-- Name: COLUMN pseq_features_tmhmm_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.descr IS 'unused';


--
-- Name: COLUMN pseq_features_tmhmm_v.details; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.details IS 'prediction details';


--
-- Name: COLUMN pseq_features_tmhmm_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_tmhmm_v.link_url IS 'URL to source data';


--
-- Name: pseq_features_tmhmm_excl_signal_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_tmhmm_excl_signal_v AS
    SELECT tm.feature_type, tm.params_id, tm.params_name, tm.pseq_id, tm.start, tm.stop, tm.score, tm.eval, NULL::integer AS origin_id, NULL::text AS origin, tm.pmodel_id, tm.feature, tm.acc, tm.descr, tm.details, tm.digest, tm.link_url FROM (pseq_features_tmhmm_v tm JOIN run r ON ((r.params_id = tm.params_id))) WHERE ((r.run_id = preferred_run_id_by_pftype('TMHMM'::text)) AND (NOT (EXISTS (SELECT ss.pfeature_id, ss.pseq_id, ss.pftype_id, ss.start, ss.stop, ss.params_id, ss.d_score, ss.signal_peptide FROM (pfsignalpnn ss JOIN run r ON ((r.params_id = ss.params_id))) WHERE (((((ss.pseq_id = tm.pseq_id) AND (r.run_id = preferred_run_id_by_pftype('SignalP'::text))) AND (ss.signal_peptide = true)) AND (ss.stop >= tm.start)) AND (ss.start <= tm.stop))))));


ALTER TABLE unison.pseq_features_tmhmm_excl_signal_v OWNER TO unison;

--
-- Name: VIEW pseq_features_tmhmm_excl_signal_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_features_tmhmm_excl_signal_v IS 'current TMHMM features that do not overlap a SignalP NN prediction';


SET search_path = tax, pg_catalog;

--
-- Name: tax_id2gs(integer); Type: FUNCTION; Schema: tax; Owner: unison
--

CREATE FUNCTION tax_id2gs(integer) RETURNS text
    AS $_$
DECLARE
	v_id alias for $1;
	rv text;
BEGIN
	select into rv gs from tax.spspec where tax_id=v_id;
	return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION tax.tax_id2gs(integer) OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: blasts_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW blasts_v AS
    SELECT a.pseq_id AS q_pseq_id, m.pseq_id AS t_pseq_id, a.pct_ident FROM (papseq a JOIN pmpseq m ON ((a.pmodel_id = m.pmodel_id))) UNION ALL SELECT m.pseq_id AS q_pseq_id, a.pseq_id AS t_pseq_id, a.pct_ident FROM (papseq a JOIN pmpseq m ON ((a.pmodel_id = m.pmodel_id)));


ALTER TABLE unison.blasts_v OWNER TO unison;

--
-- Name: COLUMN blasts_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blasts_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN blasts_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blasts_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN blasts_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blasts_v.pct_ident IS 'percent identity';


--
-- Name: pmprospect; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmprospect (
    origin_id integer DEFAULT origin_id('Prospect'::text),
    pseq_id integer NOT NULL,
    len integer NOT NULL,
    ncores integer NOT NULL
)
INHERITS (pmodel);


ALTER TABLE unison.pmprospect OWNER TO unison;

--
-- Name: TABLE pmprospect; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmprospect IS 'Prospect threading backbone (inherits from pmodel)';


--
-- Name: COLUMN pmprospect.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pmprospect.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN pmprospect.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect.acc IS 'model accession from source database';


--
-- Name: COLUMN pmprospect.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect.added IS 'when this data was created';


--
-- Name: COLUMN pmprospect.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect.descr IS 'model description';


--
-- Name: COLUMN pmprospect.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pmprospect.ncores; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect.ncores IS 'number of cores in template';


--
-- Name: pmprospect_scop_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmprospect_scop_v AS
    (SELECT m.origin_id, m.pmodel_id, m.acc, c.sunid, c.sid, c.pdb, 1 AS "case" FROM (pmprospect m JOIN scop.cla c ON ((m.acc = c.sid))) WHERE (m.origin_id = origin_id('Prospect/SCOP'::text)) UNION ALL SELECT m.origin_id, m.pmodel_id, m.acc, c.sunid, c.sid, c.pdb, 2 AS "case" FROM (pmprospect m JOIN scop.cla c ON ((rpad(m.acc, 5, '_'::text) = substr(c.sid, 2, 5)))) WHERE (m.origin_id = origin_id('Prospect/FSSP'::text))) UNION ALL SELECT m.origin_id, m.pmodel_id, m.acc, c.sunid, c.sid, c.pdb, 2 AS "case" FROM (pmprospect m JOIN scop.cla c ON ((rpad(m.acc, 5, '_'::text) = substr(c.sid, 2, 5)))) WHERE (m.origin_id = origin_id('Prospect-3.0/FSSP'::text));


ALTER TABLE unison.pmprospect_scop_v OWNER TO unison;

--
-- Name: VIEW pmprospect_scop_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmprospect_scop_v IS 'prospect pmodel_id-to-scop sunid mapping, with debugging info';


--
-- Name: COLUMN pmprospect_scop_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect_scop_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN pmprospect_scop_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect_scop_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pmprospect_scop_v.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect_scop_v.acc IS 'model accession from source database';


--
-- Name: pmprospect_scop_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmprospect_scop_dv AS
    SELECT _pmprospect_scop_v.pmodel_id, _pmprospect_scop_v.sunid FROM pmprospect_scop_v _pmprospect_scop_v;


ALTER TABLE unison.pmprospect_scop_dv OWNER TO unison;

--
-- Name: VIEW pmprospect_scop_dv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmprospect_scop_dv IS 'prospect pmodel_id-to-scop sunid mapping';


--
-- Name: COLUMN pmprospect_scop_dv.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmprospect_scop_dv.pmodel_id IS 'unique protein model identifier';


--
-- Name: paprospect_scop_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW paprospect_scop_v AS
    SELECT t.pseq_id, t.params_id, t.pmodel_id, m.acc, m.len, t.start, t.stop, t.nident, CASE WHEN (t.stop < t.start) THEN NULL::numeric ELSE round((((t.nident)::numeric / (t.nalign)::numeric) * 100.0), 0) END AS pct_ident, (t.raw)::integer AS raw, round((t.svm)::numeric, 1) AS svm, round((t.mutation)::numeric, 0) AS mutation, round((t.pairwise)::numeric, 0) AS pairwise, round((t.singleton)::numeric, 0) AS singleton, round((t.gap)::numeric, 0) AS gap, cla.cl AS clid, descl.descr AS clname, cla.cf AS cfid, descf.descr AS cfname, cla.sf AS sfid, dessf.descr AS sfname, cla.dm AS dmid, desdm.descr AS dmname FROM (((((((paprospect t JOIN pmprospect_scop_dv b ON ((t.pmodel_id = b.pmodel_id))) JOIN pmprospect m ON ((t.pmodel_id = m.pmodel_id))) LEFT JOIN scop.cla ON ((b.sunid = cla.sunid))) LEFT JOIN scop.des descl ON ((cla.cl = descl.sunid))) LEFT JOIN scop.des descf ON ((cla.cf = descf.sunid))) LEFT JOIN scop.des dessf ON ((cla.sf = dessf.sunid))) LEFT JOIN scop.des desdm ON ((cla.dm = desdm.sunid))) ORDER BY t.pseq_id, t.svm DESC;


ALTER TABLE unison.paprospect_scop_v OWNER TO unison;

--
-- Name: VIEW paprospect_scop_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW paprospect_scop_v IS 'Prospect threading alignments with SCOP class, fold, superfamily, and domain annotations';


--
-- Name: COLUMN paprospect_scop_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN paprospect_scop_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN paprospect_scop_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN paprospect_scop_v.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.acc IS 'model accession from source database';


--
-- Name: COLUMN paprospect_scop_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN paprospect_scop_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN paprospect_scop_v.nident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.nident IS 'number of identical residues';


--
-- Name: COLUMN paprospect_scop_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.pct_ident IS 'percent identity';


--
-- Name: COLUMN paprospect_scop_v.raw; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.raw IS 'Prospect ''raw'' score ';


--
-- Name: COLUMN paprospect_scop_v.svm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.svm IS 'Prospect ''svm'' score ';


--
-- Name: COLUMN paprospect_scop_v.singleton; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_scop_v.singleton IS 'Prospect ''singleton'' score ';


--
-- Name: _agg_as_set_finalfunc(anyarray); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _agg_as_set_finalfunc(anyarray) RETURNS text
    AS $_$select array_to_string($1,',')$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison._agg_as_set_finalfunc(anyarray) OWNER TO unison;

--
-- Name: FUNCTION _agg_as_set_finalfunc(anyarray); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION _agg_as_set_finalfunc(anyarray) IS '''final'' function for as_set aggregate';


--
-- Name: as_set(anyelement); Type: AGGREGATE; Schema: unison; Owner: unison
--

CREATE AGGREGATE as_set(anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    INITCOND = '{}',
    FINALFUNC = _agg_as_set_finalfunc
);


ALTER AGGREGATE unison.as_set(anyelement) OWNER TO unison;

--
-- Name: AGGREGATE as_set(anyelement); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON AGGREGATE as_set(anyelement) IS 'build a comma-separated list of arguments';


--
-- Name: pmap_aln; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_aln (
    aln_id integer NOT NULL,
    hsp_str text NOT NULL,
    ident integer NOT NULL,
    pgap_cnt integer NOT NULL,
    pgap_bases integer NOT NULL,
    ggap_cnt integer NOT NULL,
    ggap_bases integer NOT NULL,
    genasm_id integer NOT NULL,
    pseq_id integer NOT NULL,
    params_id integer NOT NULL
);


ALTER TABLE unison.pmap_aln OWNER TO unison;

--
-- Name: TABLE pmap_aln; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmap_aln IS 'protein to dna PMAP alignments - groups of PMAP HSPs';


--
-- Name: COLUMN pmap_aln.aln_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.aln_id IS 'pmap_aln alignment identifier';


--
-- Name: COLUMN pmap_aln.hsp_str; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.hsp_str IS 'serialized version of the pmap_hsp_ids in the alignment';


--
-- Name: COLUMN pmap_aln.ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.ident IS 'number of identities in the alignment';


--
-- Name: COLUMN pmap_aln.pgap_cnt; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.pgap_cnt IS 'number of query gaps';


--
-- Name: COLUMN pmap_aln.pgap_bases; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.pgap_bases IS 'number of total residues in query gaps';


--
-- Name: COLUMN pmap_aln.ggap_cnt; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.ggap_cnt IS 'number of template gaps';


--
-- Name: COLUMN pmap_aln.ggap_bases; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.ggap_bases IS 'number of total residues in template gaps';


--
-- Name: COLUMN pmap_aln.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN pmap_aln.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pmap_aln.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_aln.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: pmap_alnhsp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_alnhsp (
    aln_id integer NOT NULL,
    hsp_id integer NOT NULL
);


ALTER TABLE unison.pmap_alnhsp OWNER TO unison;

--
-- Name: TABLE pmap_alnhsp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmap_alnhsp IS 'groups protein-to-genome PMAP HSPs into alignments';


--
-- Name: COLUMN pmap_alnhsp.aln_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_alnhsp.aln_id IS 'pmap_aln alignment identifier';


--
-- Name: pmap_hsp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_hsp (
    hsp_id integer NOT NULL,
    chr text NOT NULL,
    strand character(1) NOT NULL,
    genasm_id integer NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    pseq_id integer NOT NULL,
    pstart integer NOT NULL,
    pstop integer NOT NULL,
    params_id integer NOT NULL
);


ALTER TABLE unison.pmap_hsp OWNER TO unison;

--
-- Name: TABLE pmap_hsp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmap_hsp IS 'protein to dna PMAP HSPs';


--
-- Name: COLUMN pmap_hsp.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.chr IS 'chromosome (e.g. 1..22,M,U,X,Y for homo sapiens)';


--
-- Name: COLUMN pmap_hsp.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.strand IS 'genomic strand (+/-)';


--
-- Name: COLUMN pmap_hsp.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN pmap_hsp.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.gstart IS 'start of HSP on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: COLUMN pmap_hsp.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.gstop IS 'stop of HSP on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: COLUMN pmap_hsp.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pmap_hsp.pstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.pstart IS 'start of HSP on protein (1-based)';


--
-- Name: COLUMN pmap_hsp.pstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.pstop IS 'stop of HSP on protein (1-based)';


--
-- Name: COLUMN pmap_hsp.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_hsp.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: params_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION params_id(text) RETURNS integer
    AS $_$DECLARE V_id integer; BEGIN select into V_id params_id from params where upper(name)=upper($1); IF NOT FOUND THEN RAISE WARNING 'params ''%'' not found', $1; RETURN NULL; END IF; return V_id; END;$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.params_id(text) OWNER TO unison;

--
-- Name: pmodelset_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmodelset_id(text) RETURNS integer
    AS $_$DECLARE V_id integer; BEGIN select into V_id pmodelset_id from pmodelset where upper(name)=upper($1); IF NOT FOUND THEN RAISE WARNING 'pmodelset ''%'' not found', $1; RETURN NULL; END IF; return V_id; END;$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.pmodelset_id(text) OWNER TO unison;

--
-- Name: current_annotations_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW current_annotations_v AS
    SELECT current_annotations_unsorted_v.pseq_id, current_annotations_unsorted_v.origin_id, current_annotations_unsorted_v.origin, current_annotations_unsorted_v.ann_pref, current_annotations_unsorted_v.palias_id, current_annotations_unsorted_v.tax_id, current_annotations_unsorted_v.k, current_annotations_unsorted_v.gs, current_annotations_unsorted_v.latin, current_annotations_unsorted_v.common, current_annotations_unsorted_v.alias, current_annotations_unsorted_v.descr, current_annotations_unsorted_v.added, current_annotations_unsorted_v.link_url FROM current_annotations_unsorted_v ORDER BY current_annotations_unsorted_v.pseq_id, current_annotations_unsorted_v.ann_pref, (strpos(current_annotations_unsorted_v.alias, '_'::text) = 0), current_annotations_unsorted_v.alias;


ALTER TABLE unison.current_annotations_v OWNER TO unison;

--
-- Name: COLUMN current_annotations_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN current_annotations_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN current_annotations_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN current_annotations_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN current_annotations_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN current_annotations_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN current_annotations_v.k; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.k IS 'Swiss-Prot kingdom code (A=archea; B=bacteria; E=eukaryota; V=viruses)';


--
-- Name: COLUMN current_annotations_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN current_annotations_v.latin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.latin IS 'Latin genus and species';


--
-- Name: COLUMN current_annotations_v.common; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.common IS 'common taxonomic name';


--
-- Name: COLUMN current_annotations_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN current_annotations_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.descr IS 'sequence description';


--
-- Name: COLUMN current_annotations_v.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.added IS 'date that this sequence was assigned this alias';


--
-- Name: COLUMN current_annotations_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN current_annotations_v.link_url IS 'URL to source data';


SET search_path = ncbi, pg_catalog;

--
-- Name: gene2accession; Type: TABLE; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE TABLE gene2accession (
    tax_id integer NOT NULL,
    gene_id integer NOT NULL,
    status text,
    rna_acc text,
    rna_gi integer,
    pro_acc text,
    pro_gi integer,
    gen_acc text,
    gen_gi integer,
    gen_start integer,
    gen_end integer,
    gen_orient character(1),
    assembly text
);


ALTER TABLE ncbi.gene2accession OWNER TO unison;

--
-- Name: TABLE gene2accession; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON TABLE gene2accession IS 'NCBI Entrez Gene <-> RefSeq mapping';


--
-- Name: gene2go; Type: TABLE; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE TABLE gene2go (
    tax_id integer NOT NULL,
    gene_id integer NOT NULL,
    go_id text NOT NULL,
    evidence text,
    qualifier text,
    term text NOT NULL,
    pubmed_id text,
    category text
);


ALTER TABLE ncbi.gene2go OWNER TO unison;

--
-- Name: TABLE gene2go; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON TABLE gene2go IS 'NCBI Entrez Gene <-> GO mapping';


--
-- Name: gene2unigene; Type: TABLE; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE TABLE gene2unigene (
    gene_id integer NOT NULL,
    unigene_acc text NOT NULL
);


ALTER TABLE ncbi.gene2unigene OWNER TO unison;

--
-- Name: TABLE gene2unigene; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON TABLE gene2unigene IS 'NCBI Entrez Gene <-> UniGene mapping';


--
-- Name: gene_info; Type: TABLE; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE TABLE gene_info (
    tax_id integer NOT NULL,
    gene_id integer NOT NULL,
    symbol text,
    locus_tag text,
    synonyms text,
    xrefs text,
    chromosome text,
    map_loc text,
    descr text,
    type text,
    nom_auth_symbol text,
    nom_auth text,
    nom_status character(1),
    other_desig text,
    modification_date date
);


ALTER TABLE ncbi.gene_info OWNER TO unison;

--
-- Name: TABLE gene_info; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON TABLE gene_info IS 'NCBI Entrez Gene information';


--
-- Name: generif; Type: TABLE; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE TABLE generif (
    tax_id integer NOT NULL,
    gene_id integer NOT NULL,
    pubmed_ids text,
    last_update timestamp without time zone NOT NULL,
    generif text
);


ALTER TABLE ncbi.generif OWNER TO unison;

--
-- Name: TABLE generif; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON TABLE generif IS 'NCBI Entrez Gene References into Function';


--
-- Name: COLUMN generif.pubmed_ids; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON COLUMN generif.pubmed_ids IS 'PubMed ids, comma delimited';


--
-- Name: mim2gene; Type: TABLE; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE TABLE mim2gene (
    mim_id integer NOT NULL,
    gene_id integer NOT NULL,
    type text NOT NULL
);


ALTER TABLE ncbi.mim2gene OWNER TO unison;

--
-- Name: TABLE mim2gene; Type: COMMENT; Schema: ncbi; Owner: unison
--

COMMENT ON TABLE mim2gene IS 'NCBI Entrez Gene <-> MIM mapping';


SET search_path = pdb, pg_catalog;

--
-- Name: ligand; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE ligand (
    ligand_id text NOT NULL,
    formula text,
    formula_weight numeric,
    last_modified date NOT NULL,
    formal_charge integer NOT NULL,
    type text NOT NULL
);


ALTER TABLE pdb.ligand OWNER TO unison;

--
-- Name: ligand_atoms; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE ligand_atoms (
    atom_id text NOT NULL,
    ligand_id text NOT NULL,
    type_symbol text NOT NULL,
    alt_atom_id text NOT NULL,
    formal_charge integer NOT NULL,
    aromatic boolean NOT NULL,
    leaving_atom boolean NOT NULL,
    ordinal integer NOT NULL,
    stereo_config character(1) NOT NULL
);


ALTER TABLE pdb.ligand_atoms OWNER TO unison;

--
-- Name: ligand_bonds; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE ligand_bonds (
    atom_id_1 text NOT NULL,
    atom_id_2 text NOT NULL,
    ligand_id text NOT NULL,
    bond_order text NOT NULL,
    ordinal integer NOT NULL,
    aromatic boolean NOT NULL,
    stereo_config character(1) NOT NULL
);


ALTER TABLE pdb.ligand_bonds OWNER TO unison;

--
-- Name: ligand_descriptor_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_descriptor_v AS
    SELECT _ld.ligand_id, _ld.descriptor_origin_id, _do.type, _do.origin, _do.version, _ld.descriptor FROM (ligand_descriptors _ld JOIN descriptor_origin _do ON ((_ld.descriptor_origin_id = _do.descriptor_origin_id)));


ALTER TABLE pdb.ligand_descriptor_v OWNER TO unison;

--
-- Name: VIEW ligand_descriptor_v; Type: COMMENT; Schema: pdb; Owner: unison
--

COMMENT ON VIEW ligand_descriptor_v IS 'ligand descriptors joined to origin definitions';


--
-- Name: ligand_inchi_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_inchi_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE (o.type = 'inchi'::text);


ALTER TABLE pdb.ligand_inchi_v OWNER TO unison;

--
-- Name: ligand_names_all_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_names_all_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE (((o.type = 'name'::text) OR (o.type = 'synonym'::text)) OR (o.type = 'systematic name'::text));


ALTER TABLE pdb.ligand_names_all_v OWNER TO unison;

--
-- Name: ligand_smiles_acdlabs_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_acdlabs_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE ((o.type = 'smiles'::text) AND (o.origin = 'ACDLabs'::text));


ALTER TABLE pdb.ligand_smiles_acdlabs_v OWNER TO unison;

--
-- Name: ligand_smiles_all_cactvs_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_all_cactvs_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE ((o.origin = 'CACTVS'::text) AND ((o.type = 'smiles'::text) OR (o.type = 'smiles_canonical'::text)));


ALTER TABLE pdb.ligand_smiles_all_cactvs_v OWNER TO unison;

--
-- Name: ligand_smiles_all_oe_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_all_oe_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE (((o.origin = 'OpenEye OEToolkits'::text) OR (o.origin = 'OpenEye/OEToolkits'::text)) AND ((o.type = 'smiles'::text) OR (o.type = 'smiles_canonical'::text)));


ALTER TABLE pdb.ligand_smiles_all_oe_v OWNER TO unison;

--
-- Name: ligand_smiles_all_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_all_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE ((o.type = 'smiles'::text) OR (o.type = 'smiles_canonical'::text));


ALTER TABLE pdb.ligand_smiles_all_v OWNER TO unison;

--
-- Name: ligand_smiles_cactvs_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_cactvs_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE ((o.type = 'smiles'::text) AND (o.origin = 'CACTVS'::text));


ALTER TABLE pdb.ligand_smiles_cactvs_v OWNER TO unison;

--
-- Name: ligand_smiles_canon_cactvs_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_canon_cactvs_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE ((o.type = 'smiles_canonical'::text) AND (o.origin = 'CACTVS'::text));


ALTER TABLE pdb.ligand_smiles_canon_cactvs_v OWNER TO unison;

--
-- Name: ligand_smiles_canon_oe_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_canon_oe_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE ((o.type = 'smiles_canonical'::text) AND ((o.origin = 'OpenEye OEToolkits'::text) OR (o.origin = 'OpenEye/OEToolkits'::text)));


ALTER TABLE pdb.ligand_smiles_canon_oe_v OWNER TO unison;

--
-- Name: ligand_smiles_canon_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_canon_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE (o.type = 'smiles_canonical'::text);


ALTER TABLE pdb.ligand_smiles_canon_v OWNER TO unison;

--
-- Name: ligand_smiles_oe_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_oe_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE ((o.type = 'smiles'::text) AND ((o.origin = 'OpenEye OEToolkits'::text) OR (o.origin = 'OpenEye/OEToolkits'::text)));


ALTER TABLE pdb.ligand_smiles_oe_v OWNER TO unison;

--
-- Name: ligand_smiles_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW ligand_smiles_v AS
    SELECT d.ligand_id, d.descriptor FROM (ligand_descriptors d JOIN descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE (o.type = 'smiles'::text);


ALTER TABLE pdb.ligand_smiles_v OWNER TO unison;

--
-- Name: pdb_ligand; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE pdb_ligand (
    pdbid text NOT NULL,
    ligand_id text NOT NULL
);


ALTER TABLE pdb.pdb_ligand OWNER TO unison;

--
-- Name: pdb_ligand_descriptors_v; Type: VIEW; Schema: pdb; Owner: unison
--

CREATE VIEW pdb_ligand_descriptors_v AS
    SELECT pl.pdbid, pl.ligand_id, ld.descriptor_origin_id, "DO".type, "DO".origin, "DO".version, ld.descriptor FROM (((pdb_ligand pl JOIN ligand l ON ((pl.ligand_id = l.ligand_id))) JOIN ligand_descriptors ld ON ((l.ligand_id = ld.ligand_id))) JOIN descriptor_origin "DO" ON ((ld.descriptor_origin_id = "DO".descriptor_origin_id)));


ALTER TABLE pdb.pdb_ligand_descriptors_v OWNER TO unison;

--
-- Name: residue; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE residue (
    pdbc text NOT NULL,
    seq_pos integer NOT NULL,
    seq_res character(1) NOT NULL,
    atom_res character(1),
    res_id text
);


ALTER TABLE pdb.residue OWNER TO unison;

--
-- Name: TABLE residue; Type: COMMENT; Schema: pdb; Owner: unison
--

COMMENT ON TABLE residue IS 'seqres to atom records correspondence in each pdb chain';


--
-- Name: COLUMN residue.seq_res; Type: COMMENT; Schema: pdb; Owner: unison
--

COMMENT ON COLUMN residue.seq_res IS 'residue from SEQRES records';


--
-- Name: COLUMN residue.atom_res; Type: COMMENT; Schema: pdb; Owner: unison
--

COMMENT ON COLUMN residue.atom_res IS 'residue from ATOM records, null if missing atoms';


--
-- Name: COLUMN residue.res_id; Type: COMMENT; Schema: pdb; Owner: unison
--

COMMENT ON COLUMN residue.res_id IS 'residue identifier, null if missing atoms';


--
-- Name: summary; Type: TABLE; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE TABLE summary (
    pdbid text NOT NULL,
    method text,
    resolution numeric,
    title text NOT NULL,
    header text,
    source text,
    added timestamp with time zone NOT NULL,
    md5 character(32) NOT NULL,
    r_factor numeric,
    r_free numeric,
    CONSTRAINT summary_pdbid_length_ck CHECK ((length(pdbid) = 4))
);


ALTER TABLE pdb.summary OWNER TO unison;

SET search_path = pgutils, pg_catalog;

--
-- Name: column_descriptions; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW column_descriptions AS
    SELECT n.nspname, c.relname, c.relkind, a.attname, d.description FROM (((pg_attribute a JOIN pg_class c ON ((a.attrelid = c.oid))) JOIN pg_namespace n ON ((c.relnamespace = n.oid))) LEFT JOIN pg_description d ON ((((a.attrelid = d.objoid) AND (a.attnum = d.objsubid)) AND (d.classoid = ('pg_class'::regclass)::oid)))) WHERE ((a.attnum > 0) AND ((c.relkind = 'v'::"char") OR (c.relkind = 'r'::"char")));


ALTER TABLE pgutils.column_descriptions OWNER TO rkh;

--
-- Name: VIEW column_descriptions; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW column_descriptions IS 'all column descriptions';


--
-- Name: database_sizes; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW database_sizes AS
    SELECT x.size_mb, x.datname FROM (SELECT 1 AS _order, round(((pg_database_size(pg_database.datname))::numeric / 1000000.0), 2) AS size_mb, pg_database.datname FROM pg_database UNION SELECT 2 AS _order, round(sum(((pg_database_size(pg_database.datname))::numeric / 1000000.0)), 2) AS size_mb, 'TOTAL' AS datname FROM pg_database) x ORDER BY x._order, x.datname;


ALTER TABLE pgutils.database_sizes OWNER TO rkh;

--
-- Name: VIEW database_sizes; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW database_sizes IS 'all databases and sizes [in SI MB (10^6 bytes)]';


--
-- Name: dependencies; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW dependencies AS
    SELECT DISTINCT pc.relkind AS r_relkind, pn.nspname AS p_nspname, pc.relname AS p_relname, cc.relkind AS c_relkind, cn.nspname AS c_namespace, cc.relname AS c_relname FROM ((((pg_depend d JOIN pg_class cc ON ((d.objid = cc.oid))) JOIN pg_class pc ON ((d.refobjid = pc.oid))) JOIN pg_namespace cn ON ((cc.relnamespace = cn.oid))) JOIN pg_namespace pn ON ((pc.relnamespace = pn.oid))) WHERE ((pc.relkind = ANY (ARRAY['i'::"char", 'r'::"char"])) AND (cc.relkind = ANY (ARRAY['i'::"char", 'r'::"char"]))) ORDER BY pn.nspname, pc.relname, pc.relkind, cn.nspname, cc.relname, cc.relkind;


ALTER TABLE pgutils.dependencies OWNER TO rkh;

--
-- Name: VIEW dependencies; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW dependencies IS 'all table, index dependencies (no views, yet)';


--
-- Name: foreign_keys; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW foreign_keys AS
    SELECT fkn.nspname AS fk_namespace, fkr.relname AS fk_relation, fka.attname AS fk_column, fka.attnotnull AS fk_notnull, (EXISTS (SELECT pg_index.indexrelid, pg_index.indrelid, pg_index.indkey, pg_index.indclass, pg_index.indnatts, pg_index.indisunique, pg_index.indisprimary, pg_index.indisclustered, pg_index.indexprs, pg_index.indpred FROM pg_index WHERE ((pg_index.indrelid = fkr.oid) AND (pg_index.indkey[0] = fka.attnum)))) AS fk_indexed, pkn.nspname AS pk_namespace, pkr.relname AS pk_relation, pka.attname AS pk_column, (EXISTS (SELECT pg_index.indexrelid, pg_index.indrelid, pg_index.indkey, pg_index.indclass, pg_index.indnatts, pg_index.indisunique, pg_index.indisprimary, pg_index.indisclustered, pg_index.indexprs, pg_index.indpred FROM pg_index WHERE ((pg_index.indrelid = pkr.oid) AND (pg_index.indkey[0] = pka.attnum)))) AS pk_indexed, ((c.confupdtype)::text || (c.confdeltype)::text) AS ud, cn.nspname AS c_namespace, c.conname AS c_name FROM (((((((pg_constraint c JOIN pg_namespace cn ON ((cn.oid = c.connamespace))) JOIN pg_class fkr ON ((fkr.oid = c.conrelid))) JOIN pg_namespace fkn ON ((fkn.oid = fkr.relnamespace))) JOIN pg_attribute fka ON (((fka.attrelid = c.conrelid) AND (fka.attnum = ANY (c.conkey))))) JOIN pg_class pkr ON ((pkr.oid = c.confrelid))) JOIN pg_namespace pkn ON ((pkn.oid = pkr.relnamespace))) JOIN pg_attribute pka ON (((pka.attrelid = c.confrelid) AND (pka.attnum = ANY (c.confkey))))) WHERE (c.contype = 'f'::"char");


ALTER TABLE pgutils.foreign_keys OWNER TO rkh;

--
-- Name: VIEW foreign_keys; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW foreign_keys IS 'PK-FK constraints, including indexes and cascade traits';


--
-- Name: foreign_keys_missing_indexes; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW foreign_keys_missing_indexes AS
    SELECT foreign_keys.fk_namespace, foreign_keys.fk_relation, foreign_keys.fk_column, foreign_keys.fk_notnull, foreign_keys.fk_indexed, foreign_keys.pk_namespace, foreign_keys.pk_relation, foreign_keys.pk_column, foreign_keys.pk_indexed, foreign_keys.ud, foreign_keys.c_namespace, foreign_keys.c_name FROM foreign_keys WHERE ((foreign_keys.ud ~ '[^a]'::text) AND (NOT foreign_keys.fk_indexed)) ORDER BY foreign_keys.pk_relation, foreign_keys.pk_column, foreign_keys.fk_relation, foreign_keys.fk_column;


ALTER TABLE pgutils.foreign_keys_missing_indexes OWNER TO rkh;

--
-- Name: VIEW foreign_keys_missing_indexes; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW foreign_keys_missing_indexes IS 'foreign keys with cascading constrains that do not have indexes';


--
-- Name: foreign_keys_pp; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW foreign_keys_pp AS
    SELECT ((((((foreign_keys.fk_namespace)::text || '.'::text) || (foreign_keys.fk_relation)::text) || '('::text) || (foreign_keys.fk_column)::text) || ')'::text) AS fk, ((((((foreign_keys.pk_namespace)::text || '.'::text) || (foreign_keys.pk_relation)::text) || '('::text) || (foreign_keys.pk_column)::text) || ')'::text) AS pk, ((((((foreign_keys.c_namespace)::text || '.'::text) || (foreign_keys.c_name)::text) || '('::text) || foreign_keys.ud) || ')'::text) AS "constraint", foreign_keys.fk_indexed, foreign_keys.fk_notnull, foreign_keys.pk_indexed FROM foreign_keys ORDER BY ((((((foreign_keys.fk_namespace)::text || '.'::text) || (foreign_keys.fk_relation)::text) || '('::text) || (foreign_keys.fk_column)::text) || ')'::text);


ALTER TABLE pgutils.foreign_keys_pp OWNER TO rkh;

--
-- Name: VIEW foreign_keys_pp; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW foreign_keys_pp IS 'PK-FK constraints; see also foreign_keys';


--
-- Name: function_owner_mismatch; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW function_owner_mismatch AS
    SELECT p.oid AS pro_oid, p.proname, p.proowner, up.usename AS pro_usename, p.pronamespace, n.nspname, n.nspowner, un.usename AS nsp_usename FROM (((pg_proc p JOIN pg_user up ON ((p.proowner = up.usesysid))) JOIN pg_namespace n ON ((p.pronamespace = n.oid))) JOIN pg_user un ON ((n.nspowner = un.usesysid))) WHERE (p.proowner <> n.nspowner);


ALTER TABLE pgutils.function_owner_mismatch OWNER TO rkh;

--
-- Name: VIEW function_owner_mismatch; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW function_owner_mismatch IS 'functions whose owner and namespace owner are not equal';


--
-- Name: index_owner_is_not_table_owner; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW index_owner_is_not_table_owner AS
    SELECT nind.nspname AS namespace, i.indrelid AS table_oid, cind.relname AS table_name, uind.usename AS table_owner, i.indexrelid AS index_oid, cindex.relname AS index_name, uindex.usename AS index_owner FROM (((((pg_index i JOIN pg_class cindex ON ((i.indexrelid = cindex.oid))) JOIN pg_class cind ON ((i.indrelid = cind.oid))) JOIN pg_namespace nind ON ((cind.relnamespace = nind.oid))) LEFT JOIN pg_user uindex ON ((cindex.relowner = uindex.usesysid))) LEFT JOIN pg_user uind ON ((cind.relowner = uind.usesysid))) WHERE (cind.relowner <> cindex.relowner);


ALTER TABLE pgutils.index_owner_is_not_table_owner OWNER TO rkh;

--
-- Name: VIEW index_owner_is_not_table_owner; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW index_owner_is_not_table_owner IS 'indexes which are not owned by the table owner';


--
-- Name: indexed_tables; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW indexed_tables AS
    SELECT tn.nspname AS schemaname, tc.relname AS tablename, tt.spcname AS tablespace, i.indisunique AS uniq, i.indisprimary AS pk, i.indisclustered AS cluster, ic.relname AS indexname, tt.spcname AS indexspace, pg_get_indexdef(i.indexrelid) AS indexdef FROM (((((pg_index i JOIN pg_class tc ON ((tc.oid = i.indrelid))) JOIN pg_class ic ON ((ic.oid = i.indexrelid))) LEFT JOIN pg_namespace tn ON ((tn.oid = tc.relnamespace))) LEFT JOIN pg_tablespace tt ON ((tt.oid = tc.reltablespace))) LEFT JOIN pg_tablespace it ON ((it.oid = ic.reltablespace))) WHERE ((tc.relkind = 'r'::"char") AND (ic.relkind = 'i'::"char")) ORDER BY tn.nspname, tc.relname, ic.relname;


ALTER TABLE pgutils.indexed_tables OWNER TO rkh;

--
-- Name: VIEW indexed_tables; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW indexed_tables IS 'all indexed tables, with tablespaces and index info';


--
-- Name: indexed_tables_cluster; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW indexed_tables_cluster AS
    SELECT DISTINCT ON (ti1.schemaname, ti1.tablename) ti1.schemaname, ti1.tablename, (SELECT ti2.indexname FROM indexed_tables ti2 WHERE (((ti1.schemaname = ti2.schemaname) AND (ti1.tablename = ti2.tablename)) AND (ti2.cluster = true))) AS cluster_index FROM indexed_tables ti1 ORDER BY ti1.schemaname, ti1.tablename;


ALTER TABLE pgutils.indexed_tables_cluster OWNER TO rkh;

--
-- Name: VIEW indexed_tables_cluster; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW indexed_tables_cluster IS 'indexed tables with cluster info (NULL if indexed but not clustered)';


--
-- Name: inherited_tables; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW inherited_tables AS
    SELECT sub.relname AS subtable, sup.relname AS supertable FROM pg_class sup, pg_class sub, pg_depend d WHERE (((sup.oid = d.refobjid) AND (d.objid = sub.oid)) AND (sub.relkind = 'r'::"char")) ORDER BY sub.relname;


ALTER TABLE pgutils.inherited_tables OWNER TO rkh;

--
-- Name: VIEW inherited_tables; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW inherited_tables IS 'inherited table relationships';


--
-- Name: locks; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW locks AS
    SELECT l.pid, d.datname AS database, n.nspname AS schema, c.relname AS relation, l.locktype, l.mode, CASE l.granted WHEN true THEN 'RUN'::text ELSE 'WAIT'::text END AS state, a.usename, a.current_query, to_char((now() - a.query_start), 'HH24:MI:SS'::text) AS duration FROM ((((pg_locks l JOIN pg_database d ON ((l.database = d.oid))) JOIN pg_class c ON ((l.relation = c.oid))) JOIN pg_namespace n ON ((c.relnamespace = n.oid))) JOIN pg_stat_activity a ON ((l.pid = a.procpid))) ORDER BY l.pid, d.datname, n.nspname, c.relname, l.granted;


ALTER TABLE pgutils.locks OWNER TO rkh;

--
-- Name: VIEW locks; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW locks IS 'granted and pending locks on all relations';


--
-- Name: oid_names; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW oid_names AS
    (SELECT pg_type.oid, 'pg_type' AS pgtable, pg_type.typname AS name FROM pg_type UNION SELECT pg_proc.oid, 'pg_proc' AS pgtable, pg_proc.proname AS name FROM pg_proc) UNION SELECT pg_class.oid, 'pg_class' AS pgtable, pg_class.relname AS name FROM pg_class;


ALTER TABLE pgutils.oid_names OWNER TO rkh;

--
-- Name: VIEW oid_names; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW oid_names IS 'names for oids in pg_class, pg_proc, pg_type; coverage is better than ::regclass';


--
-- Name: readme; Type: TABLE; Schema: pgutils; Owner: rkh; Tablespace: 
--

CREATE TABLE readme (
    readme text
);


ALTER TABLE pgutils.readme OWNER TO rkh;

--
-- Name: schema_not_owned_by_user; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW schema_not_owned_by_user AS
    SELECT n.nspname, owner.usename FROM ((pg_namespace n JOIN pg_user owner ON ((n.nspowner = owner.usesysid))) JOIN pg_user u ON ((n.nspname = u.usename))) WHERE (n.nspowner <> u.usesysid);


ALTER TABLE pgutils.schema_not_owned_by_user OWNER TO rkh;

--
-- Name: VIEW schema_not_owned_by_user; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW schema_not_owned_by_user IS 'schemas with the same name as a user but which is not owned by the user';


--
-- Name: table_sizes; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW table_sizes AS
    SELECT round(((pg_relation_size((((s.nspname)::text || '.'::text) || (c.relname)::text)))::numeric / 1000000.0), 2) AS size_mb, s.nspowner, so.usename AS nspowner_name, s.nspname, c.relowner, co.usename AS relowner_name, c.relname FROM (((pg_namespace s JOIN pg_class c ON ((s.oid = c.relnamespace))) JOIN pg_user so ON ((s.nspowner = so.usesysid))) JOIN pg_user co ON ((c.relowner = co.usesysid))) WHERE (c.relkind = 'r'::"char") ORDER BY s.nspname, c.relkind, c.relname;


ALTER TABLE pgutils.table_sizes OWNER TO rkh;

--
-- Name: VIEW table_sizes; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW table_sizes IS 'all tables and sizes [in SI MB (10^6 bytes)]';


--
-- Name: schema_sizes; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW schema_sizes AS
    SELECT table_sizes.nspname, table_sizes.nspowner_name, sum(table_sizes.size_mb) AS size_mb FROM table_sizes GROUP BY table_sizes.nspname, table_sizes.nspowner_name ORDER BY table_sizes.nspname;


ALTER TABLE pgutils.schema_sizes OWNER TO rkh;

--
-- Name: VIEW schema_sizes; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW schema_sizes IS 'all schemas and sizes [in SI MB (10^6 bytes)]';


--
-- Name: table_cluster_index; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW table_cluster_index AS
    SELECT rn.nspname, rc.relname, (SELECT ic.relname FROM (pg_index i JOIN pg_class ic ON ((i.indexrelid = ic.oid))) WHERE ((rc.oid = i.indrelid) AND (i.indisclustered = true))) AS cluster_index FROM (pg_class rc JOIN pg_namespace rn ON ((rc.relnamespace = rn.oid))) WHERE (rc.relkind = 'r'::"char") ORDER BY rn.nspname, rc.relname;


ALTER TABLE pgutils.table_cluster_index OWNER TO rkh;

--
-- Name: VIEW table_cluster_index; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW table_cluster_index IS 'all tables, with cluster index when such exists';


--
-- Name: table_columns; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW table_columns AS
    SELECT n.nspname, c.relname, a.attname FROM ((pg_attribute a JOIN pg_class c ON ((a.attrelid = c.oid))) JOIN pg_namespace n ON ((c.relnamespace = n.oid)));


ALTER TABLE pgutils.table_columns OWNER TO rkh;

--
-- Name: VIEW table_columns; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW table_columns IS 'all schema,table,column tuples; primarily useful for consistency checks';


--
-- Name: table_perms; Type: VIEW; Schema: pgutils; Owner: rkh
--

CREATE VIEW table_perms AS
    SELECT n.nspname AS schemaname, c.relname AS tablename, pg_get_userbyid(c.relowner) AS tableowner, c.relacl AS perms FROM (pg_class c LEFT JOIN pg_namespace n ON ((n.oid = c.relnamespace))) WHERE (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char"])) ORDER BY n.nspname, c.relname;


ALTER TABLE pgutils.table_perms OWNER TO rkh;

--
-- Name: VIEW table_perms; Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON VIEW table_perms IS 'all table permissions; primarily useful for consistency checks';


SET search_path = unison, pg_catalog;

--
-- Name: best_annotation_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE best_annotation_mv (
    pseq_id integer,
    origin_id integer,
    origin text,
    ann_pref integer,
    palias_id integer,
    tax_id integer,
    k character(1),
    gs text,
    latin text,
    common text,
    alias text,
    descr text,
    added timestamp with time zone,
    link_url text
);


ALTER TABLE unison.best_annotation_mv OWNER TO unison;

--
-- Name: TABLE best_annotation_mv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE best_annotation_mv IS 'materialized view of best annotation_v, which see';


--
-- Name: COLUMN best_annotation_mv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN best_annotation_mv.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN best_annotation_mv.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN best_annotation_mv.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN best_annotation_mv.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN best_annotation_mv.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN best_annotation_mv.k; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.k IS 'Swiss-Prot kingdom code (A=archea; B=bacteria; E=eukaryota; V=viruses)';


--
-- Name: COLUMN best_annotation_mv.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN best_annotation_mv.latin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.latin IS 'Latin genus and species';


--
-- Name: COLUMN best_annotation_mv.common; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.common IS 'common taxonomic name';


--
-- Name: COLUMN best_annotation_mv.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.alias IS 'alias for the sequence';


--
-- Name: COLUMN best_annotation_mv.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.added IS 'date that this sequence was assigned this alias';


--
-- Name: COLUMN best_annotation_mv.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_mv.link_url IS 'URL to source data';


--
-- Name: pseq_locus(integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_locus(integer, integer, integer) RETURNS text
    AS $_$select locus_fmt(chr,strand,gstart,gstop) from pmap_unambiguous_v where pseq_id=$1 and genasm_id=$2 and params_id=$3;$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.pseq_locus(integer, integer, integer) OWNER TO unison;

--
-- Name: FUNCTION pseq_locus(integer, integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pseq_locus(integer, integer, integer) IS 'unambiguous genomic location of pseq_id on given genome with given params; NULL if alignment is ambiguous or not available';


--
-- Name: pmap_locus_representative_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_locus_representative_mv (
    genasm_id integer,
    params_id integer,
    chr text,
    strand character(1),
    q_pseq_id integer,
    q_gstart integer,
    q_gstop integer,
    t_pseq_id integer,
    t_gstart integer,
    t_gstop integer,
    palias_id integer,
    origin_id integer,
    origin text,
    alias text,
    descr text,
    link_url text
);


ALTER TABLE unison.pmap_locus_representative_mv OWNER TO unison;

--
-- Name: TABLE pmap_locus_representative_mv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmap_locus_representative_mv IS 'mat view of pmap_genomic_representative_v';


SET search_path = sst, pg_catalog;

--
-- Name: v_trans; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE v_trans (
    dnaid integer NOT NULL,
    pseq_id integer NOT NULL
);


ALTER TABLE sst.v_trans OWNER TO unison;

--
-- Name: v_unq2dna; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE v_unq2dna (
    dnaid integer NOT NULL,
    proid integer NOT NULL,
    unqid integer NOT NULL,
    unqname text,
    shortname text
);


ALTER TABLE sst.v_unq2dna OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: ncbi_pseq_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE ncbi_pseq_mv (
    tax_id integer,
    gene_id integer,
    status text,
    rna_acc text,
    rna_gi integer,
    pro_acc text,
    pro_gi integer,
    gen_acc text,
    gen_gi integer,
    gen_start integer,
    gen_end integer,
    gen_orient character(1),
    assembly text,
    rna_acc_trunc text,
    pro_acc_trunc text,
    gen_acc_trunc text,
    pseq_id integer
);


ALTER TABLE unison.ncbi_pseq_mv OWNER TO unison;

--
-- Name: pmap_gg_representative_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_gg_representative_mv (
    genasm_id integer,
    params_id integer,
    chr text,
    strand character(1),
    q_pseq_id integer,
    q_gstart integer,
    q_gstop integer,
    t_pseq_id integer,
    t_gstart integer,
    t_gstop integer,
    palias_id integer,
    origin_id integer,
    origin text,
    alias text,
    descr text,
    unqid integer,
    proid integer,
    dnaid integer,
    link_url text
);


ALTER TABLE unison.pmap_gg_representative_mv OWNER TO unison;

--
-- Name: all_annotations_unsorted_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW all_annotations_unsorted_v AS
    SELECT sa.pseq_id, sa.is_current, o.ann_pref, ao.origin_id, o.origin, ao.tax_id, t.gs, ao.alias, ao.descr, ao.palias_id, sa.added AS assigned FROM (((paliasorigin ao JOIN pseqalias sa ON ((ao.palias_id = sa.palias_id))) JOIN origin o ON ((o.origin_id = ao.origin_id))) LEFT JOIN tax.spspec t ON ((ao.tax_id = t.tax_id)));


ALTER TABLE unison.all_annotations_unsorted_v OWNER TO unison;

--
-- Name: COLUMN all_annotations_unsorted_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN all_annotations_unsorted_v.is_current; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.is_current IS 'true if this annotation is current for the sequence; an alias may refer to only one sequence at any time';


--
-- Name: COLUMN all_annotations_unsorted_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN all_annotations_unsorted_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN all_annotations_unsorted_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN all_annotations_unsorted_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN all_annotations_unsorted_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN all_annotations_unsorted_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN all_annotations_unsorted_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.descr IS 'sequence description';


--
-- Name: COLUMN all_annotations_unsorted_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_unsorted_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: papseq_pdbcs_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW papseq_pdbcs_v AS
    SELECT b.q_pseq_id, b.q_start, b.q_stop, b.t_pseq_id, b.t_start, b.t_stop, a.alias AS pdbc, a.descr, a.tax_id, b.ident, b.sim, b.gaps, b.qgaps AS q_gaps, b.tgaps AS t_gaps, b.score, b.eval, b.len, b.pct_ident, b.pct_coverage FROM (papseq_v b JOIN palias a ON (((b.t_pseq_id = a.pseq_id) AND (a.origin_id = origin_id('PDB'::text)))));


ALTER TABLE unison.papseq_pdbcs_v OWNER TO unison;

--
-- Name: VIEW papseq_pdbcs_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW papseq_pdbcs_v IS 'candidated templates for given pseq_id';


--
-- Name: COLUMN papseq_pdbcs_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN papseq_pdbcs_v.q_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.q_start IS 'start position in q_pseq_id';


--
-- Name: COLUMN papseq_pdbcs_v.q_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.q_stop IS 'stop position in q_pseq_id';


--
-- Name: COLUMN papseq_pdbcs_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN papseq_pdbcs_v.t_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.t_start IS 'start position in target pseq_id';


--
-- Name: COLUMN papseq_pdbcs_v.t_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.t_stop IS 'stop position in target pseq_id';


--
-- Name: COLUMN papseq_pdbcs_v.pdbc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.pdbc IS 'PDB identifier + chain (''pdbc'')';


--
-- Name: COLUMN papseq_pdbcs_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN papseq_pdbcs_v.t_gaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.t_gaps IS 'gaps is target sequence';


--
-- Name: COLUMN papseq_pdbcs_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.score IS 'algorithm-specific score';


--
-- Name: COLUMN papseq_pdbcs_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.eval IS 'expectation value';


--
-- Name: COLUMN papseq_pdbcs_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.pct_ident IS 'percent identity';


--
-- Name: COLUMN papseq_pdbcs_v.pct_coverage; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papseq_pdbcs_v.pct_coverage IS 'percent coverage';


SET search_path = tax, pg_catalog;

--
-- Name: gs2tax_id(text); Type: FUNCTION; Schema: tax; Owner: unison
--

CREATE FUNCTION gs2tax_id(text) RETURNS integer
    AS $_$select tax_id from tax.spspec where upper(gs)=upper($1)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION tax.gs2tax_id(text) OWNER TO unison;

--
-- Name: FUNCTION gs2tax_id(text); Type: COMMENT; Schema: tax; Owner: unison
--

COMMENT ON FUNCTION gs2tax_id(text) IS 'convert gs (genus species) to NCBI tax_id';


SET search_path = unison, pg_catalog;

--
-- Name: domain_digest(integer, integer, text, integer, double precision); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text) RETURNS text
    AS $$
BEGIN
	select into digest domain_digest(pstart,pstop,name,score||';'||eval);
END;
$$
    LANGUAGE plpgsql IMMUTABLE;


ALTER FUNCTION unison.domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text) OWNER TO unison;

--
-- Name: FUNCTION domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text) IS 'formatted domain summary, like start-stop:domain(score,eval)';


--
-- Name: link_url(integer, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION link_url(integer, text) RETURNS text
    AS $_$
DECLARE
	row record;
	_o alias for $1;
	_a text = $2;
BEGIN
	SELECT INTO row origin,link_url FROM origin WHERE origin_id=_o;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'origin_id=% does not exist', _o;
	END IF;
	IF row.link_url IS NULL THEN
		RAISE DEBUG 'link_url for origin_id=% is null', _o;
	END IF;

	IF row.origin ~ '^Pfam' THEN
		-- Pfam links against only the unversioned accession
		_a = split_part(_a,'.',1);
	END IF;

	-- %a -- alias
	-- %s -- alias, deprecated
	return replace(replace(row.link_url,'%a',_a),'%s',_a);
END;
$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.link_url(integer, text) OWNER TO unison;

--
-- Name: FUNCTION link_url(integer, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION link_url(integer, text) IS 'create URL to the origin_id $1 for alias/query $2';


--
-- Name: pseq_features_hmm_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_hmm_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.start, f.stop, f.score, f.eval, m.origin_id, o.origin, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, domain_digest(f.start, f.stop, m.name, f.score, f.eval) AS digest, link_url(m.origin_id, m.acc) AS link_url FROM (((((pahmm f JOIN pmhmm m ON ((f.pmodel_id = m.pmodel_id))) JOIN origin o ON ((m.origin_id = o.origin_id))) JOIN params p ON ((f.params_id = p.params_id))) JOIN run r ON ((r.params_id = p.params_id))) JOIN pftype ft ON ((ft.preferred_run_id = r.run_id))) WHERE (((ft.name = 'HMM'::text) AND (m.is_current IS TRUE)) AND (f.eval < (1)::double precision));


ALTER TABLE unison.pseq_features_hmm_v OWNER TO unison;

--
-- Name: VIEW pseq_features_hmm_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_features_hmm_v IS 'current HMM features';


--
-- Name: COLUMN pseq_features_hmm_v.feature_type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.feature_type IS 'type of features (always ''HMM'')';


--
-- Name: COLUMN pseq_features_hmm_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pseq_features_hmm_v.params_name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.params_name IS 'parameter set name -- see params(name)';


--
-- Name: COLUMN pseq_features_hmm_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pseq_features_hmm_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_hmm_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_hmm_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.score IS 'algorithm-specific score';


--
-- Name: COLUMN pseq_features_hmm_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.eval IS 'expectation value';


--
-- Name: COLUMN pseq_features_hmm_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pseq_features_hmm_v.feature; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.feature IS 'name of feature (Pfam name)';


--
-- Name: COLUMN pseq_features_hmm_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.descr IS 'HMM description';


--
-- Name: COLUMN pseq_features_hmm_v.details; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.details IS 'prediction details';


--
-- Name: COLUMN pseq_features_hmm_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_hmm_v.link_url IS 'URL to source data';


--
-- Name: palias_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW palias_v AS
    SELECT sa.pseq_id, ao.palias_id, ao.tax_id, tax.tax_id2gs(ao.tax_id) AS tax_id2gs, ao.origin_id, o.origin, ao.alias, ao.descr, sa.added FROM paliasorigin ao, pseqalias sa, origin o WHERE (((sa.palias_id = ao.palias_id) AND (ao.origin_id = o.origin_id)) AND (sa.is_current = true)) ORDER BY o.ann_pref;


ALTER TABLE unison.palias_v OWNER TO unison;

--
-- Name: COLUMN palias_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN palias_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN palias_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN palias_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN palias_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN palias_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN palias_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.descr IS 'sequence description';


--
-- Name: COLUMN palias_v.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN palias_v.added IS 'date that this sequence was assigned this alias';


--
-- Name: run_history; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE run_history (
    pseq_id integer NOT NULL,
    ran_on timestamp with time zone DEFAULT timenow(),
    failed boolean DEFAULT false NOT NULL,
    run_id integer NOT NULL
);


ALTER TABLE unison.run_history OWNER TO unison;

--
-- Name: TABLE run_history; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE run_history IS 'if/when a query sequence (pseq_id) was run with params_id against targets, perhaps specified by origin_id and/or pmodelset_id';


--
-- Name: COLUMN run_history.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN run_history.pseq_id IS 'pseq_id of query sequence';


--
-- Name: COLUMN run_history.ran_on; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN run_history.ran_on IS 'when this sequence was run with this params against the specified targets';


--
-- Name: COLUMN run_history.failed; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN run_history.failed IS 'True if a program systematically fails with this sequence and parameters. This is useful to prevent repeatedly running problematic <sequence,program,parameter> combinations.';


--
-- Name: COLUMN run_history.run_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN run_history.run_id IS 'identifier for this run (params and modelset), see run(run_id)';


--
-- Name: pftmhmm_tm_count_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pftmhmm_tm_count_v AS
    SELECT rh.pseq_id, r.params_id, (SELECT count(*) AS count FROM pftmhmm WHERE (((pftmhmm.params_id = r.params_id) AND ((pftmhmm.type = 'M'::bpchar) OR (pftmhmm.type = 'N'::bpchar))) AND (pftmhmm.pseq_id = rh.pseq_id))) AS count FROM (run_history rh JOIN run r ON ((r.run_id = rh.run_id))) WHERE (rh.run_id = preferred_run_id_by_pftype('tmhmm'::text));


ALTER TABLE unison.pftmhmm_tm_count_v OWNER TO unison;

--
-- Name: VIEW pftmhmm_tm_count_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pftmhmm_tm_count_v IS 'number of TMHMM-predicted transmembrane domains for each sequence';


--
-- Name: COLUMN pftmhmm_tm_count_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tm_count_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pftmhmm_tm_count_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tm_count_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: seq_len(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION seq_len(q integer, OUT len integer) RETURNS integer
    AS $_$select len from unison.pseq where pseq_id=$1$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.seq_len(q integer, OUT len integer) OWNER TO unison;

--
-- Name: psdisorder; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE psdisorder (
    pseq_id integer NOT NULL,
    params_id integer NOT NULL,
    probs real[] NOT NULL,
    CONSTRAINT prob_vector_seq_size_mismatch CHECK (((array_lower(probs, 1) = 1) AND (array_upper(probs, 1) = seq_len(pseq_id))))
);


ALTER TABLE unison.psdisorder OWNER TO unison;

SET search_path = scop, pg_catalog;

--
-- Name: hie; Type: TABLE; Schema: scop; Owner: unison; Tablespace: 
--

CREATE TABLE hie (
    sunid integer NOT NULL,
    psunid integer,
    children integer[]
);


ALTER TABLE scop.hie OWNER TO unison;

--
-- Name: TABLE hie; Type: COMMENT; Schema: scop; Owner: unison
--

COMMENT ON TABLE hie IS 'SCOP node hierarchy (http://scop.berkeley.edu/)';


SET search_path = sst, pg_catalog;

--
-- Name: dna; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE dna (
    dnaid integer NOT NULL,
    is_primarydna character(1)
);


ALTER TABLE sst.dna OWNER TO unison;

--
-- Name: fam; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE fam (
    famid integer,
    familyname text,
    shortname text
);


ALTER TABLE sst.fam OWNER TO unison;

--
-- Name: TABLE fam; Type: COMMENT; Schema: sst; Owner: unison
--

COMMENT ON TABLE fam IS 'mirror of sst FAM table';


--
-- Name: pro; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE pro (
    proid integer NOT NULL,
    unqid integer,
    proname text,
    formalname text
);


ALTER TABLE sst.pro OWNER TO unison;

--
-- Name: prodna; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE prodna (
    proid integer NOT NULL,
    dnaid integer NOT NULL
);


ALTER TABLE sst.prodna OWNER TO unison;

--
-- Name: spdi_list; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE spdi_list (
    loc text,
    gene text,
    domains text,
    genbank text,
    unqid integer,
    proid integer,
    dnaid integer
);


ALTER TABLE sst.spdi_list OWNER TO unison;

--
-- Name: TABLE spdi_list; Type: COMMENT; Schema: sst; Owner: unison
--

COMMENT ON TABLE spdi_list IS 'direct import from SPDI supplementary data (http://share.gene.com/share/clark.gr.2003/Clark-12930_Supp.doc)';


--
-- Name: unq; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE unq (
    unqid integer NOT NULL,
    shortname text
);


ALTER TABLE sst.unq OWNER TO unison;

--
-- Name: unqfamily; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE unqfamily (
    unqid integer,
    famid integer
);


ALTER TABLE sst.unqfamily OWNER TO unison;

--
-- Name: TABLE unqfamily; Type: COMMENT; Schema: sst; Owner: unison
--

COMMENT ON TABLE unqfamily IS 'mirror of sst UNQFAMILY table';


--
-- Name: unqproform; Type: TABLE; Schema: sst; Owner: unison; Tablespace: 
--

CREATE TABLE unqproform (
    unqid integer NOT NULL,
    proid integer NOT NULL
);


ALTER TABLE sst.unqproform OWNER TO unison;

SET search_path = taxonomy, pg_catalog;

--
-- Name: division; Type: TABLE; Schema: taxonomy; Owner: unison; Tablespace: 
--

CREATE TABLE division (
    division_id integer NOT NULL,
    code character(3),
    name text,
    comments text
);


ALTER TABLE taxonomy.division OWNER TO unison;

--
-- Name: name; Type: TABLE; Schema: taxonomy; Owner: unison; Tablespace: 
--

CREATE TABLE name (
    tax_id integer,
    name text,
    uname text,
    class text
);


ALTER TABLE taxonomy.name OWNER TO unison;

--
-- Name: node; Type: TABLE; Schema: taxonomy; Owner: unison; Tablespace: 
--

CREATE TABLE node (
    tax_id integer NOT NULL,
    parent_tax_id integer,
    rank text,
    embl text,
    division_id integer,
    divinh boolean,
    gbhidden boolean,
    hidden boolean,
    comments text
);


ALTER TABLE taxonomy.node OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: _deprecated_pseq_gene_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _deprecated_pseq_gene_v AS
    SELECT DISTINCT sa.pseq_id, ao.tax_id, ga.gene_id, gr.pubmed_ids, gr.generif FROM (((pseqalias sa JOIN paliasorigin ao ON (((sa.palias_id = ao.palias_id) AND (ao.origin_id = origin_id('RefSeq'::text))))) JOIN ncbi.gene2accession ga ON (((ao.alias = ga.pro_acc) AND (ao.tax_id = ga.tax_id)))) LEFT JOIN ncbi.generif gr ON (((ga.gene_id = gr.gene_id) AND (ao.tax_id = gr.tax_id)))) ORDER BY sa.pseq_id, ao.tax_id, ga.gene_id, gr.generif, gr.pubmed_ids;


ALTER TABLE unison._deprecated_pseq_gene_v OWNER TO unison;

--
-- Name: _infer_tax_id_ensembl_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _infer_tax_id_ensembl_v AS
    SELECT paliasorigin.origin_id, paliasorigin.palias_id, paliasorigin.tax_id, CASE WHEN (paliasorigin.origin_id = origin_id('Ensembl/Chimp'::text)) THEN tax.gs2tax_id('PANTR'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Cow'::text)) THEN tax.gs2tax_id('BOVIN'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Fly'::text)) THEN tax.gs2tax_id('DROME'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Human'::text)) THEN tax.gs2tax_id('HUMAN'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Mouse'::text)) THEN tax.gs2tax_id('MOUSE'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Rat'::text)) THEN tax.gs2tax_id('RAT'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Zebrafish'::text)) THEN tax.gs2tax_id('BRARE'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Chimp (ab initio)'::text)) THEN tax.gs2tax_id('PANTR'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Cow (ab initio)'::text)) THEN tax.gs2tax_id('BOVIN'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Fly (ab initio)'::text)) THEN tax.gs2tax_id('DROME'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Human (ab initio)'::text)) THEN tax.gs2tax_id('HUMAN'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Mouse (ab initio)'::text)) THEN tax.gs2tax_id('MOUSE'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Rat (ab initio)'::text)) THEN tax.gs2tax_id('RAT'::text) WHEN (paliasorigin.origin_id = origin_id('Ensembl/Zebrafish (ab initio)'::text)) THEN tax.gs2tax_id('BRARE'::text) ELSE NULL::integer END AS inferred_tax_id FROM paliasorigin WHERE ((((((((((((((paliasorigin.origin_id = origin_id('Ensembl/Chimp'::text)) OR (paliasorigin.origin_id = origin_id('Ensembl/Cow'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Fly'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Human'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Mouse'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Rat'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Zebrafish'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Chimp (ab initio)'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Cow (ab initio)'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Fly (ab initio)'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Human (ab initio)'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Mouse (ab initio)'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Rat (ab initio)'::text))) OR (paliasorigin.origin_id = origin_id('Ensembl/Zebrafish (ab initio)'::text)));


ALTER TABLE unison._infer_tax_id_ensembl_v OWNER TO unison;

--
-- Name: COLUMN _infer_tax_id_ensembl_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_ensembl_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN _infer_tax_id_ensembl_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_ensembl_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN _infer_tax_id_ensembl_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_ensembl_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: _infer_tax_id_genengenes_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _infer_tax_id_genengenes_v AS
    SELECT a.origin_id, a.palias_id, a.tax_id, t.tax_id AS inferred_tax_id FROM (paliasorigin a JOIN tax.spspec t ON ((upper("substring"(a.descr, '/species=''([^\'']+)'''::text)) = t.gs))) WHERE (a.origin_id = origin_id('GenenGenes'::text));


ALTER TABLE unison._infer_tax_id_genengenes_v OWNER TO unison;

--
-- Name: COLUMN _infer_tax_id_genengenes_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_genengenes_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN _infer_tax_id_genengenes_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_genengenes_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN _infer_tax_id_genengenes_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_genengenes_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: _infer_tax_id_geneseq_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _infer_tax_id_geneseq_v AS
    SELECT a.origin_id, a.palias_id, a.tax_id, t.tax_id AS inferred_tax_id FROM (paliasorigin a JOIN tax.spspec t ON (("substring"(a.descr, '\[OS: ([^\]]+)'::text) = t.latin))) WHERE (a.origin_id = origin_id('Geneseq'::text));


ALTER TABLE unison._infer_tax_id_geneseq_v OWNER TO unison;

--
-- Name: COLUMN _infer_tax_id_geneseq_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_geneseq_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN _infer_tax_id_geneseq_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_geneseq_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN _infer_tax_id_geneseq_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_geneseq_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: _infer_tax_id_refseq_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _infer_tax_id_refseq_v AS
    SELECT a.origin_id, a.palias_id, a.tax_id, t.tax_id AS inferred_tax_id FROM (paliasorigin a LEFT JOIN tax.spspec t ON ((lower("substring"(a.descr, '\[([^\]]+)\].?$'::text)) = lower(t.latin)))) WHERE (((a.origin_id = origin_id('RefSeq'::text)) OR (a.origin_id = origin_id('RefSeq unversioned'::text))) OR (a.origin_id = origin_id('RefSeq gi'::text)));


ALTER TABLE unison._infer_tax_id_refseq_v OWNER TO unison;

--
-- Name: COLUMN _infer_tax_id_refseq_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_refseq_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN _infer_tax_id_refseq_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_refseq_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN _infer_tax_id_refseq_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_refseq_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: _infer_tax_id_uniprot_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _infer_tax_id_uniprot_v AS
    SELECT a.origin_id, a.palias_id, a.tax_id, t.tax_id AS inferred_tax_id FROM (paliasorigin a JOIN tax.spspec t ON ((substr(a.alias, (strpos(a.alias, '_'::text) + 1)) = t.gs))) WHERE (((a.origin_id = origin_id('UniProtKB/Swiss-Prot'::text)) OR (a.origin_id = origin_id('UniProtKB/TrEMBL'::text))) AND (a.alias ~ '_'::text));


ALTER TABLE unison._infer_tax_id_uniprot_v OWNER TO unison;

--
-- Name: COLUMN _infer_tax_id_uniprot_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_uniprot_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN _infer_tax_id_uniprot_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_uniprot_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN _infer_tax_id_uniprot_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_uniprot_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: _infer_tax_id_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _infer_tax_id_v AS
    (((SELECT _v_infer_tax_id_ensembl.origin_id, _v_infer_tax_id_ensembl.palias_id, _v_infer_tax_id_ensembl.tax_id, _v_infer_tax_id_ensembl.inferred_tax_id FROM _infer_tax_id_ensembl_v _v_infer_tax_id_ensembl UNION ALL SELECT _v_infer_tax_id_genengenes.origin_id, _v_infer_tax_id_genengenes.palias_id, _v_infer_tax_id_genengenes.tax_id, _v_infer_tax_id_genengenes.inferred_tax_id FROM _infer_tax_id_genengenes_v _v_infer_tax_id_genengenes) UNION ALL SELECT _v_infer_tax_id_geneseq.origin_id, _v_infer_tax_id_geneseq.palias_id, _v_infer_tax_id_geneseq.tax_id, _v_infer_tax_id_geneseq.inferred_tax_id FROM _infer_tax_id_geneseq_v _v_infer_tax_id_geneseq) UNION ALL SELECT _v_infer_tax_id_refseq.origin_id, _v_infer_tax_id_refseq.palias_id, _v_infer_tax_id_refseq.tax_id, _v_infer_tax_id_refseq.inferred_tax_id FROM _infer_tax_id_refseq_v _v_infer_tax_id_refseq) UNION ALL SELECT _v_infer_tax_id_uniprot.origin_id, _v_infer_tax_id_uniprot.palias_id, _v_infer_tax_id_uniprot.tax_id, _v_infer_tax_id_uniprot.inferred_tax_id FROM _infer_tax_id_uniprot_v _v_infer_tax_id_uniprot;


ALTER TABLE unison._infer_tax_id_v OWNER TO unison;

--
-- Name: COLUMN _infer_tax_id_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN _infer_tax_id_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN _infer_tax_id_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: _infer_tax_id_changed_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _infer_tax_id_changed_v AS
    SELECT _v_infer_tax_id.origin_id, _v_infer_tax_id.palias_id, _v_infer_tax_id.tax_id, _v_infer_tax_id.inferred_tax_id FROM _infer_tax_id_v _v_infer_tax_id WHERE ((((_v_infer_tax_id.tax_id IS NULL) AND (_v_infer_tax_id.inferred_tax_id IS NOT NULL)) OR ((_v_infer_tax_id.tax_id IS NOT NULL) AND (_v_infer_tax_id.inferred_tax_id IS NULL))) OR (_v_infer_tax_id.tax_id <> _v_infer_tax_id.inferred_tax_id));


ALTER TABLE unison._infer_tax_id_changed_v OWNER TO unison;

--
-- Name: COLUMN _infer_tax_id_changed_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_changed_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN _infer_tax_id_changed_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_changed_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN _infer_tax_id_changed_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN _infer_tax_id_changed_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: _missing_fk_indexes; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _missing_fk_indexes AS
    SELECT foreign_keys.fk_namespace, foreign_keys.fk_relation, foreign_keys.fk_column, foreign_keys.pk_relation, foreign_keys.pk_column, (((((((((('create index '::text || (foreign_keys.fk_relation)::text) || '_'::text) || (foreign_keys.fk_column)::text) || ' on '::text) || (foreign_keys.fk_namespace)::text) || '.'::text) || (foreign_keys.fk_relation)::text) || '('::text) || (foreign_keys.fk_column)::text) || ');'::text) AS sql FROM pgutils.foreign_keys WHERE (((foreign_keys.ud ~ 'c'::text) AND (NOT (foreign_keys.fk_indexed AND foreign_keys.pk_indexed))) AND (foreign_keys.pk_namespace = 'unison'::name)) ORDER BY foreign_keys.pk_relation, foreign_keys.pk_column, foreign_keys.fk_relation, foreign_keys.fk_column;


ALTER TABLE unison._missing_fk_indexes OWNER TO unison;

--
-- Name: VIEW _missing_fk_indexes; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW _missing_fk_indexes IS 'pk-fk relationships which are missing indexes on the fk';


--
-- Name: _pmsm_pmhmm_expand_by_pfam_name; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _pmsm_pmhmm_expand_by_pfam_name AS
    SELECT msm.pmodelset_id, ms.name AS pmodelset_name, m1.name AS model_name, m1.pmodel_id AS pmodel_id1, m1.origin_id AS origin_id1, o1.origin AS origin1, m2.acc AS acc1, m2.pmodel_id AS pmodel_id2, m2.origin_id AS origin_id2, o2.origin AS origin2, m2.acc AS acc2 FROM (((((pmsm_pmhmm msm JOIN pmodelset ms ON ((msm.pmodelset_id = ms.pmodelset_id))) JOIN pmhmm m1 ON ((msm.pmodel_id = m1.pmodel_id))) JOIN pmhmm m2 ON ((m1.name = m2.name))) JOIN origin o1 ON ((m1.origin_id = o1.origin_id))) JOIN origin o2 ON ((m2.origin_id = o2.origin_id))) WHERE (((o1.origin ~* 'pfam'::text) AND (o2.origin ~* 'pfam'::text)) AND (NOT (EXISTS (SELECT ne.pmodelset_id, ne.pmodel_id FROM pmsm_pmhmm ne WHERE ((ne.pmodelset_id = ms.pmodelset_id) AND (ne.pmodel_id = m2.pmodel_id))))));


ALTER TABLE unison._pmsm_pmhmm_expand_by_pfam_name OWNER TO unison;

--
-- Name: VIEW _pmsm_pmhmm_expand_by_pfam_name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW _pmsm_pmhmm_expand_by_pfam_name IS 'identify same-named pfam models to expand pmodelset';


--
-- Name: _pmsm_pmhmm_pfam_upgrade; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW _pmsm_pmhmm_pfam_upgrade AS
    SELECT _pmsm_pmhmm_expand_by_pfam_name.pmodelset_id, _pmsm_pmhmm_expand_by_pfam_name.pmodel_id2 AS pmodel_id FROM _pmsm_pmhmm_expand_by_pfam_name WHERE (_pmsm_pmhmm_expand_by_pfam_name.pmodelset_id = -500);


ALTER TABLE unison._pmsm_pmhmm_pfam_upgrade OWNER TO unison;

--
-- Name: VIEW _pmsm_pmhmm_pfam_upgrade; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW _pmsm_pmhmm_pfam_upgrade IS 'map new pfam models into pmsm_pmhmm with _pmodelset_new_pfam_models';


--
-- Name: _readme; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE _readme (
    readme text
);


ALTER TABLE unison._readme OWNER TO unison;

--
-- Name: TABLE _readme; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE _readme IS 'READ THIS FIRST -- Unison overview and licensing information';


--
-- Name: _tasks; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE _tasks (
    run_order integer NOT NULL,
    sql text NOT NULL
);


ALTER TABLE unison._tasks OWNER TO unison;

--
-- Name: TABLE _tasks; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE _tasks IS 'things to do when building unison';


--
-- Name: alias_pdbcs_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW alias_pdbcs_v AS
    SELECT a.pseq_id, a.alias AS pdbc, a.descr FROM (palias a JOIN pdb.chain c ON ((a.alias = c.pdbc))) WHERE (a.origin_id = origin_id('PDB'::text)) ORDER BY a.alias;


ALTER TABLE unison.alias_pdbcs_v OWNER TO unison;

--
-- Name: VIEW alias_pdbcs_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW alias_pdbcs_v IS 'pseq_ids and alias of sequences which are associated with a structure';


--
-- Name: COLUMN alias_pdbcs_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN alias_pdbcs_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN alias_pdbcs_v.pdbc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN alias_pdbcs_v.pdbc IS 'PDB identifier + chain (''pdbc'')';


--
-- Name: aliases_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW aliases_v AS
    SELECT sa.pseq_id, o.ann_pref, o.origin, ao.alias, t.gs, translate(ao.descr, '	'::text, ': '::text) AS descr FROM (((paliasorigin ao JOIN pseqalias sa ON ((ao.palias_id = sa.palias_id))) JOIN origin o ON ((ao.origin_id = o.origin_id))) LEFT JOIN tax.spspec t ON ((ao.tax_id = t.tax_id))) WHERE (sa.is_current = true);


ALTER TABLE unison.aliases_v OWNER TO unison;

--
-- Name: COLUMN aliases_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN aliases_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN aliases_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN aliases_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN aliases_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN aliases_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN aliases_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN aliases_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN aliases_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN aliases_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN aliases_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN aliases_v.descr IS 'sequence description';


--
-- Name: aliasset; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE aliasset (
    aliasset_id integer NOT NULL,
    owner text DEFAULT "current_user"(),
    descr text,
    is_public boolean DEFAULT false,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone
);


ALTER TABLE unison.aliasset OWNER TO unison;

--
-- Name: aliasset_alias; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE aliasset_alias (
    aliasset_id integer NOT NULL,
    alias text NOT NULL,
    pseq_id integer
);


ALTER TABLE unison.aliasset_alias OWNER TO unison;

--
-- Name: aliasset_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW aliasset_v AS
    SELECT aliasset.aliasset_id, aliasset.owner, aliasset.descr, aliasset.is_public, aliasset.created, aliasset.updated FROM aliasset WHERE ((("current_user"())::text = aliasset.owner) OR (aliasset.is_public IS TRUE));


ALTER TABLE unison.aliasset_v OWNER TO unison;

--
-- Name: aliasset_alias_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW aliasset_alias_v AS
    SELECT aa.aliasset_id, aa.alias, aa.pseq_id FROM (aliasset_v a JOIN aliasset_alias aa ON ((a.aliasset_id = aa.aliasset_id)));


ALTER TABLE unison.aliasset_alias_v OWNER TO unison;

--
-- Name: all_annotations_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW all_annotations_v AS
    SELECT v_all_annotations_unsorted.pseq_id, v_all_annotations_unsorted.is_current, v_all_annotations_unsorted.ann_pref, v_all_annotations_unsorted.origin_id, v_all_annotations_unsorted.origin, v_all_annotations_unsorted.tax_id, v_all_annotations_unsorted.gs, v_all_annotations_unsorted.alias, v_all_annotations_unsorted.descr, v_all_annotations_unsorted.palias_id, v_all_annotations_unsorted.assigned FROM all_annotations_unsorted_v v_all_annotations_unsorted ORDER BY v_all_annotations_unsorted.pseq_id, v_all_annotations_unsorted.is_current DESC, v_all_annotations_unsorted.ann_pref, (strpos(v_all_annotations_unsorted.alias, '_'::text) = 0), v_all_annotations_unsorted.alias;


ALTER TABLE unison.all_annotations_v OWNER TO unison;

--
-- Name: VIEW all_annotations_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW all_annotations_v IS 'all annotations by pseq_id';


--
-- Name: COLUMN all_annotations_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN all_annotations_v.is_current; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.is_current IS 'true if this annotation is current for the sequence; an alias may refer to only one sequence at any time';


--
-- Name: COLUMN all_annotations_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN all_annotations_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN all_annotations_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN all_annotations_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN all_annotations_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN all_annotations_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN all_annotations_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.descr IS 'sequence description';


--
-- Name: COLUMN all_annotations_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN all_annotations_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: known_bcl2_overlaps_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE known_bcl2_overlaps_mv (
    q_pseq_id integer,
    chr text,
    strand text,
    q_gstart text,
    q_gstop text,
    t_pseq_id integer,
    t_gstart text,
    t_gstop text
);


ALTER TABLE unison.known_bcl2_overlaps_mv OWNER TO unison;

--
-- Name: COLUMN known_bcl2_overlaps_mv.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_mv.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN known_bcl2_overlaps_mv.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_mv.chr IS 'chromosome';


--
-- Name: COLUMN known_bcl2_overlaps_mv.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_mv.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: COLUMN known_bcl2_overlaps_mv.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_mv.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN known_bcl2_overlaps_mv.t_gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_mv.t_gstart IS 'genomic start of target sequence';


--
-- Name: COLUMN known_bcl2_overlaps_mv.t_gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_mv.t_gstop IS 'genomic stop of target sequence';


--
-- Name: bcl2_zebrafish_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW bcl2_zebrafish_v AS
    SELECT DISTINCT ON (p.score, p.pseq_id, m.name) (EXISTS (SELECT known_bcl2_overlaps_mv.q_pseq_id FROM known_bcl2_overlaps_mv WHERE ((known_bcl2_overlaps_mv.t_pseq_id = a.pseq_id) OR ((known_bcl2_overlaps_mv.q_pseq_id = a.pseq_id) AND (known_bcl2_overlaps_mv.t_pseq_id IS NULL))))) AS known, a.pseq_id, m.name AS bh_name, p.start AS bh_start, p.stop AS bh_stop, p.mstart AS bh_mstart, p.mstop AS bh_mstop, p.score AS bh_score, p.eval AS bh_eval, t.start AS tm_start, t.stop AS tm_stop, a.alias, a.descr FROM (((pahmm p JOIN pmhmm m ON ((p.pmodel_id = m.pmodel_id))) JOIN palias a ON (((p.pseq_id = a.pseq_id) AND (a.tax_id = tax.gs2tax_id('DANRE'::text))))) LEFT JOIN pftmhmm t ON (((t.pseq_id = a.pseq_id) AND (t.start > p.stop)))) WHERE ((p.params_id = params_id('Bcl-2 ls DEPRECATED'::text)) AND (m.pmodel_id IN (SELECT pmsm_pmhmm.pmodel_id FROM pmsm_pmhmm WHERE (pmsm_pmhmm.pmodelset_id = pmodelset_id('Bcl-2 domains'::text))))) ORDER BY p.score DESC, p.pseq_id, m.name;


ALTER TABLE unison.bcl2_zebrafish_v OWNER TO unison;

--
-- Name: COLUMN bcl2_zebrafish_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN bcl2_zebrafish_v.tm_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_v.tm_start IS 'start position of TM';


--
-- Name: COLUMN bcl2_zebrafish_v.tm_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_v.tm_stop IS 'stop position of TM';


--
-- Name: COLUMN bcl2_zebrafish_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_v.alias IS 'alias for the sequence';


--
-- Name: bcl2_zebrafish_domains_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW bcl2_zebrafish_domains_v AS
    SELECT a.known, a.pseq_id, a.bh_name, a.bh_start, a.bh_stop, a.bh_mstart, a.bh_mstop, a.bh_score, a.bh_eval, a.tm_start, a.tm_stop, a.alias, a.descr, array_to_string(ARRAY(SELECT pf.bh_name FROM bcl2_zebrafish_v pf WHERE ((pf.pseq_id = a.pseq_id) AND (((((((pf.bh_name = 'BH1_TP_FN'::text) AND (pf.bh_score > 21)) OR ((pf.bh_name = 'BH2_TP_FN'::text) AND (pf.bh_score > 13))) OR ((pf.bh_name = 'BH3_TP_FN'::text) AND (pf.bh_score > 12))) OR ((pf.bh_name = 'BH4_1_TP_FN'::text) AND (pf.bh_score > 22))) OR ((pf.bh_name = 'BH4_2_TP_FN'::text) AND (pf.bh_score > 20))) OR ((pf.bh_name = 'Bcl-2_TP'::text) AND (pf.bh_score > 20))))), ','::text) AS domains FROM bcl2_zebrafish_v a;


ALTER TABLE unison.bcl2_zebrafish_domains_v OWNER TO unison;

--
-- Name: COLUMN bcl2_zebrafish_domains_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_domains_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN bcl2_zebrafish_domains_v.tm_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_domains_v.tm_start IS 'start position of TM';


--
-- Name: COLUMN bcl2_zebrafish_domains_v.tm_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_domains_v.tm_stop IS 'stop position of TM';


--
-- Name: COLUMN bcl2_zebrafish_domains_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN bcl2_zebrafish_domains_v.alias IS 'alias for the sequence';


--
-- Name: best_annotation_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW best_annotation_v AS
    SELECT DISTINCT ON (cau.pseq_id, (cau.tax_id <> 9606)) cau.pseq_id, cau.origin_id, cau.origin, cau.ann_pref, cau.palias_id, cau.tax_id, cau.k, cau.gs, cau.latin, cau.common, cau.alias, cau.descr, cau.added, cau.link_url FROM current_annotations_unsorted_v cau ORDER BY cau.pseq_id, (cau.tax_id <> 9606), cau.ann_pref, (strpos(cau.alias, '_'::text) = 0), cau.alias;


ALTER TABLE unison.best_annotation_v OWNER TO unison;

--
-- Name: COLUMN best_annotation_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN best_annotation_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN best_annotation_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN best_annotation_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN best_annotation_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN best_annotation_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN best_annotation_v.k; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.k IS 'Swiss-Prot kingdom code (A=archea; B=bacteria; E=eukaryota; V=viruses)';


--
-- Name: COLUMN best_annotation_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN best_annotation_v.latin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.latin IS 'Latin genus and species';


--
-- Name: COLUMN best_annotation_v.common; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.common IS 'common taxonomic name';


--
-- Name: COLUMN best_annotation_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN best_annotation_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.descr IS 'sequence description';


--
-- Name: COLUMN best_annotation_v.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.added IS 'date that this sequence was assigned this alias';


--
-- Name: COLUMN best_annotation_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN best_annotation_v.link_url IS 'URL to source data';


--
-- Name: better_annotations_unsorted_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW better_annotations_unsorted_v AS
    SELECT current_annotations_unsorted_v.pseq_id, current_annotations_unsorted_v.origin_id, current_annotations_unsorted_v.origin, current_annotations_unsorted_v.ann_pref, current_annotations_unsorted_v.palias_id, current_annotations_unsorted_v.tax_id, current_annotations_unsorted_v.k, current_annotations_unsorted_v.gs, current_annotations_unsorted_v.latin, current_annotations_unsorted_v.common, current_annotations_unsorted_v.alias, current_annotations_unsorted_v.descr, current_annotations_unsorted_v.added, current_annotations_unsorted_v.link_url FROM current_annotations_unsorted_v WHERE (current_annotations_unsorted_v.ann_pref IS NOT NULL);


ALTER TABLE unison.better_annotations_unsorted_v OWNER TO unison;

--
-- Name: COLUMN better_annotations_unsorted_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN better_annotations_unsorted_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN better_annotations_unsorted_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN better_annotations_unsorted_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN better_annotations_unsorted_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN better_annotations_unsorted_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN better_annotations_unsorted_v.k; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.k IS 'Swiss-Prot kingdom code (A=archea; B=bacteria; E=eukaryota; V=viruses)';


--
-- Name: COLUMN better_annotations_unsorted_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN better_annotations_unsorted_v.latin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.latin IS 'Latin genus and species';


--
-- Name: COLUMN better_annotations_unsorted_v.common; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.common IS 'common taxonomic name';


--
-- Name: COLUMN better_annotations_unsorted_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN better_annotations_unsorted_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.descr IS 'sequence description';


--
-- Name: COLUMN better_annotations_unsorted_v.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.added IS 'date that this sequence was assigned this alias';


--
-- Name: COLUMN better_annotations_unsorted_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_unsorted_v.link_url IS 'URL to source data';


--
-- Name: better_annotations_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW better_annotations_v AS
    SELECT better_annotations_unsorted_v.pseq_id, better_annotations_unsorted_v.origin_id, better_annotations_unsorted_v.origin, better_annotations_unsorted_v.ann_pref, better_annotations_unsorted_v.palias_id, better_annotations_unsorted_v.tax_id, better_annotations_unsorted_v.k, better_annotations_unsorted_v.gs, better_annotations_unsorted_v.latin, better_annotations_unsorted_v.common, better_annotations_unsorted_v.alias, better_annotations_unsorted_v.descr, better_annotations_unsorted_v.added, better_annotations_unsorted_v.link_url FROM better_annotations_unsorted_v ORDER BY better_annotations_unsorted_v.pseq_id, better_annotations_unsorted_v.ann_pref, (strpos(better_annotations_unsorted_v.alias, '_'::text) = 0), better_annotations_unsorted_v.alias;


ALTER TABLE unison.better_annotations_v OWNER TO unison;

--
-- Name: COLUMN better_annotations_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN better_annotations_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN better_annotations_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN better_annotations_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN better_annotations_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN better_annotations_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN better_annotations_v.k; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.k IS 'Swiss-Prot kingdom code (A=archea; B=bacteria; E=eukaryota; V=viruses)';


--
-- Name: COLUMN better_annotations_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN better_annotations_v.latin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.latin IS 'Latin genus and species';


--
-- Name: COLUMN better_annotations_v.common; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.common IS 'common taxonomic name';


--
-- Name: COLUMN better_annotations_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN better_annotations_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.descr IS 'sequence description';


--
-- Name: COLUMN better_annotations_v.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.added IS 'date that this sequence was assigned this alias';


--
-- Name: COLUMN better_annotations_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN better_annotations_v.link_url IS 'URL to source data';


--
-- Name: blast_result; Type: TYPE; Schema: unison; Owner: unison
--

CREATE TYPE blast_result AS (
	pfeature_id integer,
	query integer,
	qstart integer,
	qstop integer,
	target integer,
	tstart smallint,
	tstop smallint,
	ident smallint,
	sim smallint,
	gaps smallint,
	qgaps smallint,
	tgaps smallint,
	score integer,
	eval double precision,
	len smallint,
	pct_ident real,
	pct_hsp_coverage real,
	pct_coverage real
);


ALTER TYPE unison.blast_result OWNER TO unison;

--
-- Name: blatloci; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW blatloci AS
    SELECT ah.p2gblataln_id, h.pseq_id, min(h.pstart) AS pstart, max(h.pstop) AS pstop, count(*) AS exons, sum(((h.pstop - h.pstart) + 1)) AS aln_length, ((((sum(((h.pstop - h.pstart) + 1)))::double precision / (q.len)::double precision) * (100)::double precision))::integer AS pct_cov, a.ident, ((((a.ident)::double precision / (sum(((h.pstop - h.pstart) + 1)))::double precision) * (100)::double precision))::integer AS pct_ident, h.genasm_id, h.chr, h.plus_strand, min(h.gstart) AS gstart, max(h.gstop) AS gstop FROM (((p2gblathsp h JOIN p2gblatalnhsp ah ON ((h.p2gblathsp_id = ah.p2gblathsp_id))) JOIN p2gblataln a ON ((ah.p2gblataln_id = a.p2gblataln_id))) JOIN pseq q ON ((h.pseq_id = q.pseq_id))) GROUP BY h.pseq_id, ah.p2gblataln_id, h.genasm_id, h.chr, h.plus_strand, a.ident, q.len ORDER BY h.pseq_id, ((((sum(((h.pstop - h.pstart) + 1)))::double precision / (q.len)::double precision) * (100)::double precision))::integer DESC, ((((a.ident)::double precision / (sum(((h.pstop - h.pstart) + 1)))::double precision) * (100)::double precision))::integer DESC;


ALTER TABLE unison.blatloci OWNER TO unison;

--
-- Name: VIEW blatloci; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW blatloci IS 'summary of BLAT alignments';


--
-- Name: COLUMN blatloci.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN blatloci.pstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.pstart IS 'start of alignment in protein sequence';


--
-- Name: COLUMN blatloci.pstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.pstop IS 'stop of alignment in protein sequence';


--
-- Name: COLUMN blatloci.exons; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.exons IS 'number of exons';


--
-- Name: COLUMN blatloci.aln_length; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.aln_length IS 'length of alignment';


--
-- Name: COLUMN blatloci.pct_cov; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.pct_cov IS 'percent coverage';


--
-- Name: COLUMN blatloci.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.pct_ident IS 'percent identity';


--
-- Name: COLUMN blatloci.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN blatloci.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.chr IS 'chromosome';


--
-- Name: COLUMN blatloci.plus_strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.plus_strand IS 'true = ''+'' strand; false = ''-'' strand';


--
-- Name: COLUMN blatloci.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN blatloci.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN blatloci.gstop IS 'genomic stop position on chromosome';


--
-- Name: canned_views; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE canned_views (
    cv_id integer NOT NULL,
    name text NOT NULL,
    descr text NOT NULL,
    sql text NOT NULL,
    order_by text
);


ALTER TABLE unison.canned_views OWNER TO unison;

--
-- Name: TABLE canned_views; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE canned_views IS 'curated data mining views';


--
-- Name: COLUMN canned_views.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN canned_views.name IS 'view name';


--
-- Name: COLUMN canned_views.order_by; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN canned_views.order_by IS 'optional final order clause for view (independendent of any internal sorting for distinct, etc)';


--
-- Name: e3_and_bh3_cv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW e3_and_bh3_cv AS
    SELECT DISTINCT ON (e3d.pseq_id) e3d.pseq_id, e3d.start AS e3_start, e3d.stop AS e3_stop, e3d.score AS e3_score, e3d.eval AS e3_eval, bh3.start AS bh3_start, bh3.stop AS bh3_stop, bh3.score AS bh3_score, bh3.eval AS bh3_eval, m.name AS e3_name, m.descr AS e3_descr FROM (((pahmm e3d JOIN pahmm bh3 ON ((e3d.pseq_id = bh3.pseq_id))) JOIN pmsm_pmhmm msm ON (((e3d.pmodel_id = msm.pmodel_id) AND (msm.pmodelset_id = pmodelset_id('E3 Ligase Domains'::text))))) JOIN pmhmm m ON ((e3d.pmodel_id = m.pmodel_id))) WHERE (((e3d.params_id = 43) AND (bh3.params_id = 46)) AND (bh3.pmodel_id = 19028469)) ORDER BY e3d.pseq_id, e3d.eval, bh3.score DESC;


ALTER TABLE unison.e3_and_bh3_cv OWNER TO unison;

--
-- Name: ensembl_coordinates_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE ensembl_coordinates_mv (
    pseq_id integer,
    palias_id integer,
    origin_id integer,
    tax_id integer,
    method text,
    genome text,
    chr text,
    gstart text,
    gstop text,
    strand text
);


ALTER TABLE unison.ensembl_coordinates_mv OWNER TO unison;

--
-- Name: COLUMN ensembl_coordinates_mv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN ensembl_coordinates_mv.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN ensembl_coordinates_mv.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN ensembl_coordinates_mv.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN ensembl_coordinates_mv.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.chr IS 'chromosome';


--
-- Name: COLUMN ensembl_coordinates_mv.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN ensembl_coordinates_mv.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.gstop IS 'genomic stop position on chromosome';


--
-- Name: COLUMN ensembl_coordinates_mv.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_mv.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: ensembl_coordinates_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ensembl_coordinates_v AS
    SELECT palias.pseq_id, palias.palias_id, palias.origin_id, palias.tax_id, split_part(split_part(palias.descr, ':'::text, 2), ' '::text, 1) AS method, split_part(palias.descr, ':'::text, 3) AS genome, split_part(palias.descr, ':'::text, 4) AS chr, split_part(palias.descr, ':'::text, 5) AS gstart, split_part(palias.descr, ':'::text, 6) AS gstop, CASE WHEN (split_part(split_part(palias.descr, ':'::text, 7), ' '::text, 1) = (1)::text) THEN '+'::text ELSE '-'::text END AS strand FROM palias WHERE (((palias.origin_id >= 100) AND (palias.origin_id <= 160)) AND (palias.descr ~~ 'pep%'::text));


ALTER TABLE unison.ensembl_coordinates_v OWNER TO unison;

--
-- Name: COLUMN ensembl_coordinates_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN ensembl_coordinates_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN ensembl_coordinates_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN ensembl_coordinates_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN ensembl_coordinates_v.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.chr IS 'chromosome';


--
-- Name: COLUMN ensembl_coordinates_v.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN ensembl_coordinates_v.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.gstop IS 'genomic stop position on chromosome';


--
-- Name: COLUMN ensembl_coordinates_v.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_coordinates_v.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: ensembl_unambiguous_coordinates_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE ensembl_unambiguous_coordinates_mv (
    pseq_id integer,
    palias_id integer,
    origin_id integer,
    tax_id integer,
    method text,
    genome text,
    chr text,
    gstart text,
    gstop text,
    strand text
);


ALTER TABLE unison.ensembl_unambiguous_coordinates_mv OWNER TO unison;

--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.chr IS 'chromosome';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.gstop IS 'genomic stop position on chromosome';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_mv.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_mv.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: ensembl_unambiguous_coordinates_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ensembl_unambiguous_coordinates_v AS
    SELECT e1.pseq_id, e1.palias_id, e1.origin_id, e1.tax_id, e1.method, e1.genome, e1.chr, e1.gstart, e1.gstop, e1.strand FROM (ensembl_coordinates_mv e1 JOIN (SELECT ensembl_coordinates_mv.pseq_id, ensembl_coordinates_mv.genome FROM ensembl_coordinates_mv GROUP BY ensembl_coordinates_mv.pseq_id, ensembl_coordinates_mv.genome HAVING (count(*) = 1)) e2 ON (((e1.pseq_id = e2.pseq_id) AND (e1.genome = e2.genome))));


ALTER TABLE unison.ensembl_unambiguous_coordinates_v OWNER TO unison;

--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.chr IS 'chromosome';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.gstop IS 'genomic stop position on chromosome';


--
-- Name: COLUMN ensembl_unambiguous_coordinates_v.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_coordinates_v.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: ensembl_unambiguous_overlaps_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ensembl_unambiguous_overlaps_v AS
    SELECT a1.genome, a1.chr, a1.strand, a1.pseq_id AS q_pseq_id, a1.gstart AS q_gstart, a1.gstop AS q_gstop, a2.pseq_id AS t_pseq_id, a2.gstart AS t_gstart, a2.gstop AS t_gstop FROM (ensembl_unambiguous_coordinates_mv a1 JOIN ensembl_unambiguous_coordinates_mv a2 ON ((((((a1.genome = a2.genome) AND (a1.chr = a2.chr)) AND (a1.strand = a2.strand)) AND (a2.gstart <= a1.gstop)) AND (a2.gstop >= a1.gstart))));


ALTER TABLE unison.ensembl_unambiguous_overlaps_v OWNER TO unison;

--
-- Name: COLUMN ensembl_unambiguous_overlaps_v.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_v.chr IS 'chromosome';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_v.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_v.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_v.t_gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_v.t_gstart IS 'genomic start of target sequence';


--
-- Name: COLUMN ensembl_unambiguous_overlaps_v.t_gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ensembl_unambiguous_overlaps_v.t_gstop IS 'genomic stop of target sequence';


--
-- Name: sequence_ends(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION sequence_ends(text) RETURNS text
    AS $_$ select sequence_ends($1,5); $_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.sequence_ends(text) OWNER TO unison;

--
-- Name: FUNCTION sequence_ends(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION sequence_ends(text) IS 'equivalent to sequence_ends(seq,5); see sequence_ends(text,integer)';


--
-- Name: extended_annotation_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW extended_annotation_v AS
    SELECT ba.pseq_id, sequence_ends(q.seq) AS sequence_ends, ba.origin_id, ba.origin, ba.ann_pref, ba.palias_id, ba.tax_id, ba.k, ba.gs, ba.latin, ba.common, ba.alias, ba.descr, ba.added, ba.link_url, (EXISTS (SELECT pseqset.pset_id, pseqset.pseq_id FROM pseqset WHERE ((pseqset.pset_id = pset_id('patented'::text)) AND (pseqset.pseq_id = q.pseq_id)))) AS patented, (EXISTS (SELECT pseqset.pset_id, pseqset.pseq_id FROM pseqset WHERE ((pseqset.pset_id = pset_id('patented 98%'::text)) AND (pseqset.pseq_id = q.pseq_id)))) AS "patented98%" FROM (pseq q JOIN best_annotation_mv ba ON ((q.pseq_id = ba.pseq_id)));


ALTER TABLE unison.extended_annotation_v OWNER TO unison;

--
-- Name: VIEW extended_annotation_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW extended_annotation_v IS 'summary of best sequence information';


--
-- Name: fn3_prospect_pmodelset_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW fn3_prospect_pmodelset_dv AS
    SELECT DISTINCT pmprospect_scop.pmodel_id FROM pmprospect_scop_mv pmprospect_scop WHERE (pmprospect_scop.sunid IN (SELECT des.sunid FROM scop.des WHERE ((des.level = 'px'::text) AND (des.sccs ~ 'b[.]1[.]2[.]'::text)))) ORDER BY pmprospect_scop.pmodel_id;


ALTER TABLE unison.fn3_prospect_pmodelset_dv OWNER TO unison;

--
-- Name: COLUMN fn3_prospect_pmodelset_dv.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN fn3_prospect_pmodelset_dv.pmodel_id IS 'unique protein model identifier';


--
-- Name: genasm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE genasm (
    genasm_id integer NOT NULL,
    tax_id integer,
    name text NOT NULL,
    url text
);


ALTER TABLE unison.genasm OWNER TO unison;

--
-- Name: TABLE genasm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE genasm IS 'genome and assembly';


--
-- Name: COLUMN genasm.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN genasm.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN genasm.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN genasm.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN genasm.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN genasm.name IS 'genome assembly name (e.g. NHGD-34)';


--
-- Name: COLUMN genasm.url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN genasm.url IS 'URL of genome assembly';


--
-- Name: gg_famid_pseq_id_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE gg_famid_pseq_id_mv (
    famid integer,
    pseq_id integer
);


ALTER TABLE unison.gg_famid_pseq_id_mv OWNER TO unison;

--
-- Name: TABLE gg_famid_pseq_id_mv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE gg_famid_pseq_id_mv IS 'materialized view of GenenGenes<->pseq_id associations';


--
-- Name: COLUMN gg_famid_pseq_id_mv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN gg_famid_pseq_id_mv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: gg_famid_pseq_id_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW gg_famid_pseq_id_v AS
    SELECT DISTINCT uf.famid, pd.pseq_id FROM ((sst.unqfamily uf JOIN sst.v_unq2dna ud ON ((ud.unqid = uf.unqid))) JOIN sst.v_trans pd ON ((pd.dnaid = ud.dnaid))) ORDER BY uf.famid, pd.pseq_id;


ALTER TABLE unison.gg_famid_pseq_id_v OWNER TO unison;

--
-- Name: VIEW gg_famid_pseq_id_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW gg_famid_pseq_id_v IS 'GenenGenes family-to-sequence mapping';


--
-- Name: COLUMN gg_famid_pseq_id_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN gg_famid_pseq_id_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: homologene_paralogs_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW homologene_paralogs_v AS
    SELECT homologene_pairs_v.hid, homologene_pairs_v.q_pseq_id, homologene_pairs_v.q_acc, homologene_pairs_v.q_tax_id, homologene_pairs_v.q_gene_symbol, homologene_pairs_v.t_pseq_id, homologene_pairs_v.t_acc, homologene_pairs_v.t_tax_id, homologene_pairs_v.t_gene_symbol FROM homologene_pairs_v homologene_pairs_v WHERE (homologene_pairs_v.q_tax_id = homologene_pairs_v.t_tax_id);


ALTER TABLE unison.homologene_paralogs_v OWNER TO unison;

--
-- Name: VIEW homologene_paralogs_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW homologene_paralogs_v IS 'paralogs from homologene_pairs_v';


--
-- Name: COLUMN homologene_paralogs_v.hid; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_paralogs_v.hid IS 'homologene gene family identifier';


--
-- Name: COLUMN homologene_paralogs_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_paralogs_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN homologene_paralogs_v.q_tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_paralogs_v.q_tax_id IS 'tax_id of q_pseq_id';


--
-- Name: COLUMN homologene_paralogs_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_paralogs_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN homologene_paralogs_v.t_tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_paralogs_v.t_tax_id IS 'tax_id of target pseq_id';


--
-- Name: COLUMN homologene_paralogs_v.t_gene_symbol; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN homologene_paralogs_v.t_gene_symbol IS 'target sequence Entrez Gene symbol';


--
-- Name: hmm_pmodel_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION hmm_pmodel_id(text) RETURNS SETOF integer
    AS $_$select pmodel_id from pmhmm where acc=$1 or name=$1 order by added desc;$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.hmm_pmodel_id(text) OWNER TO unison;

--
-- Name: ig_tm_itim_cv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ig_tm_itim_cv AS
    SELECT h.pseq_id, (((h.start)::text || '-'::text) || (h.stop)::text) AS "Ig", h.eval, (((tm.start)::text || '-'::text) || (tm.stop)::text) AS "TM", tm.prob AS tm_prob, (((itim.start)::text || '-'::text) || (itim.stop)::text) AS "ITIM" FROM (((((pahmm h JOIN pftmdetect tm ON ((tm.pseq_id = h.pseq_id))) JOIN pfregexp itim ON ((itim.pseq_id = h.pseq_id))) JOIN run r1 ON ((r1.params_id = h.params_id))) JOIN run r2 ON ((r2.params_id = tm.params_id))) JOIN pmsm_pmhmm ms ON (((ms.pmodel_id = h.pmodel_id) AND (r1.pmodelset_id = ms.pmodelset_id)))) WHERE (((((((h.pmodel_id IN (SELECT hmm_pmodel_id('ig'::text) AS hmm_pmodel_id)) AND (r1.run_id = preferred_run_id_by_pftype('HMM'::text))) AND ((tm.type = 'M'::bpchar) OR (tm.type = 'N'::bpchar))) AND (r2.run_id = preferred_run_id_by_pftype('tmdetect'::text))) AND (itim.pmodel_id = 11368857)) AND (h.stop < tm.start)) AND (tm.stop < itim.start)) ORDER BY h.eval;


ALTER TABLE unison.ig_tm_itim_cv OWNER TO unison;

--
-- Name: pseq_sst_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_sst_v AS
    SELECT DISTINCT a.pseq_id, b.dnaid, b.proid, b.unqid, b.unqname, b.shortname FROM (sst.v_trans a JOIN sst.v_unq2dna b ON ((a.dnaid = b.dnaid))) ORDER BY a.pseq_id, b.dnaid, b.proid, b.unqid, b.unqname, b.shortname;


ALTER TABLE unison.pseq_sst_v OWNER TO unison;

--
-- Name: human_itims_w_unqs_cv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW human_itims_w_unqs_cv AS
    SELECT DISTINCT ON (itim.pseq_id) itim.pseq_id, ug.unqid, CASE WHEN ((EXISTS (SELECT uf.unqid, uf.famid FROM sst.unqfamily uf WHERE ((uf.unqid = ug.unqid) AND (uf.famid = 2502)))) = true) THEN 'Y'::text ELSE 'N'::text END AS "in FAM2502?", itim."Ig", itim.eval, itim."TM", itim.tm_prob, itim."ITIM" FROM (ig_tm_itim_cv itim LEFT JOIN pseq_sst_v ug ON ((itim.pseq_id = ug.pseq_id))) ORDER BY itim.pseq_id;


ALTER TABLE unison.human_itims_w_unqs_cv OWNER TO unison;

--
-- Name: ig_prospect_pmodelset_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ig_prospect_pmodelset_dv AS
    SELECT DISTINCT pmprospect_scop.pmodel_id FROM pmprospect_scop_mv pmprospect_scop WHERE (pmprospect_scop.sunid IN (SELECT des.sunid FROM scop.des WHERE ((des.level = 'px'::text) AND (des.sccs ~ 'b[.]1[.]1[.]'::text)))) ORDER BY pmprospect_scop.pmodel_id;


ALTER TABLE unison.ig_prospect_pmodelset_dv OWNER TO unison;

--
-- Name: VIEW ig_prospect_pmodelset_dv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW ig_prospect_pmodelset_dv IS 'defines set of Fibronectin III prospect templates';


--
-- Name: COLUMN ig_prospect_pmodelset_dv.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_prospect_pmodelset_dv.pmodel_id IS 'unique protein model identifier';


--
-- Name: ig_tm_itim; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ig_tm_itim AS
    SELECT h.pseq_id, (((h.start)::text || '-'::text) || (h.stop)::text) AS "Ig", h.eval, (((tm.start)::text || '-'::text) || (tm.stop)::text) AS "TM", tm.prob AS tm_prob, (((itim.start)::text || '-'::text) || (itim.stop)::text) AS "ITIM", ((ba.origin || ':'::text) || ba.alias) AS alias, ba.gs, ba.descr FROM (((pahmm h JOIN pftmdetect tm ON ((tm.pseq_id = h.pseq_id))) JOIN pfregexp itim ON ((itim.pseq_id = h.pseq_id))) LEFT JOIN best_annotation_mv ba ON ((h.pseq_id = ba.pseq_id))) WHERE (((((h.pmodel_id = 13609290) AND ((tm.type = 'M'::bpchar) OR (tm.type = 'N'::bpchar))) AND (itim.pmodel_id = 11368857)) AND (h.stop < tm.start)) AND (tm.stop < itim.start)) ORDER BY h.eval;


ALTER TABLE unison.ig_tm_itim OWNER TO unison;

--
-- Name: COLUMN ig_tm_itim.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN ig_tm_itim.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim.eval IS 'expectation value';


--
-- Name: COLUMN ig_tm_itim.tm_prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim.tm_prob IS 'maximum tmdetect probability';


--
-- Name: COLUMN ig_tm_itim.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim.alias IS 'alias for the sequence';


--
-- Name: COLUMN ig_tm_itim.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: ig_tm_itim2_cv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ig_tm_itim2_cv AS
    SELECT h.pseq_id, (((h.start)::text || '-'::text) || (h.stop)::text) AS "Ig", h.eval, (((tm.start)::text || '-'::text) || (tm.stop)::text) AS "TM", tm.prob AS tm_prob, (((itim.start)::text || '-'::text) || (itim.stop)::text) AS "ITIM", ((ba.origin || ':'::text) || ba.alias) AS alias, ba.gs, ba.descr FROM (((((pahmm h JOIN pftmdetect tm ON ((tm.pseq_id = h.pseq_id))) JOIN pfregexp itim ON ((itim.pseq_id = h.pseq_id))) JOIN run r1 ON ((r1.params_id = h.params_id))) JOIN run r2 ON ((r2.params_id = tm.params_id))) LEFT JOIN best_annotation_mv ba ON ((h.pseq_id = ba.pseq_id))) WHERE (((((((h.pmodel_id IN (SELECT hmm_pmodel_id('ig'::text) AS hmm_pmodel_id)) AND (r1.run_id = preferred_run_id_by_pftype('HMM'::text))) AND ((tm.type = 'M'::bpchar) OR (tm.type = 'N'::bpchar))) AND (r2.run_id = preferred_run_id_by_pftype('TMDETECT'::text))) AND (itim.pmodel_id = 11368857)) AND (h.stop < tm.start)) AND (tm.stop < itim.start)) ORDER BY h.eval;


ALTER TABLE unison.ig_tm_itim2_cv OWNER TO unison;

--
-- Name: COLUMN ig_tm_itim2_cv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim2_cv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN ig_tm_itim2_cv.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim2_cv.eval IS 'expectation value';


--
-- Name: COLUMN ig_tm_itim2_cv.tm_prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim2_cv.tm_prob IS 'maximum tmdetect probability';


--
-- Name: COLUMN ig_tm_itim2_cv.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim2_cv.alias IS 'alias for the sequence';


--
-- Name: COLUMN ig_tm_itim2_cv.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN ig_tm_itim2_cv.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: itxm_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW itxm_v AS
    SELECT DISTINCT ON (ig.pseq_id) ig.pseq_id, (((ig.start)::text || '-'::text) || (ig.stop)::text) AS "Ig", ig.eval, (((tm.start)::text || '-'::text) || (tm.stop)::text) AS "TM", tm.prob AS tm_prob, (((itam.start)::text || '-'::text) || (itam.stop)::text) AS "ITAM pos", substr(q.seq, itam.start, ((itam.stop - itam.start) + 1)) AS "ITAM seq", (((itim.start)::text || '-'::text) || (itim.stop)::text) AS "ITIM pos", substr(q.seq, itim.start, ((itim.stop - itim.start) + 1)) AS "ITIM seq", (((itsm.start)::text || '-'::text) || (itsm.stop)::text) AS "ITSM pos", substr(q.seq, itsm.start, ((itsm.stop - itsm.start) + 1)) AS "ITSM seq", ((ba.origin || ':'::text) || ba.alias) AS alias, ba.gs, ba.descr FROM (((((((pahmm ig JOIN pseq q ON ((q.pseq_id = ig.pseq_id))) JOIN run r ON ((r.params_id = ig.params_id))) JOIN pftmdetect tm ON ((((tm.pseq_id = ig.pseq_id) AND ((tm.type = 'N'::bpchar) OR (tm.type = 'M'::bpchar))) AND (tm.start > ig.stop)))) LEFT JOIN pfregexp itam ON ((((ig.pseq_id = itam.pseq_id) AND (itam.pmodel_id = 11368858)) AND (itam.start > tm.stop)))) LEFT JOIN pfregexp itim ON ((((ig.pseq_id = itim.pseq_id) AND (itim.pmodel_id = 11368857)) AND (itim.start > tm.stop)))) LEFT JOIN pfregexp itsm ON ((((ig.pseq_id = itsm.pseq_id) AND (itsm.pmodel_id = 11368859)) AND (itsm.start > tm.stop)))) LEFT JOIN best_annotation_mv ba ON ((ig.pseq_id = ba.pseq_id))) WHERE ((((ig.pmodel_id IN (SELECT hmm_pmodel_id('ig'::text) AS hmm_pmodel_id)) AND (r.run_id = preferred_run_id_by_pftype('HMM'::text))) AND (ig.eval <= (1)::double precision)) AND (((itam.start IS NOT NULL) OR (itim.start IS NOT NULL)) OR (itsm.start IS NOT NULL))) ORDER BY ig.pseq_id;


ALTER TABLE unison.itxm_v OWNER TO unison;

--
-- Name: VIEW itxm_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW itxm_v IS 'integrated view of ITAM, ITIM, and ITSM-containing proteins';


--
-- Name: COLUMN itxm_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN itxm_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_v.eval IS 'expectation value';


--
-- Name: COLUMN itxm_v.tm_prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_v.tm_prob IS 'maximum tmdetect probability';


--
-- Name: COLUMN itxm_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN itxm_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: itxm_w_unq_fam_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW itxm_w_unq_fam_v AS
    SELECT v_itxm.gs, v_itxm.pseq_id, v_itxm.alias, ('UNQ'::text || ((SELECT DISTINCT pseq_sst_v.unqid FROM pseq_sst_v WHERE (pseq_sst_v.pseq_id = v_itxm.pseq_id) ORDER BY pseq_sst_v.unqid LIMIT 1))::text) AS unq, CASE WHEN (EXISTS (SELECT fp.famid, fp.pseq_id FROM gg_famid_pseq_id_mv fp WHERE ((fp.pseq_id = v_itxm.pseq_id) AND (fp.famid = 2502)))) THEN 'Y'::text ELSE NULL::text END AS "FAM2502", CASE WHEN (EXISTS (SELECT fp.famid, fp.pseq_id FROM gg_famid_pseq_id_mv fp WHERE ((fp.pseq_id = v_itxm.pseq_id) AND (fp.famid = 2503)))) THEN 'Y'::text ELSE NULL::text END AS "FAM2503", v_itxm."Ig", v_itxm.eval, v_itxm."TM", v_itxm.tm_prob, v_itxm."ITAM pos", v_itxm."ITAM seq", v_itxm."ITIM pos", v_itxm."ITIM seq", v_itxm."ITSM pos", v_itxm."ITSM seq", v_itxm.descr FROM itxm_v v_itxm ORDER BY v_itxm.gs, CASE WHEN (EXISTS (SELECT fp.famid, fp.pseq_id FROM gg_famid_pseq_id_mv fp WHERE ((fp.pseq_id = v_itxm.pseq_id) AND (fp.famid = 2502)))) THEN 'Y'::text ELSE NULL::text END, CASE WHEN (EXISTS (SELECT fp.famid, fp.pseq_id FROM gg_famid_pseq_id_mv fp WHERE ((fp.pseq_id = v_itxm.pseq_id) AND (fp.famid = 2503)))) THEN 'Y'::text ELSE NULL::text END, v_itxm.alias;


ALTER TABLE unison.itxm_w_unq_fam_v OWNER TO unison;

--
-- Name: COLUMN itxm_w_unq_fam_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_w_unq_fam_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN itxm_w_unq_fam_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_w_unq_fam_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN itxm_w_unq_fam_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_w_unq_fam_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN itxm_w_unq_fam_v.unq; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_w_unq_fam_v.unq IS 'Genentech UNQ id';


--
-- Name: COLUMN itxm_w_unq_fam_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_w_unq_fam_v.eval IS 'expectation value';


--
-- Name: COLUMN itxm_w_unq_fam_v.tm_prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN itxm_w_unq_fam_v.tm_prob IS 'maximum tmdetect probability';


--
-- Name: known_bcl2_overlaps_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW known_bcl2_overlaps_v AS
    SELECT a.pseq_id AS q_pseq_id, b.chr, b.strand, b.q_gstart, b.q_gstop, b.t_pseq_id, b.t_gstart, b.t_gstop FROM (pseqset a LEFT JOIN ensembl_unambiguous_overlaps_mv b ON ((a.pseq_id = b.q_pseq_id))) WHERE (a.pset_id = pset_id('Bcl-2 knowns zebrafish'::text));


ALTER TABLE unison.known_bcl2_overlaps_v OWNER TO unison;

--
-- Name: COLUMN known_bcl2_overlaps_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN known_bcl2_overlaps_v.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_v.chr IS 'chromosome';


--
-- Name: COLUMN known_bcl2_overlaps_v.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_v.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: COLUMN known_bcl2_overlaps_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN known_bcl2_overlaps_v.t_gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_v.t_gstart IS 'genomic start of target sequence';


--
-- Name: COLUMN known_bcl2_overlaps_v.t_gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN known_bcl2_overlaps_v.t_gstop IS 'genomic stop of target sequence';


--
-- Name: ligand_smiles_canon_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ligand_smiles_canon_v AS
    SELECT d.ligand_id, d.descriptor FROM (pdb.ligand_descriptors d JOIN pdb.descriptor_origin o ON ((o.descriptor_origin_id = d.descriptor_origin_id))) WHERE (o.type = 'smiles_canonical'::text);


ALTER TABLE unison.ligand_smiles_canon_v OWNER TO unison;

--
-- Name: meta; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE meta (
    key text NOT NULL,
    value text
);


ALTER TABLE unison.meta OWNER TO unison;

--
-- Name: TABLE meta; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE meta IS 'key-value pairs of unison meta data';


--
-- Name: mint; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE mint (
    sprot_a text,
    organism_a text,
    short_label_a text,
    role_a text,
    modifications_a text,
    mutations_a text,
    bd_name_a text,
    bd_range_a text,
    bd_identification_method_a text,
    bd_xref_a text,
    hotspot_range_a text,
    hotspot_identification_method_a text,
    var_splice_xref_a text,
    var_splice_name_a text,
    endogenous_a text,
    tagged_a text,
    sprot_b text,
    organism_b text,
    short_label_b text,
    role_b text,
    modifications_b text,
    mutations_b text,
    bd_name_b text,
    bd_range_b text,
    bd_identification_method_b text,
    bd_xref_b text,
    hotspot_range_b text,
    hotspot_identification_method_b text,
    var_splice_xref text,
    var_splice_name_b text,
    endogenous_b text,
    tagged_b text,
    interaction_type text,
    negation text,
    kd text,
    confidence_measure text,
    confidence_value text,
    target_modified_residues text,
    comments text,
    pmid text,
    interaction_detection_method text,
    participant_detection text,
    vivo text,
    other_ref text
);


ALTER TABLE unison.mint OWNER TO unison;

--
-- Name: TABLE mint; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE mint IS 'Protein-Protein interactions from the MINT database';


--
-- Name: mint_one_way_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW mint_one_way_v AS
    SELECT a1.pseq_id AS pseq_id_a, m.sprot_a, a2.pseq_id AS pseq_id_b, m.sprot_b, m.interaction_detection_method, m.pmid FROM ((mint m JOIN all_annotations_unsorted_v a1 ON ((m.sprot_a = a1.alias))) JOIN all_annotations_unsorted_v a2 ON ((m.sprot_b = a2.alias))) WHERE ((a1.origin_id = origin_id('UniProtKB/Swiss-Prot'::text)) AND (a2.origin_id = origin_id('UniProtKB/Swiss-Prot'::text)));


ALTER TABLE unison.mint_one_way_v OWNER TO unison;

--
-- Name: VIEW mint_one_way_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW mint_one_way_v IS 'abridged view of mint with pseq_ids';


--
-- Name: mint_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW mint_v AS
    SELECT a.pseq_id_a, a.sprot_a, a.pseq_id_b, a.sprot_b, a.interaction_detection_method, a.pmid FROM mint_one_way_v a UNION ALL SELECT a.pseq_id_b AS pseq_id_a, a.sprot_b AS sprot_a, a.pseq_id_a AS pseq_id_b, a.sprot_a AS sprot_b, a.interaction_detection_method, a.pmid FROM mint_one_way_v a;


ALTER TABLE unison.mint_v OWNER TO unison;

--
-- Name: VIEW mint_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW mint_v IS 'symmetric view of mint (mint_one_way_v) with pseq_ids';


--
-- Name: ncbi_pseq_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW ncbi_pseq_v AS
    SELECT ga.tax_id, ga.gene_id, ga.status, ga.rna_acc, ga.rna_gi, ga.pro_acc, ga.pro_gi, ga.gen_acc, ga.gen_gi, ga.gen_start, ga.gen_end, ga.gen_orient, ga.assembly, split_part(ga.rna_acc, '.'::text, 1) AS rna_acc_trunc, split_part(ga.pro_acc, '.'::text, 1) AS pro_acc_trunc, split_part(ga.gen_acc, '.'::text, 1) AS gen_acc_trunc, ca.pseq_id FROM (ncbi.gene2accession ga JOIN current_annotations_unsorted_v ca ON (((ga.pro_acc = ca.alias) AND (ca.origin_id = origin_id('RefSeq'::text)))));


ALTER TABLE unison.ncbi_pseq_v OWNER TO unison;

--
-- Name: VIEW ncbi_pseq_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW ncbi_pseq_v IS 'maps accessions from NCBI''s gene2accession table to pseq_ids via RefSeq protein aliases';


--
-- Name: nearby_sequences_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW nearby_sequences_v AS
    SELECT pseq.pseq_id AS q_pseq_id, pseq.pseq_id AS t_pseq_id, pseq.len, 100 AS pct_ident, 100 AS pct_coverage FROM pseq UNION ALL SELECT v_papseq.q_pseq_id, v_papseq.t_pseq_id, v_papseq.len, v_papseq.pct_ident, v_papseq.pct_coverage FROM papseq_v v_papseq WHERE ((v_papseq.pct_ident > (90)::double precision) AND (v_papseq.pct_coverage > (90)::double precision)) ORDER BY 5 DESC, 4 DESC, 2;


ALTER TABLE unison.nearby_sequences_v OWNER TO unison;

--
-- Name: COLUMN nearby_sequences_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN nearby_sequences_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN nearby_sequences_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN nearby_sequences_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN nearby_sequences_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN nearby_sequences_v.pct_ident IS 'percent identity';


--
-- Name: COLUMN nearby_sequences_v.pct_coverage; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN nearby_sequences_v.pct_coverage IS 'percent coverage';


--
-- Name: orphaned_sequences_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW orphaned_sequences_v AS
    SELECT pseq.pseq_id FROM pseq EXCEPT SELECT pseqalias.pseq_id FROM pseqalias;


ALTER TABLE unison.orphaned_sequences_v OWNER TO unison;

--
-- Name: VIEW orphaned_sequences_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW orphaned_sequences_v IS 'sequences which do not have any alias';


--
-- Name: COLUMN orphaned_sequences_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN orphaned_sequences_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: p2gblataln_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW p2gblataln_v AS
    SELECT ah.p2gblataln_id, h.pseq_id, h.pstart, h.pstop, h.gstart, h.gstop, a.ident, h.genasm_id, h.chr, h.plus_strand FROM ((p2gblathsp h JOIN p2gblatalnhsp ah ON ((h.p2gblathsp_id = ah.p2gblathsp_id))) JOIN p2gblataln a ON ((ah.p2gblataln_id = a.p2gblataln_id))) ORDER BY ah.p2gblataln_id, h.gstart;


ALTER TABLE unison.p2gblataln_v OWNER TO unison;

--
-- Name: COLUMN p2gblataln_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN p2gblataln_v.pstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.pstart IS 'start of alignment in protein sequence';


--
-- Name: COLUMN p2gblataln_v.pstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.pstop IS 'stop of alignment in protein sequence';


--
-- Name: COLUMN p2gblataln_v.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN p2gblataln_v.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.gstop IS 'genomic stop position on chromosome';


--
-- Name: COLUMN p2gblataln_v.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN p2gblataln_v.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.chr IS 'chromosome';


--
-- Name: COLUMN p2gblataln_v.plus_strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN p2gblataln_v.plus_strand IS 'true = ''+'' strand; false = ''-'' strand';


--
-- Name: paprospect_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW paprospect_v AS
    SELECT q.pseq_id, q.params_id, q.pmodel_id, m.pseq_id AS t_pseq_id, m.acc, s.name AS descr, m.origin_id, q.start, q.stop, q.nident, (q.raw)::integer AS raw, round((q.svm)::numeric, 1) AS svm, round((q.mutation)::numeric, 0) AS mutation, round((q.pairwise)::numeric, 0) AS pairwise, round((q.singleton)::numeric, 0) AS singleton, round((q.gap)::numeric, 0) AS gap, q.nalign AS len, q.nalign, CASE WHEN (q.stop < q.start) THEN NULL::numeric ELSE round((((q.nident)::numeric / (q.nalign)::numeric(8,3)) * 100.0), 0) END AS pct_ident, CASE WHEN (q.stop < q.start) THEN NULL::numeric ELSE round((((((q.stop - q.start) + 1))::numeric / (p.len)::numeric) * 100.0), 0) END AS pct_coverage FROM (((paprospect q JOIN pmprospect m ON ((q.pmodel_id = m.pmodel_id))) JOIN pseq p ON ((p.pseq_id = q.pseq_id))) JOIN pdb.chain s ON ((lower(s.pdbc) = lower(m.acc)))) ORDER BY q.svm DESC;


ALTER TABLE unison.paprospect_v OWNER TO unison;

--
-- Name: COLUMN paprospect_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN paprospect_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN paprospect_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN paprospect_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN paprospect_v.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.acc IS 'model accession from source database';


--
-- Name: COLUMN paprospect_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN paprospect_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN paprospect_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN paprospect_v.nident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.nident IS 'number of identical residues';


--
-- Name: COLUMN paprospect_v.raw; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.raw IS 'Prospect ''raw'' score ';


--
-- Name: COLUMN paprospect_v.svm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.svm IS 'Prospect ''svm'' score ';


--
-- Name: COLUMN paprospect_v.singleton; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.singleton IS 'Prospect ''singleton'' score ';


--
-- Name: COLUMN paprospect_v.nalign; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.nalign IS 'number of aligned residues';


--
-- Name: COLUMN paprospect_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.pct_ident IS 'percent identity';


--
-- Name: COLUMN paprospect_v.pct_coverage; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN paprospect_v.pct_coverage IS 'percent coverage';


--
-- Name: papssm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE papssm (
    pftype_id integer DEFAULT pftype_id('PSSM'::text),
    ident smallint NOT NULL,
    sim smallint NOT NULL
)
INHERITS (palignment);


ALTER TABLE unison.papssm OWNER TO unison;

--
-- Name: TABLE papssm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE papssm IS 'PSI-BLAST sequence-profile alignments; inherits palignment';


--
-- Name: COLUMN papssm.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN papssm.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN papssm.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN papssm.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN papssm.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN papssm.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN papssm.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN papssm.mstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.mstart IS 'start of match /in model/';


--
-- Name: COLUMN papssm.mstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.mstop IS 'stop of match /in model/';


--
-- Name: COLUMN papssm.qgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.qgaps IS 'number of gaps in query sequence';


--
-- Name: COLUMN papssm.tgaps; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.tgaps IS 'number of gaps in target sequence';


--
-- Name: COLUMN papssm.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.score IS 'algorithm-specific score';


--
-- Name: COLUMN papssm.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN papssm.eval IS 'expectation value';


--
-- Name: params_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW params_v AS
    SELECT params.params_id, params.name, params.is_public, params.descr, params.commandline FROM params ORDER BY params.name;


ALTER TABLE unison.params_v OWNER TO unison;

--
-- Name: COLUMN params_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN params_v.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params_v.name IS 'parameter set name';


--
-- Name: COLUMN params_v.is_public; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params_v.is_public IS 'true if this data source or algorithm is publicly distributable';


--
-- Name: COLUMN params_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN params_v.descr IS 'description of parameters';


--
-- Name: origin_alias_fmt(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION origin_alias_fmt(text, text) RETURNS text
    AS $_$select $1 || ':' || $2;$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.origin_alias_fmt(text, text) OWNER TO unison;

--
-- Name: FUNCTION origin_alias_fmt(text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION origin_alias_fmt(text, text) IS 'canonical format for origin and alias, like this: <origin>:<alias>';


--
-- Name: pataa_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pataa_v AS
    SELECT sa.pseq_id, origin_alias_fmt(o.origin, ao.alias) AS alias, t.latin AS species, ("substring"(ao.descr, '\[DT: (\S+)'::text))::date AS patent_date, "substring"(ao.descr, '\[PA:\s+\([^\)]+\)\s+([^\s\]]+)'::text) AS patent_authority, ao.descr FROM (((pseqalias sa JOIN paliasorigin ao ON ((sa.palias_id = ao.palias_id))) JOIN origin o ON ((ao.origin_id = o.origin_id))) LEFT JOIN tax.spspec t ON ((ao.tax_id = t.tax_id))) WHERE ((ao.origin_id = 10002) AND sa.is_current) ORDER BY ("substring"(ao.descr, '\[DT: (\S+)'::text))::date;


ALTER TABLE unison.pataa_v OWNER TO unison;

--
-- Name: COLUMN pataa_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pataa_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pataa_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pataa_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN pataa_v.species; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pataa_v.species IS 'patent species';


--
-- Name: patents_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW patents_v AS
    SELECT sa.pseq_id, origin_alias_fmt(o.origin, ao.alias) AS alias, t.latin AS species, ("substring"(ao.descr, '\[DT: (\S+)'::text))::date AS patent_date, "substring"(ao.descr, '\[PA:\s+\([^\)]+\)\s+([^\]]+)'::text) AS patent_authority, ao.descr FROM (((pseqalias sa JOIN paliasorigin ao ON ((sa.palias_id = ao.palias_id))) JOIN origin o ON ((ao.origin_id = o.origin_id))) LEFT JOIN tax.spspec t ON ((ao.tax_id = t.tax_id))) WHERE ((ao.origin_id = origin_id('Geneseq'::text)) AND sa.is_current) ORDER BY ("substring"(ao.descr, '\[DT: (\S+)'::text))::date DESC;


ALTER TABLE unison.patents_v OWNER TO unison;

--
-- Name: COLUMN patents_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN patents_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN patents_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN patents_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN patents_v.species; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN patents_v.species IS 'patent species';


--
-- Name: COLUMN patents_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN patents_v.descr IS 'patent details';


--
-- Name: patent_count_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW patent_count_v AS
    SELECT patents_v.pseq_id, count(*) AS count FROM patents_v GROUP BY patents_v.pseq_id;


ALTER TABLE unison.patent_count_v OWNER TO unison;

--
-- Name: patents_unsorted_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW patents_unsorted_v AS
    SELECT sa.pseq_id, origin_alias_fmt(o.origin, ao.alias) AS alias, t.latin AS species, ("substring"(ao.descr, '\[DT: (\S+)'::text))::date AS patent_date, "substring"(ao.descr, '\[PA:\s+\([^\)]+\)\s+([^\]]+)'::text) AS patent_authority, ao.descr FROM (((pseqalias sa JOIN paliasorigin ao ON ((sa.palias_id = ao.palias_id))) JOIN origin o ON ((ao.origin_id = o.origin_id))) LEFT JOIN tax.spspec t ON ((ao.tax_id = t.tax_id))) WHERE ((ao.origin_id = origin_id('Geneseq'::text)) AND sa.is_current);


ALTER TABLE unison.patents_unsorted_v OWNER TO unison;

--
-- Name: pcluster; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pcluster (
    pcluster_id integer NOT NULL,
    genasm_id integer NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    chr text NOT NULL,
    plus_strand boolean NOT NULL,
    created timestamp with time zone DEFAULT timenow() NOT NULL
);


ALTER TABLE unison.pcluster OWNER TO unison;

--
-- Name: TABLE pcluster; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pcluster IS 'store pclusters of pseq_ids mapping to same genomic region';


--
-- Name: COLUMN pcluster.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN pcluster.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN pcluster.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster.gstop IS 'genomic stop position on chromosome';


--
-- Name: COLUMN pcluster.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster.chr IS 'chromosome';


--
-- Name: COLUMN pcluster.plus_strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster.plus_strand IS 'true = ''+'' strand; false = ''-'' strand';


--
-- Name: pcluster_member; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pcluster_member (
    pcluster_id integer NOT NULL,
    pseq_id integer NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL
);


ALTER TABLE unison.pcluster_member OWNER TO unison;

--
-- Name: TABLE pcluster_member; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pcluster_member IS 'stores list of pseq_ids for a given pcluster';


--
-- Name: COLUMN pcluster_member.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster_member.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pcluster_member.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster_member.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN pcluster_member.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pcluster_member.gstop IS 'genomic stop position on chromosome';


--
-- Name: perftest_def; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE perftest_def (
    def_id integer NOT NULL,
    current boolean DEFAULT true NOT NULL,
    ordr smallint DEFAULT 10000 NOT NULL,
    name text NOT NULL,
    sql text NOT NULL,
    n_runs smallint NOT NULL,
    min_n_rows integer NOT NULL,
    max_time integer NOT NULL,
    max_avg_time integer NOT NULL,
    CONSTRAINT max_avg_time_gt_zero CHECK ((max_avg_time >= 0)),
    CONSTRAINT max_avg_time_le_max_time CHECK ((max_avg_time <= max_time)),
    CONSTRAINT max_time_gt_zero CHECK ((max_time > 0)),
    CONSTRAINT min_n_rows_gt_zero CHECK ((min_n_rows > 0)),
    CONSTRAINT runs_gt_zero CHECK ((n_runs > 0))
);


ALTER TABLE unison.perftest_def OWNER TO unison;

--
-- Name: TABLE perftest_def; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE perftest_def IS 'Unison performance test definitions';


--
-- Name: COLUMN perftest_def.def_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.def_id IS 'unique test definition identifier ';


--
-- Name: COLUMN perftest_def.current; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.current IS 'whether test should be executed for new test runs';


--
-- Name: COLUMN perftest_def.ordr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.ordr IS 'order in which test should be run';


--
-- Name: COLUMN perftest_def.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.name IS 'unique name for test';


--
-- Name: COLUMN perftest_def.sql; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.sql IS 'sql definition';


--
-- Name: COLUMN perftest_def.n_runs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.n_runs IS 'number of runs for test';


--
-- Name: COLUMN perftest_def.min_n_rows; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.min_n_rows IS 'minimum number of rows expected for result set';


--
-- Name: COLUMN perftest_def.max_time; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.max_time IS 'max time expected for a single test execution';


--
-- Name: COLUMN perftest_def.max_avg_time; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_def.max_avg_time IS 'max average time for all runs';


--
-- Name: perftest_platform; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE perftest_platform (
    platform_id integer NOT NULL,
    name text NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    current boolean DEFAULT true NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    mac macaddr NOT NULL,
    ip inet NOT NULL,
    uname_s text NOT NULL,
    uname_n text NOT NULL,
    uname_r text NOT NULL,
    uname_m text NOT NULL,
    ram_gb smallint NOT NULL,
    fs_type text NOT NULL,
    pg_version_str text NOT NULL,
    pg_version text NOT NULL
);


ALTER TABLE unison.perftest_platform OWNER TO unison;

--
-- Name: TABLE perftest_platform; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE perftest_platform IS 'hardware and software platform for a set of test results';


--
-- Name: COLUMN perftest_platform.platform_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.platform_id IS 'unique id for a set of test results';


--
-- Name: COLUMN perftest_platform.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.name IS 'platform name';


--
-- Name: COLUMN perftest_platform.date; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.date IS 'date of test';


--
-- Name: COLUMN perftest_platform.current; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.current IS 'whether this platform is currently interesting';


--
-- Name: COLUMN perftest_platform.mac; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.mac IS 'host MAC address';


--
-- Name: COLUMN perftest_platform.ip; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.ip IS 'IP address';


--
-- Name: COLUMN perftest_platform.uname_s; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.uname_s IS 'result of uname -s';


--
-- Name: COLUMN perftest_platform.uname_n; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.uname_n IS 'result of uname -n';


--
-- Name: COLUMN perftest_platform.uname_r; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.uname_r IS 'result of uname -r';


--
-- Name: COLUMN perftest_platform.uname_m; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.uname_m IS 'result of uname -m';


--
-- Name: COLUMN perftest_platform.ram_gb; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.ram_gb IS 'total installed RAM, in GB';


--
-- Name: COLUMN perftest_platform.fs_type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.fs_type IS 'PGDATA filesystem type and options';


--
-- Name: COLUMN perftest_platform.pg_version_str; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.pg_version_str IS 'text from version()';


--
-- Name: COLUMN perftest_platform.pg_version; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_platform.pg_version IS 'PostgreSQL x.y.z version';


--
-- Name: perftest_result; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE perftest_result (
    def_id integer NOT NULL,
    run_id integer NOT NULL,
    had_error boolean NOT NULL,
    n_rows integer,
    times integer[],
    avg_time integer,
    CONSTRAINT avg_time_gt_zero CHECK ((avg_time > 0)),
    CONSTRAINT n_rows_gt_zero CHECK ((n_rows > 0))
);


ALTER TABLE unison.perftest_result OWNER TO unison;

--
-- Name: TABLE perftest_result; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE perftest_result IS 'results for a single test on single platform';


--
-- Name: COLUMN perftest_result.def_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_result.def_id IS 'test definition id';


--
-- Name: COLUMN perftest_result.run_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_result.run_id IS 'test run id (implies one platform)';


--
-- Name: COLUMN perftest_result.had_error; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_result.had_error IS 'whether there was an error/exception for this test';


--
-- Name: COLUMN perftest_result.n_rows; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_result.n_rows IS 'number of rows returned by this test';


--
-- Name: COLUMN perftest_result.times; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_result.times IS 'vector of elapsed times for this test (see perftest_platform.n_runs)';


--
-- Name: COLUMN perftest_result.avg_time; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN perftest_result.avg_time IS 'average elapsed time for this test';


--
-- Name: perftest_run; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE perftest_run (
    run_id integer NOT NULL,
    platform_id integer NOT NULL,
    start_ts timestamp without time zone NOT NULL,
    stop_ts timestamp without time zone,
    comments text
);


ALTER TABLE unison.perftest_run OWNER TO unison;

--
-- Name: TABLE perftest_run; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE perftest_run IS 'a set of perf results on a specific platform; perhaps >1 run/platform';


--
-- Name: pfantigenic; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfantigenic (
    pseq_id integer,
    pftype_id integer DEFAULT pftype_id('EMBOSS/antigenic'::text),
    start integer,
    stop integer,
    params_id integer,
    score double precision NOT NULL,
    max_pos smallint NOT NULL
)
INHERITS (pfeature);


ALTER TABLE unison.pfantigenic OWNER TO unison;

--
-- Name: TABLE pfantigenic; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfantigenic IS 'EMBOSS antigenic features';


--
-- Name: COLUMN pfantigenic.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfantigenic.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfantigenic.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfantigenic.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfantigenic.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfantigenic.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfantigenic.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic.score IS 'antigenic score';


--
-- Name: pfantigenic_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pfantigenic_v AS
    SELECT a.pseq_id, a.start, a.stop, ((a.stop - a.start) + 1) AS len, a.max_pos, a.score, substr(q.seq, a.start, ((a.stop - a.start) + 1)) AS subseq FROM (pfantigenic a JOIN pseq q ON ((a.pseq_id = q.pseq_id))) WHERE ((a.stop - a.start) <= 24) ORDER BY a.score DESC;


ALTER TABLE unison.pfantigenic_v OWNER TO unison;

--
-- Name: VIEW pfantigenic_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pfantigenic_v IS 'simplified view of antigenic sites with subsequences';


--
-- Name: COLUMN pfantigenic_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfantigenic_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfantigenic_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfantigenic_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfantigenic_v.score IS 'algorithm-specific score';


--
-- Name: pfbigpi; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfbigpi (
    pftype_id integer DEFAULT pftype_id('BIG-PI'::text),
    start integer,
    stop integer DEFAULT 0,
    params_id integer,
    site_no smallint NOT NULL,
    quality character(1) NOT NULL,
    score real NOT NULL,
    pvalue real NOT NULL,
    CONSTRAINT big_pi_identifies_only_two_sites CHECK (((site_no = 1) OR (site_no = 2))),
    CONSTRAINT quality_must_be_one_of_abcdsni CHECK ((strpos('ABCDSNI'::text, (quality)::text) <> 0))
)
INHERITS (pfeature);


ALTER TABLE unison.pfbigpi OWNER TO unison;

--
-- Name: TABLE pfbigpi; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfbigpi IS 'BIG-PI GPI predictions; see also bigpi_v';


--
-- Name: COLUMN pfbigpi.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfbigpi.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfbigpi.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfbigpi.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.start IS 'omega site';


--
-- Name: COLUMN pfbigpi.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.stop IS '0';


--
-- Name: COLUMN pfbigpi.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfbigpi.quality; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.quality IS 'A-D are good sites; S,N,I are rejected sites';


--
-- Name: COLUMN pfbigpi.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi.score IS 'algorithm-specific score';


--
-- Name: pfbigpi_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pfbigpi_v AS
    SELECT pfbigpi.pfeature_id, pfbigpi.pseq_id, pfbigpi.pftype_id, pfbigpi.start, pfbigpi.stop, pfbigpi.pvalue, pfbigpi.params_id, pfbigpi.site_no, pfbigpi.quality, pfbigpi.score FROM pfbigpi WHERE ((((pfbigpi.quality = 'A'::bpchar) OR (pfbigpi.quality = 'B'::bpchar)) OR (pfbigpi.quality = 'C'::bpchar)) OR (pfbigpi.quality = 'D'::bpchar));


ALTER TABLE unison.pfbigpi_v OWNER TO unison;

--
-- Name: VIEW pfbigpi_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pfbigpi_v IS 'reliable GPI anchoring predictions from BIG-PI';


--
-- Name: COLUMN pfbigpi_v.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi_v.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfbigpi_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfbigpi_v.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi_v.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfbigpi_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfbigpi_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfbigpi_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfbigpi_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfbigpi_v.score IS 'algorithm-specific score';


--
-- Name: pseq_id_sequence(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_id_sequence(pseq_id integer, OUT sequence text) RETURNS text
    AS $_$select seq from pseq where pseq_id=$1$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.pseq_id_sequence(pseq_id integer, OUT sequence text) OWNER TO unison;

--
-- Name: FUNCTION pseq_id_sequence(pseq_id integer, OUT sequence text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pseq_id_sequence(pseq_id integer, OUT sequence text) IS 'returns sequence for given pseq_id';


--
-- Name: pfnetphos; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfnetphos (
    pftype_id integer DEFAULT pftype_id('netphos'::text),
    prob double precision NOT NULL,
    kinase text NOT NULL,
    CONSTRAINT one_residue CHECK ((start = stop)),
    CONSTRAINT prob_ge_0_50 CHECK ((prob >= (0.5)::double precision)),
    CONSTRAINT sty_residue CHECK ((substr(pseq_id_sequence(pseq_id), start, 1) = ANY (ARRAY['S'::text, 'T'::text, 'Y'::text]))),
    CONSTRAINT valid_kinase_type CHECK ((kinase = ANY (ARRAY['ATM'::text, 'CaM-II'::text, 'cdc2'::text, 'cdk5'::text, 'CKI'::text, 'CKII'::text, 'DNAPK'::text, 'EGFR'::text, 'GSK3'::text, 'INSR'::text, 'p38MAPK'::text, 'PKA'::text, 'PKB'::text, 'PKC'::text, 'PKG'::text, 'RSK'::text, 'SRC'::text, 'unsp'::text])))
)
INHERITS (pfeature);


ALTER TABLE unison.pfnetphos OWNER TO unison;

--
-- Name: TABLE pfnetphos; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfnetphos IS 'S,T,Y phosphorylation prediction by netphos ONLY w/prob>=0.5';


--
-- Name: COLUMN pfnetphos.prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfnetphos.prob IS 'probability; prob<0.5 are discarded';


--
-- Name: pfnetphos_site_predictions_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pfnetphos_site_predictions_v AS
    SELECT x.pseq_id, x.params_id, x.start AS pos, max(x.prob) AS max_prob, as_set((((x.kinase || '('::text) || (x.prob)::text) || ')'::text)) AS kinases FROM (SELECT pfnetphos.pseq_id, pfnetphos.params_id, pfnetphos.start, pfnetphos.prob, pfnetphos.kinase FROM pfnetphos WHERE (pfnetphos.prob >= (0.5)::double precision) ORDER BY pfnetphos.pseq_id, pfnetphos.params_id, pfnetphos.start, pfnetphos.prob DESC) x GROUP BY x.pseq_id, x.params_id, x.start;


ALTER TABLE unison.pfnetphos_site_predictions_v OWNER TO unison;

--
-- Name: pfpepcoil; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfpepcoil (
    pftype_id integer DEFAULT pftype_id('EMBOSS/pepcoil'::text),
    score real NOT NULL,
    prob real NOT NULL,
    CONSTRAINT prob_between_0_1 CHECK (((prob >= (0)::double precision) AND (prob <= (1)::double precision)))
)
INHERITS (pfeature);


ALTER TABLE unison.pfpepcoil OWNER TO unison;

--
-- Name: TABLE pfpepcoil; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfpepcoil IS 'coiled-coiled predictions from EMBOSS pepcoil';


--
-- Name: COLUMN pfpepcoil.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpepcoil.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfpepcoil.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpepcoil.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfpepcoil.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpepcoil.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfpepcoil.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpepcoil.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfpepcoil.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpepcoil.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfpepcoil.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpepcoil.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfpepcoil.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpepcoil.score IS 'algorithm-specific score';


--
-- Name: pfpsipred; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfpsipred (
    pftype_id integer DEFAULT pftype_id('PSIPRED'::text),
    type character(1),
    CONSTRAINT sec_str_type_ck CHECK ((((type = 'H'::bpchar) OR (type = 'E'::bpchar)) OR (type = 'C'::bpchar)))
)
INHERITS (pfeature);


ALTER TABLE unison.pfpsipred OWNER TO unison;

--
-- Name: TABLE pfpsipred; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfpsipred IS 'Psipred predicted secondary structure elements';


--
-- Name: COLUMN pfpsipred.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpsipred.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfpsipred.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpsipred.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfpsipred.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpsipred.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfpsipred.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpsipred.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfpsipred.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpsipred.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfpsipred.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfpsipred.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: pfregexp_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pfregexp_v AS
    SELECT f.params_id, f.pseq_id, f.start, f.stop, m.origin_id, m.pmodel_id, m.acc, m.name, m.descr FROM (pfregexp f JOIN pmregexp m ON ((f.pmodel_id = m.pmodel_id)));


ALTER TABLE unison.pfregexp_v OWNER TO unison;

--
-- Name: VIEW pfregexp_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pfregexp_v IS 'regexp features with model origin_id, acc, name, and descr';


--
-- Name: pfseg; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfseg (
    pftype_id integer DEFAULT pftype_id('seg'::text),
    score real NOT NULL
)
INHERITS (pfeature);


ALTER TABLE unison.pfseg OWNER TO unison;

--
-- Name: TABLE pfseg; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfseg IS 'seg - segment sequences(s) by local complexity, predicitons';


--
-- Name: pfsigcleave; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfsigcleave (
    pftype_id integer DEFAULT pftype_id('EMBOSS/sigcleave'::text),
    score real
)
INHERITS (pfeature);


ALTER TABLE unison.pfsigcleave OWNER TO unison;

--
-- Name: TABLE pfsigcleave; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfsigcleave IS 'protein feature from EMBOSS sigcleave';


--
-- Name: COLUMN pfsigcleave.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsigcleave.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfsigcleave.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsigcleave.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfsigcleave.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsigcleave.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfsigcleave.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsigcleave.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfsigcleave.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsigcleave.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfsigcleave.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsigcleave.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfsigcleave.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsigcleave.score IS 'algorithm-specific score';


--
-- Name: pfsignalphmm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfsignalphmm (
    pftype_id integer DEFAULT pftype_id('SignalP'::text),
    start integer DEFAULT 1,
    sig_anchor_prob real NOT NULL,
    max_cleavage_prob real NOT NULL,
    sig_peptide_prob real NOT NULL,
    pfsignalphmm_pred_id integer
)
INHERITS (pfeature);


ALTER TABLE unison.pfsignalphmm OWNER TO unison;

--
-- Name: TABLE pfsignalphmm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfsignalphmm IS 'HMM output from SignalP';


--
-- Name: COLUMN pfsignalphmm.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pfsignalphmm.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfsignalphmm.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pfsignalphmm.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfsignalphmm.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pfsignalphmm.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfsignalphmm.sig_anchor_prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.sig_anchor_prob IS 'signal anchor probability';


--
-- Name: COLUMN pfsignalphmm.max_cleavage_prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.max_cleavage_prob IS 'max cleavage site probability';


--
-- Name: COLUMN pfsignalphmm.sig_peptide_prob; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm.sig_peptide_prob IS 'signal peptide probability';


--
-- Name: pfsignalphmm_pred; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pfsignalphmm_pred (
    pfsignalphmm_pred_id integer NOT NULL,
    prediction text NOT NULL
);


ALTER TABLE unison.pfsignalphmm_pred OWNER TO unison;

--
-- Name: TABLE pfsignalphmm_pred; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pfsignalphmm_pred IS 'lookup table for SignalP predictions';


--
-- Name: pfsignalphmm_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pfsignalphmm_v AS
    SELECT s.pseq_id, s.params_id, s.start, s.stop, s.sig_anchor_prob, s.max_cleavage_prob, s.sig_peptide_prob, p.prediction FROM (pfsignalphmm s JOIN pfsignalphmm_pred p ON ((s.pfsignalphmm_pred_id = p.pfsignalphmm_pred_id)));


ALTER TABLE unison.pfsignalphmm_v OWNER TO unison;

--
-- Name: COLUMN pfsignalphmm_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pfsignalphmm_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pfsignalphmm_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pfsignalphmm_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pfsignalphmm_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: pftmhmm_ecd_length_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pftmhmm_ecd_length_v AS
    SELECT a.pseq_id, (a.start - b.start) AS ecd_length FROM (pftmhmm a JOIN pftmhmm b ON (((a.pseq_id = b.pseq_id) AND (a.params_id = b.params_id)))) WHERE (((a.start - b.stop) = 1) AND (a.type = 'N'::bpchar));


ALTER TABLE unison.pftmhmm_ecd_length_v OWNER TO unison;

--
-- Name: pftmhmm_tms_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pftmhmm_tms_v AS
    SELECT pftmhmm.pfeature_id, pftmhmm.pseq_id, pftmhmm.pftype_id, pftmhmm.start, pftmhmm.stop, pftmhmm.params_id, pftmhmm.type FROM pftmhmm WHERE ((pftmhmm.type = 'M'::bpchar) OR (pftmhmm.type = 'N'::bpchar));


ALTER TABLE unison.pftmhmm_tms_v OWNER TO unison;

--
-- Name: VIEW pftmhmm_tms_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pftmhmm_tms_v IS 'TM regions from pftmhmm';


--
-- Name: COLUMN pftmhmm_tms_v.pfeature_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tms_v.pfeature_id IS 'unique identifier for this protein feature';


--
-- Name: COLUMN pftmhmm_tms_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tms_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pftmhmm_tms_v.pftype_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tms_v.pftype_id IS 'protein feature type identifier -- see pftype(pftype_id)';


--
-- Name: COLUMN pftmhmm_tms_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tms_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pftmhmm_tms_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tms_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pftmhmm_tms_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pftmhmm_tms_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: pftype_preferred_run_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pftype_preferred_run_v AS
    SELECT t.pftype_id, t.name AS pftype, p.params_id, p.name AS params, p.is_public, m.pmodelset_id, m.name FROM (((pftype t LEFT JOIN run r ON ((t.preferred_run_id = r.run_id))) LEFT JOIN params p ON ((r.params_id = p.params_id))) LEFT JOIN pmodelset m ON ((r.pmodelset_id = m.pmodelset_id)));


ALTER TABLE unison.pftype_preferred_run_v OWNER TO unison;

--
-- Name: VIEW pftype_preferred_run_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pftype_preferred_run_v IS 'preferred params and pmodelsets for each feature type';


--
-- Name: pmap_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_v AS
    SELECT a.params_id, a.genasm_id, h.pseq_id, ah.aln_id, min(h.pstart) AS pstart, max(h.pstop) AS pstop, count(*) AS exons, sum(((h.pstop - h.pstart) + 1)) AS aln_length, ((((sum(((h.pstop - h.pstart) + 1)))::double precision / (q.len)::double precision) * (100)::double precision))::integer AS pct_cov, a.ident, ((((a.ident)::double precision / (sum(((h.pstop - h.pstart) + 1)))::double precision) * (100)::double precision))::integer AS pct_ident, h.chr, h.strand, min(h.gstart) AS gstart, max(h.gstop) AS gstop FROM (((pmap_hsp h JOIN pmap_alnhsp ah ON ((h.hsp_id = ah.hsp_id))) JOIN pmap_aln a ON ((ah.aln_id = a.aln_id))) JOIN pseq q ON ((h.pseq_id = q.pseq_id))) GROUP BY h.pseq_id, a.params_id, a.genasm_id, ah.aln_id, h.chr, h.strand, a.ident, q.len ORDER BY h.pseq_id, ((((sum(((h.pstop - h.pstart) + 1)))::double precision / (q.len)::double precision) * (100)::double precision))::integer DESC, ((((a.ident)::double precision / (sum(((h.pstop - h.pstart) + 1)))::double precision) * (100)::double precision))::integer DESC;


ALTER TABLE unison.pmap_v OWNER TO unison;

--
-- Name: VIEW pmap_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmap_v IS 'view of pmap alignments with calculated statistics';


--
-- Name: COLUMN pmap_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pmap_v.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN pmap_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pmap_v.aln_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.aln_id IS 'pmap_aln alignment identifier';


--
-- Name: COLUMN pmap_v.pstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.pstart IS 'start of alignment in protein sequence';


--
-- Name: COLUMN pmap_v.pstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.pstop IS 'stop of alignment in protein sequence';


--
-- Name: COLUMN pmap_v.exons; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.exons IS 'number of exons';


--
-- Name: COLUMN pmap_v.aln_length; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.aln_length IS 'length of alignment';


--
-- Name: COLUMN pmap_v.pct_cov; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.pct_cov IS 'percent coverage';


--
-- Name: COLUMN pmap_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.pct_ident IS 'percent identity';


--
-- Name: COLUMN pmap_v.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.chr IS 'chromosome';


--
-- Name: COLUMN pmap_v.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: COLUMN pmap_v.gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.gstart IS 'genomic start position on chromosome';


--
-- Name: COLUMN pmap_v.gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_v.gstop IS 'genomic stop position on chromosome';


--
-- Name: pmap_best_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_best_v AS
    SELECT m.params_id, m.genasm_id, m.pseq_id, m.pct_cov, m.pct_ident, m.aln_id, m.pstart, m.pstop, m.exons, m.aln_length, m.ident, m.chr, m.strand, m.gstart, m.gstop FROM (pmap_v m NATURAL JOIN (SELECT DISTINCT ON (pmap_v.pseq_id, pmap_v.genasm_id, pmap_v.params_id) pmap_v.pseq_id, pmap_v.genasm_id, pmap_v.params_id, pmap_v.pct_cov, pmap_v.pct_ident FROM pmap_v ORDER BY pmap_v.pseq_id, pmap_v.genasm_id, pmap_v.params_id, pmap_v.pct_cov DESC, pmap_v.pct_ident DESC) x);


ALTER TABLE unison.pmap_best_v OWNER TO unison;

--
-- Name: VIEW pmap_best_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmap_best_v IS 'best pmap alignments; possibly degenerate -- see pmap_unambiguous_v';


--
-- Name: pmap_ambiguous_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_ambiguous_v AS
    SELECT pmap_best_v.params_id, pmap_best_v.genasm_id, pmap_best_v.pseq_id, pmap_best_v.pct_cov, pmap_best_v.pct_ident, pmap_best_v.aln_id, pmap_best_v.pstart, pmap_best_v.pstop, pmap_best_v.exons, pmap_best_v.aln_length, pmap_best_v.ident, pmap_best_v.chr, pmap_best_v.strand, pmap_best_v.gstart, pmap_best_v.gstop FROM pmap_best_v GROUP BY pmap_best_v.params_id, pmap_best_v.genasm_id, pmap_best_v.pseq_id, pmap_best_v.aln_id, pmap_best_v.pct_cov, pmap_best_v.pct_ident, pmap_best_v.pstart, pmap_best_v.pstop, pmap_best_v.exons, pmap_best_v.aln_length, pmap_best_v.ident, pmap_best_v.chr, pmap_best_v.strand, pmap_best_v.gstart, pmap_best_v.gstop HAVING (count(DISTINCT (((((pmap_best_v.params_id)::text || '-'::text) || (pmap_best_v.genasm_id)::text) || '-'::text) || (pmap_best_v.pseq_id)::text)) > 1);


ALTER TABLE unison.pmap_ambiguous_v OWNER TO unison;

--
-- Name: VIEW pmap_ambiguous_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmap_ambiguous_v IS 'ambiguous pmap alignments';


--
-- Name: pmap_unambiguous_overlaps_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_unambiguous_overlaps_mv (
    genasm_id integer,
    params_id integer,
    chr text,
    strand character(1),
    q_pseq_id integer,
    q_gstart integer,
    q_gstop integer,
    t_pseq_id integer,
    t_gstart integer,
    t_gstop integer
);


ALTER TABLE unison.pmap_unambiguous_overlaps_mv OWNER TO unison;

--
-- Name: TABLE pmap_unambiguous_overlaps_mv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmap_unambiguous_overlaps_mv IS 'materialized view of overlaps between protein sequences with unambiguous alignments to genomes';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.genasm_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.genasm_id IS 'genome assembly identifier -- see genasm(genasm_id)';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.chr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.chr IS 'chromosome';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.strand; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.strand IS 'genomic strand (''+'' or ''-'')';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.t_gstart; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.t_gstart IS 'genomic start of target sequence';


--
-- Name: COLUMN pmap_unambiguous_overlaps_mv.t_gstop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmap_unambiguous_overlaps_mv.t_gstop IS 'genomic stop of target sequence';


--
-- Name: pmap_gg_representative_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_gg_representative_v AS
    SELECT DISTINCT ON (o.genasm_id, o.params_id, o.q_pseq_id) o.genasm_id, o.params_id, o.chr, o.strand, o.q_pseq_id, o.q_gstart, o.q_gstop, o.t_pseq_id, o.t_gstart, o.t_gstop, tca.palias_id, tca.origin_id, tca.origin, tca.alias, tca.descr, gg.unqid, gg.proid, gg.dnaid, tca.link_url FROM ((pmap_unambiguous_overlaps_mv o JOIN current_annotations_v tca ON ((o.t_pseq_id = tca.pseq_id))) JOIN pseq_sst_v gg ON ((o.t_pseq_id = gg.pseq_id))) WHERE (tca.origin_id = origin_id('GenenGenes'::text)) ORDER BY o.genasm_id, o.params_id, o.q_pseq_id;


ALTER TABLE unison.pmap_gg_representative_v OWNER TO unison;

--
-- Name: VIEW pmap_gg_representative_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmap_gg_representative_v IS 'GenenGenes identifiers for q_pseq_id based on unambiguous genomic alignments';


--
-- Name: pmap_locus_representative_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_locus_representative_v AS
    SELECT DISTINCT ON (o.genasm_id, o.params_id, o.q_pseq_id) o.genasm_id, o.params_id, o.chr, o.strand, o.q_pseq_id, o.q_gstart, o.q_gstop, o.t_pseq_id, o.t_gstart, o.t_gstop, tba.palias_id, tba.origin_id, tba.origin, tba.alias, tba.descr, tba.link_url FROM ((pmap_unambiguous_overlaps_mv o JOIN best_annotation_mv qba ON ((o.q_pseq_id = qba.pseq_id))) JOIN best_annotation_mv tba ON ((o.t_pseq_id = tba.pseq_id))) WHERE ((tba.ann_pref <= qba.ann_pref) OR (qba.ann_pref IS NULL)) ORDER BY o.genasm_id, o.params_id, o.q_pseq_id, tba.ann_pref, (strpos(tba.alias, '_'::text) = 0), tba.alias;


ALTER TABLE unison.pmap_locus_representative_v OWNER TO unison;

--
-- Name: VIEW pmap_locus_representative_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmap_locus_representative_v IS 'unambiguously "better" (lower ann_pref) sequence that overlaps query on genome';


--
-- Name: pmap_pfam_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_pfam_mv (
    pmap_params_id integer,
    genasm_id integer,
    aln_id integer,
    pstart integer,
    pstop integer,
    chr text,
    strand character(1),
    gstart integer,
    gstop integer,
    feature_type text,
    params_id integer,
    params_name text,
    pseq_id integer,
    start integer,
    stop integer,
    score integer,
    eval double precision,
    origin_id integer,
    origin text,
    pmodel_id integer,
    feature text,
    acc text,
    descr text,
    details text,
    digest text,
    link_url text,
    pfam_start integer,
    pfam_stop integer
);


ALTER TABLE unison.pmap_pfam_mv OWNER TO unison;

--
-- Name: pmap_unambiguous_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmap_unambiguous_mv (
    params_id integer,
    genasm_id integer,
    pseq_id integer,
    pct_cov integer,
    pct_ident integer,
    aln_id integer,
    pstart integer,
    pstop integer,
    exons bigint,
    aln_length bigint,
    ident integer,
    chr text,
    strand character(1),
    gstart integer,
    gstop integer
);


ALTER TABLE unison.pmap_unambiguous_mv OWNER TO unison;

--
-- Name: TABLE pmap_unambiguous_mv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmap_unambiguous_mv IS 'matview of pmap_unambiguous_v';


--
-- Name: pseq_features_pfam_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_pfam_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.start, f.stop, f.score, f.eval, m.origin_id, o.origin, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, domain_digest(f.start, f.stop, m.name, f.score, f.eval) AS digest, link_url(m.origin_id, m.acc) AS link_url FROM ((((((pahmm f JOIN pmhmm m ON ((f.pmodel_id = m.pmodel_id))) JOIN pmsm_pmhmm ms ON ((ms.pmodel_id = m.pmodel_id))) JOIN origin o ON ((m.origin_id = o.origin_id))) JOIN params p ON ((f.params_id = p.params_id))) JOIN pftype ft ON ((p.pftype_id = ft.pftype_id))) JOIN run r ON (((r.params_id = f.params_id) AND (r.pmodelset_id = ms.pmodelset_id)))) WHERE ((r.run_id = preferred_run_id_by_pftype('HMM'::text)) AND (f.eval < (1)::double precision));


ALTER TABLE unison.pseq_features_pfam_v OWNER TO unison;

--
-- Name: pmap_pfam_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_pfam_v AS
    SELECT g.params_id AS pmap_params_id, g.genasm_id, g.aln_id, g.pstart, g.pstop, g.chr, g.strand, g.gstart, g.gstop, f.feature_type, f.params_id, f.params_name, f.pseq_id, f.start, f.stop, f.score, f.eval, f.origin_id, f.origin, f.pmodel_id, f.feature, f.acc, f.descr, f.details, f.digest, f.link_url, (SELECT ((e.gstart + ((f.start - e.pstart) * 3)) - 1) FROM (pmap_alnhsp ah JOIN pmap_hsp e ON ((e.hsp_id = ah.hsp_id))) WHERE ((g.aln_id = ah.aln_id) AND ((f.start >= e.pstart) AND (f.start <= e.pstop)))) AS pfam_start, (SELECT ((e.gstart + ((f.stop - e.pstart) * 3)) - 1) FROM (pmap_alnhsp ah JOIN pmap_hsp e ON ((e.hsp_id = ah.hsp_id))) WHERE ((g.aln_id = ah.aln_id) AND ((f.stop >= e.pstart) AND (f.stop <= e.pstop)))) AS pfam_stop FROM (pseq_features_pfam_v f JOIN pmap_unambiguous_mv g ON ((g.pseq_id = f.pseq_id))) WHERE (g.params_id = (SELECT run.params_id FROM run WHERE (run.run_id = preferred_run_id_by_pftype('PMAP'::text)))) ORDER BY f.pseq_id, f.start;


ALTER TABLE unison.pmap_pfam_v OWNER TO unison;

--
-- Name: pmap_unambiguous_overlaps_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_unambiguous_overlaps_v AS
    SELECT q.genasm_id, q.params_id, q.chr, q.strand, q.pseq_id AS q_pseq_id, q.gstart AS q_gstart, q.gstop AS q_gstop, t.pseq_id AS t_pseq_id, t.gstart AS t_gstart, t.gstop AS t_gstop FROM (pmap_unambiguous_mv q JOIN pmap_unambiguous_mv t ON (((((((q.params_id = t.params_id) AND (q.genasm_id = t.genasm_id)) AND (q.chr = t.chr)) AND (q.strand = t.strand)) AND (t.gstart <= q.gstop)) AND (t.gstop >= q.gstart)))) WHERE ((((q.pct_ident >= 90) AND (t.pct_ident >= 90)) AND (q.pct_cov >= 90)) AND (t.pct_cov >= 90));


ALTER TABLE unison.pmap_unambiguous_overlaps_v OWNER TO unison;

--
-- Name: pmap_unambiguous_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmap_unambiguous_v AS
    SELECT pmap_best_v.params_id, pmap_best_v.genasm_id, pmap_best_v.pseq_id, pmap_best_v.pct_cov, pmap_best_v.pct_ident, pmap_best_v.aln_id, pmap_best_v.pstart, pmap_best_v.pstop, pmap_best_v.exons, pmap_best_v.aln_length, pmap_best_v.ident, pmap_best_v.chr, pmap_best_v.strand, pmap_best_v.gstart, pmap_best_v.gstop FROM pmap_best_v GROUP BY pmap_best_v.params_id, pmap_best_v.genasm_id, pmap_best_v.pseq_id, pmap_best_v.aln_id, pmap_best_v.pct_cov, pmap_best_v.pct_ident, pmap_best_v.pstart, pmap_best_v.pstop, pmap_best_v.exons, pmap_best_v.aln_length, pmap_best_v.ident, pmap_best_v.chr, pmap_best_v.strand, pmap_best_v.gstart, pmap_best_v.gstop HAVING (count(DISTINCT (((((pmap_best_v.params_id)::text || '-'::text) || (pmap_best_v.genasm_id)::text) || '-'::text) || (pmap_best_v.pseq_id)::text)) = 1);


ALTER TABLE unison.pmap_unambiguous_v OWNER TO unison;

--
-- Name: VIEW pmap_unambiguous_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmap_unambiguous_v IS 'unambiguous pmap alignments';


--
-- Name: pmodel2go; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmodel2go (
    pmodel_id integer NOT NULL,
    go_id integer NOT NULL,
    reference text NOT NULL
);


ALTER TABLE unison.pmodel2go OWNER TO unison;

--
-- Name: TABLE pmodel2go; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmodel2go IS 'GO assignments to models; see gong.*';


--
-- Name: COLUMN pmodel2go.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodel2go.pmodel_id IS 'unique protein model identifier';


--
-- Name: pmsm_pmpssm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmsm_pmpssm (
)
INHERITS (pmsm);


ALTER TABLE unison.pmsm_pmpssm OWNER TO unison;

--
-- Name: TABLE pmsm_pmpssm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmsm_pmpssm IS 'pmsm for pmpssm (inherits from pmsm, which see)';


--
-- Name: COLUMN pmsm_pmpssm.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmpssm.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmsm_pmpssm.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmsm_pmpssm.pmodel_id IS 'unique protein model identifier';


--
-- Name: pmodelset_summary_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmodelset_summary_v AS
    SELECT ms.pmodelset_id, ms.name, (SELECT count(*) AS count FROM pmsm_pmhmm msm WHERE (msm.pmodelset_id = ms.pmodelset_id)) AS hmms, (SELECT count(*) AS count FROM pmsm_pmpssm msm WHERE (msm.pmodelset_id = ms.pmodelset_id)) AS pssms, (SELECT count(*) AS count FROM pmsm_pmprospect msm WHERE (msm.pmodelset_id = ms.pmodelset_id)) AS templates FROM pmodelset ms ORDER BY ms.pmodelset_id;


ALTER TABLE unison.pmodelset_summary_v OWNER TO unison;

--
-- Name: VIEW pmodelset_summary_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmodelset_summary_v IS 'summary of modelsets and # of models for hmms, pssms, and prospect templates';


--
-- Name: COLUMN pmodelset_summary_v.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset_summary_v.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmodelset_summary_v.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelset_summary_v.name IS 'modelset name';


--
-- Name: pmodelsetsummary; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmodelsetsummary AS
    SELECT count(pmsm.pmodel_id) AS count, pmodelset.pmodelset_id, pmodelset.name FROM (pmodelset NATURAL LEFT JOIN pmsm) GROUP BY pmodelset.pmodelset_id, pmodelset.name ORDER BY pmodelset.pmodelset_id;


ALTER TABLE unison.pmodelsetsummary OWNER TO unison;

--
-- Name: COLUMN pmodelsetsummary.pmodelset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelsetsummary.pmodelset_id IS 'protein model set identifier -- see pmodelset(pmodelset_id)';


--
-- Name: COLUMN pmodelsetsummary.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmodelsetsummary.name IS 'modelset name';


--
-- Name: pmpssm; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pmpssm (
    md5 character(32) NOT NULL
)
INHERITS (pmodel);


ALTER TABLE unison.pmpssm OWNER TO unison;

--
-- Name: TABLE pmpssm; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pmpssm IS 'Position Specific Scoring Matrix models (e.g., structure based profiles) ';


--
-- Name: COLUMN pmpssm.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpssm.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pmpssm.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpssm.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN pmpssm.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpssm.acc IS 'model accession from source database';


--
-- Name: COLUMN pmpssm.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpssm.added IS 'when this data was created';


--
-- Name: COLUMN pmpssm.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pmpssm.descr IS 'PSSM description';


--
-- Name: pmsm_pmhmm_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pmsm_pmhmm_v AS
    SELECT ms.name AS modelset, ms.pmodelset_id, m.origin_id, o.origin, m.pmodel_id, m.acc, m.name, m.descr FROM (((pmsm_pmhmm msm JOIN pmodelset ms ON ((msm.pmodelset_id = ms.pmodelset_id))) JOIN pmhmm m ON ((msm.pmodel_id = m.pmodel_id))) JOIN origin o ON ((m.origin_id = o.origin_id)));


ALTER TABLE unison.pmsm_pmhmm_v OWNER TO unison;

--
-- Name: VIEW pmsm_pmhmm_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pmsm_pmhmm_v IS 'HMMs in modelsets, with set, model, and origin names';


--
-- Name: pnote; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pnote (
    pseq_id integer NOT NULL,
    added timestamp with time zone DEFAULT timenow() NOT NULL,
    login text DEFAULT "current_user"() NOT NULL,
    note text NOT NULL
);


ALTER TABLE unison.pnote OWNER TO unison;

--
-- Name: TABLE pnote; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pnote IS 'user-added notations for sequences';


--
-- Name: COLUMN pnote.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pnote.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pnote.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pnote.added IS 'when this data was created';


--
-- Name: porigin; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW porigin AS
    SELECT origin.origin_id, origin.origin, origin.url, origin.descr, origin.ann_pref, origin.last_updated, origin.data_url, origin.is_public, origin.link_url, origin.version FROM origin;


ALTER TABLE unison.porigin OWNER TO unison;

--
-- Name: pseq2go; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pseq2go (
    pseq_id integer NOT NULL,
    go_id integer NOT NULL,
    reference text NOT NULL,
    evidence text NOT NULL,
    origin_id integer
);


ALTER TABLE unison.pseq2go OWNER TO unison;

--
-- Name: TABLE pseq2go; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pseq2go IS 'GO sequence assignments; see also gong.* tables';


--
-- Name: COLUMN pseq2go.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq2go.pseq_id IS 'fk into pseq.pseq_id';


--
-- Name: COLUMN pseq2go.go_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq2go.go_id IS 'GO id, fk into gong.node';


--
-- Name: COLUMN pseq2go.reference; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq2go.reference IS 'how this GO assignment was made';


--
-- Name: COLUMN pseq2go.evidence; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq2go.evidence IS 'GO evidence code';


--
-- Name: COLUMN pseq2go.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq2go.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: genasm_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION genasm_id(text) RETURNS integer
    AS $_$
DECLARE V_id integer; 
BEGIN 
	select into V_id genasm_id from genasm where upper(name)=upper($1); 
	IF NOT FOUND THEN 
		RAISE WARNING 'genasm % not found', $1; 
		RETURN NULL; 
	END IF; 
	return V_id; 
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.genasm_id(text) OWNER TO unison;

--
-- Name: FUNCTION genasm_id(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION genasm_id(text) IS 'returns genasm_id for a given genasm name';


SET search_path = unison_aux, pg_catalog;

--
-- Name: cytoband_hg18; Type: TABLE; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE TABLE cytoband_hg18 (
    chr text NOT NULL,
    gstart integer NOT NULL,
    gstop integer NOT NULL,
    band text NOT NULL,
    stain text NOT NULL,
    genasm_id integer
);


ALTER TABLE unison_aux.cytoband_hg18 OWNER TO unison;

--
-- Name: TABLE cytoband_hg18; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON TABLE cytoband_hg18 IS 'Cytobands on human chromosomes from ucsc';


--
-- Name: COLUMN cytoband_hg18.chr; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN cytoband_hg18.chr IS 'chromosome (e.g. 1..22,M,U,X,Y)';


--
-- Name: COLUMN cytoband_hg18.gstart; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN cytoband_hg18.gstart IS 'start of band on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: COLUMN cytoband_hg18.gstop; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN cytoband_hg18.gstop IS 'stop of band on genome (1-based, +1 frame, gstop > gstart)';


--
-- Name: COLUMN cytoband_hg18.band; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN cytoband_hg18.band IS 'name of the cytoband';


--
-- Name: COLUMN cytoband_hg18.stain; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN cytoband_hg18.stain IS 'gie stain';


SET search_path = unison, pg_catalog;

--
-- Name: pseq_cytoband_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_cytoband_v AS
    SELECT p.params_id, p.pseq_id, p.chr, c.band, c.stain FROM (pmap_v p JOIN unison_aux.cytoband_hg18 c ON ((c.chr = ('chr'::text || p.chr)))) WHERE (((p.genasm_id = genasm_id('NHGD-36'::text)) AND (p.gstart >= c.gstart)) AND (p.gstop <= c.gstop));


ALTER TABLE unison.pseq_cytoband_v OWNER TO unison;

--
-- Name: pseq_features_bigpi_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_bigpi_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.start, f.stop, f.score, (f.pvalue)::double precision AS eval, NULL::integer AS origin_id, NULL::text AS origin, NULL::integer AS pmodel_id, 'GPI Anchor'::text AS feature, NULL::text AS acc, NULL::text AS descr, ((('site='::text || (f.site_no)::text) || '; quality='::text) || (f.quality)::text) AS details, domain_digest(f.start, f.stop, 'GPI'::text, (f.quality)::text) AS digest, NULL::text AS link_url FROM (((pfbigpi f JOIN params p ON ((f.params_id = p.params_id))) JOIN run r ON ((r.params_id = p.params_id))) JOIN pftype ft ON ((ft.preferred_run_id = r.run_id))) WHERE ((ft.name = 'BIG-PI'::text) AND ((((f.quality = 'A'::bpchar) OR (f.quality = 'B'::bpchar)) OR (f.quality = 'C'::bpchar)) OR (f.quality = 'D'::bpchar)));


ALTER TABLE unison.pseq_features_bigpi_v OWNER TO unison;

--
-- Name: VIEW pseq_features_bigpi_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_features_bigpi_v IS 'current Big-PI neural net features';


--
-- Name: COLUMN pseq_features_bigpi_v.feature_type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.feature_type IS 'type of features (always ''BIG-PI'')';


--
-- Name: COLUMN pseq_features_bigpi_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pseq_features_bigpi_v.params_name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.params_name IS 'parameter set name -- see params(name)';


--
-- Name: COLUMN pseq_features_bigpi_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pseq_features_bigpi_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_bigpi_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_bigpi_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.score IS 'algorithm-specific score';


--
-- Name: COLUMN pseq_features_bigpi_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.eval IS 'expectation value';


--
-- Name: COLUMN pseq_features_bigpi_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pseq_features_bigpi_v.feature; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.feature IS 'name of feature (always ''GPI Anchor'')';


--
-- Name: COLUMN pseq_features_bigpi_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.descr IS 'unused';


--
-- Name: COLUMN pseq_features_bigpi_v.details; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.details IS 'prediction details';


--
-- Name: COLUMN pseq_features_bigpi_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_bigpi_v.link_url IS 'URL to source data';


--
-- Name: aa_1_to_3(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION aa_1_to_3(text) RETURNS text
    AS $_$
select case $1
	when 'A' then 'Ala'
	when 'B' then 'Bas'
	when 'C' then 'Cys'
	when 'D' then 'Asp'
	when 'E' then 'Glu'
	when 'F' then 'Phe'
	when 'G' then 'Gly'
	when 'H' then 'His'
	when 'I' then 'Iso'
	when 'K' then 'Lys'
	when 'L' then 'Leu'
	when 'M' then 'Met'
	when 'N' then 'Asn'
	when 'P' then 'Pro'
	when 'Q' then 'Gln'
	when 'R' then 'Arg'
	when 'S' then 'Ser'
	when 'T' then 'Thr'
	when 'V' then 'Val'
	when 'W' then 'Trp'
	when 'X' then 'Any'
	when 'Y' then 'Tyr'
	when 'Z' then 'Aci'
--	when '*' then 'Stp'
	else '???'
	end;
$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.aa_1_to_3(text) OWNER TO unison;

--
-- Name: domain_digest(integer, text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION domain_digest(pstart integer, name text, note text, OUT digest text) RETURNS text
    AS $$BEGIN SELECT INTO digest name || '(' || pstart || COALESCE(';'||NULLIF(note,''),'') || ')'; END;$$
    LANGUAGE plpgsql IMMUTABLE;


ALTER FUNCTION unison.domain_digest(pstart integer, name text, note text, OUT digest text) OWNER TO unison;

--
-- Name: pseq_features_netphos_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_netphos_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.pos AS start, f.pos AS stop, f.max_prob AS score, NULL::double precision AS eval, NULL::integer AS origin_id, NULL::text AS origin, NULL::integer AS pmodel_id, ('p'::text || aa_1_to_3(substr(q.seq, f.pos, 1))) AS feature, NULL::text AS acc, ((('predicted phospho-'::text || aa_1_to_3(substr(q.seq, f.pos, 1))) || '; '::text) || f.kinases) AS descr, NULL::text AS details, domain_digest(f.pos, ('p'::text || aa_1_to_3(substr(q.seq, f.pos, 1))), (f.max_prob)::text) AS digest, NULL::text AS link_url FROM ((((pfnetphos_site_predictions_v f JOIN pseq q ON ((f.pseq_id = q.pseq_id))) JOIN params p ON ((f.params_id = p.params_id))) JOIN run r ON ((r.params_id = p.params_id))) JOIN pftype ft ON ((ft.preferred_run_id = r.run_id))) WHERE ((ft.name = 'netphos'::text) AND (f.max_prob >= (0.5)::double precision));


ALTER TABLE unison.pseq_features_netphos_v OWNER TO unison;

--
-- Name: pseq_features_prosite_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_prosite_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.start, f.stop, NULL::smallint AS score, NULL::double precision AS eval, m.origin_id, o.origin, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, domain_digest(f.start, f.stop, m.name, NULL::text) AS digest, link_url(m.origin_id, m.acc) AS link_url FROM ((((((pfregexp f JOIN pmregexp m ON ((f.pmodel_id = m.pmodel_id))) JOIN pmsm_pmregexp ms ON ((ms.pmodel_id = m.pmodel_id))) JOIN origin o ON ((m.origin_id = o.origin_id))) JOIN params p ON ((f.params_id = p.params_id))) JOIN pftype ft ON ((p.pftype_id = ft.pftype_id))) JOIN run r ON (((r.params_id = f.params_id) AND (r.pmodelset_id = ms.pmodelset_id)))) WHERE (r.run_id = preferred_run_id_by_pftype('regexp'::text));


ALTER TABLE unison.pseq_features_prosite_v OWNER TO unison;

--
-- Name: pseq_features_regexp_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_regexp_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f.start, f.stop, NULL::smallint AS score, NULL::double precision AS eval, m.origin_id, o.origin, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, domain_digest(f.start, f.stop, m.name, NULL::text) AS digest, link_url(m.origin_id, m.acc) AS link_url FROM (((((pfregexp f JOIN pmregexp m ON ((f.pmodel_id = m.pmodel_id))) JOIN origin o ON ((m.origin_id = o.origin_id))) JOIN params p ON ((f.params_id = p.params_id))) JOIN run r ON ((r.params_id = p.params_id))) JOIN pftype ft ON ((ft.preferred_run_id = r.run_id))) WHERE (ft.name = 'regexp'::text);


ALTER TABLE unison.pseq_features_regexp_v OWNER TO unison;

--
-- Name: VIEW pseq_features_regexp_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_features_regexp_v IS 'current regular expression features';


--
-- Name: COLUMN pseq_features_regexp_v.feature_type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.feature_type IS 'type of features (always ''regexp'')';


--
-- Name: COLUMN pseq_features_regexp_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN pseq_features_regexp_v.params_name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.params_name IS 'parameter set name -- see params(name)';


--
-- Name: COLUMN pseq_features_regexp_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pseq_features_regexp_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.start IS 'start of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_regexp_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.stop IS 'stop of prediction in protein sequence';


--
-- Name: COLUMN pseq_features_regexp_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.score IS 'algorithm-specific score';


--
-- Name: COLUMN pseq_features_regexp_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.eval IS 'expectation value';


--
-- Name: COLUMN pseq_features_regexp_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: COLUMN pseq_features_regexp_v.feature; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.feature IS 'name of feature (motif name)';


--
-- Name: COLUMN pseq_features_regexp_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.descr IS 'motif description';


--
-- Name: COLUMN pseq_features_regexp_v.details; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.details IS 'prediction details';


--
-- Name: COLUMN pseq_features_regexp_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_regexp_v.link_url IS 'URL to source data';


--
-- Name: pdb_seq_pos(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pdb_seq_pos(text, text) RETURNS integer
    AS $_$DECLARE V_id text; BEGIN select into V_id seq_pos from pdb.residue where pdbc=$1 and res_id=$2; IF NOT FOUND THEN RAISE WARNING 'pdbc ''%'' res_id ''%''  not found', $1,$2; RETURN NULL; END IF; return V_id; END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pdb_seq_pos(text, text) OWNER TO unison;

--
-- Name: scop_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW scop_v AS
    SELECT c.sid, c.pdb, c.sccs AS scop_id, e.descr AS species, d.descr AS domain, f.descr AS family, s.descr AS superfamily, fo.descr AS fold, cl.descr AS class, dom.chain, dom.start, dom.stop FROM (((((((scop.cla c JOIN scop.des f ON ((c.fa = f.sunid))) JOIN scop.des s ON ((c.sf = s.sunid))) JOIN scop.des d ON ((c.dm = d.sunid))) JOIN scop.des e ON ((c.sp = e.sunid))) JOIN scop.des fo ON ((c.cf = fo.sunid))) JOIN scop.des cl ON ((c.cl = cl.sunid))) JOIN scop.dom dom ON ((dom.sid = c.sid)));


ALTER TABLE unison.scop_v OWNER TO unison;

--
-- Name: pseq_features_scop_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_scop_v AS
    SELECT 'SCOP'::text AS feature_type, NULL::integer AS params_id, NULL::text AS params_name, a.q_pseq_id AS pseq_id, (SELECT CASE WHEN (b.start IS NOT NULL) THEN (a.q_start + int4larger(0, (pdb_seq_pos(a.pdbc, (b.start)::text) - a.t_start))) ELSE a.q_start END AS "case") AS start, (SELECT CASE WHEN (b.stop IS NOT NULL) THEN (a.q_start + (int4smaller(a.t_stop, pdb_seq_pos(a.pdbc, (b.stop)::text)) - a.t_start)) ELSE a.q_stop END AS "case") AS stop, a.score, a.eval, NULL::integer AS pmodel_id, b.scop_id AS acc, b.family AS feature, ((((('Classification='::text || b.class) || ', '::text) || b.fold) || ', '::text) || b.superfamily) AS descr, ((((b.sid || ', '::text) || b.domain) || ', '::text) || b.species) AS details, NULL::text AS link_url FROM (papseq_pdbcs_mv a JOIN scop_v b ON ((a.pdbc = ((b.pdb)::text || (b.chain)::text)))) WHERE ((((b.start IS NOT NULL) AND (pdb_seq_pos(a.pdbc, (b.stop)::text) >= a.t_start)) AND (pdb_seq_pos(a.pdbc, (b.start)::text) <= a.t_stop)) OR (b.start IS NULL));


ALTER TABLE unison.pseq_features_scop_v OWNER TO unison;

--
-- Name: pseq_features_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_features_v AS
    (((SELECT pseq_features_bigpi_v.feature_type, pseq_features_bigpi_v.params_id, pseq_features_bigpi_v.params_name, pseq_features_bigpi_v.pseq_id, pseq_features_bigpi_v.start, pseq_features_bigpi_v.stop, pseq_features_bigpi_v.score, pseq_features_bigpi_v.eval, pseq_features_bigpi_v.origin_id, pseq_features_bigpi_v.origin, pseq_features_bigpi_v.pmodel_id, pseq_features_bigpi_v.feature, pseq_features_bigpi_v.acc, pseq_features_bigpi_v.descr, pseq_features_bigpi_v.details, pseq_features_bigpi_v.digest, pseq_features_bigpi_v.link_url FROM pseq_features_bigpi_v UNION ALL SELECT pseq_features_pfam_v.feature_type, pseq_features_pfam_v.params_id, pseq_features_pfam_v.params_name, pseq_features_pfam_v.pseq_id, pseq_features_pfam_v.start, pseq_features_pfam_v.stop, pseq_features_pfam_v.score, pseq_features_pfam_v.eval, pseq_features_pfam_v.origin_id, pseq_features_pfam_v.origin, pseq_features_pfam_v.pmodel_id, pseq_features_pfam_v.feature, pseq_features_pfam_v.acc, pseq_features_pfam_v.descr, pseq_features_pfam_v.details, pseq_features_pfam_v.digest, pseq_features_pfam_v.link_url FROM pseq_features_pfam_v) UNION ALL SELECT pseq_features_prosite_v.feature_type, pseq_features_prosite_v.params_id, pseq_features_prosite_v.params_name, pseq_features_prosite_v.pseq_id, pseq_features_prosite_v.start, pseq_features_prosite_v.stop, pseq_features_prosite_v.score, pseq_features_prosite_v.eval, pseq_features_prosite_v.origin_id, pseq_features_prosite_v.origin, pseq_features_prosite_v.pmodel_id, pseq_features_prosite_v.feature, pseq_features_prosite_v.acc, pseq_features_prosite_v.descr, pseq_features_prosite_v.details, pseq_features_prosite_v.digest, pseq_features_prosite_v.link_url FROM pseq_features_prosite_v) UNION ALL SELECT pseq_features_signalpnn_v.feature_type, pseq_features_signalpnn_v.params_id, pseq_features_signalpnn_v.params_name, pseq_features_signalpnn_v.pseq_id, pseq_features_signalpnn_v.start, pseq_features_signalpnn_v.stop, pseq_features_signalpnn_v.score, pseq_features_signalpnn_v.eval, pseq_features_signalpnn_v.origin_id, pseq_features_signalpnn_v.origin, pseq_features_signalpnn_v.pmodel_id, pseq_features_signalpnn_v.feature, pseq_features_signalpnn_v.acc, pseq_features_signalpnn_v.descr, pseq_features_signalpnn_v.details, pseq_features_signalpnn_v.digest, pseq_features_signalpnn_v.link_url FROM pseq_features_signalpnn_v) UNION ALL SELECT pseq_features_tmhmm_v.feature_type, pseq_features_tmhmm_v.params_id, pseq_features_tmhmm_v.params_name, pseq_features_tmhmm_v.pseq_id, pseq_features_tmhmm_v.start, pseq_features_tmhmm_v.stop, pseq_features_tmhmm_v.score, pseq_features_tmhmm_v.eval, pseq_features_tmhmm_v.origin_id, pseq_features_tmhmm_v.origin, pseq_features_tmhmm_v.pmodel_id, pseq_features_tmhmm_v.feature, pseq_features_tmhmm_v.acc, pseq_features_tmhmm_v.descr, pseq_features_tmhmm_v.details, pseq_features_tmhmm_v.digest, pseq_features_tmhmm_v.link_url FROM pseq_features_tmhmm_v ORDER BY 4, 5, 6;


ALTER TABLE unison.pseq_features_v OWNER TO unison;

--
-- Name: VIEW pseq_features_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_features_v IS 'most current features';


--
-- Name: COLUMN pseq_features_v.feature_type; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.feature_type IS 'type of prediction feature';


--
-- Name: COLUMN pseq_features_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.params_id IS 'Unison parameter set';


--
-- Name: COLUMN pseq_features_v.params_name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.params_name IS 'parameter set name';


--
-- Name: COLUMN pseq_features_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.pseq_id IS 'Unison pseq_id';


--
-- Name: COLUMN pseq_features_v.start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.start IS 'starting residue of feature';


--
-- Name: COLUMN pseq_features_v.stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.stop IS 'starting residue of feature';


--
-- Name: COLUMN pseq_features_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.score IS 'raw score of prediction, where available';


--
-- Name: COLUMN pseq_features_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.eval IS 'evalue or pvalue of prediction, where available';


--
-- Name: COLUMN pseq_features_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.pmodel_id IS 'Unison unique protein model id';


--
-- Name: COLUMN pseq_features_v.feature; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.feature IS 'feature name';


--
-- Name: COLUMN pseq_features_v.acc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.acc IS 'model accession in external database';


--
-- Name: COLUMN pseq_features_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.descr IS 'model description';


--
-- Name: COLUMN pseq_features_v.details; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.details IS 'additional prediction details';


--
-- Name: COLUMN pseq_features_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_features_v.link_url IS 'link to model in external database';


--
-- Name: pseq_gene_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pseq_gene_mv (
    pseq_id integer,
    alias text,
    descr text,
    tax_id integer,
    gene_id integer
);


ALTER TABLE unison.pseq_gene_mv OWNER TO unison;

--
-- Name: TABLE pseq_gene_mv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE pseq_gene_mv IS 'materialized view of pseq_gene_v, which see';


--
-- Name: pseq_gene_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_gene_v AS
    SELECT DISTINCT sa.pseq_id, ao.alias, ao.descr, ao.tax_id, ga.gene_id FROM ((pseqalias sa JOIN paliasorigin ao ON (((sa.palias_id = ao.palias_id) AND (ao.origin_id = origin_id('RefSeq'::text))))) JOIN ncbi.gene2accession ga ON (((ao.alias = ga.pro_acc) AND (ao.tax_id = ga.tax_id)))) ORDER BY sa.pseq_id, ao.tax_id, ga.gene_id, ao.alias, ao.descr;


ALTER TABLE unison.pseq_gene_v OWNER TO unison;

--
-- Name: VIEW pseq_gene_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_gene_v IS 'map pseq_id to NCBI gene_id via RefSeq alias';


--
-- Name: pseq_generif_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_generif_v AS
    SELECT b.q_pseq_id, b.t_pseq_id, b.pct_ident, g.alias, g.tax_id, t.gs, t.latin, g.descr, r.pubmed_ids, r.last_update, r.generif FROM ((((SELECT blasts_v.q_pseq_id, blasts_v.t_pseq_id, blasts_v.pct_ident FROM blasts_v UNION ALL SELECT blasts_v.q_pseq_id, blasts_v.q_pseq_id, 100 FROM blasts_v) b JOIN pseq_gene_mv g ON ((b.t_pseq_id = g.pseq_id))) LEFT JOIN tax.spspec t ON ((g.tax_id = t.tax_id))) JOIN ncbi.generif r ON ((g.gene_id = r.gene_id)));


ALTER TABLE unison.pseq_generif_v OWNER TO unison;

--
-- Name: pseq_id_sets_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_id_sets_v AS
    SELECT x.pseq_id, as_set((((x.name || '('::text) || (x.pset_id)::text) || ')'::text)) AS sets FROM (SELECT ss.pseq_id, s.name, s.pset_id FROM (pseqset ss JOIN pset s ON ((ss.pset_id = s.pset_id))) ORDER BY ss.pseq_id, s.name) x GROUP BY x.pseq_id;


ALTER TABLE unison.pseq_id_sets_v OWNER TO unison;

--
-- Name: VIEW pseq_id_sets_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_id_sets_v IS 'summary of sets to which a pseq_id belongs';


--
-- Name: COLUMN pseq_id_sets_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_id_sets_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pseq_probe_mv; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE pseq_probe_mv (
    pseq_id integer,
    params_id integer,
    genasm_id integer,
    genasm text,
    chr text,
    pseq_strand character(1),
    pseq_gstart integer,
    pseq_gstop integer,
    chip_id integer,
    chip text,
    probe_id text,
    probe_strand character(1),
    probe_gstart integer,
    probe_gstop integer
);


ALTER TABLE unison.pseq_probe_mv OWNER TO unison;

--
-- Name: pseq_probe_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_probe_v AS
    SELECT p.pseq_id, p.params_id, p.genasm_id, g.name AS genasm, p.chr, p.strand AS pseq_strand, p.gstart AS pseq_gstart, p.gstop AS pseq_gstop, m.chip_id, m.name AS chip, m.probe_id, m.strand AS probe_strand, m.gstart AS probe_gstart, m.gstop AS probe_gstop FROM ((pmap_v p JOIN marray.chip_probe_v m ON (((((p.genasm_id = m.genasm_id) AND (p.chr = m.chr)) AND (m.gstart >= p.gstart)) AND (m.gstop <= p.gstop)))) JOIN genasm g ON ((g.genasm_id = p.genasm_id)));


ALTER TABLE unison.pseq_probe_v OWNER TO unison;

--
-- Name: VIEW pseq_probe_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_probe_v IS 'overlapping pseqs and microarray probes';


--
-- Name: a280(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION a280(text, text) RETURNS real
    AS $_$
DECLARE 
	ans float;
BEGIN 
	select INTO ans A280($1,$2,'f');
	return ans;
END$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.a280(text, text) OWNER TO unison;

--
-- Name: mol_wt(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION mol_wt(text) RETURNS real
    AS $_X$

# http://www.expasy.org/tools/pi_tool-doc.html
# Protein Mw can be calculated by 
# the addition of average isotopic masses of amino acids (zwitter ion) in the protein 
# and the average isotopic mass of one water molecule.

#from EMBOSS/share/EMBOSS/data/Eamino.dat
my %weights = (
A => 71.0786,
B => 114.5960,
# They are for proteins with full reduced cysteine residues.  If all
# cysteines are oxidized to cystine, use
# a value of 60 for C
C => 103.1386,
D => 115.0884,
E => 129.1152,
F => 147.1762,
G => 57.0518,
H => 137.1408,
I => 113.1590,
K => 128.1736,
L => 113.1590,
# If met gets oxidised to the sulphoxide replace by 147.1926
M => 131.1926,
N => 114.1036,
P => 97.1164,
Q => 128.1304,
R => 156.1870,
S => 87.0780,
T => 101.1048,
U => 150.038, #not in EMBOSS
V => 99.1322,
W => 186.2128,
X => 144.0000,
Y => 163.1756,
Z => 128.6228
);

$_ = shift;
elog(ERROR, "sequence length <= 0") if(length($_) <= 0);

my $mol_wt =18.015; #mass of one water molecule

foreach my $aa(split //, $_) {
	elog(ERROR, "Unexpected amino acid ".$aa) if(not defined $weights{uc($aa)});
	$mol_wt += $weights{uc($aa)};
}	
return $mol_wt;
$_X$
    LANGUAGE plperl IMMUTABLE STRICT;


ALTER FUNCTION unison.mol_wt(text) OWNER TO unison;

--
-- Name: FUNCTION mol_wt(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION mol_wt(text) IS 'returns the molecular weight of the protein in daltons';


--
-- Name: pi(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pi(text, text) RETURNS real
    AS $_X$
# pK values from the DTASelect program from Scripps
# http://fields.scripps.edu/DTASelect
my %pK_params;
$pK_params{dtaselect} = {  
		      N_term   =>  8.0,
                      K        => 10.0, # Lys
                      R        => 12.0, # Arg
                      H        =>  6.5, # His
                      D        =>  4.4, # Asp
                      E        =>  4.4, # Glu
                      C        =>  8.5, # Cys
                      Y        => 10.0, # Tyr
                      C_term   =>  3.1
                    };

# pK values from the iep program from EMBOSS
# http://www.hgmp.mrc.ac.uk/Software/EMBOSS/
$pK_params{emboss}  = { 
		   N_term   =>  8.6,
                   K        => 10.8, # Lys
                   R        => 12.5, # Arg
                   H        =>  6.5, # His
                   D        =>  3.9, # Asp
                   E        =>  4.1, # Glu
                   C        =>  8.5, # Cys
                   Y        => 10.1, # Tyr
                   C_term   =>  3.6
                 };
my $seq = shift;
elog(ERROR, "sequence length <= 0") if(length($seq) <= 0);

my $params = shift;
elog(ERROR, "pK params $params does not exist options are 'emboss' and 'dtaselect'
") if(not defined $pK_params{$params});
my $pKset = $pK_params{$params};

my $places = 2; #decimal places
my $count = _count_charged_residues( $seq );

return _calculate_iep($pKset,$places,$seq,$count);	

sub _calculate_iep {
    my( $pK, $places, $seq, $count ) = @_;
    my $pH = 7.0;
    my $step = 3.5;
    my $last_charge = 0.0;
    my $format = "%.${places}f";
    my $count = _count_charged_residues($seq);

    while(1){
       my $charge = _calculate_charge_at_pH( $pH, $pK, $count );
       last if sprintf($format,$charge) == 
	 sprintf($format,$last_charge);
       $charge > 0 ? ( $pH += $step ) : ( $pH -= $step );
       $step /= 2.0;
       $last_charge = $charge;
    }
    return sprintf( $format, $pH );
}

sub _count_charged_residues {
   my $seq = shift;
   my $count;
   for ( qw( K R H D E C Y ) ){ # charged AAs
      $count->{$_}++ while $seq =~ /$_/ig;
   }
   return $count;
}

# its the sum of all the partial charges for the
# termini and all of the charged aa s!
sub _calculate_charge_at_pH {

   my( $pH, $pK, $count ) = @_;
   my $charge =    _partial_charge( $pK->{N_term}, $pH )
   + $count->{K} * _partial_charge( $pK->{K},      $pH )
   + $count->{R} * _partial_charge( $pK->{R},      $pH )
   + $count->{H} * _partial_charge( $pK->{H},      $pH )
   - $count->{D} * _partial_charge( $pH,      $pK->{D} )
   - $count->{E} * _partial_charge( $pH,      $pK->{E} )
   - $count->{C} * _partial_charge( $pH,      $pK->{C} )
   - $count->{Y} * _partial_charge( $pH,      $pK->{Y} )
   -               _partial_charge( $pH, $pK->{C_term} );
   return $charge;
}

# Concentration Ratio is 10**(pK - pH) for positive groups
# and 10**(pH - pK) for negative groups
sub _partial_charge {
   my $cr = 10 ** ( $_[0] - $_[1] );
   return $cr / ( $cr + 1 );
}

$_X$
    LANGUAGE plperl IMMUTABLE STRICT;


ALTER FUNCTION unison.pi(text, text) OWNER TO unison;

--
-- Name: FUNCTION pi(text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pi(text, text) IS 'returns the theoretical isoelectric point of a protein, try pI(seq,''emboss'')';


--
-- Name: pseq_prop_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_prop_v AS
    SELECT pseq.pseq_id, mol_wt(pseq.seq) AS mol_wt, pi(pseq.seq, 'emboss'::text) AS pi, a280(pseq.seq, 'emboss'::text) AS a280 FROM pseq;


ALTER TABLE unison.pseq_prop_v OWNER TO unison;

--
-- Name: pseq_set_membership; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_set_membership AS
    SELECT x.pseq_id, count(x.name) AS "#sets", as_set(x.name) AS sets FROM (SELECT qs.pseq_id, s.name FROM (pseqset qs JOIN pset s ON ((qs.pset_id = s.pset_id))) WHERE (qs.pset_id > 0) ORDER BY s.name) x GROUP BY x.pseq_id ORDER BY x.pseq_id;


ALTER TABLE unison.pseq_set_membership OWNER TO unison;

--
-- Name: VIEW pseq_set_membership; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pseq_set_membership IS 'sets to which sequences belong';


--
-- Name: COLUMN pseq_set_membership.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_set_membership.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: sp_var; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE sp_var (
    sp_id character(6) NOT NULL,
    start_pos integer NOT NULL,
    end_pos integer NOT NULL,
    original_aa text NOT NULL,
    variant_aa text NOT NULL,
    descr text,
    var_id character(10)
);


ALTER TABLE unison.sp_var OWNER TO unison;

--
-- Name: TABLE sp_var; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE sp_var IS 'EXPERIMENTAL! Swiss-Prot variants';


--
-- Name: pseq_sp_var_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_sp_var_v AS
    SELECT a.pseq_id, s.sp_id, s.start_pos, s.end_pos, s.original_aa, s.variant_aa, s.descr, s.var_id FROM palias a, sp_var s WHERE ((a.origin_id = origin_id('UniProtKB/Swiss-Prot'::text)) AND (a.alias = (s.sp_id)::text));


ALTER TABLE unison.pseq_sp_var_v OWNER TO unison;

--
-- Name: COLUMN pseq_sp_var_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_sp_var_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pseq_template_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseq_template_v AS
    SELECT papseq_pdbcs_v.q_pseq_id, papseq_pdbcs_v.t_pseq_id, papseq_pdbcs_v.q_start, papseq_pdbcs_v.q_stop, papseq_pdbcs_v.t_start, papseq_pdbcs_v.t_stop, papseq_pdbcs_v.pct_ident, papseq_pdbcs_v.len, papseq_pdbcs_v.gaps, round((papseq_pdbcs_v.pct_coverage)::double precision) AS pct_coverage, papseq_pdbcs_v.eval, papseq_pdbcs_v.score, 'blast'::text AS method, papseq_pdbcs_v.pdbc AS template, papseq_pdbcs_v.descr FROM papseq_pdbcs_v papseq_pdbcs_v ORDER BY papseq_pdbcs_v.eval, round((papseq_pdbcs_v.pct_coverage)::double precision) DESC;


ALTER TABLE unison.pseq_template_v OWNER TO unison;

--
-- Name: COLUMN pseq_template_v.q_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.q_pseq_id IS 'query pseq_id';


--
-- Name: COLUMN pseq_template_v.t_pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.t_pseq_id IS 'target pseq_id';


--
-- Name: COLUMN pseq_template_v.q_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.q_start IS 'start position in q_pseq_id';


--
-- Name: COLUMN pseq_template_v.q_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.q_stop IS 'stop position in q_pseq_id';


--
-- Name: COLUMN pseq_template_v.t_start; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.t_start IS 'start position in target pseq_id';


--
-- Name: COLUMN pseq_template_v.t_stop; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.t_stop IS 'stop position in target pseq_id';


--
-- Name: COLUMN pseq_template_v.pct_ident; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.pct_ident IS 'percent identity';


--
-- Name: COLUMN pseq_template_v.pct_coverage; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.pct_coverage IS 'percent coverage';


--
-- Name: COLUMN pseq_template_v.eval; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.eval IS 'expectation value';


--
-- Name: COLUMN pseq_template_v.score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseq_template_v.score IS 'algorithm-specific score';


--
-- Name: best_annotation(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION best_annotation(integer) RETURNS text
    AS $_$select origin_alias_descr_fmt(origin,alias,descr) from best_annotation_mv where pseq_id=$1 ORDER BY tax_id <> 9606$_$
    LANGUAGE sql;


ALTER FUNCTION unison.best_annotation(integer) OWNER TO unison;

--
-- Name: FUNCTION best_annotation(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION best_annotation(integer) IS '"best" annotation for given pseq_id. NOTE: from materialized view, which may be stale.';


--
-- Name: pseq_species(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_species(integer) RETURNS text
    AS $_$
DECLARE
	v_pseq_id alias for $1;
	rv text;
BEGIN
	select into rv
		as_set(distinct tax.tax_id2gs(tax_id)) from pseqalias
		natural join paliasorigin
		where pseq_id=v_pseq_id and is_current=TRUE
		group by pseq_id;
	return rv;
END;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison.pseq_species(integer) OWNER TO unison;

--
-- Name: pseqsummary_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pseqsummary_v AS
    SELECT pseq.pseq_id, pseq.len, pseq_species(pseq.pseq_id) AS species, best_annotation(pseq.pseq_id) AS "best-guess annotation" FROM pseq;


ALTER TABLE unison.pseqsummary_v OWNER TO unison;

--
-- Name: COLUMN pseqsummary_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pseqsummary_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_bacterial_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_bacterial_dv AS
    SELECT a.pseq_id FROM (palias a JOIN tax.spspec t ON ((a.tax_id = t.tax_id))) WHERE (t.k = 'B'::bpchar);


ALTER TABLE unison.pset_bacterial_dv OWNER TO unison;

--
-- Name: COLUMN pset_bacterial_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_bacterial_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_blast_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_blast_dv AS
    SELECT current_annotations_unsorted_v.pseq_id FROM current_annotations_unsorted_v WHERE (current_annotations_unsorted_v.ann_pref < 50000);


ALTER TABLE unison.pset_blast_dv OWNER TO unison;

--
-- Name: VIEW pset_blast_dv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pset_blast_dv IS 'defining view for pset BLAST';


--
-- Name: COLUMN pset_blast_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_blast_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_counts_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_counts_v AS
    SELECT c.count, c.pset_id, s.name, s.descr FROM ((SELECT count(*) AS count, pseqset.pset_id FROM pseqset GROUP BY pseqset.pset_id) c JOIN pset s ON ((c.pset_id = s.pset_id))) ORDER BY c.pset_id;


ALTER TABLE unison.pset_counts_v OWNER TO unison;

--
-- Name: VIEW pset_counts_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW pset_counts_v IS 'psets with # of (distinct) sequences in each set';


--
-- Name: COLUMN pset_counts_v.pset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_counts_v.pset_id IS 'protein sequence set identifier -- see pset(pset_id)';


--
-- Name: COLUMN pset_counts_v.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_counts_v.name IS 'set name';


--
-- Name: COLUMN pset_counts_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_counts_v.descr IS 'set description';


--
-- Name: pset_criteria_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_criteria_v AS
    SELECT ca.pseq_id, ca.origin_id, ca.origin, ca.ann_pref, ca.palias_id, ca.tax_id, ca.k, ca.gs, ca.latin, ca.common, ca.alias, ca.descr, ca.added, ca.link_url, q.len FROM (current_annotations_unsorted_v ca JOIN pseq q ON ((ca.pseq_id = q.pseq_id)));


ALTER TABLE unison.pset_criteria_v OWNER TO unison;

--
-- Name: COLUMN pset_criteria_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN pset_criteria_v.origin_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.origin_id IS 'origin identifier -- see origin(origin_id)';


--
-- Name: COLUMN pset_criteria_v.origin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.origin IS 'origin of sequence -- see origin(origin_id)';


--
-- Name: COLUMN pset_criteria_v.ann_pref; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.ann_pref IS 'annotation preference for the origin of this alias';


--
-- Name: COLUMN pset_criteria_v.palias_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.palias_id IS 'annotation identifier -- see paliasorigin(palias_id)';


--
-- Name: COLUMN pset_criteria_v.tax_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.tax_id IS 'NCBI taxonomy identifier';


--
-- Name: COLUMN pset_criteria_v.k; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.k IS 'Swiss-Prot kingdom code (A=archea; B=bacteria; E=eukaryota; V=viruses)';


--
-- Name: COLUMN pset_criteria_v.gs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.gs IS 'Swiss-Prot genus-species code (e.g., ''HUMAN'', ''BRARE'', ''BOVIN'')';


--
-- Name: COLUMN pset_criteria_v.latin; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.latin IS 'Latin genus and species';


--
-- Name: COLUMN pset_criteria_v.common; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.common IS 'common taxonomic name';


--
-- Name: COLUMN pset_criteria_v.alias; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.alias IS 'alias for the sequence';


--
-- Name: COLUMN pset_criteria_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.descr IS 'set description';


--
-- Name: COLUMN pset_criteria_v.added; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.added IS 'when this data was created';


--
-- Name: COLUMN pset_criteria_v.link_url; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_criteria_v.link_url IS 'URL to source data';


--
-- Name: pset_patented_98_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_patented_98_dv AS
    SELECT DISTINCT b.t_pseq_id AS pseq_id FROM (blasts_v b JOIN pseqset s ON ((b.q_pseq_id = s.pseq_id))) WHERE (s.pset_id = pset_id('patented'::text)) ORDER BY b.t_pseq_id;


ALTER TABLE unison.pset_patented_98_dv OWNER TO unison;

--
-- Name: COLUMN pset_patented_98_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_patented_98_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_patented_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_patented_dv AS
    SELECT DISTINCT palias.pseq_id FROM palias WHERE (palias.origin_id = origin_id('Geneseq'::text)) ORDER BY palias.pseq_id;


ALTER TABLE unison.pset_patented_dv OWNER TO unison;

--
-- Name: COLUMN pset_patented_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_patented_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_unia_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_unia_dv AS
    SELECT DISTINCT pset_criteria_v.pseq_id FROM pset_criteria_v WHERE ((((pset_criteria_v.ann_pref < 10000) AND (pset_criteria_v.tax_id = tax.gs2tax_id('HUMAN'::text))) AND (pset_criteria_v.len >= 100)) AND (pset_criteria_v.len <= 1000)) ORDER BY pset_criteria_v.pseq_id;


ALTER TABLE unison.pset_unia_dv OWNER TO unison;

--
-- Name: COLUMN pset_unia_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_unia_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_runa_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_runa_dv AS
    SELECT pset_unia_dv.pseq_id FROM pset_unia_dv UNION SELECT pseq_gene_v.pseq_id FROM _deprecated_pseq_gene_v pseq_gene_v WHERE (pseq_gene_v.tax_id = tax.gs2tax_id('HUMAN'::text));


ALTER TABLE unison.pset_runa_dv OWNER TO unison;

--
-- Name: pset_unib_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_unib_dv AS
    SELECT DISTINCT pset_criteria_v.pseq_id FROM pset_criteria_v WHERE ((pset_criteria_v.ann_pref < 20000) AND ((((pset_criteria_v.tax_id = tax.gs2tax_id('HUMAN'::text)) AND (pset_criteria_v.len >= 100)) AND (pset_criteria_v.len <= 2000)) OR (((((pset_criteria_v.tax_id = tax.gs2tax_id('MOUSE'::text)) OR (pset_criteria_v.tax_id = tax.gs2tax_id('RAT'::text))) OR (pset_criteria_v.tax_id = tax.gs2tax_id('PANTR'::text))) AND (pset_criteria_v.len >= 100)) AND (pset_criteria_v.len <= 1000)))) ORDER BY pset_criteria_v.pseq_id;


ALTER TABLE unison.pset_unib_dv OWNER TO unison;

--
-- Name: COLUMN pset_unib_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_unib_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_runb_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_runb_dv AS
    SELECT pset_runa_dv.pseq_id FROM pset_runa_dv UNION SELECT pset_unib_dv.pseq_id FROM pset_unib_dv;


ALTER TABLE unison.pset_runb_dv OWNER TO unison;

--
-- Name: pset_unic_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_unic_dv AS
    SELECT DISTINCT pset_criteria_v.pseq_id FROM pset_criteria_v WHERE ((((pset_criteria_v.ann_pref < 50000) AND (pset_criteria_v.tax_id = ANY (ARRAY[tax.gs2tax_id('ANOGA'::text), tax.gs2tax_id('BOVIN'::text), tax.gs2tax_id('CAEEL'::text), tax.gs2tax_id('CANFA'::text), tax.gs2tax_id('CHICK'::text), tax.gs2tax_id('DANRE'::text), tax.gs2tax_id('DROME'::text), tax.gs2tax_id('FELCA'::text), tax.gs2tax_id('FUGRU'::text), tax.gs2tax_id('HUMAN'::text), tax.gs2tax_id('MACFU'::text), tax.gs2tax_id('MACMU'::text), tax.gs2tax_id('MOUSE'::text), tax.gs2tax_id('PANPA'::text), tax.gs2tax_id('PANTR'::text), tax.gs2tax_id('RAT'::text), tax.gs2tax_id('TETFL'::text), tax.gs2tax_id('RABIT'::text), tax.gs2tax_id('YEAST'::text), tax.gs2tax_id('XENTR'::text)]))) AND (pset_criteria_v.len >= 100)) AND (pset_criteria_v.len <= 5000)) ORDER BY pset_criteria_v.pseq_id;


ALTER TABLE unison.pset_unic_dv OWNER TO unison;

--
-- Name: COLUMN pset_unic_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_unic_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_runc_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_runc_dv AS
    SELECT pset_runb_dv.pseq_id FROM pset_runb_dv UNION SELECT pset_unic_dv.pseq_id FROM pset_unic_dv;


ALTER TABLE unison.pset_runc_dv OWNER TO unison;

--
-- Name: pset_rungga_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_rungga_dv AS
    SELECT current_annotations_v.pseq_id FROM current_annotations_v WHERE (current_annotations_v.origin_id = origin_id('GenenGenes auto'::text));


ALTER TABLE unison.pset_rungga_dv OWNER TO unison;

--
-- Name: COLUMN pset_rungga_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_rungga_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_uptodate_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_uptodate_dv AS
    SELECT current_annotations_v.pseq_id FROM current_annotations_v WHERE (((((current_annotations_v.origin_id = origin_id('UniProt'::text)) OR (current_annotations_v.origin_id = origin_id('Refseq'::text))) OR (current_annotations_v.origin_id = origin_id('Geneseq'::text))) OR (current_annotations_v.origin_id = origin_id('GenenGenes'::text))) AND (((current_annotations_v.tax_id = tax.gs2tax_id('HUMAN'::text)) OR (current_annotations_v.tax_id = tax.gs2tax_id('MOUSE'::text))) OR (current_annotations_v.tax_id = tax.gs2tax_id('RAT'::text))));


ALTER TABLE unison.pset_uptodate_dv OWNER TO unison;

--
-- Name: COLUMN pset_uptodate_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_uptodate_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: pset_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_v AS
    SELECT pset.pset_id, pset.name, pset.descr, pset.def FROM pset ORDER BY pset.pset_id;


ALTER TABLE unison.pset_v OWNER TO unison;

--
-- Name: COLUMN pset_v.pset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_v.pset_id IS 'protein sequence set identifier -- see pset(pset_id)';


--
-- Name: COLUMN pset_v.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_v.name IS 'set name';


--
-- Name: COLUMN pset_v.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_v.descr IS 'set description';


--
-- Name: pset_viral_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW pset_viral_dv AS
    SELECT a.pseq_id FROM (palias a JOIN tax.spspec t ON ((a.tax_id = t.tax_id))) WHERE (t.k = 'V'::bpchar);


ALTER TABLE unison.pset_viral_dv OWNER TO unison;

--
-- Name: COLUMN pset_viral_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN pset_viral_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: psetsummary; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW psetsummary AS
    SELECT count(pseqset.pseq_id) AS count, pset.pset_id, pset.name, pset.descr FROM (pset NATURAL LEFT JOIN pseqset) GROUP BY pset.pset_id, pset.name, pset.descr ORDER BY pset.pset_id;


ALTER TABLE unison.psetsummary OWNER TO unison;

--
-- Name: COLUMN psetsummary.pset_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psetsummary.pset_id IS 'protein sequence set identifier -- see pset(pset_id)';


--
-- Name: COLUMN psetsummary.name; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psetsummary.name IS 'set name';


--
-- Name: COLUMN psetsummary.descr; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psetsummary.descr IS 'set description';


--
-- Name: psipred; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE psipred (
    prediction text NOT NULL,
    confidence text NOT NULL,
    pseq_id integer NOT NULL,
    h_confidence text,
    e_confidence text,
    c_confidence text,
    params_id integer NOT NULL
);


ALTER TABLE unison.psipred OWNER TO unison;

--
-- Name: TABLE psipred; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE psipred IS 'Psipred secondary structure prediction results';


--
-- Name: COLUMN psipred.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psipred.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN psipred.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psipred.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: psprotcomp; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE psprotcomp (
    pseq_id integer NOT NULL,
    params_id integer NOT NULL,
    sim_psloc_id integer NOT NULL,
    sim_score real,
    sim_db text,
    sim_target_ac text,
    nn_psloc_id integer NOT NULL,
    nn_score real NOT NULL,
    int_psloc_id integer NOT NULL,
    int_score real NOT NULL,
    int_membrane boolean DEFAULT false NOT NULL,
    int_nuc_score real NOT NULL,
    int_pm_score real NOT NULL,
    int_ext_score real NOT NULL,
    int_cyt_score real NOT NULL,
    int_mit_score real NOT NULL,
    int_er_score real NOT NULL,
    int_per_score real NOT NULL,
    int_lys_score real NOT NULL,
    int_gol_score real NOT NULL,
    features text,
    result_block text NOT NULL
);


ALTER TABLE unison.psprotcomp OWNER TO unison;

--
-- Name: TABLE psprotcomp; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE psprotcomp IS 'Softberry protcomp predictions';


--
-- Name: COLUMN psprotcomp.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN psprotcomp.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN psprotcomp.sim_psloc_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.sim_psloc_id IS 'similarity-based localization identifier';


--
-- Name: COLUMN psprotcomp.sim_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.sim_score IS 'similarity-based prediction score';


--
-- Name: COLUMN psprotcomp.sim_db; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.sim_db IS 'source database similarity-based prediction';


--
-- Name: COLUMN psprotcomp.sim_target_ac; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.sim_target_ac IS 'similarity-based prediction target accession (in sim_db)';


--
-- Name: COLUMN psprotcomp.nn_psloc_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.nn_psloc_id IS 'neural net localization prediction id';


--
-- Name: COLUMN psprotcomp.nn_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.nn_score IS 'neural net localization score';


--
-- Name: COLUMN psprotcomp.int_psloc_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_psloc_id IS 'localization based on best integral score';


--
-- Name: COLUMN psprotcomp.int_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_score IS 'best integral score';


--
-- Name: COLUMN psprotcomp.int_membrane; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_membrane IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_nuc_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_nuc_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_pm_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_pm_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_ext_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_ext_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_cyt_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_cyt_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_mit_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_mit_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_er_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_er_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_per_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_per_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_lys_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_lys_score IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp.int_gol_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp.int_gol_score IS 'component ''integral'' score';


--
-- Name: psprotcomp_location; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE psprotcomp_location (
    psloc_id integer NOT NULL,
    location text NOT NULL
);


ALTER TABLE unison.psprotcomp_location OWNER TO unison;

--
-- Name: TABLE psprotcomp_location; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE psprotcomp_location IS 'lookup table for protcomp cellular locations';


--
-- Name: psprotcomp_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW psprotcomp_v AS
    SELECT pc.pseq_id, pc.params_id, pc.sim_psloc_id, sl.location AS sim_loc, pc.sim_db, pc.sim_target_ac, pc.sim_score, pc.nn_psloc_id, nl.location AS nn_loc, pc.nn_score, pc.int_psloc_id, il.location AS int_loc, pc.int_score FROM (((psprotcomp pc JOIN psprotcomp_location sl ON ((sl.psloc_id = pc.sim_psloc_id))) JOIN psprotcomp_location nl ON ((nl.psloc_id = pc.nn_psloc_id))) JOIN psprotcomp_location il ON ((il.psloc_id = pc.int_psloc_id)));


ALTER TABLE unison.psprotcomp_v OWNER TO unison;

--
-- Name: VIEW psprotcomp_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW psprotcomp_v IS 'protcomp summary view';


--
-- Name: COLUMN psprotcomp_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN psprotcomp_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: COLUMN psprotcomp_v.sim_psloc_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.sim_psloc_id IS 'similarity-based localization identifier';


--
-- Name: COLUMN psprotcomp_v.sim_loc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.sim_loc IS 'similarity-based localization';


--
-- Name: COLUMN psprotcomp_v.sim_db; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.sim_db IS 'source database for similarity-based prediction';


--
-- Name: COLUMN psprotcomp_v.sim_target_ac; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.sim_target_ac IS 'similarity-based prediction target accession (in sim_db)';


--
-- Name: COLUMN psprotcomp_v.sim_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.sim_score IS 'similarity-based prediction score';


--
-- Name: COLUMN psprotcomp_v.nn_psloc_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.nn_psloc_id IS 'neural net localization prediction id';


--
-- Name: COLUMN psprotcomp_v.nn_loc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.nn_loc IS 'neural net localization prediction';


--
-- Name: COLUMN psprotcomp_v.nn_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.nn_score IS 'neural net localization score';


--
-- Name: COLUMN psprotcomp_v.int_psloc_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.int_psloc_id IS 'localization based on best integral score';


--
-- Name: COLUMN psprotcomp_v.int_loc; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.int_loc IS 'component ''integral'' score';


--
-- Name: COLUMN psprotcomp_v.int_score; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_v.int_score IS 'best integral score';


--
-- Name: psprotcomp_reliable_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW psprotcomp_reliable_v AS
    SELECT pc.pseq_id, pc.params_id, pc.sim_psloc_id AS psloc_id, pc.sim_loc AS loc, 'sequence similarity' AS method, pc.sim_target_ac AS details FROM psprotcomp_v pc WHERE (pc.sim_psloc_id <> 0) UNION ALL SELECT pc.pseq_id, pc.params_id, pc.nn_psloc_id AS psloc_id, pc.nn_loc AS loc, 'nn & integral agreement' AS method, NULL::unknown AS details FROM psprotcomp_v pc WHERE ((pc.sim_psloc_id = 0) AND (pc.int_psloc_id = pc.nn_psloc_id));


ALTER TABLE unison.psprotcomp_reliable_v OWNER TO unison;

--
-- Name: VIEW psprotcomp_reliable_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW psprotcomp_reliable_v IS 'reliable protcomp predictions';


--
-- Name: COLUMN psprotcomp_reliable_v.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_reliable_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: COLUMN psprotcomp_reliable_v.params_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN psprotcomp_reliable_v.params_id IS 'parameter set identifier -- see params(params_id)';


--
-- Name: public_pseq_ids_dv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW public_pseq_ids_dv AS
    SELECT DISTINCT sa.pseq_id FROM ((origin o JOIN paliasorigin ao ON ((o.origin_id = ao.origin_id))) JOIN pseqalias sa ON ((ao.palias_id = sa.palias_id))) WHERE (o.is_public AND sa.is_current) ORDER BY sa.pseq_id;


ALTER TABLE unison.public_pseq_ids_dv OWNER TO unison;

--
-- Name: VIEW public_pseq_ids_dv; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW public_pseq_ids_dv IS 'public pseq_ids; see pset 150';


--
-- Name: COLUMN public_pseq_ids_dv.pseq_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN public_pseq_ids_dv.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';


--
-- Name: run_history_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW run_history_v AS
    SELECT r.run_id, h.pseq_id, r.params_id, p.name AS params, p.commandline, r.pmodelset_id, m.name AS modelset, to_char(h.ran_on, 'YYYY-MM-DD HH24:MI'::text) AS ran_on, h.failed FROM (((run_history h JOIN run r ON ((r.run_id = h.run_id))) JOIN params p ON ((r.params_id = p.params_id))) LEFT JOIN pmodelset m ON ((r.pmodelset_id = m.pmodelset_id))) ORDER BY h.pseq_id, p.name, m.name;


ALTER TABLE unison.run_history_v OWNER TO unison;

--
-- Name: VIEW run_history_v; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON VIEW run_history_v IS 'history of analyses by sequence and run (=<parameter,modelset>)';


--
-- Name: run_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW run_v AS
    SELECT r.run_id, r.params_id, p.name AS params, r.pmodelset_id, m.name AS modelset FROM ((run r JOIN params p ON ((r.params_id = p.params_id))) LEFT JOIN pmodelset m ON ((r.pmodelset_id = m.pmodelset_id)));


ALTER TABLE unison.run_v OWNER TO unison;

--
-- Name: get_scopid(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION get_scopid(text) RETURNS text
    AS $_$

DECLARE
        arg alias for $1;
	ret text;
	pos text;
BEGIN
	ret=arg;

	--add d at the beginning if it doesnt exist already
	IF substring(ret from 1 for 1) != 'd' THEN
		ret := 'd'||ret;
	END IF;

	IF ret ~ '_[A-Z]$' THEN
		ret := overlay(ret placing '' from length(ret)-1 for 1);
	END IF;

	ret := rpad(ret, 7, '_');

        return lower(ret);
END;
$_$
    LANGUAGE plpgsql IMMUTABLE;


ALTER FUNCTION unison.get_scopid(text) OWNER TO unison;

--
-- Name: scop_pmodel_v; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW scop_pmodel_v AS
    SELECT c.sid, c.pdb, c.sccs, c.sp, d.descr, p.pmodel_id FROM pmprospect p, (scop.cla c JOIN scop.des d ON ((c.dm = d.sunid))) WHERE (c.sid = get_scopid(p.acc));


ALTER TABLE unison.scop_pmodel_v OWNER TO unison;

--
-- Name: COLUMN scop_pmodel_v.pmodel_id; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON COLUMN scop_pmodel_v.pmodel_id IS 'unique protein model identifier';


--
-- Name: tm_kunitz_cv; Type: VIEW; Schema: unison; Owner: unison
--

CREATE VIEW tm_kunitz_cv AS
    SELECT DISTINCT ON (a.pseq_id) a.pseq_id, (SELECT pftmhmm_tm_count_v.count FROM pftmhmm_tm_count_v WHERE (pftmhmm_tm_count_v.pseq_id = a.pseq_id)) AS "#TM", ea.patented AS pat, ea."patented98%" AS pat98, a.eval FROM ((pahmm a JOIN extended_annotation_v ea ON ((a.pseq_id = ea.pseq_id))) JOIN run r ON ((r.params_id = a.params_id))) WHERE (((r.run_id = preferred_run_id_by_pftype('HMM'::text)) AND (a.pmodel_id IN (SELECT hmm_pmodel_id('Kunitz_BPTI'::text) AS hmm_pmodel_id))) AND (a.eval < (1)::double precision)) ORDER BY a.pseq_id;


ALTER TABLE unison.tm_kunitz_cv OWNER TO unison;

--
-- Name: userprefs; Type: TABLE; Schema: unison; Owner: unison; Tablespace: 
--

CREATE TABLE userprefs (
    usesysid integer NOT NULL,
    show_tips boolean DEFAULT true NOT NULL,
    show_sql boolean DEFAULT true NOT NULL
);


ALTER TABLE unison.userprefs OWNER TO unison;

--
-- Name: TABLE userprefs; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON TABLE userprefs IS 'user preferences for web interface';


SET search_path = unison_aux, pg_catalog;

--
-- Name: hugo; Type: TABLE; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE TABLE hugo (
    hgnc_id integer NOT NULL,
    approved_symbold text NOT NULL,
    approved_name text NOT NULL,
    status text NOT NULL,
    locus_type text NOT NULL,
    previous_symbols text,
    previous_names text,
    aliases text,
    chromosome text,
    date_approved text,
    date_modified text,
    date_name_changed text,
    accession_numbers text,
    enzyme_ids text,
    entrez_gene_id text,
    mgd_id text,
    specialist_db_links text,
    pubmed_ids text,
    refseq_ids text,
    gene_family_name text,
    gdb_id_md text,
    entrez_gene_id_md text,
    omim_id_md text,
    refseq_md text,
    uniprot_id_md text
);


ALTER TABLE unison_aux.hugo OWNER TO unison;

--
-- Name: TABLE hugo; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON TABLE hugo IS 'Human Genome Organization official gene names';


--
-- Name: COLUMN hugo.hgnc_id; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.hgnc_id IS 'HGNC ID';


--
-- Name: COLUMN hugo.approved_symbold; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.approved_symbold IS 'Approved Symbol';


--
-- Name: COLUMN hugo.approved_name; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.approved_name IS 'Approved Name';


--
-- Name: COLUMN hugo.status; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.status IS 'Status';


--
-- Name: COLUMN hugo.locus_type; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.locus_type IS 'Locus Type';


--
-- Name: COLUMN hugo.previous_symbols; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.previous_symbols IS 'Previous Symbols';


--
-- Name: COLUMN hugo.previous_names; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.previous_names IS 'Previous Names';


--
-- Name: COLUMN hugo.aliases; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.aliases IS 'Aliases';


--
-- Name: COLUMN hugo.chromosome; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.chromosome IS 'Chromosome';


--
-- Name: COLUMN hugo.date_approved; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.date_approved IS 'Date Approved';


--
-- Name: COLUMN hugo.date_modified; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.date_modified IS 'Date Modified';


--
-- Name: COLUMN hugo.date_name_changed; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.date_name_changed IS 'Date Name Changed';


--
-- Name: COLUMN hugo.accession_numbers; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.accession_numbers IS 'Accession Numbers';


--
-- Name: COLUMN hugo.enzyme_ids; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.enzyme_ids IS 'Enzyme IDs';


--
-- Name: COLUMN hugo.entrez_gene_id; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.entrez_gene_id IS 'Entrez Gene ID';


--
-- Name: COLUMN hugo.mgd_id; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.mgd_id IS 'MGD ID';


--
-- Name: COLUMN hugo.specialist_db_links; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.specialist_db_links IS 'Misc IDs';


--
-- Name: COLUMN hugo.pubmed_ids; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.pubmed_ids IS 'Pubmed IDs';


--
-- Name: COLUMN hugo.refseq_ids; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.refseq_ids IS 'RefSeq IDs';


--
-- Name: COLUMN hugo.gene_family_name; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.gene_family_name IS 'Gene Family Name';


--
-- Name: COLUMN hugo.gdb_id_md; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.gdb_id_md IS 'GDB ID (mapped data)';


--
-- Name: COLUMN hugo.entrez_gene_id_md; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.entrez_gene_id_md IS 'Entrez Gene ID (mapped data)';


--
-- Name: COLUMN hugo.omim_id_md; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.omim_id_md IS 'OMIM ID (mapped data)';


--
-- Name: COLUMN hugo.refseq_md; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.refseq_md IS 'RefSeq (mapped data)';


--
-- Name: COLUMN hugo.uniprot_id_md; Type: COMMENT; Schema: unison_aux; Owner: unison
--

COMMENT ON COLUMN hugo.uniprot_id_md IS 'UniProt ID (mapped data)';


SET search_path = gong, pg_catalog;

--
-- Name: acc2id(text); Type: FUNCTION; Schema: gong; Owner: unison
--

CREATE FUNCTION acc2id(text) RETURNS integer
    AS $_$
DECLARE
	acc alias for $1;
	pos integer;
BEGIN
	pos := strpos($1,':');
	if pos is null then
		raise exception 'oops.. doesn''t look like a GO Accession (GO:12345)';
		return null;
	end if;
	return substr(acc,pos+1)::integer;
END$_$
    LANGUAGE plpgsql;


ALTER FUNCTION gong.acc2id(text) OWNER TO unison;

--
-- Name: id2acc(integer); Type: FUNCTION; Schema: gong; Owner: unison
--

CREATE FUNCTION id2acc(integer) RETURNS text
    AS $_X$return sprintf("GO:%06d",$_[0])$_X$
    LANGUAGE plperl;


ALTER FUNCTION gong.id2acc(integer) OWNER TO unison;

SET search_path = pdb, pg_catalog;

--
-- Name: descriptor_origin_id(text, text, text); Type: FUNCTION; Schema: pdb; Owner: unison
--

CREATE FUNCTION descriptor_origin_id(text, text, text) RETURNS integer
    AS $_$
DECLARE V_id integer; 
BEGIN 
	IF $3 is NULL THEN
		select into V_id descriptor_origin_id from descriptor_origin where type = $1 and upper(origin) = upper($2) and version is NULL;
	
	ELSE
		select into V_id descriptor_origin_id from descriptor_origin where type = $1 and upper(origin) = upper($2) and version = $3; 
	END IF; 
		IF NOT FOUND THEN 
			RAISE WARNING 'descriptor type ''%'' from origin ''%'' version ''%'' not found', $1,$2,$3; 
		RETURN NULL; 
	END IF;
	return V_id; 
END;
$_$
    LANGUAGE plpgsql IMMUTABLE;


ALTER FUNCTION pdb.descriptor_origin_id(text, text, text) OWNER TO unison;

--
-- Name: descriptor_origin_id(text); Type: FUNCTION; Schema: pdb; Owner: unison
--

CREATE FUNCTION descriptor_origin_id(text) RETURNS SETOF integer
    AS $_$
 DECLARE 
	V_id integer;
 BEGIN 
	FOR V_id IN select descriptor_origin_id from descriptor_origin where type = $1 LOOP 
		return NEXT V_id; 
	END LOOP;
 	RETURN; 
 END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION pdb.descriptor_origin_id(text) OWNER TO unison;

--
-- Name: descriptor_origin_si_descriptor_origin_id(text, text, text); Type: FUNCTION; Schema: pdb; Owner: unison
--

CREATE FUNCTION descriptor_origin_si_descriptor_origin_id(text, text, text) RETURNS integer
    AS $_$
DECLARE
	t alias for $1;
        o alias for $2;                         -- origin
	v alias for $3;
        rv integer;
BEGIN
	if v is null then
		select into rv descriptor_origin_id from descriptor_origin where type = t and upper(origin) = upper(o) and version is NULL;
	else
		select into rv descriptor_origin_id from descriptor_origin where type = t and upper(origin) = upper(o) and version = v;
	end if;
        if found then 
		return rv; 
	end if;
        insert into descriptor_origin(type,origin,version) values (t,o,v);
	if v is null then
		select into rv descriptor_origin_id from descriptor_origin where type = t and upper(origin) = upper(o) and version is NULL;
	else
		select into rv descriptor_origin_id from descriptor_origin where type = t and upper(origin) = upper(o) and version = v;
	end if;
        return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION pdb.descriptor_origin_si_descriptor_origin_id(text, text, text) OWNER TO unison;

--
-- Name: FUNCTION descriptor_origin_si_descriptor_origin_id(text, text, text); Type: COMMENT; Schema: pdb; Owner: unison
--

COMMENT ON FUNCTION descriptor_origin_si_descriptor_origin_id(text, text, text) IS 'select/insert a descriptor_origin_id from descriptor_origin, returns decsriptor_origin_id';


--
-- Name: residue_atomres_trigger(); Type: FUNCTION; Schema: pdb; Owner: unison
--

CREATE FUNCTION residue_atomres_trigger() RETURNS trigger
    AS $$
  DECLARE
  BEGIN

	IF new.atom_res IS null or new.atom_res = '' THEN
		IF new.res_id IS not null or new.res_id != '' THEN
			RAISE EXCEPTION 'res_id is not null when atom_res is null for pdbc = % and seqpos = %',new.pdbc,new.seq_pos;
			RETURN NULL;
		END IF;
	END IF;
	IF new.res_id IS null or new.res_id = '' THEN
		IF new.atom_res IS not null or new.atom_res != '' THEN
			RAISE EXCEPTION 'atom_res is not null when res_id is null for pdbc = % and seqpos = %',new.pdbc,new.seq_pos;
			RETURN NULL;
		END IF;
	END IF;
	RETURN new;

  END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION pdb.residue_atomres_trigger() OWNER TO unison;

SET search_path = pgutils, pg_catalog;

--
-- Name: pk_references(text, text, text, text); Type: FUNCTION; Schema: pgutils; Owner: rkh
--

CREATE FUNCTION pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text) RETURNS SETOF record
    AS $$
DECLARE
	v_fkinfo record;
	v_sql text;
	v_countrow record;
	v_total integer = 0;
	v_rc integer;
BEGIN
	-- for...in...execute is the only way to get the results of a dynamic query
	-- This construct is used several times below

	-- check pgtools.foreign_keys to see whether n.r.c is really a PK at all
	-- twould be better to chech pg_constraint for contype=p
	SELECT into v_sql 'SELECT count(*) from pgtools.foreign_keys'
		||' WHERE pk_namespace='''||nsp||''' AND pk_relation='''||rel||''' AND pk_column='''||col||'''';
	FOR v_countrow IN EXECUTE v_sql LOOP
		v_rc = v_countrow.count;
	END LOOP;
	IF v_rc = 0 THEN
		RAISE EXCEPTION '%.%.% is not a primary key or has no foreign key references',nsp,rel,col;
	END IF;

	-- ensure that expr matches anything in the PK column
	v_rc = 0;
	SELECT INTO v_sql 'SELECT count(*) FROM '||nsp||'.'||rel||' WHERE '||col||' '||expr;
	FOR v_countrow IN EXECUTE v_sql LOOP
		v_rc = v_countrow.count;
	END LOOP;
	IF v_rc = 0 THEN
		RAISE WARNING '`% %'' doesn''t match any rows in %.%',col,expr,nsp,rel;
	END IF;

	-- loop over all nsp.rel.col referents to this PK, counting the number of hits per expr
	FOR v_fkinfo IN
		SELECT * from pgtools.foreign_keys
		WHERE pk_namespace=nsp AND pk_relation=rel AND pk_column=col
	LOOP
		SELECT INTO v_sql 
			'SELECT count(*) as n,'''
			||v_fkinfo.fk_namespace||'.'||v_fkinfo.fk_relation||'.'||v_fkinfo.fk_column||''' as fk_referent'
			||' from '||v_fkinfo.fk_namespace||'.'||v_fkinfo.fk_relation
			||' where '||v_fkinfo.fk_column||' '||expr||';';
		FOR v_countrow IN EXECUTE v_sql LOOP
			n = v_countrow.n;
			fk_referent = v_countrow.fk_referent;
			v_total = v_total+n;
			RETURN NEXT;
		END LOOP;

	END LOOP;

	-- return total too
	n = v_total;
	fk_referent = 'total';
	RETURN NEXT;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION pgutils.pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text) OWNER TO rkh;

--
-- Name: FUNCTION pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text); Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON FUNCTION pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text) IS 'count number of rows in all tables which reference the column specified by nsp($1),rel($2),col($3) and match expr($4)';


--
-- Name: pk_references(text, text); Type: FUNCTION; Schema: pgutils; Owner: rkh
--

CREATE FUNCTION pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text) RETURNS SETOF record
    AS $$
DECLARE
	v_nsp text;
	v_rel text;
	v_col text;
	v_row record;
BEGIN
	v_nsp = split_part(nrc,'.',1);
	v_rel = split_part(nrc,'.',2);
	v_col = split_part(nrc,'.',3);
	FOR v_row IN SELECT * FROM pgtools.pk_references(v_nsp,v_rel,v_col,expr) LOOP
		n=v_row.n;
		fk_referent=v_row.fk_referent;
		RETURN NEXT;
	END LOOP;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION pgutils.pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text) OWNER TO rkh;

--
-- Name: FUNCTION pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text); Type: COMMENT; Schema: pgutils; Owner: rkh
--

COMMENT ON FUNCTION pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text) IS 'count number of rows in all tables which reference the nsp.rel.col($1) and match expr($4)';


SET search_path = tax, pg_catalog;

--
-- Name: spspec_name(integer); Type: FUNCTION; Schema: tax; Owner: unison
--

CREATE FUNCTION spspec_name(integer) RETURNS text
    AS $_$
DECLARE
	v_id alias for $1;
	rv text;
BEGIN
	select into rv name from tax.spspec where id=v_id;
	return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION tax.spspec_name(integer) OWNER TO unison;

SET search_path = unison, pg_catalog;

--
-- Name: _clean_regexp(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _clean_regexp(text) RETURNS text
    AS $_X$
$_ = shift;

my $NOT_RT_BRACKET = qr([^\]]);

# flatten nested [] e.g., [A[BC]D[EF]FG] -> ABCDEFFG
while (s/\[($NOT_RT_BRACKET*)\[($NOT_RT_BRACKET*)\]/[\1\2/) {
	die("complement operator ('^') is not allowed inside nested regexps
") if $2 =~ m/\^/;
};

# eliminate redundancies in [] sets e.g., A[BBC]D -> A[BC]D
# postgresql 7.x requires plperlu, 8.x may use plperl
# WARNING: - is intepreted literally, i.e., ranges aren't supported
s&
  \[($NOT_RT_BRACKET+)\]
&
  my %aa = map {$_=>1} split(//,$1);
  my @aa = sort keys %aa;
  my $comp = 0;
  if ($aa[$#aa] eq '^') { $comp++; pop(@aa); }  # pop '^'
  '[' . ($comp?'^':'') . join("",@aa) . ']';
&egx;

return $_;
$_X$
    LANGUAGE plperlu IMMUTABLE STRICT;


ALTER FUNCTION unison._clean_regexp(text) OWNER TO unison;

--
-- Name: FUNCTION _clean_regexp(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION _clean_regexp(text) IS 'reformat regular expression';


--
-- Name: _dblast_species(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _dblast_species(text) RETURNS text
    AS $_$select postgres.plregex($1,E'/^.* - (.+?)\\.?\$/$1/'::TEXT)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison._dblast_species(text) OWNER TO unison;

--
-- Name: _defline_agg_finalfunc(anyarray); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _defline_agg_finalfunc(anyarray) RETURNS text
    AS $_$select array_to_string($1,'')$_$
    LANGUAGE sql;


ALTER FUNCTION unison._defline_agg_finalfunc(anyarray) OWNER TO unison;

--
-- Name: _expand_aa_sets(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _expand_aa_sets(text) RETURNS text
    AS $_X$
# http://www.dur.ac.uk/biological.sciences/Bioinformatics/aminoacids.htm
# http://www.ncbi.nlm.nih.gov/Class/MLACourse/Modules/MolBioReview/iupac_aa_abbreviations.html
# http://www.ncbi.nlm.nih.gov/projects/collab/FT/index.html#7.5.3
# Expasy References:
# 1) Thomas E. Creighton (1993) "Proteins." W.H. Freeman and Company, New York. 2nd Edition.
# 2) Richards, F.M. (1974) J. Mol.Biol. 82:1-14. [Van-der-Waals radii of amino acids]

$_ = shift;

# IUPAC ambiguities
## Ambiguity codes are included in their own expansions so that
## they match themselves in sequences which contain ambiguities.
s/B/[BDN]/g;
s/Z/[ZEQ]/g;
s/X/[ACDEFGHIKLMNPQRSTVWYUBZX]/g;

# amino acid sets
s/<(?:basic|\+)>/[HKR]/g;
s/<(?:acidic|-)>/[DE]/g;
s/<(?:neutral|0)>/[ACFGILMNPQSTUVWY]/g;
s/<(?:polar|p)>/[NQST]/g;
s/<(?:hphobic|o)>/[AIFLMVWY]/g;
s/<(?:aromatic|r)>/[FWY]/g;
s/<(?:small|s)>/[AGS]/g;
s/<(?:medium|m)>/[CDEHILMNPQTUV]/g;	 # U~C
s/<(?:large|l)>/[FKRWY]/g;

s/<(.*)>/!!$1!!/g;				# unrecognized sets

return $_;
$_X$
    LANGUAGE plperl IMMUTABLE STRICT;


ALTER FUNCTION unison._expand_aa_sets(text) OWNER TO unison;

--
-- Name: FUNCTION _expand_aa_sets(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION _expand_aa_sets(text) IS 'INTERNAL; see expand_aa_sets(text)';


--
-- Name: _geneseq_species(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _geneseq_species(text) RETURNS text
    AS $_$select postgres.plregex($1,E'/^.*\\[OS: ([^\\]+]+)\\]/$1/'::TEXT)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison._geneseq_species(text) OWNER TO unison;

--
-- Name: _nr_species(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _nr_species(text) RETURNS text
    AS $_$select postgres.plregex($1,E'/^.+\\[(.+)\\].*/$1/'::TEXT)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison._nr_species(text) OWNER TO unison;

--
-- Name: _pseq_md5len_lookup(text, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _pseq_md5len_lookup(text, integer) RETURNS integer
    AS $_$
DECLARE
	c refcursor;
	rv integer;
BEGIN
	open c for execute 'select pseq_id from pseq where '
		|| ' md5=' || quote_literal($1) || ' and '
		|| ' len=' || quote_literal($2) ;
	fetch c into rv;
	close c;
	return rv;
end;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison._pseq_md5len_lookup(text, integer) OWNER TO unison;

--
-- Name: _pseq_seq_lookup(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _pseq_seq_lookup(text) RETURNS integer
    AS $_$
BEGIN
	return _pseq_md5len_lookup(md5($1),length($1));
END;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison._pseq_seq_lookup(text) OWNER TO unison;

--
-- Name: _publicize(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _publicize() RETURNS void
    AS $_$
DECLARE
	v_row record;
BEGIN
	IF current_database() !~ '-public$' THEN
		RAISE EXCEPTION 'publicize(): database must be named "csb-public"';
	END IF;

	RAISE WARNING '%: BEGINNING MASSIVE DELETE OF PROPRIETARY DATA.', timeofday();

	FOR v_row IN SELECT origin,origin_id FROM origin WHERE is_public=FALSE ORDER BY origin_id LOOP
		RAISE NOTICE '%: deleting results for ''%'' (origin_id=%)', timeofday(), v_row.origin, v_row.origin_id;
		DELETE FROM paliasorigin WHERE origin_id=v_row.origin_id;
		DELETE FROM origin WHERE origin_id=v_row.origin_id;
	END LOOP;

	FOR v_row IN SELECT name,params_id FROM params WHERE is_public=FALSE ORDER BY params_id LOOP   
		RAISE NOTICE '%: deleting results for ''%'' (params_id=%)', timeofday(), v_row.name, v_row.params_id;
		DELETE FROM pahmm WHERE params_id=v_row.params_id;
		DELETE FROM paprospect WHERE params_id=v_row.params_id;
		DELETE FROM params WHERE params_id=v_row.params_id;
	END LOOP;

	RAISE NOTICE 'deleting sequences NOT in pset_id=150';
	DELETE FROM pseq WHERE pseq_id NOT IN (SELECT pseq_id FROM pseqset WHERE pset_id=150);

	SELECT meta_update_kv('publicized at',NOW());

	RAISE NOTICE '%: Done. You should VACUUM ANALYZE VERBOSE.', timeofday();
	RETURN;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison._publicize() OWNER TO unison;

--
-- Name: FUNCTION _publicize(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION _publicize() IS 'DANGER: This function deletes all proprietary data. It may only be run in a database named csb-public.';


--
-- Name: _refseq_species(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _refseq_species(text) RETURNS text
    AS $_$select postgres.plregex($1,E'/^.+\\[(.+)\\]/$1/'::TEXT)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison._refseq_species(text) OWNER TO unison;

--
-- Name: _seqhash_no_cleaning(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION _seqhash_no_cleaning(text) RETURNS text
    AS $_$DECLARE S text; BEGIN return ( md5($1) || length($1) ); END$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison._seqhash_no_cleaning(text) OWNER TO unison;

--
-- Name: a280(text, text, boolean); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION a280(text, text, boolean) RETURNS real
    AS $_X$

my %ec_params;
#EMBOSS/share/EMBOSS/data/Eamino.dat
$ec_params{emboss} = {
	eY => 1280,
	eW => 5690,
	eC => 60
	}; 
 
#Pace et al
$ec_params{pace} = {
	eY => 1490,
	eW => 5500,
	eC => 125
	};

my $seq = shift;
elog(ERROR, "sequence length <= 0") if(length($seq) <= 0);

my $params = shift;
elog(ERROR, "extinction coefficents set $params does not exist options are 'emboss' (Gill and von Hippel (1989) _Anal_Biochem_ 182 319-326) and 'Pace' (Pace et. al. Protein Science 1995)
") if(not defined $ec_params{$params});

my $all_cystines = shift;
my $count = count_TyrTrp_residues($seq);

my $ans= (($count->{Y} * $ec_params{$params}{eY}) + ($count->{W} * $ec_params{$params}{eW}) );
$ans +=  int($count->{C}/2) * $ec_params{$params}{eC} if($all_cystines eq 't');

return $ans;

sub count_TyrTrp_residues {
   my $seq = shift;
   my $count;
   for ( qw( Y W C) ){ # Tyrosine and Trptophan AAs
      $count->{$_}++ while $seq =~ /$_/ig;
   }
   return $count;
}	

$_X$
    LANGUAGE plperl IMMUTABLE STRICT;


ALTER FUNCTION unison.a280(text, text, boolean) OWNER TO unison;

--
-- Name: FUNCTION a280(text, text, boolean); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION a280(text, text, boolean) IS 'returns the molar Extinction Coefficient of a protein in ';


--
-- Name: a280(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION a280(text) RETURNS real
    AS $_$
DECLARE 
	ans float;
BEGIN 
	select INTO ans A280($1,'emboss','f');
	return ans;
END$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.a280(text) OWNER TO unison;

--
-- Name: aa_3_to_1(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION aa_3_to_1(text) RETURNS text
    AS $_$
select case $1
	when 'Ala' then 'A'
	when 'Bas' then 'B'
	when 'Cys' then 'C'
	when 'Asp' then 'D'
	when 'Glu' then 'E'
	when 'Phe' then 'F'
	when 'Gly' then 'G'
	when 'His' then 'H'
	when 'Iso' then 'I'
	when 'Lys' then 'K'
	when 'Leu' then 'L'
	when 'Met' then 'M'
	when 'Asn' then 'N'
	when 'Pro' then 'P'
	when 'Gln' then 'Q'
	when 'Arg' then 'R'
	when 'Ser' then 'S'
	when 'Thr' then 'T'
	when 'Val' then 'V'
	when 'Trp' then 'W'
	when 'Any' then 'X'
	when 'Tyr' then 'Y'
	when 'Aci' then 'Z'
	else '?'
	end;
$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.aa_3_to_1(text) OWNER TO unison;

--
-- Name: add_soa(text, text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION add_soa(text, text, text) RETURNS integer
    AS $_$
DECLARE
	S alias for $1;				-- sequence
	O alias for $2;				-- origin
	A alias for $3;				-- alias
	si	integer;				-- pseq_id
	oi	integer;				-- origin_id
BEGIN
	si := si_pseq_id(S);
	oi := si_origin_id(O);
	insert into palias (pseq_id,origin_id,alias) values (si,oi,A);
	return si;
END;$_$
    LANGUAGE plpgsql STRICT;


ALTER FUNCTION unison.add_soa(text, text, text) OWNER TO unison;

--
-- Name: FUNCTION add_soa(text, text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION add_soa(text, text, text) IS 'add <sequnce,origin,alias> tuple, using existing ids when available, returns pseq_id';


--
-- Name: assign_alias(integer, text, text, integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION assign_alias(integer, text, text, integer, integer, integer) RETURNS integer
    AS $_$
DECLARE
	v_origin_id ALIAS FOR $1;
	v_alias ALIAS FOR $2;
	v_descr ALIAS FOR $3;
	v_pseq_id ALIAS FOR $4;
	v_ref_pseq_id ALIAS FOR $5;
	v_tax_id ALIAS FOR $6;
	v_palias_id integer;
BEGIN
	RAISE WARNING 'This version of assign_alias is deprecated; ref_pseq_id is being ignored (if provided)';
	SELECT INTO v_palias_id assign_alias(v_pseq_id,v_origin_id,v_alias,v_descr,v_tax_id);
	RETURN v_palias_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.assign_alias(integer, text, text, integer, integer, integer) OWNER TO unison;

--
-- Name: FUNCTION assign_alias(integer, text, text, integer, integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION assign_alias(integer, text, text, integer, integer, integer) IS 'create a pseqalias record for the given paliasorigin and pseq entries';


--
-- Name: assign_alias(integer, integer, text, text, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION assign_alias(v_pseq_id integer, v_origin_id integer, v_alias text, v_descr text, v_tax_id integer, OUT v_palias_id integer) RETURNS integer
    AS $$
DECLARE
	rv integer;
	rec record;
BEGIN
	-- insert/fetch the origin/alias/descr/tax_id annotation
	SELECT INTO v_palias_id ins_paliasorigin( v_origin_id, v_alias, v_descr, v_tax_id );

	-- fetch the most recent pseqalias entry for this palias_id, if any
	SELECT INTO rec * FROM pseqalias WHERE palias_id=v_palias_id ORDER BY version DESC LIMIT 1;

	IF NOT FOUND THEN
		-- No pseqalias entry exists for this palias_id.
		-- The paliasorigin row was probably just created above.
		RAISE DEBUG 'assigning new palias_id % to pseq_id %, version %',
			 v_palias_id, v_pseq_id, 1;
		INSERT INTO pseqalias ( palias_id, pseq_id )
			VALUES ( v_palias_id, v_pseq_id );
		RETURN;
	END IF;

	-- palias_id is currently assigned to some sequence
	RAISE DEBUG 'palias_id %: pseq_id=%, version=%, is_current=%, added=%',
		rec.palias_id, rec.pseq_id, rec.version, rec.is_current, rec.added;
	
	IF v_pseq_id != rec.pseq_id THEN
		RAISE DEBUG '  reassigning palias_id to pseq_id=%', v_pseq_id;
		UPDATE pseqalias SET is_current = FALSE
			WHERE palias_id = v_palias_id;
		INSERT INTO pseqalias ( palias_id, pseq_id, version ) 
			VALUES ( v_palias_id, v_pseq_id, rec.version+1 );

	ELSEIF rec.is_current = FALSE THEN
		-- rec.pseq_id = v_pseq_id, but the assignment's been deprecated.
		-- Instead of making a new row, revive this deprecated assignment.
		-- WARNING: added=rec.added practically ensures that the row is unique
		RAISE DEBUG '  pseq_id unchanged; resuscitating palias_id';
		UPDATE pseqalias SET is_current = TRUE
			WHERE palias_id = v_palias_id AND pseq_id = v_pseq_id AND added = rec.added;

	ELSEIF v_pseq_id=rec.pseq_id AND rec.is_current=TRUE THEN
		-- do nothing
		RAISE DEBUG '  no pseqalias change required.';

	ELSE
		RAISE EXCEPTION 'Logic error -- contact Reece';

	END IF;

	RETURN;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.assign_alias(v_pseq_id integer, v_origin_id integer, v_alias text, v_descr text, v_tax_id integer, OUT v_palias_id integer) OWNER TO unison;

--
-- Name: FUNCTION assign_alias(v_pseq_id integer, v_origin_id integer, v_alias text, v_descr text, v_tax_id integer, OUT v_palias_id integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION assign_alias(v_pseq_id integer, v_origin_id integer, v_alias text, v_descr text, v_tax_id integer, OUT v_palias_id integer) IS '<pseq_id,origin_id,alias,descr,tax_id>: create/fetch <origin_id,alias,descr,tax_id> row in paliasorigin, and then create/fetch <palias_id,pseq_id> in pseqalias, deprecating an existing assignment if necessary';


--
-- Name: assign_p2gblataln(text, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION assign_p2gblataln(text, integer, integer, integer, integer, integer) RETURNS integer
    AS $_$
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
    SELECT INTO v_p2gblataln_id nextval('unison.p2gblataln_p2gblataln_id_seq'::text);
    INSERT INTO p2gblataln (p2gblataln_id, hsp_str, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases) VALUES
      (v_p2gblataln_id, v_hsp_str, v_ident, v_pgap_cnt, v_pgap_bases, v_ggap_cnt, v_ggap_bases);
  END IF;

  -- insert into p2gblatalnhsp table (let the unique indices deal with redudancies
  SELECT INTO v_p2gblataln_ids hsp_str_to_hsp_ids( v_hsp_str );
  low  := replace(split_part(array_dims(v_p2gblataln_ids),':',1),'[','')::int;
  high := replace(split_part(array_dims(v_p2gblataln_ids),':',2),']','')::int;
  FOR i IN low..high LOOP
    INSERT INTO p2gblatalnhsp (p2gblataln_id, p2gblathsp_id) VALUES
      (v_p2gblataln_id, v_p2gblataln_ids[i]);
  END LOOP;

  return v_p2gblataln_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.assign_p2gblataln(text, integer, integer, integer, integer, integer) OWNER TO unison;

--
-- Name: FUNCTION assign_p2gblataln(text, integer, integer, integer, integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION assign_p2gblataln(text, integer, integer, integer, integer, integer) IS 'insert protein-to-genome BLAT alignments';


--
-- Name: best_alias(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION best_alias(integer) RETURNS text
    AS $_$select origin_alias_fmt(origin,alias) from best_annotation_mv where pseq_id=$1;$_$
    LANGUAGE sql;


ALTER FUNCTION unison.best_alias(integer) OWNER TO unison;

--
-- Name: FUNCTION best_alias(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION best_alias(integer) IS '"best" alias for given pseq_id. NOTE: from materialized view, which may be stale.';


--
-- Name: best_alias(integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION best_alias(integer, integer) RETURNS text
    AS $_$select origin_alias_fmt(origin,alias) from best_annotation_mv where pseq_id=$1 and tax_id=$2$_$
    LANGUAGE sql;


ALTER FUNCTION unison.best_alias(integer, integer) OWNER TO unison;

--
-- Name: best_alias(integer, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION best_alias(integer, text) RETURNS text
    AS $_$select origin_alias_fmt(origin,alias) from best_annotation_mv where pseq_id=$1 and tax_id=gs2tax_id($2)$_$
    LANGUAGE sql;


ALTER FUNCTION unison.best_alias(integer, text) OWNER TO unison;

--
-- Name: best_annotation(integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION best_annotation(integer, integer) RETURNS text
    AS $_$select origin_alias_descr_fmt(origin,alias,descr) from best_annotation_mv where pseq_id=$1 and tax_id=$2;$_$
    LANGUAGE sql;


ALTER FUNCTION unison.best_annotation(integer, integer) OWNER TO unison;

--
-- Name: best_annotation(integer, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION best_annotation(integer, text) RETURNS text
    AS $_$select origin_alias_descr_fmt(origin,alias,descr) from best_annotation_mv where pseq_id=$1 and tax_id=gs2tax_id($2);$_$
    LANGUAGE sql;


ALTER FUNCTION unison.best_annotation(integer, text) OWNER TO unison;

--
-- Name: check_public_acl(name, name, character); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION check_public_acl(name, name, character) RETURNS boolean
    AS $_$
DECLARE
  acl text;
  rec record;
BEGIN
  IF ( $3 NOT IN ( 'w','r','a','R','x','t' ) ) THEN
    RAISE EXCEPTION 'mode flags must use single letter from "arwRxt"';
  END IF;
  SELECT INTO rec perms 
  FROM table_perms_v WHERE schemaname = $1 AND tablename = $2;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Did not find any schema name "%", relation named "%".', $1, $2;
  END IF;
  acl := rec.perms;
  IF acl IS NULL THEN
    RETURN 'f';
  END IF;
  IF acl ~ ( ',=[rwaRxt]*' || $3 ) /* public */
  THEN
    RETURN 't';
  END IF;
  RETURN 'f';
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.check_public_acl(name, name, character) OWNER TO unison;

--
-- Name: check_public_perms(name, name, character[]); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION check_public_perms(name, name, character[]) RETURNS boolean
    AS $_$
DECLARE
  schema alias for $1;
  table alias for $2;
  privs alias for $3;
  acl text;
  rec record;
  i integer;
BEGIN
  -- check if the input array has the right permission letters
  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
  IF ( privs[i] NOT IN ( 'w','r','a','d','R','x','t' ) ) THEN
    RAISE EXCEPTION 'mode flags must use single letter from "arwdRxt"';
  END IF;
  END LOOP;
  SELECT INTO rec perms 
  FROM table_perms_v WHERE schemaname = schema AND tablename = table;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Did not find any schema name "%", relation named "%".', schema, table;
  END IF;
  acl := rec.perms;
  IF acl IS NULL THEN
    RETURN false;
  END IF;
  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
	  IF acl ~ ( ',=[rwadRxt]*' || privs[i] ) /* public */
	  THEN
	    RETURN true;
	  END IF;
  END LOOP;
  RETURN false;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.check_public_perms(name, name, character[]) OWNER TO unison;

--
-- Name: FUNCTION check_public_perms(name, name, character[]); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION check_public_perms(name, name, character[]) IS 'check_public_perms ( <schema::name>, <table::name>, <char[]> ) returns true if public has any of the permissions listed in the char[] array';


--
-- Name: check_user_acl(name, name, name, character); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION check_user_acl(name, name, name, character) RETURNS boolean
    AS $_$
DECLARE
  user alias for $1;
  schema alias for $2;
  table alias for $3;
  perm alias for $4;
  acl text;
  rec record;
BEGIN
  IF ( perm NOT IN ( 'w','r','a','R','x','t','d' ) ) THEN
    RAISE EXCEPTION 'mode flags must use single letter from "rwadRxt"';
  END IF;
  SELECT INTO rec tableowner, tablename, schemaname, perms,  usesuper 
  FROM table_perms_v, pg_user 
  WHERE schemaname = schema AND tablename = table;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Did not find any user named "%" or  schema named "%" or relation named "%".', user,schema,table;
  END IF;
  IF rec.tableowner = user OR rec.usesuper THEN
    RETURN 't';
  END IF;
  acl := rec.perms;
  IF acl IS NULL THEN
    RETURN 'f';
  END IF;
  IF acl ~ ( user || '=[rwadRxt]*' || perm) /* user */
  THEN
    RETURN 't';
  END IF;
  RETURN 'f';
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.check_user_acl(name, name, name, character) OWNER TO unison;

--
-- Name: check_user_perms(name, name, name, character[]); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION check_user_perms(name, name, name, character[]) RETURNS boolean
    AS $_$
DECLARE
  user alias for $1;
  schema alias for $2;
  table alias for $3;
  privs alias for $4;
  acl text;
  rec record;
  i integer;
BEGIN
  -- check if the input array has the right permission letters
  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
  IF ( privs[i] NOT IN ( 'w','r','a','R','x','t','d' ) ) THEN
    RAISE EXCEPTION 'mode flags must use single letter from "rwadRxt"';
  END IF;
  END LOOP;
  SELECT INTO rec tableowner, tablename, schemaname, perms,  usesuper 
  FROM table_perms_v, pg_user 
  WHERE schemaname = schema AND tablename = table;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Did not find either a schema named "%" or a table named "%".', schema,table;
  END IF;
  IF rec.tableowner = user OR rec.usesuper THEN
    RETURN true;
  END IF;
  acl := rec.perms;
  IF acl IS NULL THEN
    RETURN false;
  END IF;
  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
  	IF acl ~ ( user || '=[rwadRxt]*' || privs[i]) /* user */
  	THEN
    	RETURN true;
  	END IF;
  END LOOP;
  RETURN false;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.check_user_perms(name, name, name, character[]) OWNER TO unison;

--
-- Name: FUNCTION check_user_perms(name, name, name, character[]); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION check_user_perms(name, name, name, character[]) IS 'check_user_perms ( <user::name>, <schema::name>, <table::name>, <char[]> ) returns true if the user has any of the permissions listed in the char[] array';


--
-- Name: chr2locus(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION chr2locus(text) RETURNS real
    AS $_X$$_[0] =~ m/^([XYME])$/ ? return 100+ord($1) : $_[0];$_X$
    LANGUAGE plperl IMMUTABLE;


ALTER FUNCTION unison.chr2locus(text) OWNER TO unison;

--
-- Name: chr2locus(text, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION chr2locus(text, integer) RETURNS real
    AS $_X$return ($_[0] =~ m/^([XYME])$/ ? 100+ord($1) : $_[0]) . "." . $_[1];$_X$
    LANGUAGE plperl IMMUTABLE;


ALTER FUNCTION unison.chr2locus(text, integer) OWNER TO unison;

--
-- Name: clean_sequence(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION clean_sequence(text) RETURNS text
    AS $_$
  my $x = shift;
  $x =~ s/[^-\*ABCDEFGHIKLMNPQRSTUVWXYZ]//g;
  $x =~ s/\*+$//;
  return $x;
$_$
    LANGUAGE plperl IMMUTABLE STRICT;


ALTER FUNCTION unison.clean_sequence(text) OWNER TO unison;

--
-- Name: current_params_id_by_pftype_id(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION current_params_id_by_pftype_id(integer) RETURNS integer
    AS $_$BEGIN RAISE EXCEPTION 'current_params_id_by_pftype_id was deprecated on 2006-01-31; use preferred_params_id_by_pftype(text) or preferred_params_id_by_pftype_id(integer) instead'; return preferred_params_id_by_pftype_id($1); END;$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.current_params_id_by_pftype_id(integer) OWNER TO unison;

--
-- Name: FUNCTION current_params_id_by_pftype_id(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION current_params_id_by_pftype_id(integer) IS 'returns current/preferred params_id for a given feature type';


--
-- Name: current_usesysid(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION current_usesysid() RETURNS integer
    AS $$select usesysid from pg_user where usename=current_user;$$
    LANGUAGE sql STABLE STRICT;


ALTER FUNCTION unison.current_usesysid() OWNER TO unison;

--
-- Name: domain_digests(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION domain_digests(integer) RETURNS text
    AS $_$ select as_set(digest) as domain_digests from (select * from pseq_features_v where pseq_id=$1 order by start,stop) X $_$
    LANGUAGE sql STRICT;


ALTER FUNCTION unison.domain_digests(integer) OWNER TO unison;

--
-- Name: FUNCTION domain_digests(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION domain_digests(integer) IS 'domain digests in N-to-C terminus order';


--
-- Name: expand_aa_sets(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION expand_aa_sets(text) RETURNS text
    AS $_$select _clean_regexp(_expand_aa_sets($1))$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.expand_aa_sets(text) OWNER TO unison;

--
-- Name: FUNCTION expand_aa_sets(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION expand_aa_sets(text) IS 'expand sets of amino acids represented in the given string';


--
-- Name: get_current_users(name, name); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION get_current_users(name, name) RETURNS name[]
    AS $_$
declare
  schema alias for $1;
  table alias for $2;
  current_users name[] = '{}';
  pguser record;
  acl text;
  user text;
  rec record;
begin
  for pguser in select usename from pg_user LOOP
	for rec in select perms FROM table_perms_v WHERE schemaname = schema AND tablename = table LOOP
		acl := rec.perms;
		user := pguser.usename||'=';
	  	IF acl ~ user THEN
			current_users = array_append(current_users,pguser.usename);
			EXIT;
	  	END IF;
	END LOOP;
  END LOOP;
  RETURN current_users;
end;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.get_current_users(name, name) OWNER TO unison;

--
-- Name: FUNCTION get_current_users(name, name); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION get_current_users(name, name) IS 'get_current_users(<schema_name>, <table_name>) returns a name[] array of current users of the input schema,table';


--
-- Name: get_paliasorigin_palias_id(integer, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION get_paliasorigin_palias_id(integer, text) RETURNS integer
    AS $_$
DECLARE
    v_origin_id ALIAS FOR $1;
    v_alias ALIAS FOR $2;
    rec record;
    v_palias_id integer;
BEGIN
    -- check whether paliasorigin exists: if yes, then return palias_id, otherwise return null
    RAISE DEBUG 'select * from pseqaliasorigin where origin_id=% and alias=%',v_origin_id,v_alias;
    select into rec * from paliasorigin where origin_id=v_origin_id and alias=v_alias;
    IF found THEN
        RAISE DEBUG 'record exists for this alias and origin: %', rec.palias_id;
        v_palias_id := rec.palias_id;
    END IF;
    return v_palias_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.get_paliasorigin_palias_id(integer, text) OWNER TO unison;

--
-- Name: FUNCTION get_paliasorigin_palias_id(integer, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION get_paliasorigin_palias_id(integer, text) IS 'retrieve the palias_id for a given origin_id and alias';


--
-- Name: get_run_timestamp(integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION get_run_timestamp(integer, integer) RETURNS timestamp with time zone
    AS $_$
DECLARE
    q alias for $1;
    r alias for $2;
    z timestamp;
BEGIN
    select into z ran_on from run_history
        where pseq_id=q
        and run_id=r;
    return z;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.get_run_timestamp(integer, integer) OWNER TO unison;

--
-- Name: FUNCTION get_run_timestamp(integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION get_run_timestamp(integer, integer) IS 'for the given pseq_id and run_id, returns the ran_on timestamp from run_history';


--
-- Name: gseq_iu_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION gseq_iu_trigger() RETURNS trigger
    AS $$
DECLARE
    oldmd5 text;
BEGIN
    oldmd5 := md5(new.seq);
    new.seq := clean_sequence(new.seq);
    new.md5 := md5(new.seq);
    if oldmd5 != new.md5 then
        raise notice 'gseq_id % modified during insert.',new.gseq_id;
    end if;
    new.len := length(new.seq);
    return new;
END; $$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.gseq_iu_trigger() OWNER TO unison;

--
-- Name: has_iupac_ambiguity_aa(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION has_iupac_ambiguity_aa(text) RETURNS boolean
    AS $_$select $1 ~ '[BXZ]'$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.has_iupac_ambiguity_aa(text) OWNER TO unison;

--
-- Name: FUNCTION has_iupac_ambiguity_aa(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION has_iupac_ambiguity_aa(text) IS 'sequence contains IUPAC ambiguity (B=[DE], Z=[NQ], X=any)';


--
-- Name: has_iupac_gap_aa(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION has_iupac_gap_aa(text) RETURNS boolean
    AS $_$select $1 ~ '-'$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.has_iupac_gap_aa(text) OWNER TO unison;

--
-- Name: FUNCTION has_iupac_gap_aa(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION has_iupac_gap_aa(text) IS 'sequence contains an IUPAC gap';


--
-- Name: has_iupac_stop_aa(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION has_iupac_stop_aa(text) RETURNS boolean
    AS $_$select $1 ~ '\\*'$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.has_iupac_stop_aa(text) OWNER TO unison;

--
-- Name: FUNCTION has_iupac_stop_aa(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION has_iupac_stop_aa(text) IS 'sequence contains an IUPAC stop';


--
-- Name: has_non_iupac_aa(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION has_non_iupac_aa(text) RETURNS boolean
    AS $_$select $1 ~ '[^-*ACDEFGHIKLMNPQRSTVWYUBZX]'$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.has_non_iupac_aa(text) OWNER TO unison;

--
-- Name: FUNCTION has_non_iupac_aa(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION has_non_iupac_aa(text) IS 'sequence has non-IUPAC symbols (selenocysteine, gaps, stops, and ambiguities okay)';


--
-- Name: has_only_iupac_aa_ungapped(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION has_only_iupac_aa_ungapped(text) RETURNS boolean
    AS $_$select $1 !~ '[^ACDEFGHIKLMNPQRSTVWYUBZX]'$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.has_only_iupac_aa_ungapped(text) OWNER TO unison;

--
-- Name: FUNCTION has_only_iupac_aa_ungapped(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION has_only_iupac_aa_ungapped(text) IS 'ungapped sequence contains only IUPAC amino acids or ambiguities';


--
-- Name: has_only_iupac_std_aa_ungapped(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION has_only_iupac_std_aa_ungapped(text) RETURNS boolean
    AS $_$select $1 !~ '[^ACDEFGHIKLMNPQRSTVWY]'$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.has_only_iupac_std_aa_ungapped(text) OWNER TO unison;

--
-- Name: FUNCTION has_only_iupac_std_aa_ungapped(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION has_only_iupac_std_aa_ungapped(text) IS 'ungapped sequence contains only the standard 20 IUPAC amino acids';


--
-- Name: hmm_pmodel_id(text, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION hmm_pmodel_id(text, integer) RETURNS integer
    AS $_$DECLARE V_id integer; BEGIN  perform * from origin where origin_id=$2; IF NOT FOUND THEN RAISE EXCEPTION 'origin_id ''%'' not found', $2; END IF; select into V_id pmodel_id from pmhmm where upper(acc)=upper($1) and origin_id=$2; IF NOT FOUND THEN RAISE WARNING 'model ''%'' not found', $1; RETURN NULL; END IF; return V_id; END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.hmm_pmodel_id(text, integer) OWNER TO unison;

--
-- Name: hsp_coverage(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION hsp_coverage(integer) RETURNS double precision
    AS $_$
  declare
    v_pfeature_id alias for $1;
    v_pct_hsp_coverage float;
		v_pseq_id integer;
		v_t_pseq_id integer;
		q_seq_len integer;
		t_seq_len integer;
		shorter_len integer;
		longer_len integer;
		rec record;
  begin

    -- get the papseq record for this pfeature_id
    select into rec * from papseq where pfeature_id=v_pfeature_id;
    IF not found THEN
      RAISE EXCEPTION 'no record pfeature_id=%',v_pfeature_id;
    END IF;

    -- get the pseq_id for the target
    select into v_t_pseq_id pseq_id from pmpseq where pmodel_id=rec.pmodel_id;
    IF v_t_pseq_id is null THEN
      RAISE EXCEPTION 'no pseq_id for pmodel_id=%',rec.pmodel_id;
    END IF;

    -- get sequence lengths for derived values
    select into q_seq_len len from pseq where pseq_id=rec.pseq_id;
    select into t_seq_len len from pseq where pseq_id=v_t_pseq_id;
    IF    q_seq_len is null or q_seq_len = 0 THEN
      RAISE EXCEPTION 'length for pseq_id=% is null or zero',rec.pseq_id;
    ELSIF t_seq_len is null or t_seq_len = 0 THEN
      RAISE EXCEPTION 'length for pseq_id=% is null or zero',v_t_pseq_id;
    END IF;

    -- calculate derived values
    IF q_seq_len > t_seq_len THEN
      shorter_len := t_seq_len;
      longer_len := q_seq_len;
    ELSE
      shorter_len := q_seq_len;
      longer_len := t_seq_len;
    END IF;
    v_pct_hsp_coverage := ( rec.len::real / shorter_len::real ) * 100.0;

    return v_pct_hsp_coverage;
  end; $_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.hsp_coverage(integer) OWNER TO unison;

--
-- Name: hsp_ids_to_hsp_str(integer[]); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION hsp_ids_to_hsp_str(integer[]) RETURNS text
    AS $_$
DECLARE
  hsp_ids ALIAS FOR $1;
  hsp_str text;
  low integer;
  high integer;
BEGIN
  -- get bounds of hsp_ids array for looping
  low  := replace(split_part(array_dims(hsp_ids),':',1),'[','')::int;
  high := replace(split_part(array_dims(hsp_ids),':',2),']','')::int;

  hsp_str := hsp_ids[1];
  FOR i IN low+1..high LOOP
    hsp_str := hsp_str || ':' || hsp_ids[i];
  END LOOP;

  return hsp_str;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.hsp_ids_to_hsp_str(integer[]) OWNER TO unison;

--
-- Name: FUNCTION hsp_ids_to_hsp_str(integer[]); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION hsp_ids_to_hsp_str(integer[]) IS 'serialize an array of p2gblathsp_ids';


--
-- Name: hsp_str_to_hsp_ids(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION hsp_str_to_hsp_ids(text) RETURNS integer[]
    AS $_$
DECLARE
  hsp_str ALIAS FOR $1;
  hsp_ids int[];
BEGIN
  SELECT INTO hsp_ids split(hsp_str,':');
  RETURN hsp_ids;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.hsp_str_to_hsp_ids(text) OWNER TO unison;

--
-- Name: FUNCTION hsp_str_to_hsp_ids(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION hsp_str_to_hsp_ids(text) IS 'deserialize a hsp_str into an array of p2gblathsp_ids';


--
-- Name: init_db(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION init_db() RETURNS void
    AS $_$
DECLARE
	v_db text;
	cmd text;
BEGIN
	SELECT INTO v_db current_database();

	SELECT INTO cmd 'ALTER DATABASE "' || v_db || '" SET search_path="$user", unison, pdb, gong, scop, tax, public';
	RAISE NOTICE '%', cmd;
	EXECUTE cmd;

	SELECT INTO cmd 'ALTER DATABASE "' || v_db || '" SET statement_timeout=1800000';
	RAISE NOTICE '%', cmd;
	EXECUTE cmd;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.init_db() OWNER TO unison;

--
-- Name: ins_last_run(integer, integer, integer, timestamp with time zone); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION ins_last_run(integer, integer, integer, timestamp with time zone) RETURNS void
    AS $_$
DECLARE
	v_pseq_id ALIAS FOR $1;
	v_pftype_id ALIAS FOR $2;
	v_params_id ALIAS FOR $3;
	v_last_run ALIAS FOR $4;
	rec record;
BEGIN
	-- check whether last_run exists for this pseq_id, pftype_id, params_id tuple
	-- RAISE INFO 'select * into rec from last_run where pseq_id=% and pftype_id=% and params_id=%', v_pseq_id, v_pftype_id, v_params_id;
	select into rec * from last_run where pseq_id=v_pseq_id and pftype_id=v_pftype_id and params_id=v_params_id;

	IF found THEN
		 -- RAISE INFO 'update set last_run=% where pseq_id=% and pftype_id=% and params_id=%', v_last_run, v_pseq_id, v_pftype_id, v_params_id;
		update last_run set last_run=v_last_run where pseq_id=v_pseq_id and pftype_id=v_pftype_id and params_id=v_params_id;
	ELSE 
		-- RAISE INFO 'insert into last_run (pseq_id, pftype_id, params_id, last_run) values (%,%,%,%)',v_pseq_id, v_pftype_id, v_params_id, v_last_run;
		insert into last_run (pseq_id, pftype_id, params_id, last_run) values (v_pseq_id, v_pftype_id, v_params_id, v_last_run);
	END IF;
	return;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.ins_last_run(integer, integer, integer, timestamp with time zone) OWNER TO unison;

--
-- Name: FUNCTION ins_last_run(integer, integer, integer, timestamp with time zone); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION ins_last_run(integer, integer, integer, timestamp with time zone) IS 'create/update last_run record';


--
-- Name: ins_p2gblathsp(integer, text, boolean, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION ins_p2gblathsp(integer, text, boolean, integer, integer, integer, integer, integer) RETURNS integer
    AS $_$
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
    SELECT INTO v_p2gblathsp_id nextval('unison.p2gblathsp_p2gblathsp_id_seq'::text);
    INSERT INTO p2gblathsp (p2gblathsp_id,genasm_id,chr,plus_strand,gstart,gstop,pseq_id,pstart,pstop) VALUES
      (v_p2gblathsp_id,v_genasm_id,v_chr,v_plus_strand,v_gstart,v_gstop,v_pseq_id,v_pstart,v_pstop);
  END IF;
  return v_p2gblathsp_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.ins_p2gblathsp(integer, text, boolean, integer, integer, integer, integer, integer) OWNER TO unison;

--
-- Name: FUNCTION ins_p2gblathsp(integer, text, boolean, integer, integer, integer, integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION ins_p2gblathsp(integer, text, boolean, integer, integer, integer, integer, integer) IS 'insert protein-to-genome BLAT HSPs';


--
-- Name: ins_paliasorigin(integer, text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION ins_paliasorigin(integer, text, text) RETURNS integer
    AS $_$
DECLARE
        v_origin_id ALIAS FOR $1;
        v_alias ALIAS FOR $2;
        v_descr ALIAS FOR $3;
        v_palias_id integer;
BEGIN
        -- check whether paliasorigin exists: if yes, then return palias_id, otherwise enter a new record
        RAISE WARNING 'deprecated method use ins_paliasorigininteger, text, text, integer) instead';
        select into v_palias_id ins_paliasorigin(v_origin_id, v_alias, v_descr, NULL);
        return v_palias_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.ins_paliasorigin(integer, text, text) OWNER TO unison;

--
-- Name: FUNCTION ins_paliasorigin(integer, text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION ins_paliasorigin(integer, text, text) IS 'backwardly compatible - calls new ins_paliasorigin with NULL tax_id';


--
-- Name: ins_paliasorigin(integer, text, text, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION ins_paliasorigin(integer, text, text, integer) RETURNS integer
    AS $_$
DECLARE
        v_origin_id ALIAS FOR $1;
        v_alias ALIAS FOR $2;
        v_descr ALIAS FOR $3;
        v_tax_id ALIAS FOR $4;
        v_palias_id integer;
BEGIN
        -- check whether paliasorigin exists: if yes, then return palias_id, otherwise enter a new record
        RAISE DEBUG 'select into v_palias_id get_paliasorigin_palias_id( %, % )', v_origin_id, v_alias;
        select into v_palias_id get_paliasorigin_palias_id( v_origin_id, v_alias );
        IF v_palias_id is null THEN
                select into v_palias_id nextval('paliasorigin_palias_id_seq');
                RAISE DEBUG 'executing insert into paliasorigin (palias_id, origin_id, alias, descr, tax_id) values (%, %, %, %, %)',v_palias_id, v_origin_id, v_alias, v_descr, v_tax_id;
                insert into paliasorigin (palias_id, origin_id, alias, descr, tax_id) values (v_palias_id, v_origin_id, v_alias, v_descr, v_tax_id);
        ELSE
                RAISE DEBUG 'record exists for this alias and origin: palias_id %', v_palias_id;
                UPDATE paliasorigin SET descr=v_descr,tax_id=v_tax_id WHERE palias_id=v_palias_id
                        AND (    (descr !=v_descr  OR (descr  IS NULL AND v_descr  IS NOT NULL) OR (descr  IS NOT NULL AND v_descr  IS NULL))
                                  OR (tax_id!=v_tax_id OR (tax_id IS NULL AND v_tax_id IS NOT NULL) OR (tax_id IS NOT NULL AND v_tax_id IS NULL)) );
                IF FOUND THEN
                        RAISE DEBUG 'ins_paliasorigin: description, tax_id, or both differ from existing entry and were updated for palias_id %', v_palias_id;
                END IF;
        END IF;
        return v_palias_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.ins_paliasorigin(integer, text, text, integer) OWNER TO unison;

--
-- Name: FUNCTION ins_paliasorigin(integer, text, text, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION ins_paliasorigin(integer, text, text, integer) IS 'create a new paliasorigin record or return known palias_id';


--
-- Name: ins_pmap_aln(text, integer, integer, integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION ins_pmap_aln(text, integer, integer, integer, integer, integer, integer, integer, integer) RETURNS integer
    AS $_$
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
	RAISE EXCEPTION 'Length hsp_str cannot be 0';
  END IF;
  -- check whether hsp_str is already in the database
  SELECT INTO v_aln_id aln_id FROM pmap_aln WHERE hsp_str=v_hsp_str;
  IF v_aln_id is null THEN

    SELECT INTO v_aln_id nextval('pmap_aln_aln_id_seq'::text);
 
   -- insert into pmap_alnhsp table (let the unique indices deal with redudancies
    SELECT INTO v_hsp_ids hsp_str_to_hsp_ids( v_hsp_str );
    low  := replace(split_part(array_dims(v_hsp_ids),':',1),'[','')::int;
    high := replace(split_part(array_dims(v_hsp_ids),':',2),']','')::int;
    FOR i IN low..high LOOP
     INSERT INTO pmap_alnhsp (aln_id, hsp_id) VALUES
    	(v_aln_id, v_hsp_ids[i]);
    END LOOP;

    INSERT INTO pmap_aln (aln_id, ident, pgap_cnt, pgap_bases, ggap_cnt, ggap_bases, params_id, genasm_id, pseq_id) VALUES
      (v_aln_id, v_ident, v_pgap_cnt, v_pgap_bases, v_ggap_cnt, v_ggap_bases, v_params_id, v_genasm_id, v_pseq_id);
  ELSE
	RAISE EXCEPTION 'the hsps already exists, aln_id is %',v_aln_id;
  END IF;

  RETURN v_aln_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.ins_pmap_aln(text, integer, integer, integer, integer, integer, integer, integer, integer) OWNER TO unison;

--
-- Name: FUNCTION ins_pmap_aln(text, integer, integer, integer, integer, integer, integer, integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION ins_pmap_aln(text, integer, integer, integer, integer, integer, integer, integer, integer) IS 'insert protein-to-genome PMAP alignments';


--
-- Name: ins_pmap_hsp(integer, text, character, integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION ins_pmap_hsp(integer, text, character, integer, integer, integer, integer, integer, integer) RETURNS integer
    AS $_$
DECLARE
  v_genasm_id ALIAS FOR $1;	
  v_chr ALIAS FOR $2;
  v_strand ALIAS FOR $3;
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
    strand=v_strand AND
    gstart=v_gstart AND
    gstop=v_gstop AND
    pseq_id=v_pseq_id AND
    pstart=v_pstart AND
    pstop=v_pstop AND
    genasm_id=v_genasm_id AND
    params_id=v_params_id;
  IF v_hsp_id is null THEN
    SELECT INTO v_hsp_id nextval('pmap_hsp_hsp_id_seq'::text);
    INSERT INTO pmap_hsp (hsp_id,genasm_id,chr,strand,gstart,gstop,pseq_id,pstart,pstop,params_id) VALUES
      (v_hsp_id,v_genasm_id,v_chr,v_strand,v_gstart,v_gstop,v_pseq_id,v_pstart,v_pstop,v_params_id);	
  END IF;
  RETURN v_hsp_id;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.ins_pmap_hsp(integer, text, character, integer, integer, integer, integer, integer, integer) OWNER TO unison;

--
-- Name: link_url(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION link_url(text, text) RETURNS text
    AS $_$select link_url(origin_id($1),$2)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.link_url(text, text) OWNER TO unison;

--
-- Name: FUNCTION link_url(text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION link_url(text, text) IS 'create URL to the origin $1 for alias/query $2';


--
-- Name: locus_fmt(text, text, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION locus_fmt(chr text, str text, gstart integer, gstop integer) RETURNS text
    AS $$BEGIN return coalesce(chr::text,'?')||coalesce(str::text,'?')||':'||coalesce(gstart::text,'?')||'-'||coalesce(gstop::text,'?'); END;$$
    LANGUAGE plpgsql IMMUTABLE;


ALTER FUNCTION unison.locus_fmt(chr text, str text, gstart integer, gstop integer) OWNER TO unison;

--
-- Name: FUNCTION locus_fmt(chr text, str text, gstart integer, gstop integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION locus_fmt(chr text, str text, gstart integer, gstop integer) IS 'standard format for genomic locus information, i.e., <chr><strand>:<gstart>-<gstop>';


--
-- Name: make_csb_read_only(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION make_csb_read_only() RETURNS boolean
    AS $$
declare
	schemas name[] := '{unison,scop,gong,tax}';
	dbname name;
	i integer := 0;
	n integer := 0;
	ret bool := false;
begin
	select into dbname current_database();

	IF dbname != 'csb' THEN
	RAISE EXCEPTION 'This operation is restricted for the CSB database';
	END IF;

	FOR i IN array_lower(schemas, 1)..array_upper(schemas, 1) LOOP	
		select into ret make_schema_read_only(schemas[i]);

		IF ret = true THEN
		n := n + 1;
		END IF;

	END LOOP;

	IF n = array_upper(schemas, 1) THEN
	return true;
	END IF;

return false;
end;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.make_csb_read_only() OWNER TO unison;

--
-- Name: FUNCTION make_csb_read_only(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION make_csb_read_only() IS 'make_csb_read_only() runs make_schema_read_only for each schema in the current database and returns true if make_schema_read_only is successful for all schemas';


--
-- Name: make_schema_read_only(name); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION make_schema_read_only(name) RETURNS boolean
    AS $_$
declare
	schema alias for $1;
	table_schema record;
	num_tables integer;
	ret bool;
	n integer := 0;
begin
	select into num_tables COUNT(*) from table_perms_v where schemaname = schema;
	IF num_tables = 0 THEN
	RAISE EXCEPTION '% tables found in % schema',num_tables,schema;
	END IF;
	FOR table_schema in select tablename from table_perms_v where schemaname = schema LOOP
		select into ret make_table_read_only(schema,table_schema.tablename);
		IF ret = true THEN
		n := n + 1;
		END IF;
	END LOOP;
	IF n = num_tables THEN
	return true;
	END IF;
return false;
end;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.make_schema_read_only(name) OWNER TO unison;

--
-- Name: FUNCTION make_schema_read_only(name); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION make_schema_read_only(name) IS 'make_schema_read_only(<schema_name>) runs make_table_read_only for each table in the input schema and returns true if make_table_read_only is successful for all tables';


--
-- Name: make_table_read_only(name, name); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION make_table_read_only(name, name) RETURNS boolean
    AS $_$
declare
	schema alias for $1;
	table alias for $2;
	perm_letter char[] := '{w,a,d,x,t,R}';
	var boolean;
	users name[];
	i integer;
begin
	-- all users
	select into users get_current_users(schema,table);
	FOR i IN array_lower(users, 1)..array_upper(users, 1) LOOP
		IF check_user_perms(users[i],schema,table,perm_letter) THEN
			EXECUTE 'REVOKE UPDATE, INSERT, DELETE, REFERENCES, TRIGGER, RULE ON '|| schema||'.'||table ||' FROM ' || users[i];
		END IF;

	END LOOP;

	-- public
	IF check_public_perms(schema,table,perm_letter) THEN
		EXECUTE 'REVOKE UPDATE, INSERT, DELETE, REFERENCES, TRIGGER, RULE ON '|| schema||'.'||table ||' FROM PUBLIC';
	END IF;

return true;
end;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.make_table_read_only(name, name) OWNER TO unison;

--
-- Name: FUNCTION make_table_read_only(name, name); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION make_table_read_only(name, name) IS 'make_table_read_only(<schema_name>,<table_name>) checks and revokes wadxRt permissions for each user and public';


--
-- Name: meta_stats_distinct(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION meta_stats_distinct() RETURNS void
    AS $$
DECLARE
	n integer;
	r record;
BEGIN
	return;
END;$$
    LANGUAGE plpgsql STABLE;


ALTER FUNCTION unison.meta_stats_distinct() OWNER TO unison;

--
-- Name: FUNCTION meta_stats_distinct(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION meta_stats_distinct() IS 'count number of sequences unique to an origin';


--
-- Name: meta_stats_unique(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION meta_stats_unique() RETURNS void
    AS $$
DECLARE
	n integer;
	r record;
BEGIN
	return;
END;$$
    LANGUAGE plpgsql STABLE;


ALTER FUNCTION unison.meta_stats_unique() OWNER TO unison;

--
-- Name: meta_stats_update(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION meta_stats_update() RETURNS void
    AS $$
DECLARE
	n integer;
	r record;
	ts timestamp with time zone;
BEGIN
	ts:=now(); raise notice 'meta_stats_update: started %',ts;

	-- sequence stats
--	select into n count(*) from pseq;
--	perform meta_update_kv('unique sequences',n);
--	select into n count(*) from pseq where added>=now()-'30 days'::interval;
--	perform meta_update_kv('new sequences in last 30 days',n);
--	select into n count(*) from pseq where added>=now()-'60 days'::interval;
--	perform meta_update_kv('new sequences in last 60 days',n);
--	select into n count(*) from pseq where added>=now()-'180 days'::interval;
--	perform meta_update_kv('new sequences in last 180 days',n);
--
--	-- alias and origin stats
--	select into n count(*) from palias;
--	perform meta_update_kv('aliases',n);
--	select into n count(distinct tax_id) from palias;
--	perform meta_update_kv('species',n);

	-- number of distinct sequences in an origin and 
	-- number of distinct sequences unique to an origin
	FOR r IN select origin_id,origin from origin where ann_pref is not null LOOP
		create temp table in_r as select distinct pseq_id from palias
			where origin_id=r.origin_id limit 10000;
		select into n count(*) from in_r;
		perform meta_update_kv('distinct sequences in '||r.origin ,n);

		create temp table not_in_r as select pseq_id from in_r
			except select pseq_id from palias where origin_id!=r.origin_id limit 1000;
		select into n count(*) from not_in_r;
		-- this is faster (I think):
--		select into n count(distinct pseq_id) from palias a1 where a1.origin_id=r.origin_id
-- 			and	not exists (select * from palias a2 where a2.pseq_id=a1.pseq_id and a2.origin_id!=a1.origin_id);
--		perform meta_update_kv('distinct sequences unique to '||r.origin ,n);

		drop table in_r;
		drop table not_in_r;
	END LOOP;

	-- pfeatures
	select into n count(*) from pfeature;
	perform meta_update_kv('protein features',n);

	-- prospect features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from paprospect2 where params_id=1 group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv('threading alignments',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv('threaded sequences',n);
	select count(pseq_id) from counts where count!=(select max(count) from counts);
	perform meta_update_kv('incompletely threaded sequences',n);

	-- hmm features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from pahmm group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv('HMM alignments',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv('HMM-aligned sequences',n);

	-- pssm features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from papssm group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv('PSSM alignments',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv('PSSM-aligned sequences',n);

	-- papseq features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from papseq group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv('BLAST alignments',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv('BLAST-aligned sequences',n);

	perform meta_update_kv('stats timestamp',now());

	ts:=now(); raise notice 'meta_stats_update: finished %',ts;

	return;
END;$$
    LANGUAGE plpgsql STABLE;


ALTER FUNCTION unison.meta_stats_update() OWNER TO unison;

--
-- Name: FUNCTION meta_stats_update(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION meta_stats_update() IS 'update database statistics in meta';


--
-- Name: meta_update_kv(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION meta_update_kv(text, text) RETURNS void
    AS $_$
BEGIN
	delete from meta where key=$1;
	insert into meta (key,value) values ($1,$2);
	raise notice 'meta_update_kv: % = %',$1,$2;
	return;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.meta_update_kv(text, text) OWNER TO unison;

--
-- Name: FUNCTION meta_update_kv(text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION meta_update_kv(text, text) IS 'replacement insert into meta table';


--
-- Name: notice(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION notice(text) RETURNS void
    AS $_$
DECLARE
	msg text;
BEGIN
	msg:=$1;
	RAISE notice '%', msg;
	return;
END;$_$
    LANGUAGE plpgsql STRICT;


ALTER FUNCTION unison.notice(text) OWNER TO unison;

--
-- Name: origin_alias_descr_fmt(text, text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION origin_alias_descr_fmt(text, text, text) RETURNS text
    AS $_$select $1 || ':' || $2 || ' (' || coalesce($3, 'No description available') || ')' ;$_$
    LANGUAGE sql IMMUTABLE;


ALTER FUNCTION unison.origin_alias_descr_fmt(text, text, text) OWNER TO unison;

--
-- Name: FUNCTION origin_alias_descr_fmt(text, text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION origin_alias_descr_fmt(text, text, text) IS 'canonical format for origin, alias, and description, like this: <origin>:<alias> (<descr>)';


--
-- Name: origin_si_origin_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION origin_si_origin_id(text) RETURNS integer
    AS $_$
DECLARE
	O alias for $1;				-- origin
	rv integer;
BEGIN
	select into rv origin_id from origin where upper(origin) = upper(O);
	if found then return rv; end if;
	insert into origin (origin) values (O);
	select into rv origin_id from origin where origin = O;
	return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.origin_si_origin_id(text) OWNER TO unison;

--
-- Name: FUNCTION origin_si_origin_id(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION origin_si_origin_id(text) IS 'select/insert a origin_id from origin text, returns origin_id';


--
-- Name: ortholog(integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION ortholog(integer, integer, integer) RETURNS integer
    AS $_$
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
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.ortholog(integer, integer, integer) OWNER TO unison;

--
-- Name: FUNCTION ortholog(integer, integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION ortholog(integer, integer, integer) IS 'returns ortholog pseq_id given pseq_id, tax_id of the given pseq_id, and tax_id of the desired pseq_id';


--
-- Name: palias_oa_fmt(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION palias_oa_fmt(integer) RETURNS text
    AS $_$select origin_alias_fmt(O.origin,AO.alias) from paliasorigin AO join origin O on O.origin_id=AO.origin_id where AO.palias_id=$1$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.palias_oa_fmt(integer) OWNER TO unison;

--
-- Name: FUNCTION palias_oa_fmt(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION palias_oa_fmt(integer) IS 'origin_alias_fmt() for given palias_id';


--
-- Name: palias_oad_fmt(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION palias_oad_fmt(integer) RETURNS text
    AS $_$select origin_alias_descr_fmt(O.origin,AO.alias,AO.descr) from paliasorigin AO join origin O on O.origin_id=AO.origin_id where AO.palias_id=$1$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.palias_oad_fmt(integer) OWNER TO unison;

--
-- Name: FUNCTION palias_oad_fmt(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION palias_oad_fmt(integer) IS 'origin_alias_descr_fmt() for given palias_id';


--
-- Name: paliasorigin_iu_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION paliasorigin_iu_trigger() RETURNS trigger
    AS $$BEGIN new.descr_tsv = to_tsvector(new.descr); END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.paliasorigin_iu_trigger() OWNER TO unison;

--
-- Name: paprospect_create_indices(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION paprospect_create_indices() RETURNS void
    AS $$
BEGIN
	create index paprospect_gap_idx on paprospect (gap);
	raise notice 'created paprospect_gap_idx';
	create index paprospect_mutation_idx on paprospect (mutation);
	raise notice 'created paprospect_mutation_idx';
	create index paprospect_nalign_idx on paprospect (nalign);
	raise notice 'created paprospect_nalign_idx';
	create index paprospect_nident_idx on paprospect (nident);
	raise notice 'created paprospect_nident_idx';
	create index paprospect_pairwise_idx on paprospect (pairwise);
	raise notice 'created paprospect_pairwise_idx';
	create index paprospect_quality_idx on paprospect (quality);
	raise notice 'created paprospect_quality_idx';
	create index paprospect_raw_idx on paprospect (raw);
	raise notice 'created paprospect_raw_idx';
	create index paprospect_rgyr_idx on paprospect (rgyr);
	raise notice 'created paprospect_rgyr_idx';
	create index paprospect_singleton_idx on paprospect (singleton);
	raise notice 'created paprospect_singleton_idx';
	create index paprospect_ssfit_idx on paprospect (ssfit);
	raise notice 'created paprospect_ssfit_idx';
	create index paprospect_start_idx on paprospect (start);
	raise notice 'created paprospect_start_idx';
	create index paprospect_stop_idx on paprospect (stop);
	raise notice 'created paprospect_stop_idx';
	create index paprospect_svm_idx on paprospect (svm);
	raise notice 'created paprospect_svm_idx';
	create index paprospect_zscore_idx on paprospect (zscore);
	raise notice 'created paprospect_zscore_idx';
	return;
END;$$
    LANGUAGE plpgsql STABLE;


ALTER FUNCTION unison.paprospect_create_indices() OWNER TO unison;

--
-- Name: FUNCTION paprospect_create_indices(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION paprospect_create_indices() IS 'create non-integrity indicies on paprospect; WARNING: takes hours';


--
-- Name: paprospect_drop_indices(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION paprospect_drop_indices() RETURNS void
    AS $$
BEGIN
	drop index paprospect_gap_idx;
	drop index paprospect_mutation_idx;
	drop index paprospect_nalign_idx;
	drop index paprospect_nident_idx;
	drop index paprospect_pairwise_idx;
	drop index paprospect_quality_idx;
	drop index paprospect_raw_idx;
	drop index paprospect_rgyr_idx;
	drop index paprospect_singleton_idx;
	drop index paprospect_ssfit_idx;
	drop index paprospect_start_idx;
	drop index paprospect_stop_idx;
	drop index paprospect_svm_idx;
	drop index paprospect_zscore_idx;
	return;
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.paprospect_drop_indices() OWNER TO unison;

--
-- Name: FUNCTION paprospect_drop_indices(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION paprospect_drop_indices() IS 'drops non-integrity indicies from paprospect';


--
-- Name: paprospect_i_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION paprospect_i_trigger() RETURNS trigger
    AS $$BEGIN NEW.pftype_id=pftype_id('Prospect'); return new; END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.paprospect_i_trigger() OWNER TO unison;

--
-- Name: papseq_iu_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION papseq_iu_trigger() RETURNS trigger
    AS $$
declare
  t_pseq_id integer;
  q_seq_len integer;
  t_seq_len integer;
  shorter_len integer;
  longer_len integer;
begin
  -- get the pftype_id
  NEW.pftype_id=pftype_id('blast');
  IF NEW.pftype_id is null THEN
    RAISE EXCEPTION 'no pftype_id for name="blast"';
  END IF;

  -- get the t_pseq_id given the pmodel_id
  select into t_pseq_id pseq_id from pmpseq where pmodel_id=new.pmodel_id;
  IF t_pseq_id is null THEN
    RAISE EXCEPTION 'no pseq_id for pmodel_id=%',new.pmodel_id;
  END IF;

  -- get sequence lengths for derived values
  select into q_seq_len len from pseq where pseq_id=new.pseq_id;
  IF q_seq_len is null or q_seq_len = 0 THEN
    RAISE EXCEPTION 'length for pseq_id=% is null or zero',new.pseq_id;
	END IF;
  select into t_seq_len len from pseq where pseq_id=t_pseq_id;
  IF t_seq_len is null or t_seq_len = 0 THEN
    RAISE EXCEPTION 'length for pseq_id=% is null or zero',t_pseq_id;
  END IF;

  -- calculate derived values
  IF q_seq_len > t_seq_len THEN
    shorter_len := t_seq_len;
    longer_len := q_seq_len;
  ELSE
    shorter_len := q_seq_len;
    longer_len := t_seq_len;
  END IF;
  new.pct_hsp_coverage := ( new.len::real / shorter_len::real ) * 100.0;
  new.pct_coverage := ( shorter_len::real / longer_len::real )  * 100.0;

  return new;
end; $$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.papseq_iu_trigger() OWNER TO unison;

--
-- Name: FUNCTION papseq_iu_trigger(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION papseq_iu_trigger() IS 'calculate derived values for inserting into papseq';


--
-- Name: papssm_create_indices(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION papssm_create_indices() RETURNS void
    AS $$
BEGIN
	create index papssm_eval_idx on papssm(eval);
	raise notice 'created papssm_eval_idx';
	create index papssm_len_idx on papssm(len);
	raise notice 'created papssm_len_idx';
	create index papssm_score_idx on papssm(score);
	raise notice 'created papssm_score_idx';
	create index papssm_ident_idx on papssm(ident);
	raise notice 'created papssm_ident_idx';
	create index papssm_pos_idx on papssm(pos);
	raise notice 'created papssm_pos_idx';
	create index papssm_gap_idx on papssm(gap);
	raise notice 'created papssm_gap_idx';
	return;
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.papssm_create_indices() OWNER TO unison;

--
-- Name: papssm_drop_indices(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION papssm_drop_indices() RETURNS void
    AS $$
BEGIN
	drop index papssm_eval_idx;
	drop index papssm_len_idx;
	drop index papssm_score_idx;
	drop index papssm_ident_idx;
	drop index papssm_pos_idx;
	drop index papssm_gap_idx;
	return;
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.papssm_drop_indices() OWNER TO unison;

--
-- Name: papssm_iu_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION papssm_iu_trigger() RETURNS trigger
    AS $$BEGIN new.pftype_id = pftype_id( 'PSSM' ); return new; END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.papssm_iu_trigger() OWNER TO unison;

--
-- Name: params_id_exists(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION params_id_exists(integer) RETURNS boolean
    AS $_$
BEGIN
	perform * from params where params_id=$1;
	return FOUND;
END;
$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.params_id_exists(integer) OWNER TO unison;

--
-- Name: FUNCTION params_id_exists(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION params_id_exists(integer) IS 'return true if params_id exists';


--
-- Name: perftest_iu_trigger_fx(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION perftest_iu_trigger_fx() RETURNS trigger
    AS $$
BEGIN
	NEW.pg_version = substring(NEW.pg_version_str from E'^PostgreSQL (\\S+) ');
	RETURN NEW;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.perftest_iu_trigger_fx() OWNER TO unison;

--
-- Name: pfbigpi_site_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pfbigpi_site_trigger() RETURNS trigger
    AS $$
  begin
    new.stop := new.start;
    return new;
  end; $$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pfbigpi_site_trigger() OWNER TO unison;

--
-- Name: FUNCTION pfbigpi_site_trigger(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pfbigpi_site_trigger() IS 'sets stop equal to start';


--
-- Name: pfsignalphmm_pred(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pfsignalphmm_pred(text) RETURNS integer
    AS $_$

DECLARE V_id integer; 
BEGIN

select into V_id pfsignalphmm_pred_id from pfsignalphmm_pred where upper(prediction)=upper($1); 
IF NOT FOUND THEN 
RAISE WARNING 'prediction % not found', $1; 
RETURN NULL; 
END IF; 
return V_id; 
END;$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.pfsignalphmm_pred(text) OWNER TO unison;

--
-- Name: pi(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pi(text) RETURNS real
    AS $_$
DECLARE 
	ans float;
BEGIN 
	select INTO ans pI($1,'emboss');
	return ans;
END$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pi(text) OWNER TO unison;

--
-- Name: pmap_hsp_str_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmap_hsp_str_trigger() RETURNS trigger
    AS $$
  declare
hsp RECORD;
v_hsp_str text := '';
  begin
    select into v_hsp_str as_set(hsp_id) from (select hsp_id from pmap_alnhsp where aln_id=new.aln_id order by hsp_id) X;

    IF length(v_hsp_str) = 0 THEN
RAISE EXCEPTION 'Could not construct hsp_str for %',new.aln_id;
    END IF;

    new.hsp_str=v_hsp_str;
    return new;
  end; $$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pmap_hsp_str_trigger() OWNER TO unison;

--
-- Name: FUNCTION pmap_hsp_str_trigger(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pmap_hsp_str_trigger() IS 'calculate hsp_str before inserting into pmap_aln';


--
-- Name: pmhmm_si_pmodel_id(integer, text, text, text, integer, integer, integer, real, real, real, real, real, real); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmhmm_si_pmodel_id(integer, text, text, text, integer, integer, integer, real, real, real, real, real, real) RETURNS integer
    AS $_$
DECLARE
        rv integer;
        hmm_origin_id alias for $1;
        hmm_name alias for $2;
        hmm_acc alias for $3;
        hmm_descr alias for $4;
        hmm_len alias for $5;
        hmm_nseq alias for $6;
        hmm_cksum alias for $7;
        hmm_ga_seq alias for $8;
        hmm_ga_dom alias for $9;
        hmm_tc_seq alias for $10;
        hmm_tc_dom alias for $11;
        hmm_nc_seq alias for $12;
        hmm_nc_dom alias for $13;
BEGIN
        rv := hmm_pmodel_id(hmm_acc,hmm_origin_id);
        if rv is NULL then
                select into rv nextval('pmodel_pmodel_id_seq');
                insert into pmhmm (pmodel_id,origin_id,name,acc,descr,len,nseq,cksum,ga_seq,ga_dom,tc_seq,tc_dom,nc_seq,nc_dom) values ( rv,hmm_origin_id,hmm_name,hmm_acc,hmm_descr,hmm_len,hmm_nseq,hmm_cksum,hmm_ga_seq,hmm_ga_dom,hmm_tc_seq,hmm_tc_dom,hmm_nc_seq,hmm_nc_dom);
	else
		update pmhmm set name=hmm_name,descr=hmm_descr,len=hmm_len,nseq=hmm_nseq,cksum=hmm_cksum,ga_seq=hmm_ga_seq,ga_dom=hmm_ga_dom,tc_seq=hmm_tc_seq,tc_dom=hmm_tc_dom,nc_seq=hmm_nc_seq,nc_dom=hmm_nc_dom where pmodel_id=rv;
        end if;
        return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pmhmm_si_pmodel_id(integer, text, text, text, integer, integer, integer, real, real, real, real, real, real) OWNER TO unison;

--
-- Name: FUNCTION pmhmm_si_pmodel_id(integer, text, text, text, integer, integer, integer, real, real, real, real, real, real); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pmhmm_si_pmodel_id(integer, text, text, text, integer, integer, integer, real, real, real, real, real, real) IS 'select/insert a pmodel_id from pmhmm, returns pmodel_id';


--
-- Name: pmodel_id_exists(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmodel_id_exists(integer) RETURNS boolean
    AS $_$
BEGIN
	perform * from pmodel where pmodel_id=$1;
	return FOUND;
END;
$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.pmodel_id_exists(integer) OWNER TO unison;

--
-- Name: FUNCTION pmodel_id_exists(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pmodel_id_exists(integer) IS 'return true if pmodel_id exists pmodel or subclass thereof';


--
-- Name: pmodelset_id_exists(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmodelset_id_exists(integer) RETURNS boolean
    AS $_$
BEGIN
	perform * from pmodelset where pmodelset_id=$1;
	return FOUND;
END;
$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.pmodelset_id_exists(integer) OWNER TO unison;

--
-- Name: FUNCTION pmodelset_id_exists(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pmodelset_id_exists(integer) IS 'return true if pmodelset_id exists';


--
-- Name: pmodelset_immutable_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmodelset_immutable_trigger() RETURNS trigger
    AS $$
 declare
 v_locked boolean;
v_pmodelset_id integer; 
 begin
 --check if this set is locked
 IF (TG_OP = 'DELETE') THEN
 select into v_locked locked from pmodelset where pmodelset_id=old.pmodelset_id;
 IF v_locked is TRUE THEN
 RAISE EXCEPTION 'pmodelset_id % is locked for deletes',old.pmodelset_id;
 END IF;
 return old;
 ELSIF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
 select into v_locked locked from pmodelset where pmodelset_id=new.pmodelset_id;
 IF v_locked is TRUE THEN
 RAISE EXCEPTION 'pmodelset_id % is locked for inserts/updates',new.pmodelset_id;
 END IF;
 return new;
 END IF;
 end;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pmodelset_immutable_trigger() OWNER TO unison;

--
-- Name: pmodelset_si_pmodelset_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmodelset_si_pmodelset_id(text) RETURNS integer
    AS $_$
DECLARE
        M alias for $1;                         -- pmodelset
        rv integer;
BEGIN
        select into rv pmodelset_id from pmodelset where upper(name) = upper(M);
        if found then return rv; end if;
        insert into pmodelset (name) values (M);
        select into rv pmodelset_id from pmodelset where name = M;
        return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pmodelset_si_pmodelset_id(text) OWNER TO unison;

--
-- Name: FUNCTION pmodelset_si_pmodelset_id(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pmodelset_si_pmodelset_id(text) IS 'select/insert a pmodelset_id from pmodelset, returns pmodelset_id';


--
-- Name: pmpseq_iu_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmpseq_iu_trigger() RETURNS trigger
    AS $$
  declare
		v_best_palias_id integer;
  begin

		-- get the best palias_id for this pseq_id
    select into v_best_palias_id best_palias_id(new.pseq_id,true);
    IF v_best_palias_id is null THEN
      RAISE EXCEPTION 'no best_palias_id for pseq_id=%',new.pseq_id;
    END IF;

		select into new.origin_id,new.name origin_id,alias from palias where palias_id=v_best_palias_id;

    return new;
  end; $$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pmpseq_iu_trigger() OWNER TO unison;

--
-- Name: FUNCTION pmpseq_iu_trigger(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pmpseq_iu_trigger() IS 'calculate derived values for inserting into pmpseq';


--
-- Name: pmregexp_si_pmodel_id(integer, text, text, text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmregexp_si_pmodel_id(integer, text, text, text, text) RETURNS integer
    AS $_$
DECLARE
        rv integer;
BEGIN
	select into rv pmodel_id from pmregexp where regexp=$5 and origin_id=$1;
	if rv is NULL then
		select into rv nextval('pmodel_pmodel_id_seq');
		insert into pmregexp (pmodel_id,origin_id,acc,name,descr,regexp) values ( rv,$1,$2,$3,$4,$5);
	end if;
        return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pmregexp_si_pmodel_id(integer, text, text, text, text) OWNER TO unison;

--
-- Name: FUNCTION pmregexp_si_pmodel_id(integer, text, text, text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pmregexp_si_pmodel_id(integer, text, text, text, text) IS 'select/insert a pmodel_id from pmregexp, returns pmodel_id';


--
-- Name: pmregexp_u_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pmregexp_u_trigger() RETURNS trigger
    AS $$BEGIN IF OLD.regexp!=NEW.regexp THEN RAISE EXCEPTION 'pmodel_id % (%): regular expressions are immutable', OLD.pmodel_id,OLD.acc; END IF; return NEW; END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pmregexp_u_trigger() OWNER TO unison;

--
-- Name: pnote_iu_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pnote_iu_trigger() RETURNS trigger
    AS $$BEGIN new.login := current_user; new.added = now(); return new; END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pnote_iu_trigger() OWNER TO unison;

--
-- Name: porigin_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION porigin_id(text) RETURNS integer
    AS $_$
BEGIN
raise warning 'porigin_id() deprecated on 2006-06-26; use origin_id() instead';
return origin_id($1);
END;
$_$
    LANGUAGE plpgsql STRICT;


ALTER FUNCTION unison.porigin_id(text) OWNER TO unison;

--
-- Name: FUNCTION porigin_id(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION porigin_id(text) IS 'DEPRECATED; use origin_id()';


--
-- Name: pro2descr(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pro2descr(integer) RETURNS text
    AS $_$
DECLARE
	p alias for $1;
	d text;
BEGIN
	select into d descr from palias where pseq_id=p and alias~'^PRO';
	if found then
		raise notice 'descr=%',d;
		update palias set descr=d where origin_id=15 and pseq_id=p and descr is null;
	end if;
	return d;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pro2descr(integer) OWNER TO unison;

--
-- Name: pseq_genasm_params_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_genasm_params_trigger() RETURNS trigger
    AS $$
  declare
	hsp RECORD;
  begin
    -- get pseq,genasm,params from hps for this alignment
    FOR hsp IN
	select h.genasm_id,h.pseq_id,h.params_id from pmap_hsp h join pmap_alnhsp a on a.hsp_id=h.hsp_id and a.aln_id=new.aln_id
    LOOP
	IF hsp.genasm_id != new.genasm_id OR hsp.pseq_id != new.pseq_id OR hsp.params_id != new.params_id THEN
		RAISE NOTICE '% % %',hsp.genasm_id,hsp.pseq_id,hsp.params_id;
		RAISE EXCEPTION 'genasm, pseq params mismatch for aln %',new.aln_id;
	END IF;
    END LOOP;  
    return new;
  end; $$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pseq_genasm_params_trigger() OWNER TO unison;

--
-- Name: FUNCTION pseq_genasm_params_trigger(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pseq_genasm_params_trigger() IS 'makes sure pseq_id, genasm_id and params_id are consistant between aln and hsp';


--
-- Name: pseq_i_pseq_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_i_pseq_id(text) RETURNS integer
    AS $_$
DECLARE
	S alias for $1;
	rv integer;
BEGIN
	select into rv nextval('pseq_pseq_id_seq');
	insert into pseq (pseq_id,seq) values (rv,S);
	return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pseq_i_pseq_id(text) OWNER TO unison;

--
-- Name: pseq_id_from_sequence(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_id_from_sequence(text) RETURNS integer
    AS $_$select _pseq_seq_lookup(clean_sequence($1))$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.pseq_id_from_sequence(text) OWNER TO unison;

--
-- Name: FUNCTION pseq_id_from_sequence(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pseq_id_from_sequence(text) IS 'return pseq_id for sequence; sequence is made canonical by clean_sequence';


--
-- Name: pseq_iu_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_iu_trigger() RETURNS trigger
    AS $$
declare
    orig_md5 text;
begin
	-- compute the incoming sequence's md5 so that we can warn about changes
    orig_md5 := md5(new.seq);

	-- remove whitespace and bogus chars, and upcase sequence
    new.seq := clean_sequence(new.seq);

	-- modifying sequences is prohibited
	-- if tg_op = 'UPDATE' and old.seq != new.seq then
	if tg_op = 'UPDATE' then
	if old.seq != new.seq then
		raise exception 'pseq sequences may not be altered';
	end if;
	end if;

	-- compute the md5 and length of the "cleaned" sequence
    new.md5 := md5(new.seq);
    new.len := length(new.seq);

	-- warn (and proceed) if the sequence was modified by clean_sequence
    if orig_md5 != new.md5 then
        raise notice 'pseq_id % modified during insert.',new.pseq_id;
    end if;

	-- fatal if sequences have non-IUPAC chars
	IF has_non_iupac_aa(new.seq) THEN
        raise exception 'pseq_id % contains non standard amino acids.',new.pseq_id;
	END IF;

	-- warn if sequence contains gaps or ambiguities
	IF has_iupac_gap_aa(new.seq) THEN
        raise notice 'pseq_id % contains gaps.',new.pseq_id;
	END IF;
	IF has_iupac_ambiguity_aa(new.seq) THEN
        raise notice 'pseq_id % contains ambiguity amino acids.',new.pseq_id;
	END IF;

    RETURN new;
end;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pseq_iu_trigger() OWNER TO unison;

--
-- Name: pseq_locus_human(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_locus_human(integer) RETURNS text
    AS $_$select * from pseq_locus($1,3,48)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.pseq_locus_human(integer) OWNER TO unison;

--
-- Name: pseq_locus_rep(integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_locus_rep(integer, integer, integer) RETURNS integer
    AS $_$select t_pseq_id from pmap_locus_representative_v where q_pseq_id=$1 and genasm_id=$2 and params_id=$3;$_$
    LANGUAGE sql STABLE STRICT;


ALTER FUNCTION unison.pseq_locus_rep(integer, integer, integer) OWNER TO unison;

--
-- Name: pseq_si_pseq_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pseq_si_pseq_id(text) RETURNS integer
    AS $_$
DECLARE
        S text;
        rv integer;
        Smd5 text;
BEGIN
        S := clean_sequence($1);
        Smd5 := md5(S);
        rv := _pseq_seq_lookup( S );
        if rv is NULL then
                select into rv pseq_i_pseq_id( S );
        end if;
        return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pseq_si_pseq_id(text) OWNER TO unison;

--
-- Name: FUNCTION pseq_si_pseq_id(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pseq_si_pseq_id(text) IS 'select/insert a pseq_id from sequence, returns pseq_id';


--
-- Name: pstr_get_pstr_id(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION pstr_get_pstr_id(text) RETURNS integer
    AS $_$
DECLARE
	rv integer;
BEGIN
	select into rv pstr_id from pstr where pdbc = upper($1);
	return rv;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.pstr_get_pstr_id(text) OWNER TO unison;

--
-- Name: FUNCTION pstr_get_pstr_id(text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION pstr_get_pstr_id(text) IS 'return pstr_id for pdbc (pdb + chain)';


--
-- Name: publicize(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION publicize() RETURNS void
    AS $$
DECLARE
	v_row record;
BEGIN
	if current_database() != 'csb-public' then
		RAISE EXCEPTION 'publicize(): database must be named "csb-public"';
	end if;
	RAISE WARNING '%: BEGINNING MASSIVE DELETE OF PROPRIETARY DATA.', timeofday();

	FOR v_row IN SELECT origin,origin_id FROM origin WHERE is_public=FALSE ORDER BY origin_id LOOP
		RAISE NOTICE '%: deleting results for ''%'' (origin_id=%)', timeofday(), v_row.origin, v_row.origin_id;
		DELETE FROM paliasorigin WHERE origin_id=v_row.origin_id;
		DELETE FROM origin WHERE origin_id=v_row.origin_id;
	END LOOP;

	FOR v_row IN SELECT name,params_id FROM params WHERE is_public=FALSE ORDER BY params_id LOOP   
		RAISE NOTICE '%: deleting results for ''%'' (params_id=%)', timeofday(), v_row.name, v_row.params_id;
		DELETE FROM pahmm WHERE params_id=v_row.params_id;
		DELETE FROM paprospect WHERE params_id=v_row.params_id;
		DELETE FROM params WHERE params_id=v_row.params_id;
	END LOOP;

	RAISE NOTICE 'deleting sequences NOT in pset_id=150';
	DELETE FROM pseq WHERE pseq_id NOT IN (SELECT pseq_id FROM pseqset WHERE pset_id=150);

	select meta_update_kv('publicized at',now());
	RAISE NOTICE '%: Done. You should VACUUM ANALYZE VERBOSE.', timeofday();
	RETURN;
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.publicize() OWNER TO unison;

--
-- Name: FUNCTION publicize(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION publicize() IS 'DANGER: This function deletes all proprietary data. It may only be run in a database named csb-public.';


--
-- Name: randseq(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION randseq(integer) RETURNS text
    AS $_X$my $A="ACDEFGHIKLMNPQRSTVWY"; my $s=""; $s.=substr($A,rand(length($A)),1) for 1..$_[0]; return $s;$_X$
    LANGUAGE plperl;


ALTER FUNCTION unison.randseq(integer) OWNER TO unison;

--
-- Name: release(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION release() RETURNS void
    AS $$
BEGIN
perform meta_update_kv('release timestamp',now());
perform meta_update_kv('release',to_char(now(), 'YYYY-MM-DD') );
return;
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.release() OWNER TO unison;

--
-- Name: FUNCTION release(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION release() IS 'perform final operations for unison release';


--
-- Name: representative_pseq_id(integer, integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer) RETURNS integer
    AS $_$select t_pseq_id as pseq_id from pmap_locus_representative_mv where q_pseq_id=$1 and genasm_id=$2 and params_id=$3$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer) OWNER TO unison;

--
-- Name: FUNCTION representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer) IS 'return "best" representative pseq_id for given pseq_id, genasm_id, params_id';


--
-- Name: representative_pseq_id(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION representative_pseq_id(q_pseq_id integer, OUT pseq_id integer) RETURNS integer
    AS $_$select representative_pseq_id($1,3,48)$_$
    LANGUAGE sql IMMUTABLE STRICT;


ALTER FUNCTION unison.representative_pseq_id(q_pseq_id integer, OUT pseq_id integer) OWNER TO unison;

--
-- Name: FUNCTION representative_pseq_id(q_pseq_id integer, OUT pseq_id integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION representative_pseq_id(q_pseq_id integer, OUT pseq_id integer) IS 'return "best" representative pseq_id for given pseq_id using current human genasm_id and params_id';


--
-- Name: residue_atomres_trigger(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION residue_atomres_trigger() RETURNS trigger
    AS $$
  DECLARE
  BEGIN

	IF new.atom_res IS null or new.atom_res = '' THEN
		IF new.res_id IS not null or new.res_id != '' THEN
			RAISE EXCEPTION 'res_id is not null when atom_res is null for pdbc = % and seqpos = %',new.pdbc,new.seq_pos;
			RETURN NULL;
		END IF;
	END IF;
	IF new.res_id IS null or new.res_id = '' THEN
		IF new.atom_res IS not null or new.atom_res != '' THEN
			RAISE EXCEPTION 'atom_res is not null when res_id is null for pdbc = % and seqpos = %',new.pdbc,new.seq_pos;
			RETURN NULL;
		END IF;
	END IF;
	RETURN new;

  END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.residue_atomres_trigger() OWNER TO unison;

--
-- Name: run_all_perftests(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION run_all_perftests(pid integer) RETURNS void
    AS $$
DECLARE
	pla perftest_platform%ROWTYPE;
	def perftest_def%ROWTYPE;
	res perftest_result%ROWTYPE;
	i smallint;
	t0 timestamp;
	t1 timestamp;
	td integer;
	sum_td integer;
	rows integer;
	rid integer;
BEGIN
	SELECT INTO pla * FROM perftest_platform where platform_id = pid;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'platform_id=%: NOT FOUND; aborting', pid;
	END IF;

	-- sanity checks to ensure that the user doesn't call us with an obviously bogus
	-- platform_id
	IF NOT pla.current THEN
		RAISE EXCEPTION 'platform_id=%: platform is not current; aborting', pid;
	END IF;

	IF pla.locked THEN
		RAISE EXCEPTION 'platform_id=%: platform is locked; aborting', pid;
	END IF;

	IF pla.pg_version_str != version() THEN
		RAISE EXCEPTION 'platform_id=% pg_version_str=% but version()=%; aborting', pid, pla.pg_version_str, version();
	END IF;

	IF pla.ip != inet_server_addr() THEN
		RAISE EXCEPTION 'platform_id=% ip=% but inet_server_addr()=%; aborting', pid, pla_ip, inet_server_addr();
	END IF;

	insert into perftest_run (platform_id,start_ts) values (pid,clock_timestamp()::timestamp);
	rid := lastval();			-- run_id from above insertion

	RAISE NOTICE '* running perftest for platform_id=% (%), run_id %', pid, pla.name, rid;

	FOR def IN SELECT * FROM perftest_def WHERE current ORDER BY ordr,def_id LOOP
		RAISE NOTICE 'def_id=% (%): %', def.def_id, def.name, def.sql;
		sum_td := 0;
		FOR i IN 1..def.n_runs LOOP
			-- run test
			t0 := clock_timestamp();
			EXECUTE def.sql;
			GET DIAGNOSTICS rows = ROW_COUNT;
			t1 := clock_timestamp();
			td := extract(milliseconds from t1-t0)::integer;

			IF i = 1 THEN
				res.n_rows = rows;
				IF rows < def.min_n_rows THEN
					RAISE WARNING 'def_id=%, #%: returned % rows; expected >%', def.def_id, i, rows, def.min_n_rows;
				END IF;
			ELSE
				IF rows != res.n_rows THEN
					RAISE WARNING 'def_id=%, #%: returned % rows; iteration 1 returned % rows', def.def_id, i, rows, res.n_rows;
				END IF;
			END IF;
			
			IF td > def.max_time THEN
				RAISE WARNING 'def_id=%, #%: time exceeded max_time (% ms > % ms)', def.def_id, i, td, def.max_time;
			END IF;
	
			res.times[i] = td;
			sum_td := sum_td + td;

			RAISE NOTICE '  #%: % rows, % ms', i, rows, td;
		END LOOP;

		res.avg_time = sum_td / def.n_runs;
		IF res.avg_time > def.max_avg_time THEN
			RAISE WARNING 'def_id=%: avg_time (% ms) exceeed max_av_time (% ms)', def.def_id, res.avg_time, def.max_time;
		END IF;

		res.def_id := def.def_id;
		res.run_id := rid;
		res.had_error := FALSE;

		INSERT INTO perftest_result(def_id,run_id,had_error,n_rows,times,avg_time)
			VALUES (res.def_id,res.run_id,res.had_error,res.n_rows,res.times,res.avg_time);
	END LOOP;

	update perftest_run set stop_ts=clock_timestamp()::timestamp where run_id=rid;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.run_all_perftests(pid integer) OWNER TO unison;

--
-- Name: seqhash(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION seqhash(text) RETURNS text
    AS $_$DECLARE S text; BEGIN return ( _seqhash_no_cleaning( clean_sequence($1) ) ); END$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;


ALTER FUNCTION unison.seqhash(text) OWNER TO unison;

--
-- Name: sequence_ends(text, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION sequence_ends(text, integer) RETURNS text
    AS $_X$
my $seq = $_[0];
my $end_len = $_[1];
my $elipsis = '..';
return $seq if ( length($seq) <= $end_len + $end_len + length($elipsis) );
return substr($seq,0,$end_len) . $elipsis . substr($seq,-$end_len);
$_X$
    LANGUAGE plperl IMMUTABLE STRICT;


ALTER FUNCTION unison.sequence_ends(text, integer) OWNER TO unison;

--
-- Name: FUNCTION sequence_ends(text, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION sequence_ends(text, integer) IS 'returns first and last N chars of sequence, e.g., ACDEF..STVWY';


--
-- Name: spdi_dna_palias_id(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION spdi_dna_palias_id(integer) RETURNS integer
    AS $_$
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.is_current=TRUE and OA.origin_id=origin_id('SPDI') and alias~'^DNA'
		limit 1;
	return a_id;
END;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison.spdi_dna_palias_id(integer) OWNER TO unison;

--
-- Name: spdi_palias_id(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION spdi_palias_id(integer) RETURNS integer
    AS $_$
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	-- order by alias desc has the effect of preferring UNQ, then PRO, then DNA
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.is_current=TRUE and OA.origin_id=origin_id('GenenGenes')
		order by alias desc
		limit 1;
	return a_id;
END;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison.spdi_palias_id(integer) OWNER TO unison;

--
-- Name: spdi_pro_palias_id(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION spdi_pro_palias_id(integer) RETURNS integer
    AS $_$
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.is_current=TRUE and OA.origin_id=origin_id('SPDI') and alias~'^PRO'
		limit 1;
	return a_id;
END;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison.spdi_pro_palias_id(integer) OWNER TO unison;

--
-- Name: spdi_unq_palias_id(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION spdi_unq_palias_id(integer) RETURNS integer
    AS $_$
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.is_current=TRUE and OA.origin_id=origin_id('SPDI') and alias~'^UNQ'
		limit 1;
	return a_id;
END;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison.spdi_unq_palias_id(integer) OWNER TO unison;

--
-- Name: split(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION split(text, text) RETURNS text[]
    AS $_$
  DECLARE
    i int := 0;
    word text;
    result text := '{';
    result_arr text[];
  BEGIN
    LOOP
      i := i + 1;
      SELECT INTO word split_part($1, $2, i);
      IF word = '' THEN
        EXIT;
      END IF;
      IF i > 1 THEN
        result := result || ',"' || word || '"';
      ELSE
        result := result || '"' || word || '"';
      END IF;
    END LOOP;
    result := result || '}';
    result_arr := result;
    RETURN result_arr;
  END
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.split(text, text) OWNER TO unison;

--
-- Name: FUNCTION split(text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION split(text, text) IS 'split text into an array - similar to Perl split';


--
-- Name: sprintf(text, text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION sprintf(text, text, text) RETURNS text
    AS $_$
  my ($string, $args, $delim) = @_;
  my $delsplit = defined $delim ? qr{\Q$delim} : qr{\s+};
  return sprintf($string, (split $delsplit, $args));
$_$
    LANGUAGE plperl;


ALTER FUNCTION unison.sprintf(text, text, text) OWNER TO unison;

--
-- Name: FUNCTION sprintf(text, text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION sprintf(text, text, text) IS 'sprintf(fmt,argstring,dlm): format dlm-delimited argstring using fmt';


--
-- Name: sprintf(text, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION sprintf(text, text) RETURNS text
    AS $_$
  SELECT sprintf($1,$2,null);
$_$
    LANGUAGE sql;


ALTER FUNCTION unison.sprintf(text, text) OWNER TO unison;

--
-- Name: FUNCTION sprintf(text, text); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION sprintf(text, text) IS 'sprintf(fmt,argstring): format whitespace-delimited  argstring using fmt';


--
-- Name: sst_palias_id(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION sst_palias_id(integer) RETURNS integer
    AS $_$
BEGIN
	raise warning 'SST_PALIAS_ID is deprecated';
	raise warning '  use SPDI_PALIAS_ID instead';
	return( spdi_palias_id( $1 ) );	
END;$_$
    LANGUAGE plpgsql STABLE STRICT;


ALTER FUNCTION unison.sst_palias_id(integer) OWNER TO unison;

--
-- Name: unq2descr(integer, text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION unq2descr(integer, text) RETURNS void
    AS $_$
DECLARE
	p alias for $1;
	UNQ alias for $2;
BEGIN
	raise notice 'UNQ=%',UNQ;
	update palias set descr=UNQ||' '||descr where origin_id=15 and pseq_id=p and descr not null;
	return;
END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.unq2descr(integer, text) OWNER TO unison;

--
-- Name: upd_run_history(integer, integer, boolean); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION upd_run_history(integer, integer, boolean) RETURNS timestamp with time zone
    AS $_$
DECLARE
	q alias for $1;
	r alias for $2;
	f alias for $3;
	z timestamp;
BEGIN
	z:=now();
	update run_history set failed=f,ran_on=z where pseq_id=q and run_id=r;
	if not FOUND then
		-- update failed... tuple must not exist
		insert into run_history (pseq_id,run_id,failed,ran_on) values (q,r,f,z);
	end if;
	return z;
END;$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.upd_run_history(integer, integer, boolean) OWNER TO unison;

--
-- Name: FUNCTION upd_run_history(integer, integer, boolean); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION upd_run_history(integer, integer, boolean) IS 'inserts/updates run_history for the given pseq_id,run_id,failed); returns timestamp';


--
-- Name: upd_run_history(integer, integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION upd_run_history(integer, integer) RETURNS timestamp with time zone
    AS $_$BEGIN return upd_run_history($1,$2,NULL); END$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.upd_run_history(integer, integer) OWNER TO unison;

--
-- Name: FUNCTION upd_run_history(integer, integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION upd_run_history(integer, integer) IS 'equivalent to upd_run_history(pseq_id,run_id,NULL)';


--
-- Name: update_pmodelset(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION update_pmodelset(integer) RETURNS integer
    AS $_$
DECLARE
	v_pmodelset_id alias for $1;

	v_row record;
	v_pg_row record;
	v_cmd text;
	v_tmptblname text;

	v_nrows_del integer := 0;
	v_nrows_ins integer := 0;
	v_nrows_tot integer := 0;
BEGIN
	-- ********************************* checklist *****************************************
	-- check if the requested pmodelset_id exists
	SELECT INTO v_row pmodelset_id,name,descr,def,locked,pmsm_table FROM pmodelset WHERE pmodelset_id=v_pmodelset_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'pmodelset_id=% does not exist', v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if pmodelset is immutable (locked)
	IF v_row.locked IS TRUE THEN
		RAISE EXCEPTION '% set (pmodelset_id=%) is locked for updates.', v_row.name,v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if an sql definition exists
	IF v_row.def IS NULL THEN
		RAISE EXCEPTION 'The definition for pmodelset_id=% is null.', v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if the pmsm_pm* table is set
	IF v_row.pmsm_table IS NULL THEN
		RAISE EXCEPTION 'The pmsm_pm* table name for this set (pmodelset_id=%) is null.', v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if the pmsm_pm* table exists
	SELECT INTO v_pg_row tablename FROM pg_tables where tablename=v_row.pmsm_table;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'table=% does not exist', v_row.pmsm_table;
		RETURN NULL;
	END IF;
	-- **************************************************************************************

	-- warn with name and id
	RAISE DEBUG '* % (pmodelset_id=%)', v_row.name, v_row.pmodelset_id;

	v_tmptblname := 'update_pmodelset_' || v_pmodelset_id || '_' || md5(now()||random());

	-- materialize a temp table of the current set contents
	v_cmd := 'CREATE TEMP TABLE '||v_tmptblname||' AS SELECT DISTINCT pmodel_id FROM ('||v_row.def||') X';
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_tot = ROW_COUNT;
	RAISE DEBUG '% rows in temp table', v_nrows_tot;

	-- delete obsolete models using an intermediate, indexed table
	v_cmd := 'CREATE TEMP TABLE '||v_tmptblname||'_del AS SELECT pmodel_id from '||v_row.pmsm_table||' where pmodelset_id='||v_pmodelset_id||' EXCEPT select pmodel_id from '||v_tmptblname;
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

	v_cmd := 'CREATE INDEX '||v_tmptblname||'_del_m_idx on '||v_tmptblname||'_del(pmodel_id)';
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

	v_cmd := 'ANALYZE '||v_tmptblname||'_del';
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

	v_cmd:='DELETE FROM '||v_row.pmsm_table||' USING '||v_tmptblname||'_del D WHERE pmodelset_id='||v_pmodelset_id||' AND '||v_row.pmsm_table||'.pmodel_id=D.pmodel_id';
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_del = ROW_COUNT;

	v_cmd:='DROP TABLE ' || v_tmptblname||'_del';
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

	-- add new models
	v_cmd:='INSERT INTO '||v_row.pmsm_table||' (pmodelset_id,pmodel_id) SELECT '||v_pmodelset_id||',pmodel_id FROM (SELECT pmodel_id FROM '||v_tmptblname||' EXCEPT SELECT pmodel_id FROM '||v_row.pmsm_table||' WHERE pmodelset_id='||v_pmodelset_id||') X';
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_ins = ROW_COUNT;

	-- drop the temp table
	v_cmd:='DROP TABLE ' || v_tmptblname;
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

	v_cmd := 'SELECT pmodel_id FROM '||v_row.pmsm_table||' WHERE pmodelset_id = '||v_pmodelset_id;
	RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_tot = ROW_COUNT;

	RAISE NOTICE '  % (pmodelset_id=%): % model deleted, % models added, % total',
	v_row.name, v_row.pmodelset_id, v_nrows_del, v_nrows_ins, v_nrows_tot;
	RETURN v_nrows_tot;

END
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.update_pmodelset(integer) OWNER TO unison;

--
-- Name: FUNCTION update_pmodelset(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION update_pmodelset(integer) IS 'update pmodelset for a specified pmodelset_id using the definition in pmodelset.def';


--
-- Name: update_pset(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION update_pset(integer) RETURNS integer
    AS $_$
DECLARE
    v_pset_id alias for $1;
    v_row record;
    v_cmd text;
    v_nrows_del integer;
    v_nrows_ins integer;
    v_nrows_tot integer;
    v_tmptblname text;
BEGIN
    SELECT INTO v_row pset_id,name,def FROM pset WHERE pset_id=v_pset_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'pset_id=% does not exist', v_pset_id;
        RETURN NULL;
    END IF;

    IF v_row.def IS NULL THEN
        RAISE EXCEPTION 'The set definition for pset_id=% is null.', v_pset_id;
        RETURN NULL;
    END IF;
    RAISE DEBUG '* % (pset_id=%)', v_row.name, v_row.pset_id;

    v_tmptblname := 'update_pset_' || v_pset_id || '_' || md5(now()::text||random()::text);

	-- materialize a temp table of the current set contents
    v_cmd := 'CREATE TEMP TABLE '||v_tmptblname||' AS SELECT DISTINCT pseq_id FROM ('||v_row.def||') X';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    GET DIAGNOSTICS v_nrows_tot = ROW_COUNT;
	RAISE DEBUG '% rows in temp table', v_nrows_tot;

	-- delete obsolete seqs using an intermediate, indexed table
    v_cmd := 'CREATE TEMP TABLE '||v_tmptblname||'_del AS SELECT pseq_id from pseqset where pset_id='||v_pset_id||' EXCEPT select pseq_id from '||v_tmptblname;
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    v_cmd := 'CREATE INDEX '||v_tmptblname||'_del_q_idx on '||v_tmptblname||'_del(pseq_id)';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    v_cmd := 'ANALYZE '||v_tmptblname||'_del';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    v_cmd:='DELETE FROM pseqset USING '||v_tmptblname||'_del D WHERE pset_id='||v_pset_id||' AND pseqset.pseq_id=D.pseq_id';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    GET DIAGNOSTICS v_nrows_del = ROW_COUNT;
    v_cmd:='DROP TABLE ' || v_tmptblname||'_del';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

	-- add new seqs
    v_cmd:='INSERT INTO pseqset (pset_id,pseq_id) SELECT '||v_row.pset_id||',pseq_id FROM (SELECT pseq_id FROM '||v_tmptblname||' EXCEPT SELECT pseq_id FROM pseqset WHERE pset_id='||v_pset_id||') X';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    GET DIAGNOSTICS v_nrows_ins = ROW_COUNT;

	-- drop the temp table
    v_cmd:='DROP TABLE ' || v_tmptblname;
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

    SELECT INTO v_nrows_tot COUNT(*) FROM pseqset WHERE pset_id = v_pset_id;
    RAISE NOTICE '  % (pset_id=%): % sequences deleted, % sequences added, % total',
        v_row.name, v_row.pset_id, v_nrows_del, v_nrows_ins, v_nrows_tot;
    RETURN v_nrows_tot;
END
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.update_pset(integer) OWNER TO unison;

--
-- Name: FUNCTION update_pset(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION update_pset(integer) IS 'update pmodelset for a specified pmodelset_id using the definition in pmodelset.def';


--
-- Name: update_pset_orig(integer); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION update_pset_orig(integer) RETURNS integer
    AS $_$
DECLARE
    v_pset_id alias for $1;
    v_row record;
    v_cmd text;
    v_nrows_del integer;
    v_nrows_ins integer;
    v_nrows_tot integer;
    v_tmptblname text;
BEGIN
    SELECT INTO v_row pset_id,name,def FROM pset WHERE pset_id=v_pset_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'pset_id=% does not exist', v_pset_id;
        RETURN NULL;
    END IF;

    IF v_row.def IS NULL THEN
        RAISE EXCEPTION 'The set definition for pset_id=% is null.', v_pset_id;
        RETURN NULL;
    END IF;
    RAISE DEBUG '* % (pset_id=%)', v_row.name, v_row.pset_id;

	-- populate a temp table of the current set contents
    v_tmptblname := 'update_pset_' || v_pset_id || '_' || substr(md5(now()||random(),1,10));
    v_cmd := 'CREATE TEMP TABLE '||v_tmptblname||' AS SELECT DISTINCT pseq_id FROM ('||v_row.def||') X';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    GET DIAGNOSTICS v_nrows_tot = ROW_COUNT;
	RAISE DEBUG '% rows in temp table', v_nrows_tot;

    v_cmd := 'CREATE TEMP TABLE '||v_tmptblname||'_del AS SELECT pseq_id from pseqset where pset_id='||v_pset_id||' EXCEPT select pseq_id from '||v_tmptblname;
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    v_cmd := 'CREATE INDEX '||v_tmptblname||'_del_q_idx on '||v_tmptblname||'_del(pseq_id)';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    v_cmd := 'ANALYZE '||v_tmptblname||'_del';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
	
	-- delete obsolete seqs
    v_cmd:='DELETE FROM pseqset USING '||v_tmptblname||'_del D WHERE pset_id='||v_pset_id||' AND pseqset.pseq_id=D.pseq_id';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    GET DIAGNOSTICS v_nrows_del = ROW_COUNT;

	-- add new seqs
    v_cmd:='INSERT INTO pseqset (pset_id,pseq_id) SELECT '||v_row.pset_id||',pseq_id FROM (SELECT pseq_id FROM '||v_tmptblname||' EXCEPT SELECT pseq_id FROM pseqset WHERE pset_id='||v_pset_id||') X';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    GET DIAGNOSTICS v_nrows_ins = ROW_COUNT;

	-- drop the temp tables
    v_cmd:='DROP TABLE ' || v_tmptblname;
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;
    v_cmd:='DROP TABLE ' || v_tmptblname||'_del';
    RAISE DEBUG '%', v_cmd;
	EXECUTE v_cmd;

    SELECT INTO v_nrows_tot COUNT(*) FROM pseqset WHERE pset_id = v_pset_id;
    RAISE NOTICE '  % (pset_id=%): % sequences deleted, % sequences added, % total',
        v_row.name, v_row.pset_id, v_nrows_del, v_nrows_ins, v_nrows_tot;
    RETURN v_nrows_tot;
END
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.update_pset_orig(integer) OWNER TO unison;

--
-- Name: FUNCTION update_pset_orig(integer); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION update_pset_orig(integer) IS 'update pseqset for a specified pset_id using the definition in pset.def';


--
-- Name: update_psets_extrinsic(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION update_psets_extrinsic() RETURNS void
    AS $$
DECLARE
	v_row record;
	v_nseqs integer;
BEGIN
	FOR v_row IN SELECT pset_id,name FROM pset WHERE pset_id between 100 and 199 order by pset_id LOOP
		SELECT INTO v_nseqs update_pset( v_row.pset_id );
		RAISE NOTICE '% (pset_id=%): % sequences', v_row.name, v_row.pset_id, v_nseqs;
    END LOOP;
    RETURN;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.update_psets_extrinsic() OWNER TO unison;

--
-- Name: FUNCTION update_psets_extrinsic(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION update_psets_extrinsic() IS 'update pseqset for set definitions based on computed features';


--
-- Name: update_psets_intrinsic(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION update_psets_intrinsic() RETURNS void
    AS $$
DECLARE
	v_row record;
	v_nseqs integer;
BEGIN
	FOR v_row IN SELECT pset_id,name FROM pset WHERE pset_id between 1 and 99 order by pset_id LOOP
		SELECT INTO v_nseqs update_pset( v_row.pset_id );
		RAISE NOTICE '% (pset_id=%): % sequences', v_row.name, v_row.pset_id, v_nseqs;
    END LOOP;
    RETURN;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION unison.update_psets_intrinsic() OWNER TO unison;

--
-- Name: FUNCTION update_psets_intrinsic(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION update_psets_intrinsic() IS 'update pseqset for set definitions based on origin, alias, description, and tax_id';


--
-- Name: update_tax_ids(); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION update_tax_ids() RETURNS void
    AS $$update paliasorigin set tax_id=inferred_tax_id from _infer_tax_id_changed_v where paliasorigin.palias_id=_infer_tax_id_changed_v.palias_id;$$
    LANGUAGE sql;


ALTER FUNCTION unison.update_tax_ids() OWNER TO unison;

--
-- Name: FUNCTION update_tax_ids(); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON FUNCTION update_tax_ids() IS 'update paliasorigin.tax_id as necessary based on tax_ids inferred from origin, alias, and description';


--
-- Name: warn(text); Type: FUNCTION; Schema: unison; Owner: unison
--

CREATE FUNCTION warn(text) RETURNS void
    AS $_$
DECLARE
	msg text;
BEGIN
	msg:=$1;
	RAISE WARNING '%', msg;
	return;
END;$_$
    LANGUAGE plpgsql STRICT;


ALTER FUNCTION unison.warn(text) OWNER TO unison;

--
-- Name: array_accum(anyelement); Type: AGGREGATE; Schema: unison; Owner: unison
--

CREATE AGGREGATE array_accum(anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    INITCOND = '{}'
);


ALTER AGGREGATE unison.array_accum(anyelement) OWNER TO unison;

--
-- Name: defline_agg(anyelement); Type: AGGREGATE; Schema: unison; Owner: unison
--

CREATE AGGREGATE defline_agg(anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    INITCOND = '{}',
    FINALFUNC = _defline_agg_finalfunc
);


ALTER AGGREGATE unison.defline_agg(anyelement) OWNER TO unison;

--
-- Name: AGGREGATE defline_agg(anyelement); Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON AGGREGATE defline_agg(anyelement) IS 'Ctrl-A delimited deflines';


SET search_path = go, pg_catalog;

--
-- Name: association_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE association_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.association_id_seq OWNER TO unison;

--
-- Name: db_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE db_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.db_id_seq OWNER TO unison;

--
-- Name: dbxref_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE dbxref_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.dbxref_id_seq OWNER TO unison;

--
-- Name: evidence_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE evidence_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.evidence_id_seq OWNER TO unison;

--
-- Name: gene_product_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE gene_product_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.gene_product_id_seq OWNER TO unison;

--
-- Name: graph_path_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE graph_path_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.graph_path_id_seq OWNER TO unison;

--
-- Name: seq_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE seq_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.seq_id_seq OWNER TO unison;

--
-- Name: seq_property_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE seq_property_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.seq_property_id_seq OWNER TO unison;

--
-- Name: species_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE species_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.species_id_seq OWNER TO unison;

--
-- Name: term2term_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE term2term_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.term2term_id_seq OWNER TO unison;

--
-- Name: term_id_seq; Type: SEQUENCE; Schema: go; Owner: unison
--

CREATE SEQUENCE term_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE go.term_id_seq OWNER TO unison;

SET search_path = gong, pg_catalog;

--
-- Name: alias_alias_id_seq; Type: SEQUENCE; Schema: gong; Owner: unison
--

CREATE SEQUENCE alias_alias_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE gong.alias_alias_id_seq OWNER TO unison;

--
-- Name: alias_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: gong; Owner: unison
--

ALTER SEQUENCE alias_alias_id_seq OWNED BY alias.alias_id;


SET search_path = marray, pg_catalog;

--
-- Name: chip_chip_id_seq; Type: SEQUENCE; Schema: marray; Owner: unison
--

CREATE SEQUENCE chip_chip_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE marray.chip_chip_id_seq OWNER TO unison;

--
-- Name: chip_chip_id_seq; Type: SEQUENCE OWNED BY; Schema: marray; Owner: unison
--

ALTER SEQUENCE chip_chip_id_seq OWNED BY chip.chip_id;


SET search_path = pdb, pg_catalog;

--
-- Name: descriptor_origin_descriptor_origin_id_seq; Type: SEQUENCE; Schema: pdb; Owner: unison
--

CREATE SEQUENCE descriptor_origin_descriptor_origin_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    MINVALUE 0
    CACHE 1;


ALTER TABLE pdb.descriptor_origin_descriptor_origin_id_seq OWNER TO unison;

--
-- Name: descriptor_origin_descriptor_origin_id_seq; Type: SEQUENCE OWNED BY; Schema: pdb; Owner: unison
--

ALTER SEQUENCE descriptor_origin_descriptor_origin_id_seq OWNED BY descriptor_origin.descriptor_origin_id;


SET search_path = unison, pg_catalog;

--
-- Name: aliasset_aliasset_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE aliasset_aliasset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.aliasset_aliasset_id_seq OWNER TO unison;

--
-- Name: aliasset_aliasset_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE aliasset_aliasset_id_seq OWNED BY aliasset.aliasset_id;


--
-- Name: canned_views_cv_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE canned_views_cv_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.canned_views_cv_id_seq OWNER TO unison;

--
-- Name: canned_views_cv_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE canned_views_cv_id_seq OWNED BY canned_views.cv_id;


--
-- Name: genasm_genasm_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE genasm_genasm_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.genasm_genasm_id_seq OWNER TO unison;

--
-- Name: genasm_genasm_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE genasm_genasm_id_seq OWNED BY genasm.genasm_id;


--
-- Name: origin_origin_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE origin_origin_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.origin_origin_id_seq OWNER TO unison;

--
-- Name: origin_origin_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE origin_origin_id_seq OWNED BY origin.origin_id;


--
-- Name: p2gblataln_p2gblataln_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE p2gblataln_p2gblataln_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.p2gblataln_p2gblataln_id_seq OWNER TO unison;

--
-- Name: p2gblataln_p2gblataln_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE p2gblataln_p2gblataln_id_seq OWNED BY p2gblataln.p2gblataln_id;


--
-- Name: p2gblathsp_p2gblathsp_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE p2gblathsp_p2gblathsp_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.p2gblathsp_p2gblathsp_id_seq OWNER TO unison;

--
-- Name: p2gblathsp_p2gblathsp_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE p2gblathsp_p2gblathsp_id_seq OWNED BY p2gblathsp.p2gblathsp_id;


--
-- Name: paliasorigin_palias_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE paliasorigin_palias_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.paliasorigin_palias_id_seq OWNER TO unison;

--
-- Name: paliasorigin_palias_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE paliasorigin_palias_id_seq OWNED BY paliasorigin.palias_id;


--
-- Name: params_params_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE params_params_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.params_params_id_seq OWNER TO unison;

--
-- Name: params_params_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE params_params_id_seq OWNED BY params.params_id;


--
-- Name: pcluster_pcluster_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pcluster_pcluster_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pcluster_pcluster_id_seq OWNER TO unison;

--
-- Name: pcluster_pcluster_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pcluster_pcluster_id_seq OWNED BY pcluster.pcluster_id;


--
-- Name: perftest_def_def_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE perftest_def_def_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.perftest_def_def_id_seq OWNER TO unison;

--
-- Name: perftest_def_def_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE perftest_def_def_id_seq OWNED BY perftest_def.def_id;


--
-- Name: perftest_platform_platform_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE perftest_platform_platform_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.perftest_platform_platform_id_seq OWNER TO unison;

--
-- Name: perftest_platform_platform_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE perftest_platform_platform_id_seq OWNED BY perftest_platform.platform_id;


--
-- Name: perftest_run_run_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE perftest_run_run_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.perftest_run_run_id_seq OWNER TO unison;

--
-- Name: perftest_run_run_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE perftest_run_run_id_seq OWNED BY perftest_run.run_id;


--
-- Name: pftype_pftype_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pftype_pftype_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pftype_pftype_id_seq OWNER TO unison;

--
-- Name: pftype_pftype_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pftype_pftype_id_seq OWNED BY pftype.pftype_id;


--
-- Name: pmap_aln_aln_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pmap_aln_aln_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pmap_aln_aln_id_seq OWNER TO unison;

--
-- Name: pmap_aln_aln_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pmap_aln_aln_id_seq OWNED BY pmap_aln.aln_id;


--
-- Name: pmap_hsp_hsp_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pmap_hsp_hsp_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pmap_hsp_hsp_id_seq OWNER TO unison;

--
-- Name: pmap_hsp_hsp_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pmap_hsp_hsp_id_seq OWNED BY pmap_hsp.hsp_id;


--
-- Name: pmodelset_pmodelset_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pmodelset_pmodelset_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pmodelset_pmodelset_id_seq OWNER TO unison;

--
-- Name: pmodelset_pmodelset_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pmodelset_pmodelset_id_seq OWNED BY pmodelset.pmodelset_id;


--
-- Name: pseq_pseq_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pseq_pseq_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pseq_pseq_id_seq OWNER TO unison;

--
-- Name: pseq_pseq_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pseq_pseq_id_seq OWNED BY pseq.pseq_id;


--
-- Name: pset_pset_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE pset_pset_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.pset_pset_id_seq OWNER TO unison;

--
-- Name: pset_pset_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE pset_pset_id_seq OWNED BY pset.pset_id;


--
-- Name: psprotcomp_location_psloc_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE psprotcomp_location_psloc_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.psprotcomp_location_psloc_id_seq OWNER TO unison;

--
-- Name: psprotcomp_location_psloc_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE psprotcomp_location_psloc_id_seq OWNED BY psprotcomp_location.psloc_id;


--
-- Name: run_run_id_seq; Type: SEQUENCE; Schema: unison; Owner: unison
--

CREATE SEQUENCE run_run_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE unison.run_run_id_seq OWNER TO unison;

--
-- Name: run_run_id_seq; Type: SEQUENCE OWNED BY; Schema: unison; Owner: unison
--

ALTER SEQUENCE run_run_id_seq OWNED BY run.run_id;


SET search_path = gong, pg_catalog;

--
-- Name: alias_id; Type: DEFAULT; Schema: gong; Owner: unison
--

ALTER TABLE alias ALTER COLUMN alias_id SET DEFAULT nextval('alias_alias_id_seq'::regclass);


SET search_path = marray, pg_catalog;

--
-- Name: chip_id; Type: DEFAULT; Schema: marray; Owner: unison
--

ALTER TABLE chip ALTER COLUMN chip_id SET DEFAULT nextval('chip_chip_id_seq'::regclass);


SET search_path = pdb, pg_catalog;

--
-- Name: descriptor_origin_id; Type: DEFAULT; Schema: pdb; Owner: unison
--

ALTER TABLE descriptor_origin ALTER COLUMN descriptor_origin_id SET DEFAULT nextval('descriptor_origin_descriptor_origin_id_seq'::regclass);


SET search_path = unison, pg_catalog;

--
-- Name: aliasset_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE aliasset ALTER COLUMN aliasset_id SET DEFAULT nextval('aliasset_aliasset_id_seq'::regclass);


--
-- Name: cv_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE canned_views ALTER COLUMN cv_id SET DEFAULT nextval('canned_views_cv_id_seq'::regclass);


--
-- Name: genasm_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE genasm ALTER COLUMN genasm_id SET DEFAULT nextval('genasm_genasm_id_seq'::regclass);


--
-- Name: origin_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE origin ALTER COLUMN origin_id SET DEFAULT nextval('origin_origin_id_seq'::regclass);


--
-- Name: p2gblataln_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE p2gblataln ALTER COLUMN p2gblataln_id SET DEFAULT nextval('p2gblataln_p2gblataln_id_seq'::regclass);


--
-- Name: p2gblathsp_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE p2gblathsp ALTER COLUMN p2gblathsp_id SET DEFAULT nextval('p2gblathsp_p2gblathsp_id_seq'::regclass);


--
-- Name: palias_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE paliasorigin ALTER COLUMN palias_id SET DEFAULT nextval('paliasorigin_palias_id_seq'::regclass);


--
-- Name: params_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE params ALTER COLUMN params_id SET DEFAULT nextval('params_params_id_seq'::regclass);


--
-- Name: pcluster_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pcluster ALTER COLUMN pcluster_id SET DEFAULT nextval('pcluster_pcluster_id_seq'::regclass);


--
-- Name: def_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE perftest_def ALTER COLUMN def_id SET DEFAULT nextval('perftest_def_def_id_seq'::regclass);


--
-- Name: platform_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE perftest_platform ALTER COLUMN platform_id SET DEFAULT nextval('perftest_platform_platform_id_seq'::regclass);


--
-- Name: run_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE perftest_run ALTER COLUMN run_id SET DEFAULT nextval('perftest_run_run_id_seq'::regclass);


--
-- Name: pfeature_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pfeature ALTER COLUMN pfeature_id SET DEFAULT nextval('pfeature_pfeature_id_seq'::regclass);


--
-- Name: pftype_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pftype ALTER COLUMN pftype_id SET DEFAULT nextval('pftype_pftype_id_seq'::regclass);


--
-- Name: aln_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pmap_aln ALTER COLUMN aln_id SET DEFAULT nextval('pmap_aln_aln_id_seq'::regclass);


--
-- Name: hsp_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pmap_hsp ALTER COLUMN hsp_id SET DEFAULT nextval('pmap_hsp_hsp_id_seq'::regclass);


--
-- Name: pmodel_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pmodel ALTER COLUMN pmodel_id SET DEFAULT nextval('pmodel_pmodel_id_seq'::regclass);


--
-- Name: pmodelset_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pmodelset ALTER COLUMN pmodelset_id SET DEFAULT nextval('pmodelset_pmodelset_id_seq'::regclass);


--
-- Name: pseq_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pseq ALTER COLUMN pseq_id SET DEFAULT nextval('pseq_pseq_id_seq'::regclass);


--
-- Name: pset_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE pset ALTER COLUMN pset_id SET DEFAULT nextval('pset_pset_id_seq'::regclass);


--
-- Name: psloc_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE psprotcomp_location ALTER COLUMN psloc_id SET DEFAULT nextval('psprotcomp_location_psloc_id_seq'::regclass);


--
-- Name: run_id; Type: DEFAULT; Schema: unison; Owner: unison
--

ALTER TABLE run ALTER COLUMN run_id SET DEFAULT nextval('run_run_id_seq'::regclass);


SET search_path = go, pg_catalog;

--
-- Name: association_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY association
    ADD CONSTRAINT association_pkey PRIMARY KEY (id);


--
-- Name: db_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY db
    ADD CONSTRAINT db_pkey PRIMARY KEY (id);


--
-- Name: dbxref_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY dbxref
    ADD CONSTRAINT dbxref_pkey PRIMARY KEY (id);


--
-- Name: evidence_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY evidence
    ADD CONSTRAINT evidence_pkey PRIMARY KEY (id);


--
-- Name: gene_product_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY gene_product
    ADD CONSTRAINT gene_product_pkey PRIMARY KEY (id);


--
-- Name: gene_product_synonym_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY gene_product_synonym
    ADD CONSTRAINT gene_product_synonym_pkey PRIMARY KEY (gene_product_id, product_synonym);


--
-- Name: graph_path_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY graph_path
    ADD CONSTRAINT graph_path_pkey PRIMARY KEY (id);


--
-- Name: seq_dbxref_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY seq_dbxref
    ADD CONSTRAINT seq_dbxref_pkey PRIMARY KEY (seq_id, dbxref_id);


--
-- Name: seq_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY seq
    ADD CONSTRAINT seq_pkey PRIMARY KEY (id);


--
-- Name: seq_property_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY seq_property
    ADD CONSTRAINT seq_property_pkey PRIMARY KEY (id);


--
-- Name: species_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY species
    ADD CONSTRAINT species_pkey PRIMARY KEY (id);


--
-- Name: term2term_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY term2term
    ADD CONSTRAINT term2term_pkey PRIMARY KEY (id);


--
-- Name: term_audit_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY term_audit
    ADD CONSTRAINT term_audit_pkey PRIMARY KEY (term_id);


--
-- Name: term_dbxref_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY term_dbxref
    ADD CONSTRAINT term_dbxref_pkey PRIMARY KEY (term_id, dbxref_id, is_for_definition);


--
-- Name: term_definition_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY term_definition
    ADD CONSTRAINT term_definition_pkey PRIMARY KEY (term_id);


--
-- Name: term_pkey; Type: CONSTRAINT; Schema: go; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY term
    ADD CONSTRAINT term_pkey PRIMARY KEY (id);


SET search_path = gong, pg_catalog;

--
-- Name: alias_pkey; Type: CONSTRAINT; Schema: gong; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_pkey PRIMARY KEY (alias_id);


--
-- Name: evidence_code_pkey; Type: CONSTRAINT; Schema: gong; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY evidence_code
    ADD CONSTRAINT evidence_code_pkey PRIMARY KEY (evidence_code);


--
-- Name: node_pkey; Type: CONSTRAINT; Schema: gong; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY node
    ADD CONSTRAINT node_pkey PRIMARY KEY (go_id);


SET search_path = marray, pg_catalog;

--
-- Name: chip_id_pkey; Type: CONSTRAINT; Schema: marray; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY chip
    ADD CONSTRAINT chip_id_pkey PRIMARY KEY (chip_id);


--
-- Name: probe_pkey; Type: CONSTRAINT; Schema: marray; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY probe
    ADD CONSTRAINT probe_pkey PRIMARY KEY (probe_id, genasm_id);


SET search_path = ncbi, pg_catalog;

--
-- Name: homologene_pkey; Type: CONSTRAINT; Schema: ncbi; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY homologene
    ADD CONSTRAINT homologene_pkey PRIMARY KEY (acc);


SET search_path = pdb, pg_catalog;

--
-- Name: chain_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY chain
    ADD CONSTRAINT chain_pkey PRIMARY KEY (pdbc);


--
-- Name: descriptor_origin_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY descriptor_origin
    ADD CONSTRAINT descriptor_origin_pkey PRIMARY KEY (descriptor_origin_id);


--
-- Name: ligand_atoms_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY ligand_atoms
    ADD CONSTRAINT ligand_atoms_pkey PRIMARY KEY (atom_id, ligand_id);


--
-- Name: ligand_bonds_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY ligand_bonds
    ADD CONSTRAINT ligand_bonds_pkey PRIMARY KEY (atom_id_1, atom_id_2, ligand_id);


--
-- Name: ligand_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY ligand
    ADD CONSTRAINT ligand_pkey PRIMARY KEY (ligand_id);


--
-- Name: pdb_ligand_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pdb_ligand
    ADD CONSTRAINT pdb_ligand_pkey PRIMARY KEY (pdbid, ligand_id);


--
-- Name: residue_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY residue
    ADD CONSTRAINT residue_pkey PRIMARY KEY (pdbc, seq_pos);


--
-- Name: summary_pkey; Type: CONSTRAINT; Schema: pdb; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY summary
    ADD CONSTRAINT summary_pkey PRIMARY KEY (pdbid);


SET search_path = scop, pg_catalog;

--
-- Name: cla_pkey; Type: CONSTRAINT; Schema: scop; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY cla
    ADD CONSTRAINT cla_pkey PRIMARY KEY (sunid);


--
-- Name: des_pkey; Type: CONSTRAINT; Schema: scop; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY des
    ADD CONSTRAINT des_pkey PRIMARY KEY (sunid);


--
-- Name: hie_pkey; Type: CONSTRAINT; Schema: scop; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY hie
    ADD CONSTRAINT hie_pkey PRIMARY KEY (sunid);


--
-- Name: scop_cla_sid_unique; Type: CONSTRAINT; Schema: scop; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY cla
    ADD CONSTRAINT scop_cla_sid_unique UNIQUE (sid);


SET search_path = sst, pg_catalog;

--
-- Name: dna_pkey; Type: CONSTRAINT; Schema: sst; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY dna
    ADD CONSTRAINT dna_pkey PRIMARY KEY (dnaid);


--
-- Name: pro_pkey; Type: CONSTRAINT; Schema: sst; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pro
    ADD CONSTRAINT pro_pkey PRIMARY KEY (proid);


--
-- Name: unq_pkey; Type: CONSTRAINT; Schema: sst; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY unq
    ADD CONSTRAINT unq_pkey PRIMARY KEY (unqid);


SET search_path = tax, pg_catalog;

--
-- Name: spspec_pkey; Type: CONSTRAINT; Schema: tax; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY spspec
    ADD CONSTRAINT spspec_pkey PRIMARY KEY (tax_id);


SET search_path = taxonomy, pg_catalog;

--
-- Name: division_pkey; Type: CONSTRAINT; Schema: taxonomy; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY division
    ADD CONSTRAINT division_pkey PRIMARY KEY (division_id);


--
-- Name: node_pkey; Type: CONSTRAINT; Schema: taxonomy; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY node
    ADD CONSTRAINT node_pkey PRIMARY KEY (tax_id);


SET search_path = unison, pg_catalog;

--
-- Name: aliasset_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY aliasset
    ADD CONSTRAINT aliasset_pkey PRIMARY KEY (aliasset_id);


--
-- Name: canned_views_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY canned_views
    ADD CONSTRAINT canned_views_pkey PRIMARY KEY (cv_id);

ALTER TABLE canned_views CLUSTER ON canned_views_pkey;


--
-- Name: genasm_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY genasm
    ADD CONSTRAINT genasm_pkey PRIMARY KEY (genasm_id);

ALTER TABLE genasm CLUSTER ON genasm_pkey;


--
-- Name: meta_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY meta
    ADD CONSTRAINT meta_pkey PRIMARY KEY (key);

ALTER TABLE meta CLUSTER ON meta_pkey;


--
-- Name: one_result_per_def_platform; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY perftest_result
    ADD CONSTRAINT one_result_per_def_platform UNIQUE (def_id, run_id);


--
-- Name: origin_id_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY origin
    ADD CONSTRAINT origin_id_pkey PRIMARY KEY (origin_id);

ALTER TABLE origin CLUSTER ON origin_id_pkey;


--
-- Name: p2gblataln_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY p2gblataln
    ADD CONSTRAINT p2gblataln_pkey PRIMARY KEY (p2gblataln_id);


--
-- Name: p2gblathsp_id_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY p2gblathsp
    ADD CONSTRAINT p2gblathsp_id_pkey PRIMARY KEY (p2gblathsp_id);


--
-- Name: palias_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY paliasorigin
    ADD CONSTRAINT palias_pkey PRIMARY KEY (palias_id);


--
-- Name: paprospect_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY paprospect
    ADD CONSTRAINT paprospect_pkey PRIMARY KEY (params_id, pseq_id, pmodel_id, start, stop);

ALTER TABLE paprospect CLUSTER ON paprospect_pkey;


--
-- Name: params_params_id; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY params
    ADD CONSTRAINT params_params_id PRIMARY KEY (params_id);


--
-- Name: pcluster_id_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pcluster
    ADD CONSTRAINT pcluster_id_pkey PRIMARY KEY (pcluster_id);


--
-- Name: perftest_def_name_key; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY perftest_def
    ADD CONSTRAINT perftest_def_name_key UNIQUE (name);


--
-- Name: perftest_def_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY perftest_def
    ADD CONSTRAINT perftest_def_pkey PRIMARY KEY (def_id);


--
-- Name: perftest_platform_name_key; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY perftest_platform
    ADD CONSTRAINT perftest_platform_name_key UNIQUE (name);


--
-- Name: perftest_platform_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY perftest_platform
    ADD CONSTRAINT perftest_platform_pkey PRIMARY KEY (platform_id);


--
-- Name: perftest_run_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY perftest_run
    ADD CONSTRAINT perftest_run_pkey PRIMARY KEY (run_id);


--
-- Name: pfsignalphmm_pred_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pfsignalphmm_pred
    ADD CONSTRAINT pfsignalphmm_pred_pkey PRIMARY KEY (pfsignalphmm_pred_id);

ALTER TABLE pfsignalphmm_pred CLUSTER ON pfsignalphmm_pred_pkey;


--
-- Name: pftype_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pftype
    ADD CONSTRAINT pftype_pkey PRIMARY KEY (pftype_id);

ALTER TABLE pftype CLUSTER ON pftype_pkey;


--
-- Name: pmap_aln_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT pmap_aln_pkey PRIMARY KEY (aln_id);

ALTER TABLE pmap_aln CLUSTER ON pmap_aln_pkey;


--
-- Name: pmap_hsp_id_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT pmap_hsp_id_pkey PRIMARY KEY (hsp_id);


--
-- Name: pmodel_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pmodel
    ADD CONSTRAINT pmodel_pkey PRIMARY KEY (pmodel_id);


--
-- Name: pmodelset_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pmodelset
    ADD CONSTRAINT pmodelset_pkey PRIMARY KEY (pmodelset_id);

ALTER TABLE pmodelset CLUSTER ON pmodelset_pkey;


--
-- Name: pmprospect_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pmprospect
    ADD CONSTRAINT pmprospect_pkey PRIMARY KEY (pmodel_id);

ALTER TABLE pmprospect CLUSTER ON pmprospect_pkey;


--
-- Name: pseq_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pseq
    ADD CONSTRAINT pseq_pkey PRIMARY KEY (pseq_id);

ALTER TABLE pseq CLUSTER ON pseq_pkey;


--
-- Name: pset_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY pset
    ADD CONSTRAINT pset_pkey PRIMARY KEY (pset_id);

ALTER TABLE pset CLUSTER ON pset_pkey;


--
-- Name: psipred_pseq_params_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY psipred
    ADD CONSTRAINT psipred_pseq_params_pkey PRIMARY KEY (pseq_id, params_id);

ALTER TABLE psipred CLUSTER ON psipred_pseq_params_pkey;


--
-- Name: psprotcomp_location_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY psprotcomp_location
    ADD CONSTRAINT psprotcomp_location_pkey PRIMARY KEY (psloc_id);

ALTER TABLE psprotcomp_location CLUSTER ON psprotcomp_location_pkey;


--
-- Name: psprotcomp_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY psprotcomp
    ADD CONSTRAINT psprotcomp_pkey PRIMARY KEY (params_id, pseq_id);

ALTER TABLE psprotcomp CLUSTER ON psprotcomp_pkey;


--
-- Name: run_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_pkey PRIMARY KEY (run_id);

ALTER TABLE run CLUSTER ON run_pkey;


--
-- Name: sp_snp_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY sp_var
    ADD CONSTRAINT sp_snp_pkey PRIMARY KEY (sp_id, start_pos, original_aa, variant_aa);

ALTER TABLE sp_var CLUSTER ON sp_snp_pkey;


--
-- Name: userprefs_pkey; Type: CONSTRAINT; Schema: unison; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY userprefs
    ADD CONSTRAINT userprefs_pkey PRIMARY KEY (usesysid);

ALTER TABLE userprefs CLUSTER ON userprefs_pkey;


SET search_path = unison_aux, pg_catalog;

--
-- Name: cytoband_pkey; Type: CONSTRAINT; Schema: unison_aux; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY cytoband_hg18
    ADD CONSTRAINT cytoband_pkey PRIMARY KEY (chr, gstart);


--
-- Name: hugo_pkey; Type: CONSTRAINT; Schema: unison_aux; Owner: unison; Tablespace: 
--

ALTER TABLE ONLY hugo
    ADD CONSTRAINT hugo_pkey PRIMARY KEY (hgnc_id);


SET search_path = go, pg_catalog;

--
-- Name: a0_association_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX a0_association_index_idx ON association USING btree (id);


--
-- Name: a1_association_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX a1_association_index_idx ON association USING btree (term_id);


--
-- Name: a2_association_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX a2_association_index_idx ON association USING btree (gene_product_id);


--
-- Name: a3_association_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX a3_association_index_idx ON association USING btree (term_id, gene_product_id);


--
-- Name: a4_association_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX a4_association_index_idx ON association USING btree (id, term_id, gene_product_id);


--
-- Name: acc_term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX acc_term_index_idx ON term USING btree (acc);


--
-- Name: association_id_evidence_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX association_id_evidence_index_idx ON evidence USING btree (association_id, dbxref_id, code, seq_acc);


--
-- Name: db0_db_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX db0_db_index_idx ON db USING btree (id);


--
-- Name: db1_db_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX db1_db_index_idx ON db USING btree (name);


--
-- Name: db2_db_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX db2_db_index_idx ON db USING btree (fullname);


--
-- Name: db3_db_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX db3_db_index_idx ON db USING btree (datatype);


--
-- Name: display_id_seq_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX display_id_seq_index_idx ON seq USING btree (display_id, md5checksum);


--
-- Name: dx0_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX dx0_dbxref_index_idx ON dbxref USING btree (id);


--
-- Name: dx1_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX dx1_dbxref_index_idx ON dbxref USING btree (xref_dbname);


--
-- Name: dx2_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX dx2_dbxref_index_idx ON dbxref USING btree (xref_key);


--
-- Name: dx3_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX dx3_dbxref_index_idx ON dbxref USING btree (id, xref_dbname);


--
-- Name: dx4_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX dx4_dbxref_index_idx ON dbxref USING btree (id, xref_key, xref_dbname);


--
-- Name: ev0_evidence_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX ev0_evidence_index_idx ON evidence USING btree (id);


--
-- Name: ev1_evidence_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ev1_evidence_index_idx ON evidence USING btree (association_id);


--
-- Name: ev2_evidence_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ev2_evidence_index_idx ON evidence USING btree (code);


--
-- Name: ev3_evidence_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ev3_evidence_index_idx ON evidence USING btree (dbxref_id);


--
-- Name: ev4_evidence_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ev4_evidence_index_idx ON evidence USING btree (association_id, code);


--
-- Name: evx1_evidence_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX evx1_evidence_dbxref_index_idx ON evidence_dbxref USING btree (evidence_id);


--
-- Name: evx2_evidence_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX evx2_evidence_dbxref_index_idx ON evidence_dbxref USING btree (dbxref_id);


--
-- Name: evx3_evidence_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX evx3_evidence_dbxref_index_idx ON evidence_dbxref USING btree (evidence_id, dbxref_id);


--
-- Name: fa1_source_audit_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX fa1_source_audit_index_idx ON source_audit USING btree (source_path);


--
-- Name: g0_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX g0_gene_product_index_idx ON gene_product USING btree (id);


--
-- Name: g1_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX g1_gene_product_index_idx ON gene_product USING btree (symbol);


--
-- Name: g2_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX g2_gene_product_index_idx ON gene_product USING btree (dbxref_id);


--
-- Name: g3_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX g3_gene_product_index_idx ON gene_product USING btree (species_id);


--
-- Name: g4_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX g4_gene_product_index_idx ON gene_product USING btree (id, species_id);


--
-- Name: g5_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX g5_gene_product_index_idx ON gene_product USING btree (dbxref_id, species_id);


--
-- Name: g6_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX g6_gene_product_index_idx ON gene_product USING btree (id, dbxref_id);


--
-- Name: gpc1_gene_product_count_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpc1_gene_product_count_index_idx ON gene_product_count USING btree (term_id);


--
-- Name: gpc2_gene_product_count_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpc2_gene_product_count_index_idx ON gene_product_count USING btree (code);


--
-- Name: gpc3_gene_product_count_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpc3_gene_product_count_index_idx ON gene_product_count USING btree (speciesdbname);


--
-- Name: gpc4_gene_product_count_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpc4_gene_product_count_index_idx ON gene_product_count USING btree (term_id, code, speciesdbname);


--
-- Name: gpp1_gene_product_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpp1_gene_product_property_index_idx ON gene_product_property USING btree (gene_product_id);


--
-- Name: gpp2_gene_product_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpp2_gene_product_property_index_idx ON gene_product_property USING btree (property_key);


--
-- Name: gpp3_gene_product_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpp3_gene_product_property_index_idx ON gene_product_property USING btree (property_val);


--
-- Name: gppu4_gene_product_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX gppu4_gene_product_property_index_idx ON gene_product_property USING btree (gene_product_id, property_key, property_val);


--
-- Name: gpseq1_gene_product_seq_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpseq1_gene_product_seq_index_idx ON gene_product_seq USING btree (gene_product_id);


--
-- Name: gpseq2_gene_product_seq_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpseq2_gene_product_seq_index_idx ON gene_product_seq USING btree (seq_id);


--
-- Name: gpseq3_gene_product_seq_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gpseq3_gene_product_seq_index_idx ON gene_product_seq USING btree (seq_id, gene_product_id);


--
-- Name: graph_path0_graph_path_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX graph_path0_graph_path_index_idx ON graph_path USING btree (id);


--
-- Name: graph_path1_graph_path_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX graph_path1_graph_path_index_idx ON graph_path USING btree (term1_id);


--
-- Name: graph_path2_graph_path_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX graph_path2_graph_path_index_idx ON graph_path USING btree (term2_id);


--
-- Name: graph_path3_graph_path_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX graph_path3_graph_path_index_idx ON graph_path USING btree (term1_id, term2_id);


--
-- Name: graph_path4_graph_path_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX graph_path4_graph_path_index_idx ON graph_path USING btree (term1_id, distance);


--
-- Name: gs1_gene_product_synonym_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gs1_gene_product_synonym_index_idx ON gene_product_synonym USING btree (gene_product_id);


--
-- Name: gs2_gene_product_synonym_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX gs2_gene_product_synonym_index_idx ON gene_product_synonym USING btree (product_synonym);


--
-- Name: release_name_instance_data_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX release_name_instance_data_index_idx ON instance_data USING btree (release_name);


--
-- Name: seq0_seq_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX seq0_seq_index_idx ON seq USING btree (id);


--
-- Name: seq1_seq_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seq1_seq_index_idx ON seq USING btree (display_id);


--
-- Name: seq2_seq_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seq2_seq_index_idx ON seq USING btree (md5checksum);


--
-- Name: seq_id_seq_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX seq_id_seq_property_index_idx ON seq_property USING btree (seq_id, property_key, property_val);


--
-- Name: seqp0_seq_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seqp0_seq_property_index_idx ON seq_property USING btree (seq_id);


--
-- Name: seqp1_seq_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seqp1_seq_property_index_idx ON seq_property USING btree (property_key);


--
-- Name: seqp2_seq_property_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seqp2_seq_property_index_idx ON seq_property USING btree (property_val);


--
-- Name: seqx0_seq_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seqx0_seq_dbxref_index_idx ON seq_dbxref USING btree (seq_id);


--
-- Name: seqx1_seq_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seqx1_seq_dbxref_index_idx ON seq_dbxref USING btree (dbxref_id);


--
-- Name: seqx2_seq_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX seqx2_seq_dbxref_index_idx ON seq_dbxref USING btree (seq_id, dbxref_id);


--
-- Name: sp0_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX sp0_species_index_idx ON species USING btree (id);


--
-- Name: sp1_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX sp1_species_index_idx ON species USING btree (ncbi_taxa_id);


--
-- Name: sp2_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX sp2_species_index_idx ON species USING btree (common_name);


--
-- Name: sp3_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX sp3_species_index_idx ON species USING btree (genus);


--
-- Name: sp4_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX sp4_species_index_idx ON species USING btree (species);


--
-- Name: sp5_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX sp5_species_index_idx ON species USING btree (genus, species);


--
-- Name: sp6_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX sp6_species_index_idx ON species USING btree (id, ncbi_taxa_id);


--
-- Name: sp7_species_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX sp7_species_index_idx ON species USING btree (id, ncbi_taxa_id, genus, species);


--
-- Name: symbol_gene_product_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX symbol_gene_product_index_idx ON gene_product USING btree (symbol, dbxref_id);


--
-- Name: t0_term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX t0_term_index_idx ON term USING btree (id);


--
-- Name: t1_term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX t1_term_index_idx ON term USING btree (name);


--
-- Name: t2_term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX t2_term_index_idx ON term USING btree (term_type);


--
-- Name: t3_term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX t3_term_index_idx ON term USING btree (acc);


--
-- Name: ta1_term_audit_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ta1_term_audit_index_idx ON term_audit USING btree (term_id);


--
-- Name: td1_term_definition_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX td1_term_definition_index_idx ON term_definition USING btree (term_id);


--
-- Name: term1_id_term2term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX term1_id_term2term_index_idx ON term2term USING btree (term1_id, term2_id, relationship_type_id);


--
-- Name: term_id_term_synonym_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX term_id_term_synonym_index_idx ON term_synonym USING btree (term_id, term_synonym);


--
-- Name: ts1_term_synonym_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ts1_term_synonym_index_idx ON term_synonym USING btree (term_id);


--
-- Name: ts2_term_synonym_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ts2_term_synonym_index_idx ON term_synonym USING btree (term_synonym);


--
-- Name: ts3_term_synonym_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX ts3_term_synonym_index_idx ON term_synonym USING btree (term_id, term_synonym);


--
-- Name: tt1_term2term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX tt1_term2term_index_idx ON term2term USING btree (term1_id);


--
-- Name: tt2_term2term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX tt2_term2term_index_idx ON term2term USING btree (term2_id);


--
-- Name: tt3_term2term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX tt3_term2term_index_idx ON term2term USING btree (term1_id, term2_id);


--
-- Name: tt4_term2term_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX tt4_term2term_index_idx ON term2term USING btree (relationship_type_id);


--
-- Name: tx0_term_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX tx0_term_dbxref_index_idx ON term_dbxref USING btree (term_id);


--
-- Name: tx1_term_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX tx1_term_dbxref_index_idx ON term_dbxref USING btree (dbxref_id);


--
-- Name: tx2_term_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE INDEX tx2_term_dbxref_index_idx ON term_dbxref USING btree (term_id, dbxref_id);


--
-- Name: xref_key_dbxref_index_idx; Type: INDEX; Schema: go; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX xref_key_dbxref_index_idx ON dbxref USING btree (xref_key, xref_dbname);


SET search_path = gong, pg_catalog;

--
-- Name: alias_alias_idx; Type: INDEX; Schema: gong; Owner: unison; Tablespace: 
--

CREATE INDEX alias_alias_idx ON alias USING btree (upper(alias));


--
-- Name: is_a_go_id2_idx; Type: INDEX; Schema: gong; Owner: unison; Tablespace: 
--

CREATE INDEX is_a_go_id2_idx ON is_a USING btree (go_id2);


--
-- Name: is_a_nonredundant_idx; Type: INDEX; Schema: gong; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX is_a_nonredundant_idx ON is_a USING btree (go_id1, go_id2);


--
-- Name: part_of_go_id2_idx; Type: INDEX; Schema: gong; Owner: unison; Tablespace: 
--

CREATE INDEX part_of_go_id2_idx ON part_of USING btree (go_id2);


--
-- Name: part_of_nonredundant_idx; Type: INDEX; Schema: gong; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX part_of_nonredundant_idx ON part_of USING btree (go_id1, go_id2);


SET search_path = marray, pg_catalog;

--
-- Name: chip_unq_idx; Type: INDEX; Schema: marray; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX chip_unq_idx ON chip USING btree (name);


--
-- Name: probe_g_lookup_idx; Type: INDEX; Schema: marray; Owner: unison; Tablespace: 
--

CREATE INDEX probe_g_lookup_idx ON probe USING btree (genasm_id, chip_id, origin_id, chr, strand, gstart, gstop);


--
-- Name: probe_unq_idx; Type: INDEX; Schema: marray; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX probe_unq_idx ON probe USING btree (genasm_id, chip_id, origin_id, chr, strand, gstart, gstop, probe_id);


SET search_path = ncbi, pg_catalog;

--
-- Name: gene2accession_gen_acc; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2accession_gen_acc ON gene2accession USING btree (gen_acc);


--
-- Name: gene2accession_gene_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2accession_gene_id ON gene2accession USING btree (gene_id);


--
-- Name: gene2accession_pro_acc; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2accession_pro_acc ON gene2accession USING btree (pro_acc);


--
-- Name: gene2accession_rna_acc; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2accession_rna_acc ON gene2accession USING btree (rna_acc);


--
-- Name: gene2go_gene_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2go_gene_id ON gene2go USING btree (gene_id);


--
-- Name: gene2go_go_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2go_go_id ON gene2go USING btree (go_id);


--
-- Name: gene2unigene_gene_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2unigene_gene_id ON gene2unigene USING btree (gene_id);


--
-- Name: gene2unigene_unigene_acc; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene2unigene_unigene_acc ON gene2unigene USING btree (unigene_acc);


--
-- Name: gene_info_gene_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX gene_info_gene_id ON gene_info USING btree (gene_id);


--
-- Name: generif_gene_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX generif_gene_id ON generif USING btree (gene_id);


--
-- Name: homologene_acc_hid_idx; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX homologene_acc_hid_idx ON homologene USING btree (acc, hid);


--
-- Name: homologene_gene_id_idx; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX homologene_gene_id_idx ON homologene USING btree (gene_id);


--
-- Name: homologene_hid_acc_idx; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX homologene_hid_acc_idx ON homologene USING btree (hid, acc);


--
-- Name: mim2gene_gene_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX mim2gene_gene_id ON mim2gene USING btree (gene_id);


--
-- Name: mim2gene_mim_id; Type: INDEX; Schema: ncbi; Owner: unison; Tablespace: 
--

CREATE INDEX mim2gene_mim_id ON mim2gene USING btree (mim_id);


SET search_path = pdb, pg_catalog;

--
-- Name: chain_pdbid_idx; Type: INDEX; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE INDEX chain_pdbid_idx ON chain USING btree (pdbid);


--
-- Name: descriptor_origin_tov_idx; Type: INDEX; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX descriptor_origin_tov_idx ON descriptor_origin USING btree (type, origin, version);


--
-- Name: ligand_descriptor_ld_origin_id; Type: INDEX; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX ligand_descriptor_ld_origin_id ON ligand_descriptors USING btree (ligand_id, descriptor_origin_id) WHERE (descriptor_origin_id <> descriptor_origin_id('synonym'::text, 'PDB'::text, NULL::text));


--
-- Name: residue_res_seq_idx; Type: INDEX; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX residue_res_seq_idx ON residue USING btree (pdbc, res_id, seq_pos);


--
-- Name: residue_seq_res_idx; Type: INDEX; Schema: pdb; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX residue_seq_res_idx ON residue USING btree (pdbc, seq_pos, res_id);


SET search_path = scop, pg_catalog;

--
-- Name: cla_pdb_idx; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX cla_pdb_idx ON cla USING btree (pdb);


--
-- Name: cla_sccs_idx; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX cla_sccs_idx ON cla USING btree (sccs);


--
-- Name: cla_sid_idx; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX cla_sid_idx ON cla USING btree (sid);


--
-- Name: dom_pdb; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX dom_pdb ON dom USING btree (pdb);


--
-- Name: dom_sid; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX dom_sid ON dom USING btree (sid);


--
-- Name: hie_psunid_idx; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX hie_psunid_idx ON hie USING btree (psunid);


--
-- Name: pdb_idx; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX pdb_idx ON cla USING btree (pdb);


--
-- Name: sccs_idx; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX sccs_idx ON cla USING btree (sccs);


--
-- Name: sid_idx; Type: INDEX; Schema: scop; Owner: unison; Tablespace: 
--

CREATE INDEX sid_idx ON cla USING btree (sid);


SET search_path = sst, pg_catalog;

--
-- Name: spdi_list_proid_idx; Type: INDEX; Schema: sst; Owner: unison; Tablespace: 
--

CREATE INDEX spdi_list_proid_idx ON spdi_list USING btree (proid);


--
-- Name: unqfamily_f_idx; Type: INDEX; Schema: sst; Owner: unison; Tablespace: 
--

CREATE INDEX unqfamily_f_idx ON unqfamily USING btree (famid);


--
-- Name: unqfamily_u_idx; Type: INDEX; Schema: sst; Owner: unison; Tablespace: 
--

CREATE INDEX unqfamily_u_idx ON unqfamily USING btree (unqid);


--
-- Name: v_trans_dna_pseq_idx; Type: INDEX; Schema: sst; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX v_trans_dna_pseq_idx ON v_trans USING btree (dnaid, pseq_id);


--
-- Name: v_trans_pseq_idx; Type: INDEX; Schema: sst; Owner: unison; Tablespace: 
--

CREATE INDEX v_trans_pseq_idx ON v_trans USING btree (pseq_id);


--
-- Name: v_unq2dna_dna_unq_idx; Type: INDEX; Schema: sst; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX v_unq2dna_dna_unq_idx ON v_unq2dna USING btree (dnaid, proid, unqid);


SET search_path = tax, pg_catalog;

--
-- Name: spspec_common_idx; Type: INDEX; Schema: tax; Owner: unison; Tablespace: 
--

CREATE INDEX spspec_common_idx ON spspec USING btree (upper(common));


--
-- Name: spspec_gs_idx; Type: INDEX; Schema: tax; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX spspec_gs_idx ON spspec USING btree (upper(gs));


--
-- Name: spspec_k_idx; Type: INDEX; Schema: tax; Owner: unison; Tablespace: 
--

CREATE INDEX spspec_k_idx ON spspec USING btree (k);


--
-- Name: spspec_latin_idx; Type: INDEX; Schema: tax; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX spspec_latin_idx ON spspec USING btree (upper(latin));


SET search_path = taxonomy, pg_catalog;

--
-- Name: name_name_idx; Type: INDEX; Schema: taxonomy; Owner: unison; Tablespace: 
--

CREATE INDEX name_name_idx ON name USING btree (name);


--
-- Name: name_tax_id_idx; Type: INDEX; Schema: taxonomy; Owner: unison; Tablespace: 
--

CREATE INDEX name_tax_id_idx ON name USING btree (tax_id);


--
-- Name: name_uname_idx; Type: INDEX; Schema: taxonomy; Owner: unison; Tablespace: 
--

CREATE INDEX name_uname_idx ON name USING btree (uname);


--
-- Name: node_parent_tax_id_idx; Type: INDEX; Schema: taxonomy; Owner: unison; Tablespace: 
--

CREATE INDEX node_parent_tax_id_idx ON node USING btree (parent_tax_id);


SET search_path = unison, pg_catalog;

--
-- Name: best_annotation_mv_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX best_annotation_mv_pseq_id_idx ON best_annotation_mv USING btree (pseq_id);

ALTER TABLE best_annotation_mv CLUSTER ON best_annotation_mv_pseq_id_idx;


--
-- Name: ensembl_unambiguous_coordinates_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX ensembl_unambiguous_coordinates_search1_idx ON ensembl_unambiguous_coordinates_mv USING btree (genome, chr, strand, gstart, gstop);

ALTER TABLE ensembl_unambiguous_coordinates_mv CLUSTER ON ensembl_unambiguous_coordinates_search1_idx;


--
-- Name: ensembl_unambiguous_overlaps_mv_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX ensembl_unambiguous_overlaps_mv_search1_idx ON ensembl_unambiguous_overlaps_mv USING btree (q_pseq_id, t_pseq_id);

ALTER TABLE ensembl_unambiguous_overlaps_mv CLUSTER ON ensembl_unambiguous_overlaps_mv_search1_idx;


--
-- Name: gg_famid_pseq_id_fq_mv_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX gg_famid_pseq_id_fq_mv_idx ON gg_famid_pseq_id_mv USING btree (famid, pseq_id);

ALTER TABLE gg_famid_pseq_id_mv CLUSTER ON gg_famid_pseq_id_fq_mv_idx;


--
-- Name: gg_famid_pseq_id_qf_mv_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX gg_famid_pseq_id_qf_mv_idx ON gg_famid_pseq_id_mv USING btree (pseq_id, famid);


--
-- Name: known_bcl2_overlaps_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX known_bcl2_overlaps_search1_idx ON known_bcl2_overlaps_mv USING btree (t_pseq_id);


--
-- Name: known_bcl2_overlaps_search2_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX known_bcl2_overlaps_search2_idx ON known_bcl2_overlaps_mv USING btree (q_pseq_id);


--
-- Name: mint_sprot_a_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX mint_sprot_a_idx ON mint USING btree (sprot_a);

ALTER TABLE mint CLUSTER ON mint_sprot_a_idx;


--
-- Name: mint_sprot_b_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX mint_sprot_b_idx ON mint USING btree (sprot_b);


--
-- Name: ncbi_pseq_mv_gen_gi; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX ncbi_pseq_mv_gen_gi ON ncbi_pseq_mv USING btree (gen_gi);


--
-- Name: ncbi_pseq_mv_gene_id; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX ncbi_pseq_mv_gene_id ON ncbi_pseq_mv USING btree (gene_id);


--
-- Name: ncbi_pseq_mv_pro_gi; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX ncbi_pseq_mv_pro_gi ON ncbi_pseq_mv USING btree (pro_gi);


--
-- Name: ncbi_pseq_mv_q; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX ncbi_pseq_mv_q ON ncbi_pseq_mv USING btree (pseq_id);


--
-- Name: origin_origin_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX origin_origin_idx ON origin USING btree (upper(origin));


--
-- Name: p2gblatalnhsp_hsp_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX p2gblatalnhsp_hsp_id_idx ON p2gblatalnhsp USING btree (p2gblathsp_id);


--
-- Name: p2gblatalnhsp_unq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX p2gblatalnhsp_unq_idx ON p2gblatalnhsp USING btree (p2gblataln_id, p2gblathsp_id);


--
-- Name: p2gblathsp_g_lookup_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX p2gblathsp_g_lookup_idx ON p2gblathsp USING btree (genasm_id, chr, gstart, gstop);


--
-- Name: p2gblathsp_p_lookup_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX p2gblathsp_p_lookup_idx ON p2gblathsp USING btree (pseq_id, pstart, pstop);


--
-- Name: p2gblathsp_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX p2gblathsp_pseq_id_idx ON p2gblathsp USING btree (pseq_id);


--
-- Name: p2gblathsp_unq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX p2gblathsp_unq_idx ON p2gblathsp USING btree (genasm_id, chr, plus_strand, gstart, gstop, pseq_id, pstart, pstop);


--
-- Name: pahmm_mining1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pahmm_mining1_idx ON pahmm USING btree (params_id, pmodel_id, eval);


--
-- Name: pahmm_mining2_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pahmm_mining2_idx ON pahmm USING btree (params_id, pmodel_id, score);


--
-- Name: pahmm_params_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pahmm_params_idx ON pahmm USING btree (params_id);


--
-- Name: pahmm_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pahmm_pmodel_id_idx ON pahmm USING btree (pmodel_id);


--
-- Name: pahmm_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pahmm_pseq_id_idx ON pahmm USING btree (pseq_id);


--
-- Name: pahmm_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pahmm_redundant_feature_idx ON pahmm USING btree (params_id, pseq_id, pmodel_id, start, stop, mstart, mstop);

ALTER TABLE pahmm CLUSTER ON pahmm_redundant_feature_idx;


--
-- Name: paliasorigin_alias_casefold_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paliasorigin_alias_casefold_idx ON paliasorigin USING btree (upper(alias));

ALTER TABLE paliasorigin CLUSTER ON paliasorigin_alias_casefold_idx;


--
-- Name: paliasorigin_alias_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paliasorigin_alias_idx ON paliasorigin USING btree (alias);


--
-- Name: paliasorigin_alias_unique_in_origin_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX paliasorigin_alias_unique_in_origin_idx ON paliasorigin USING btree (origin_id, alias);


--
-- Name: paliasorigin_o_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paliasorigin_o_idx ON paliasorigin USING btree (origin_id);


--
-- Name: paliasorigin_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paliasorigin_search1_idx ON paliasorigin USING btree (palias_id, origin_id);


--
-- Name: paliasorigin_search3_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paliasorigin_search3_idx ON paliasorigin USING btree (origin_id, tax_id, palias_id);


--
-- Name: paliasorigin_tax_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paliasorigin_tax_id_idx ON paliasorigin USING btree (tax_id);


--
-- Name: palignment_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX palignment_pseq_id_idx ON palignment USING btree (pseq_id);

ALTER TABLE palignment CLUSTER ON palignment_pseq_id_idx;


--
-- Name: paprospect_mining1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paprospect_mining1_idx ON paprospect USING btree (pmodel_id, params_id, svm);


--
-- Name: paprospect_mining2_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paprospect_mining2_idx ON paprospect USING btree (pmodel_id, params_id, raw);


--
-- Name: paprospect_pseq_id_params_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX paprospect_pseq_id_params_id_idx ON paprospect USING btree (pseq_id, params_id);


--
-- Name: papseq_eval_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_eval_idx ON papseq USING btree (eval);


--
-- Name: papseq_gaps_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_gaps_idx ON papseq USING btree (gaps);


--
-- Name: papseq_ident_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_ident_idx ON papseq USING btree (ident);


--
-- Name: papseq_len_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_len_idx ON papseq USING btree (len);


--
-- Name: papseq_pct_coverage_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pct_coverage_idx ON papseq USING btree (pct_coverage);


--
-- Name: papseq_pct_hsp_coverage_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pct_hsp_coverage_idx ON papseq USING btree (pct_hsp_coverage);


--
-- Name: papseq_pct_ident_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pct_ident_idx ON papseq USING btree (pct_ident);


--
-- Name: papseq_pdbcs_mv_eval; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pdbcs_mv_eval ON papseq_pdbcs_mv USING btree (eval);


--
-- Name: papseq_pdbcs_mv_pct_cov; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pdbcs_mv_pct_cov ON papseq_pdbcs_mv USING btree (pct_coverage);


--
-- Name: papseq_pdbcs_mv_pct_ident; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pdbcs_mv_pct_ident ON papseq_pdbcs_mv USING btree (pct_ident);


--
-- Name: papseq_pdbcs_mv_qq; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pdbcs_mv_qq ON papseq_pdbcs_mv USING btree (q_pseq_id);


--
-- Name: papseq_pdbcs_mv_tq; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pdbcs_mv_tq ON papseq_pdbcs_mv USING btree (t_pseq_id);


--
-- Name: papseq_pdbcs_pdbc; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pdbcs_pdbc ON papseq_pdbcs_mv USING btree (pdbc);


--
-- Name: papseq_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_pmodel_id_idx ON papseq USING btree (pmodel_id);


--
-- Name: papseq_qss_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_qss_idx ON papseq USING btree (pseq_id, start, stop);


--
-- Name: papseq_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX papseq_redundant_feature_idx ON papseq USING btree (params_id, pseq_id, pmodel_id, start, stop, mstart, mstop);

ALTER TABLE papseq CLUSTER ON papseq_redundant_feature_idx;


--
-- Name: papseq_score_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_score_idx ON papseq USING btree (score);


--
-- Name: papseq_sim_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papseq_sim_idx ON papseq USING btree (sim);


--
-- Name: papssm_eval_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_eval_idx ON papssm USING btree (eval);


--
-- Name: papssm_gap_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_gap_idx ON papssm USING btree (gaps);


--
-- Name: papssm_ident_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_ident_idx ON papssm USING btree (ident);


--
-- Name: papssm_len_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_len_idx ON papssm USING btree (len);


--
-- Name: papssm_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_pmodel_id_idx ON papssm USING btree (pmodel_id);


--
-- Name: papssm_qss_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_qss_idx ON papssm USING btree (pseq_id, start, stop);


--
-- Name: papssm_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX papssm_redundant_feature_idx ON papssm USING btree (params_id, pseq_id, pmodel_id, start, stop, mstart, mstop);

ALTER TABLE papssm CLUSTER ON papssm_redundant_feature_idx;


--
-- Name: papssm_score_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_score_idx ON papssm USING btree (score);


--
-- Name: papssm_sim_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX papssm_sim_idx ON papssm USING btree (sim);


--
-- Name: params_name_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX params_name_idx ON params USING btree (name);


--
-- Name: params_pkey_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX params_pkey_idx ON params USING btree (params_id);

ALTER TABLE params CLUSTER ON params_pkey_idx;


--
-- Name: pcluster_member_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pcluster_member_pseq_id_idx ON pcluster_member USING btree (pseq_id);


--
-- Name: pcluster_member_unq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pcluster_member_unq_idx ON pcluster_member USING btree (pcluster_id, pseq_id, gstart, gstop);

ALTER TABLE pcluster_member CLUSTER ON pcluster_member_unq_idx;


--
-- Name: pcluster_uniq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pcluster_uniq_idx ON pcluster USING btree (genasm_id, gstart, gstop, chr, plus_strand);

ALTER TABLE pcluster CLUSTER ON pcluster_uniq_idx;


--
-- Name: pfantigenic_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfantigenic_pseq_id_idx ON pfantigenic USING btree (pseq_id);


--
-- Name: pfantigenic_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfantigenic_redundant_feature_idx ON pfantigenic USING btree (params_id, pseq_id, start, stop);

ALTER TABLE pfantigenic CLUSTER ON pfantigenic_redundant_feature_idx;


--
-- Name: pfantigenic_score_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfantigenic_score_idx ON pfantigenic USING btree (score);


--
-- Name: pfbigpi_gpi_proteins_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfbigpi_gpi_proteins_idx ON pfbigpi USING btree (pseq_id) WHERE ((((quality = 'A'::bpchar) OR (quality = 'B'::bpchar)) OR (quality = 'C'::bpchar)) OR (quality = 'D'::bpchar));


--
-- Name: pfbigpi_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfbigpi_pseq_id_idx ON pfbigpi USING btree (pseq_id);


--
-- Name: pfbigpi_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfbigpi_redundant_feature_idx ON pfbigpi USING btree (params_id, pseq_id, start);

ALTER TABLE pfbigpi CLUSTER ON pfbigpi_redundant_feature_idx;


--
-- Name: pfeature_p_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfeature_p_idx ON pfeature USING btree (params_id);


--
-- Name: pfeature_pftype_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfeature_pftype_id_idx ON pfeature USING btree (pftype_id);


--
-- Name: pfeature_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfeature_pseq_id_idx ON pfeature USING btree (pseq_id);

ALTER TABLE pfeature CLUSTER ON pfeature_pseq_id_idx;


--
-- Name: pfnetphos_kinase_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfnetphos_kinase_idx ON pfnetphos USING btree (kinase);


--
-- Name: pfnetphos_q; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfnetphos_q ON pfnetphos USING btree (pseq_id);


--
-- Name: pfnetphos_unique_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfnetphos_unique_idx ON pfnetphos USING btree (pseq_id, params_id, start, kinase);


--
-- Name: pfpepcoil_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfpepcoil_pseq_id_idx ON pfpepcoil USING btree (pseq_id);


--
-- Name: pfpepcoil_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfpepcoil_redundant_feature_idx ON pfpepcoil USING btree (params_id, pseq_id, start, stop);

ALTER TABLE pfpepcoil CLUSTER ON pfpepcoil_redundant_feature_idx;


--
-- Name: pfpsipred_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfpsipred_pseq_id_idx ON pfpsipred USING btree (pseq_id);


--
-- Name: pfpsipred_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfpsipred_redundant_feature_idx ON pfpsipred USING btree (params_id, pseq_id, start, stop, type);

ALTER TABLE pfpsipred CLUSTER ON pfpsipred_redundant_feature_idx;


--
-- Name: pfpsipred_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfpsipred_search1_idx ON pfpsipred USING btree (((stop - start)), type);


--
-- Name: pfregexp_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfregexp_pseq_id_idx ON pfregexp USING btree (pseq_id);


--
-- Name: pfregexp_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfregexp_redundant_feature_idx ON pfregexp USING btree (params_id, pseq_id, pmodel_id, start, stop);

ALTER TABLE pfregexp CLUSTER ON pfregexp_redundant_feature_idx;


--
-- Name: pfregexp_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfregexp_search1_idx ON pfregexp USING btree (pmodel_id, pseq_id, start, stop);


--
-- Name: pfseg_params_id; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfseg_params_id ON pfseg USING btree (params_id);


--
-- Name: pfseg_redundant_feature; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfseg_redundant_feature ON pfseg USING btree (pseq_id, params_id, start, stop);

ALTER TABLE pfseg CLUSTER ON pfseg_redundant_feature;


--
-- Name: pfseg_score_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfseg_score_idx ON pfseg USING btree (score);


--
-- Name: pfsigcleave_qss_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfsigcleave_qss_idx ON pfsigcleave USING btree (pseq_id, start, stop);


--
-- Name: pfsigcleave_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfsigcleave_redundant_feature_idx ON pfsigcleave USING btree (params_id, pseq_id, start, stop);

ALTER TABLE pfsigcleave CLUSTER ON pfsigcleave_redundant_feature_idx;


--
-- Name: pfsigcleave_score_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfsigcleave_score_idx ON pfsigcleave USING btree (score);


--
-- Name: pfsignalphmm_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfsignalphmm_pseq_id_idx ON pfsignalphmm USING btree (pseq_id);


--
-- Name: pfsignalphmm_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfsignalphmm_redundant_feature_idx ON pfsignalphmm USING btree (params_id, pseq_id, start, stop);

ALTER TABLE pfsignalphmm CLUSTER ON pfsignalphmm_redundant_feature_idx;


--
-- Name: pfsignalpnn_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pfsignalpnn_pseq_id_idx ON pfsignalpnn USING btree (pseq_id);


--
-- Name: pfsignalpnn_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pfsignalpnn_redundant_feature_idx ON pfsignalpnn USING btree (params_id, pseq_id, start, stop);

ALTER TABLE pfsignalpnn CLUSTER ON pfsignalpnn_redundant_feature_idx;


--
-- Name: pftmdetect_analyze1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pftmdetect_analyze1_idx ON pftmdetect USING btree (pseq_id, params_id);


--
-- Name: pftmdetect_mine1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pftmdetect_mine1_idx ON pftmdetect USING btree (params_id, type, prob, pseq_id);


--
-- Name: pftmdetect_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pftmdetect_pseq_id_idx ON pftmdetect USING btree (pseq_id);


--
-- Name: pftmdetect_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pftmdetect_redundant_feature_idx ON pftmdetect USING btree (params_id, pseq_id, start, stop);

ALTER TABLE pftmdetect CLUSTER ON pftmdetect_redundant_feature_idx;


--
-- Name: pftmhmm_qss_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pftmhmm_qss_idx ON pftmhmm USING btree (pseq_id, start, stop);


--
-- Name: pftmhmm_redundant_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pftmhmm_redundant_feature_idx ON pftmhmm USING btree (params_id, pseq_id, start, stop, type);

ALTER TABLE pftmhmm CLUSTER ON pftmhmm_redundant_feature_idx;


--
-- Name: pmap_aln_genasm_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_aln_genasm_idx ON pmap_aln USING btree (genasm_id);


--
-- Name: pmap_aln_params_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_aln_params_idx ON pmap_aln USING btree (params_id);


--
-- Name: pmap_aln_q_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_aln_q_idx ON pmap_aln USING btree (pseq_id);


--
-- Name: pmap_aln_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_aln_search1_idx ON pmap_aln USING btree (params_id, genasm_id, pseq_id);


--
-- Name: pmap_alnhsp_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_alnhsp_search1_idx ON pmap_alnhsp USING btree (hsp_id, aln_id);


--
-- Name: pmap_alnhsp_unq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmap_alnhsp_unq_idx ON pmap_alnhsp USING btree (aln_id, hsp_id);

ALTER TABLE pmap_alnhsp CLUSTER ON pmap_alnhsp_unq_idx;


--
-- Name: pmap_gg_representative_genomic_search_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_gg_representative_genomic_search_idx ON pmap_gg_representative_mv USING btree (params_id, genasm_id, chr, strand, q_gstart, q_gstop);


--
-- Name: pmap_gg_representative_mv_pseq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_gg_representative_mv_pseq_idx ON pmap_gg_representative_mv USING btree (q_pseq_id, t_pseq_id);


--
-- Name: pmap_hsp_chr_str_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_hsp_chr_str_idx ON pmap_hsp USING btree (chr, strand);


--
-- Name: pmap_hsp_g_lookup_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_hsp_g_lookup_idx ON pmap_hsp USING btree (params_id, genasm_id, chr, strand, gstart, gstop);


--
-- Name: pmap_hsp_q_lookup_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_hsp_q_lookup_idx ON pmap_hsp USING btree (pseq_id, params_id, genasm_id);


--
-- Name: pmap_hsp_str_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmap_hsp_str_idx ON pmap_aln USING btree (hsp_str);


--
-- Name: pmap_hsp_unq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmap_hsp_unq_idx ON pmap_hsp USING btree (params_id, genasm_id, chr, strand, gstart, gstop, pseq_id, pstart, pstop);

ALTER TABLE pmap_hsp CLUSTER ON pmap_hsp_unq_idx;


--
-- Name: pmap_locus_representative_mv_pseq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_locus_representative_mv_pseq_idx ON pmap_locus_representative_mv USING btree (q_pseq_id, t_pseq_id);


--
-- Name: pmap_pfam_feature_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_pfam_feature_idx ON pmap_pfam_mv USING btree (feature);


--
-- Name: pmap_pfam_pseq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_pfam_pseq_idx ON pmap_pfam_mv USING btree (pseq_id);


--
-- Name: pmap_pfam_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_pfam_search1_idx ON pmap_pfam_mv USING btree (genasm_id, chr, strand, pfam_start, pfam_stop);


--
-- Name: pmap_unambiguous_genomic_search_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_unambiguous_genomic_search_idx ON pmap_unambiguous_mv USING btree (params_id, genasm_id, chr, strand, gstart, gstop);

ALTER TABLE pmap_unambiguous_mv CLUSTER ON pmap_unambiguous_genomic_search_idx;


--
-- Name: pmap_unambiguous_overlaps_genomic_search_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_unambiguous_overlaps_genomic_search_idx ON pmap_unambiguous_overlaps_mv USING btree (params_id, genasm_id, chr, strand, q_gstart, q_gstop);

ALTER TABLE pmap_unambiguous_overlaps_mv CLUSTER ON pmap_unambiguous_overlaps_genomic_search_idx;


--
-- Name: pmap_unambiguous_overlaps_qq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_unambiguous_overlaps_qq_idx ON pmap_unambiguous_overlaps_mv USING btree (q_pseq_id);


--
-- Name: pmap_unambiguous_overlaps_tq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_unambiguous_overlaps_tq_idx ON pmap_unambiguous_overlaps_mv USING btree (t_pseq_id);


--
-- Name: pmap_unambiguous_q_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmap_unambiguous_q_idx ON pmap_unambiguous_mv USING btree (pseq_id);


--
-- Name: pmhmm_acc_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmhmm_acc_idx ON pmhmm USING btree (acc);


--
-- Name: pmhmm_duplicate_model_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmhmm_duplicate_model_idx ON pmhmm USING btree (acc, origin_id);


--
-- Name: pmhmm_name_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmhmm_name_idx ON pmhmm USING btree (name);


--
-- Name: pmhmm_origin_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmhmm_origin_id_idx ON pmhmm USING btree (origin_id);


--
-- Name: pmhmm_pkey_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmhmm_pkey_idx ON pmhmm USING btree (pmodel_id);

ALTER TABLE pmhmm CLUSTER ON pmhmm_pkey_idx;


--
-- Name: pmodel2go_nonredundant_mapping_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmodel2go_nonredundant_mapping_idx ON pmodel2go USING btree (pmodel_id, go_id, reference);

ALTER TABLE pmodel2go CLUSTER ON pmodel2go_nonredundant_mapping_idx;


--
-- Name: pmodel_name_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmodel_name_idx ON pmodel USING btree (acc);

ALTER TABLE pmodel CLUSTER ON pmodel_name_idx;


--
-- Name: pmodel_origin_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmodel_origin_id_idx ON pmodel USING btree (origin_id);


--
-- Name: pmodelset_name_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmodelset_name_idx ON pmodelset USING btree (upper(name));


--
-- Name: pmprospect_name_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmprospect_name_idx ON pmprospect USING btree (acc);


--
-- Name: pmprospect_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmprospect_pseq_id_idx ON pmprospect USING btree (pseq_id);


--
-- Name: pmprospect_redundant_name_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmprospect_redundant_name_idx ON pmprospect USING btree (origin_id, acc);


--
-- Name: pmprospect_scop_sunid_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmprospect_scop_sunid_idx ON pmprospect_scop_mv USING btree (sunid);


--
-- Name: pmprospect_scop_uniq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmprospect_scop_uniq_idx ON pmprospect_scop_mv USING btree (pmodel_id, sunid);

ALTER TABLE pmprospect_scop_mv CLUSTER ON pmprospect_scop_uniq_idx;


--
-- Name: pmprospect_unq_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmprospect_unq_idx ON pmprospect USING btree (pmodel_id, acc);


--
-- Name: pmpseq_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmpseq_pmodel_id_idx ON pmpseq USING btree (pmodel_id);

ALTER TABLE pmpseq CLUSTER ON pmpseq_pmodel_id_idx;


--
-- Name: pmpseq_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmpseq_pseq_id_idx ON pmpseq USING btree (pseq_id);


--
-- Name: pmpseq_search1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmpseq_search1_idx ON pmpseq USING btree (pmodel_id, pseq_id);


--
-- Name: pmpseq_search2_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmpseq_search2_idx ON pmpseq USING btree (pseq_id, pmodel_id);


--
-- Name: pmpssm_duplicate_model_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmpssm_duplicate_model_idx ON pmpssm USING btree (origin_id, acc, md5);

ALTER TABLE pmpssm CLUSTER ON pmpssm_duplicate_model_idx;


--
-- Name: pmpssm_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmpssm_pmodel_id_idx ON pmpssm USING btree (pmodel_id);


--
-- Name: pmregexp_origin_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmregexp_origin_id_idx ON pmregexp USING btree (origin_id);


--
-- Name: pmregexp_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmregexp_pmodel_id_idx ON pmregexp USING btree (pmodel_id);

ALTER TABLE pmregexp CLUSTER ON pmregexp_pmodel_id_idx;


--
-- Name: pmsm_pmhmm_model_already_in_set_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmsm_pmhmm_model_already_in_set_idx ON pmsm_pmhmm USING btree (pmodelset_id, pmodel_id);

ALTER TABLE pmsm_pmhmm CLUSTER ON pmsm_pmhmm_model_already_in_set_idx;


--
-- Name: pmsm_pmhmm_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmsm_pmhmm_pmodel_id_idx ON pmsm_pmhmm USING btree (pmodel_id);


--
-- Name: pmsm_pmhmm_pmodelset_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmsm_pmhmm_pmodelset_id_idx ON pmsm_pmhmm USING btree (pmodelset_id);


--
-- Name: pmsm_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmsm_pmodel_id_idx ON pmsm USING btree (pmodel_id);


--
-- Name: pmsm_pmodelset_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmsm_pmodelset_id_idx ON pmsm USING btree (pmodelset_id);

ALTER TABLE pmsm CLUSTER ON pmsm_pmodelset_id_idx;


--
-- Name: pmsm_pmprospect_model_already_in_set_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmsm_pmprospect_model_already_in_set_idx ON pmsm_pmprospect USING btree (pmodelset_id, pmodel_id);

ALTER TABLE pmsm_pmprospect CLUSTER ON pmsm_pmprospect_model_already_in_set_idx;


--
-- Name: pmsm_pmpssm_model_already_in_set_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmsm_pmpssm_model_already_in_set_idx ON pmsm_pmpssm USING btree (pmodelset_id, pmodel_id);

ALTER TABLE pmsm_pmpssm CLUSTER ON pmsm_pmpssm_model_already_in_set_idx;


--
-- Name: pmsm_pmpssm_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmsm_pmpssm_pmodel_id_idx ON pmsm_pmpssm USING btree (pmodel_id);


--
-- Name: pmsm_prospect_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmsm_prospect_pmodel_id_idx ON pmsm_pmprospect USING btree (pmodel_id);


--
-- Name: pmsm_regexp_model_already_in_set_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pmsm_regexp_model_already_in_set_idx ON pmsm_pmregexp USING btree (pmodelset_id, pmodel_id);

ALTER TABLE pmsm_pmregexp CLUSTER ON pmsm_regexp_model_already_in_set_idx;


--
-- Name: pmsm_regexp_pmodel_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pmsm_regexp_pmodel_id_idx ON pmsm_pmregexp USING btree (pmodel_id);


--
-- Name: pnote_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pnote_pseq_id_idx ON pnote USING btree (pseq_id);

ALTER TABLE pnote CLUSTER ON pnote_pseq_id_idx;


--
-- Name: psdisorder_q_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX psdisorder_q_idx ON psdisorder USING btree (pseq_id);


--
-- Name: psdisorder_redundant_prediction_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX psdisorder_redundant_prediction_idx ON psdisorder USING btree (params_id, pseq_id);

ALTER TABLE psdisorder CLUSTER ON psdisorder_redundant_prediction_idx;


--
-- Name: pseq2go_origin_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseq2go_origin_id_idx ON pseq2go USING btree (origin_id);


--
-- Name: pseq2go_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseq2go_pseq_id_idx ON pseq2go USING btree (pseq_id);

ALTER TABLE pseq2go CLUSTER ON pseq2go_pseq_id_idx;


--
-- Name: pseq_added_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseq_added_idx ON pseq USING btree (added);


--
-- Name: pseq_gene_mv_gene_id; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseq_gene_mv_gene_id ON pseq_gene_mv USING btree (gene_id);


--
-- Name: pseq_gene_mv_pseq_id; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseq_gene_mv_pseq_id ON pseq_gene_mv USING btree (pseq_id);


--
-- Name: pseq_len_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseq_len_idx ON pseq USING btree (len);


--
-- Name: pseq_md5_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pseq_md5_idx ON pseq USING btree (md5);


--
-- Name: pseq_probe_serach1_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseq_probe_serach1_idx ON pseq_probe_mv USING btree (pseq_id, params_id, genasm_id);

ALTER TABLE pseq_probe_mv CLUSTER ON pseq_probe_serach1_idx;


--
-- Name: pseqalias_current_palias_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseqalias_current_palias_id_idx ON pseqalias USING btree (pseq_id, palias_id) WHERE (is_current = true);


--
-- Name: INDEX pseqalias_current_palias_id_idx; Type: COMMENT; Schema: unison; Owner: unison
--

COMMENT ON INDEX pseqalias_current_palias_id_idx IS 'rapid pseq_id->palias_id mapping';


--
-- Name: pseqalias_current_palias_id_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseqalias_current_palias_id_pseq_id_idx ON pseqalias USING btree (palias_id, pseq_id) WHERE (is_current = true);


--
-- Name: pseqalias_duplicate_alias_and_version_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pseqalias_duplicate_alias_and_version_idx ON pseqalias USING btree (palias_id, version);

ALTER TABLE pseqalias CLUSTER ON pseqalias_duplicate_alias_and_version_idx;


--
-- Name: pseqalias_is_current_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseqalias_is_current_idx ON pseqalias USING btree (is_current);


--
-- Name: pseqalias_one_iscurrent_per_palias_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pseqalias_one_iscurrent_per_palias_id_idx ON pseqalias USING btree (palias_id) WHERE (is_current = true);


--
-- Name: pseqalias_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseqalias_pseq_id_idx ON pseqalias USING btree (pseq_id);


--
-- Name: pseqalias_ref_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseqalias_ref_pseq_id_idx ON pseqalias USING btree (ref_pseq_id);


--
-- Name: pseqset_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX pseqset_pseq_id_idx ON pseqset USING btree (pseq_id);


--
-- Name: pseqset_pseq_id_pset_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pseqset_pseq_id_pset_id_idx ON pseqset USING btree (pseq_id, pset_id);


--
-- Name: pseqset_seq_already_in_set_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pseqset_seq_already_in_set_idx ON pseqset USING btree (pset_id, pseq_id);

ALTER TABLE pseqset CLUSTER ON pseqset_seq_already_in_set_idx;


--
-- Name: pset_name_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX pset_name_idx ON pset USING btree (upper(name));


--
-- Name: psipred_params_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX psipred_params_idx ON psipred USING btree (params_id);


--
-- Name: psprotcomp_int_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX psprotcomp_int_idx ON psprotcomp USING btree (int_psloc_id, int_score);


--
-- Name: psprotcomp_nn_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX psprotcomp_nn_idx ON psprotcomp USING btree (nn_psloc_id, nn_score);


--
-- Name: psprotcomp_pseq_id_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX psprotcomp_pseq_id_idx ON psprotcomp USING btree (pseq_id);


--
-- Name: psprotcomp_sim_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX psprotcomp_sim_idx ON psprotcomp USING btree (sim_psloc_id, sim_score);


--
-- Name: run_history_qr_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX run_history_qr_idx ON run_history USING btree (pseq_id, run_id);

ALTER TABLE run_history CLUSTER ON run_history_qr_idx;


--
-- Name: run_history_r_idx; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE INDEX run_history_r_idx ON run_history USING btree (run_id);


--
-- Name: run_params_modelset_unique1; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX run_params_modelset_unique1 ON run USING btree (params_id, pmodelset_id);


--
-- Name: run_params_modelset_unique2; Type: INDEX; Schema: unison; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX run_params_modelset_unique2 ON run USING btree (params_id) WHERE (pmodelset_id IS NULL);


SET search_path = unison_aux, pg_catalog;

--
-- Name: cytoband_chr_gstop_unique_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX cytoband_chr_gstop_unique_idx ON cytoband_hg18 USING btree (chr, gstop);


--
-- Name: hugo_approved_name_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_approved_name_idx ON hugo USING btree (approved_name);


--
-- Name: hugo_approved_symbold_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE UNIQUE INDEX hugo_approved_symbold_idx ON hugo USING btree (approved_symbold);


--
-- Name: hugo_entrez_gene_id_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_entrez_gene_id_idx ON hugo USING btree (entrez_gene_id);


--
-- Name: hugo_entrez_gene_id_md_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_entrez_gene_id_md_idx ON hugo USING btree (entrez_gene_id_md);


--
-- Name: hugo_gdb_id_md_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_gdb_id_md_idx ON hugo USING btree (gdb_id_md);


--
-- Name: hugo_gene_family_name_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_gene_family_name_idx ON hugo USING btree (gene_family_name);


--
-- Name: hugo_omim_id_md_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_omim_id_md_idx ON hugo USING btree (omim_id_md);


--
-- Name: hugo_refseq_md_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_refseq_md_idx ON hugo USING btree (refseq_md);


--
-- Name: hugo_status_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_status_idx ON hugo USING btree (status);


--
-- Name: hugo_uniprot_id_md_idx; Type: INDEX; Schema: unison_aux; Owner: unison; Tablespace: 
--

CREATE INDEX hugo_uniprot_id_md_idx ON hugo USING btree (uniprot_id_md);


SET search_path = pdb, pg_catalog;

--
-- Name: residue_atomres_trigger; Type: TRIGGER; Schema: pdb; Owner: unison
--

CREATE TRIGGER residue_atomres_trigger
    BEFORE INSERT OR UPDATE ON residue
    FOR EACH ROW
    EXECUTE PROCEDURE residue_atomres_trigger();


SET search_path = unison, pg_catalog;

--
-- Name: paprospect_i_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER paprospect_i_trigger
    BEFORE INSERT ON paprospect
    FOR EACH ROW
    EXECUTE PROCEDURE paprospect_i_trigger();


--
-- Name: papseq_iu_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER papseq_iu_trigger
    BEFORE INSERT OR UPDATE ON papseq
    FOR EACH ROW
    EXECUTE PROCEDURE papseq_iu_trigger();


--
-- Name: perftest_iu_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER perftest_iu_trigger
    BEFORE INSERT OR UPDATE ON perftest_platform
    FOR EACH ROW
    EXECUTE PROCEDURE perftest_iu_trigger_fx();


--
-- Name: pfbigpi_site_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pfbigpi_site_trigger
    BEFORE INSERT ON pfbigpi
    FOR EACH ROW
    EXECUTE PROCEDURE pfbigpi_site_trigger();


--
-- Name: pmap_hsp_str_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pmap_hsp_str_trigger
    BEFORE INSERT ON pmap_aln
    FOR EACH ROW
    EXECUTE PROCEDURE pmap_hsp_str_trigger();


--
-- Name: pmregexp_u_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pmregexp_u_trigger
    BEFORE UPDATE ON pmregexp
    FOR EACH ROW
    EXECUTE PROCEDURE pmregexp_u_trigger();


--
-- Name: pmsm_pmhmm_immutable_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pmsm_pmhmm_immutable_trigger
    BEFORE INSERT OR DELETE OR UPDATE ON pmsm_pmhmm
    FOR EACH ROW
    EXECUTE PROCEDURE pmodelset_immutable_trigger();


--
-- Name: pmsm_pmprospect_immutable_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pmsm_pmprospect_immutable_trigger
    BEFORE INSERT OR DELETE OR UPDATE ON pmsm_pmprospect
    FOR EACH ROW
    EXECUTE PROCEDURE pmodelset_immutable_trigger();


--
-- Name: pmsm_pmregexp_immutable_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pmsm_pmregexp_immutable_trigger
    BEFORE INSERT OR DELETE OR UPDATE ON pmsm_pmregexp
    FOR EACH ROW
    EXECUTE PROCEDURE pmodelset_immutable_trigger();


--
-- Name: pnote_iu_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pnote_iu_trigger
    BEFORE INSERT OR UPDATE ON pnote
    FOR EACH ROW
    EXECUTE PROCEDURE pnote_iu_trigger();


--
-- Name: pseq_genasm_params_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE CONSTRAINT TRIGGER pseq_genasm_params_trigger
    AFTER INSERT ON pmap_aln
DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE pseq_genasm_params_trigger();


--
-- Name: pseq_iu_trigger; Type: TRIGGER; Schema: unison; Owner: unison
--

CREATE TRIGGER pseq_iu_trigger
    BEFORE INSERT OR UPDATE ON pseq
    FOR EACH ROW
    EXECUTE PROCEDURE pseq_iu_trigger();


SET search_path = gong, pg_catalog;

--
-- Name: $1; Type: FK CONSTRAINT; Schema: gong; Owner: unison
--

ALTER TABLE ONLY is_a
    ADD CONSTRAINT "$1" FOREIGN KEY (go_id1) REFERENCES node(go_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $1; Type: FK CONSTRAINT; Schema: gong; Owner: unison
--

ALTER TABLE ONLY part_of
    ADD CONSTRAINT "$1" FOREIGN KEY (go_id1) REFERENCES node(go_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $1; Type: FK CONSTRAINT; Schema: gong; Owner: unison
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT "$1" FOREIGN KEY (go_id) REFERENCES node(go_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $2; Type: FK CONSTRAINT; Schema: gong; Owner: unison
--

ALTER TABLE ONLY is_a
    ADD CONSTRAINT "$2" FOREIGN KEY (go_id2) REFERENCES node(go_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $2; Type: FK CONSTRAINT; Schema: gong; Owner: unison
--

ALTER TABLE ONLY part_of
    ADD CONSTRAINT "$2" FOREIGN KEY (go_id2) REFERENCES node(go_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alias_id_exists; Type: FK CONSTRAINT; Schema: gong; Owner: unison
--

ALTER TABLE ONLY node
    ADD CONSTRAINT alias_id_exists FOREIGN KEY (alias_id) REFERENCES alias(alias_id) ON UPDATE CASCADE ON DELETE SET NULL;


SET search_path = pdb, pg_catalog;

--
-- Name: chain_pdbid_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY chain
    ADD CONSTRAINT chain_pdbid_fkey FOREIGN KEY (pdbid) REFERENCES summary(pdbid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ligand_atoms_ligand_id_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY ligand_atoms
    ADD CONSTRAINT ligand_atoms_ligand_id_fkey FOREIGN KEY (ligand_id) REFERENCES ligand(ligand_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ligand_bonds_ligand_id_atom_id_1_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY ligand_bonds
    ADD CONSTRAINT ligand_bonds_ligand_id_atom_id_1_fkey FOREIGN KEY (ligand_id, atom_id_1) REFERENCES ligand_atoms(ligand_id, atom_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ligand_bonds_ligand_id_atom_id_2_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY ligand_bonds
    ADD CONSTRAINT ligand_bonds_ligand_id_atom_id_2_fkey FOREIGN KEY (ligand_id, atom_id_2) REFERENCES ligand_atoms(ligand_id, atom_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ligand_descriptors_ligand_id_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY ligand_descriptors
    ADD CONSTRAINT ligand_descriptors_ligand_id_fkey FOREIGN KEY (ligand_id) REFERENCES ligand(ligand_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ligand_descriptors_origin_id_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY ligand_descriptors
    ADD CONSTRAINT ligand_descriptors_origin_id_fkey FOREIGN KEY (descriptor_origin_id) REFERENCES descriptor_origin(descriptor_origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pdb_ligand_pdbid_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY pdb_ligand
    ADD CONSTRAINT pdb_ligand_pdbid_fkey FOREIGN KEY (pdbid) REFERENCES summary(pdbid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: residue_pdbc_fkey; Type: FK CONSTRAINT; Schema: pdb; Owner: unison
--

ALTER TABLE ONLY residue
    ADD CONSTRAINT residue_pdbc_fkey FOREIGN KEY (pdbc) REFERENCES chain(pdbc) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = taxonomy, pg_catalog;

--
-- Name: $1; Type: FK CONSTRAINT; Schema: taxonomy; Owner: unison
--

ALTER TABLE ONLY node
    ADD CONSTRAINT "$1" FOREIGN KEY (division_id) REFERENCES division(division_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $1; Type: FK CONSTRAINT; Schema: taxonomy; Owner: unison
--

ALTER TABLE ONLY name
    ADD CONSTRAINT "$1" FOREIGN KEY (tax_id) REFERENCES node(tax_id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = unison, pg_catalog;

--
-- Name: $1; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseq2go
    ADD CONSTRAINT "$1" FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $1; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmodel2go
    ADD CONSTRAINT "$1" FOREIGN KEY (go_id) REFERENCES gong.node(go_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $1; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY params
    ADD CONSTRAINT "$1" FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $2; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseq2go
    ADD CONSTRAINT "$2" FOREIGN KEY (go_id) REFERENCES gong.node(go_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: $3; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseq2go
    ADD CONSTRAINT "$3" FOREIGN KEY (origin_id) REFERENCES origin(origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: aliasset_alias_aliasset_id_fkey; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY aliasset_alias
    ADD CONSTRAINT aliasset_alias_aliasset_id_fkey FOREIGN KEY (aliasset_id) REFERENCES aliasset(aliasset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: aliasset_alias_pseq_id_fkey; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY aliasset_alias
    ADD CONSTRAINT aliasset_alias_pseq_id_fkey FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: aln_genasm_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT aln_genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id);


--
-- Name: aln_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT aln_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: aln_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_aln
    ADD CONSTRAINT aln_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: genasm_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY p2gblathsp
    ADD CONSTRAINT genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: genasm_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pcluster
    ADD CONSTRAINT genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hsp_genasm_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT hsp_genasm_id_exists FOREIGN KEY (genasm_id) REFERENCES genasm(genasm_id);


--
-- Name: hsp_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT hsp_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hsp_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_hsp
    ADD CONSTRAINT hsp_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origin_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmodel
    ADD CONSTRAINT origin_id_exists FOREIGN KEY (origin_id) REFERENCES origin(origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origin_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY paliasorigin
    ADD CONSTRAINT origin_id_exists FOREIGN KEY (origin_id) REFERENCES origin(origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origin_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmhmm
    ADD CONSTRAINT origin_id_exists FOREIGN KEY (origin_id) REFERENCES origin(origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origin_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmregexp
    ADD CONSTRAINT origin_id_exists FOREIGN KEY (origin_id) REFERENCES origin(origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origin_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmprospect
    ADD CONSTRAINT origin_id_exists FOREIGN KEY (origin_id) REFERENCES origin(origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origin_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmpssm
    ADD CONSTRAINT origin_id_exists FOREIGN KEY (origin_id) REFERENCES origin(origin_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: p2gblataln_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY p2gblatalnhsp
    ADD CONSTRAINT p2gblataln_id_exists FOREIGN KEY (p2gblataln_id) REFERENCES p2gblataln(p2gblataln_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: p2gblathsp_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY p2gblatalnhsp
    ADD CONSTRAINT p2gblathsp_id_exists FOREIGN KEY (p2gblathsp_id) REFERENCES p2gblathsp(p2gblathsp_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pahmm_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pahmm
    ADD CONSTRAINT pahmm_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pahmm_pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pahmm
    ADD CONSTRAINT pahmm_pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmhmm(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: palias_fk; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseqalias
    ADD CONSTRAINT palias_fk FOREIGN KEY (palias_id) REFERENCES paliasorigin(palias_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paprospect_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY paprospect
    ADD CONSTRAINT paprospect_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paprospect_pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY paprospect
    ADD CONSTRAINT paprospect_pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmprospect(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: papseq_pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY papseq
    ADD CONSTRAINT papseq_pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmpseq(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: papssm_pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY papssm
    ADD CONSTRAINT papssm_pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmpssm(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfantigenic
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfregexp
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfpsipred
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psipred
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pftmhmm
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psdisorder
    ADD CONSTRAINT params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pcluster_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pcluster_member
    ADD CONSTRAINT pcluster_id_exists FOREIGN KEY (pcluster_id) REFERENCES pcluster(pcluster_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: perftest_result_def_id_fkey; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY perftest_result
    ADD CONSTRAINT perftest_result_def_id_fkey FOREIGN KEY (def_id) REFERENCES perftest_def(def_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: perftest_result_run_id_fkey; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY perftest_result
    ADD CONSTRAINT perftest_result_run_id_fkey FOREIGN KEY (run_id) REFERENCES perftest_run(run_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: perftest_run_platform_id_fkey; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY perftest_run
    ADD CONSTRAINT perftest_run_platform_id_fkey FOREIGN KEY (platform_id) REFERENCES perftest_platform(platform_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfbigpi_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfbigpi
    ADD CONSTRAINT pfbigpi_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfbigpi_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfbigpi
    ADD CONSTRAINT pfbigpi_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pftmdetect
    ADD CONSTRAINT pfeature_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsignalpnn
    ADD CONSTRAINT pfeature_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsignalphmm
    ADD CONSTRAINT pfeature_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfpepcoil
    ADD CONSTRAINT pfeature_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfeature
    ADD CONSTRAINT pfeature_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY papseq
    ADD CONSTRAINT pfeature_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY paprospect
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsigcleave
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY palignment
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pftmdetect
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfantigenic
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsignalpnn
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsignalphmm
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pahmm
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY papssm
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY papseq
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfeature
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfbigpi
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfpepcoil
    ADD CONSTRAINT pfeature_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY paprospect
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsigcleave
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY palignment
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pftmdetect
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfantigenic
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsignalpnn
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsignalphmm
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pahmm
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY papssm
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY papseq
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfeature
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfeature_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfpepcoil
    ADD CONSTRAINT pfeature_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfseg_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfseg
    ADD CONSTRAINT pfseg_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfseg_pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfseg
    ADD CONSTRAINT pfseg_pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfseg_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfseg
    ADD CONSTRAINT pfseg_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pfsignalphmm_pred_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfsignalphmm
    ADD CONSTRAINT pfsignalphmm_pred_id_exists FOREIGN KEY (pfsignalphmm_pred_id) REFERENCES pfsignalphmm_pred(pfsignalphmm_pred_id);


--
-- Name: pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfregexp
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfpsipred
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pftype_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pftmhmm
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pftype_run_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pftype
    ADD CONSTRAINT pftype_run_id_exists FOREIGN KEY (preferred_run_id) REFERENCES run(run_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pmap_aln_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_alnhsp
    ADD CONSTRAINT pmap_aln_id_exists FOREIGN KEY (aln_id) REFERENCES pmap_aln(aln_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pmap_hsp_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmap_alnhsp
    ADD CONSTRAINT pmap_hsp_id_exists FOREIGN KEY (hsp_id) REFERENCES pmap_hsp(hsp_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfregexp
    ADD CONSTRAINT pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmregexp(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmregexp
    ADD CONSTRAINT pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmregexp(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmprospect_scop_mv
    ADD CONSTRAINT pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmprospect(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmodelset_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmregexp
    ADD CONSTRAINT pmodelset_id_exists FOREIGN KEY (pmodelset_id) REFERENCES pmodelset(pmodelset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmsm_pmhmm_pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmhmm
    ADD CONSTRAINT pmsm_pmhmm_pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmhmm(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmsm_pmhmm_pmodelset_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmhmm
    ADD CONSTRAINT pmsm_pmhmm_pmodelset_id_exists FOREIGN KEY (pmodelset_id) REFERENCES pmodelset(pmodelset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmsm_pmodelset_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm
    ADD CONSTRAINT pmsm_pmodelset_id_exists FOREIGN KEY (pmodelset_id) REFERENCES pmodelset(pmodelset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmsm_pmprospect_pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmprospect
    ADD CONSTRAINT pmsm_pmprospect_pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmprospect(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmsm_pmprospect_pmodelset_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmprospect
    ADD CONSTRAINT pmsm_pmprospect_pmodelset_id_exists FOREIGN KEY (pmodelset_id) REFERENCES pmodelset(pmodelset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmsm_pmpssm_pmodel_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmpssm
    ADD CONSTRAINT pmsm_pmpssm_pmodel_id_exists FOREIGN KEY (pmodel_id) REFERENCES pmpssm(pmodel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pmsm_pmpssm_pmodelset_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmsm_pmpssm
    ADD CONSTRAINT pmsm_pmpssm_pmodelset_id_exists FOREIGN KEY (pmodelset_id) REFERENCES pmodelset(pmodelset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseqset
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseqalias
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pmpseq
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY run_history
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfregexp
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pcluster_member
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY p2gblathsp
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pnote
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psipred
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pfpsipred
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pftmhmm
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psdisorder
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pset_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseqset
    ADD CONSTRAINT pset_id_exists FOREIGN KEY (pset_id) REFERENCES pset(pset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: psprotcomp_int_psloc_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psprotcomp
    ADD CONSTRAINT psprotcomp_int_psloc_id_exists FOREIGN KEY (int_psloc_id) REFERENCES psprotcomp_location(psloc_id);


--
-- Name: psprotcomp_nn_psloc_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psprotcomp
    ADD CONSTRAINT psprotcomp_nn_psloc_id_exists FOREIGN KEY (nn_psloc_id) REFERENCES psprotcomp_location(psloc_id);


--
-- Name: psprotcomp_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psprotcomp
    ADD CONSTRAINT psprotcomp_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: psprotcomp_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psprotcomp
    ADD CONSTRAINT psprotcomp_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: psprotcomp_sim_psloc_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY psprotcomp
    ADD CONSTRAINT psprotcomp_sim_psloc_id_exists FOREIGN KEY (sim_psloc_id) REFERENCES psprotcomp_location(psloc_id);


--
-- Name: ref_pseq_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY pseqalias
    ADD CONSTRAINT ref_pseq_id_exists FOREIGN KEY (ref_pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: run_history_run_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY run_history
    ADD CONSTRAINT run_history_run_id_exists FOREIGN KEY (run_id) REFERENCES run(run_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: run_params_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_params_id_exists FOREIGN KEY (params_id) REFERENCES params(params_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: run_pomodelset_id_exists; Type: FK CONSTRAINT; Schema: unison; Owner: unison
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_pomodelset_id_exists FOREIGN KEY (pmodelset_id) REFERENCES pmodelset(pmodelset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: go; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA go FROM PUBLIC;
REVOKE ALL ON SCHEMA go FROM unison;
GRANT ALL ON SCHEMA go TO unison;
GRANT USAGE ON SCHEMA go TO PUBLIC;


--
-- Name: gong; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA gong FROM PUBLIC;
REVOKE ALL ON SCHEMA gong FROM unison;
GRANT ALL ON SCHEMA gong TO unison;
GRANT USAGE ON SCHEMA gong TO PUBLIC;


--
-- Name: marray; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA marray FROM PUBLIC;
REVOKE ALL ON SCHEMA marray FROM unison;
GRANT ALL ON SCHEMA marray TO unison;
GRANT USAGE ON SCHEMA marray TO PUBLIC;


--
-- Name: ncbi; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA ncbi FROM PUBLIC;
REVOKE ALL ON SCHEMA ncbi FROM unison;
GRANT ALL ON SCHEMA ncbi TO unison;
GRANT USAGE ON SCHEMA ncbi TO PUBLIC;


--
-- Name: pdb; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA pdb FROM PUBLIC;
REVOKE ALL ON SCHEMA pdb FROM unison;
GRANT ALL ON SCHEMA pdb TO unison;
GRANT CREATE ON SCHEMA pdb TO loader;
GRANT USAGE ON SCHEMA pdb TO PUBLIC;


--
-- Name: pgutils; Type: ACL; Schema: -; Owner: rkh
--

REVOKE ALL ON SCHEMA pgutils FROM PUBLIC;
REVOKE ALL ON SCHEMA pgutils FROM rkh;
GRANT ALL ON SCHEMA pgutils TO rkh;
GRANT USAGE ON SCHEMA pgutils TO PUBLIC;


--
-- Name: scop; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA scop FROM PUBLIC;
REVOKE ALL ON SCHEMA scop FROM unison;
GRANT ALL ON SCHEMA scop TO unison;
GRANT USAGE ON SCHEMA scop TO PUBLIC;


--
-- Name: sst; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA sst FROM PUBLIC;
REVOKE ALL ON SCHEMA sst FROM unison;
GRANT ALL ON SCHEMA sst TO unison;
GRANT USAGE ON SCHEMA sst TO PUBLIC;


--
-- Name: tax; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA tax FROM PUBLIC;
REVOKE ALL ON SCHEMA tax FROM unison;
GRANT ALL ON SCHEMA tax TO unison;
GRANT USAGE ON SCHEMA tax TO PUBLIC;


--
-- Name: taxonomy; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA taxonomy FROM PUBLIC;
REVOKE ALL ON SCHEMA taxonomy FROM unison;
GRANT ALL ON SCHEMA taxonomy TO unison;
GRANT USAGE ON SCHEMA taxonomy TO PUBLIC;


--
-- Name: unison; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA unison FROM PUBLIC;
REVOKE ALL ON SCHEMA unison FROM unison;
GRANT ALL ON SCHEMA unison TO unison;
GRANT USAGE ON SCHEMA unison TO PUBLIC;


--
-- Name: unison_aux; Type: ACL; Schema: -; Owner: unison
--

REVOKE ALL ON SCHEMA unison_aux FROM PUBLIC;
REVOKE ALL ON SCHEMA unison_aux FROM unison;
GRANT ALL ON SCHEMA unison_aux TO unison;
GRANT USAGE ON SCHEMA unison_aux TO PUBLIC;


--
-- Name: p2gblataln; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE p2gblataln FROM PUBLIC;
REVOKE ALL ON TABLE p2gblataln FROM unison;
GRANT ALL ON TABLE p2gblataln TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE p2gblataln TO loader;
GRANT SELECT ON TABLE p2gblataln TO PUBLIC;


--
-- Name: p2gblatalnhsp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE p2gblatalnhsp FROM PUBLIC;
REVOKE ALL ON TABLE p2gblatalnhsp FROM unison;
GRANT ALL ON TABLE p2gblatalnhsp TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE p2gblatalnhsp TO loader;
GRANT SELECT ON TABLE p2gblatalnhsp TO PUBLIC;


--
-- Name: p2gblathsp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE p2gblathsp FROM PUBLIC;
REVOKE ALL ON TABLE p2gblathsp FROM unison;
GRANT ALL ON TABLE p2gblathsp TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE p2gblathsp TO loader;
GRANT SELECT ON TABLE p2gblathsp TO PUBLIC;


--
-- Name: pseq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq FROM PUBLIC;
REVOKE ALL ON TABLE pseq FROM unison;
GRANT ALL ON TABLE pseq TO unison;
GRANT INSERT,UPDATE ON TABLE pseq TO loader;
GRANT INSERT ON TABLE pseq TO genengenes;
GRANT SELECT,REFERENCES ON TABLE pseq TO PUBLIC;


--
-- Name: pftype_id(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pftype_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pftype_id(text) FROM unison;
GRANT ALL ON FUNCTION pftype_id(text) TO unison;
GRANT ALL ON FUNCTION pftype_id(text) TO PUBLIC;


--
-- Name: pfeature; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfeature FROM PUBLIC;
REVOKE ALL ON TABLE pfeature FROM unison;
GRANT ALL ON TABLE pfeature TO unison;
GRANT INSERT,UPDATE ON TABLE pfeature TO loader;
GRANT SELECT ON TABLE pfeature TO PUBLIC;


--
-- Name: pfeature_pfeature_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pfeature_pfeature_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pfeature_pfeature_id_seq FROM unison;
GRANT ALL ON SEQUENCE pfeature_pfeature_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pfeature_pfeature_id_seq TO loader;


--
-- Name: palignment; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE palignment FROM PUBLIC;
REVOKE ALL ON TABLE palignment FROM unison;
GRANT ALL ON TABLE palignment TO unison;
GRANT SELECT ON TABLE palignment TO PUBLIC;


--
-- Name: pahmm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pahmm FROM PUBLIC;
REVOKE ALL ON TABLE pahmm FROM unison;
GRANT ALL ON TABLE pahmm TO unison;
GRANT INSERT ON TABLE pahmm TO loader;
GRANT SELECT ON TABLE pahmm TO PUBLIC;


--
-- Name: pfregexp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfregexp FROM PUBLIC;
REVOKE ALL ON TABLE pfregexp FROM unison;
GRANT ALL ON TABLE pfregexp TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pfregexp TO loader;
GRANT SELECT ON TABLE pfregexp TO PUBLIC;


--
-- Name: pftmdetect; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pftmdetect FROM PUBLIC;
REVOKE ALL ON TABLE pftmdetect FROM unison;
GRANT ALL ON TABLE pftmdetect TO unison;
GRANT INSERT,UPDATE ON TABLE pftmdetect TO loader;
GRANT SELECT ON TABLE pftmdetect TO PUBLIC;


--
-- Name: paprospect; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE paprospect FROM PUBLIC;
REVOKE ALL ON TABLE paprospect FROM unison;
GRANT ALL ON TABLE paprospect TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE paprospect TO loader;
GRANT SELECT ON TABLE paprospect TO PUBLIC;


--
-- Name: pmsm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmsm FROM PUBLIC;
REVOKE ALL ON TABLE pmsm FROM unison;
GRANT ALL ON TABLE pmsm TO unison;
GRANT SELECT ON TABLE pmsm TO PUBLIC;


--
-- Name: pmsm_pmprospect; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmsm_pmprospect FROM PUBLIC;
REVOKE ALL ON TABLE pmsm_pmprospect FROM unison;
GRANT ALL ON TABLE pmsm_pmprospect TO unison;
GRANT SELECT ON TABLE pmsm_pmprospect TO PUBLIC;


SET search_path = scop, pg_catalog;

--
-- Name: des; Type: ACL; Schema: scop; Owner: unison
--

REVOKE ALL ON TABLE des FROM PUBLIC;
REVOKE ALL ON TABLE des FROM unison;
GRANT ALL ON TABLE des TO unison;
GRANT INSERT,UPDATE ON TABLE des TO loader;
GRANT SELECT ON TABLE des TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: pmprospect_scop_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmprospect_scop_mv FROM PUBLIC;
REVOKE ALL ON TABLE pmprospect_scop_mv FROM unison;
GRANT ALL ON TABLE pmprospect_scop_mv TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pmprospect_scop_mv TO loader;
GRANT SELECT ON TABLE pmprospect_scop_mv TO PUBLIC;


--
-- Name: pmodel; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmodel FROM PUBLIC;
REVOKE ALL ON TABLE pmodel FROM unison;
GRANT ALL ON TABLE pmodel TO unison;
GRANT INSERT,UPDATE ON TABLE pmodel TO loader;
GRANT SELECT ON TABLE pmodel TO PUBLIC;


--
-- Name: pmodel_pmodel_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pmodel_pmodel_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pmodel_pmodel_id_seq FROM unison;
GRANT ALL ON SEQUENCE pmodel_pmodel_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pmodel_pmodel_id_seq TO loader;


--
-- Name: pmhmm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmhmm FROM PUBLIC;
REVOKE ALL ON TABLE pmhmm FROM unison;
GRANT ALL ON TABLE pmhmm TO unison;
GRANT INSERT,UPDATE ON TABLE pmhmm TO loader;
GRANT SELECT ON TABLE pmhmm TO PUBLIC;


--
-- Name: pseqset; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseqset FROM PUBLIC;
REVOKE ALL ON TABLE pseqset FROM unison;
GRANT ALL ON TABLE pseqset TO unison;
GRANT INSERT,UPDATE ON TABLE pseqset TO loader;
GRANT SELECT,INSERT,DELETE ON TABLE pseqset TO cavs;
GRANT SELECT ON TABLE pseqset TO PUBLIC;
GRANT INSERT,DELETE,UPDATE ON TABLE pseqset TO matthejb;


--
-- Name: pset; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset FROM PUBLIC;
REVOKE ALL ON TABLE pset FROM unison;
GRANT ALL ON TABLE pset TO unison;
GRANT INSERT,UPDATE ON TABLE pset TO loader;
GRANT SELECT ON TABLE pset TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pset TO matthejb;


--
-- Name: paliasorigin; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE paliasorigin FROM PUBLIC;
REVOKE ALL ON TABLE paliasorigin FROM unison;
GRANT ALL ON TABLE paliasorigin TO unison;
GRANT SELECT,INSERT,UPDATE ON TABLE paliasorigin TO loader;
GRANT SELECT,INSERT,UPDATE ON TABLE paliasorigin TO genengenes;
GRANT SELECT ON TABLE paliasorigin TO PUBLIC;


--
-- Name: pseqalias; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseqalias FROM PUBLIC;
REVOKE ALL ON TABLE pseqalias FROM unison;
GRANT ALL ON TABLE pseqalias TO unison;
GRANT SELECT,INSERT,UPDATE ON TABLE pseqalias TO loader;
GRANT INSERT ON TABLE pseqalias TO genengenes;
GRANT SELECT ON TABLE pseqalias TO PUBLIC;


--
-- Name: palias; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE palias FROM PUBLIC;
REVOKE ALL ON TABLE palias FROM unison;
GRANT ALL ON TABLE palias TO unison;
GRANT ALL ON TABLE palias TO loader;
GRANT SELECT ON TABLE palias TO PUBLIC;


SET search_path = go, pg_catalog;

--
-- Name: association; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE association FROM PUBLIC;
REVOKE ALL ON TABLE association FROM unison;
GRANT ALL ON TABLE association TO unison;


--
-- Name: db; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE db FROM PUBLIC;
REVOKE ALL ON TABLE db FROM unison;
GRANT ALL ON TABLE db TO unison;


--
-- Name: dbxref; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE dbxref FROM PUBLIC;
REVOKE ALL ON TABLE dbxref FROM unison;
GRANT ALL ON TABLE dbxref TO unison;


--
-- Name: evidence; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE evidence FROM PUBLIC;
REVOKE ALL ON TABLE evidence FROM unison;
GRANT ALL ON TABLE evidence TO unison;


--
-- Name: evidence_dbxref; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE evidence_dbxref FROM PUBLIC;
REVOKE ALL ON TABLE evidence_dbxref FROM unison;
GRANT ALL ON TABLE evidence_dbxref TO unison;


--
-- Name: gene_product; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE gene_product FROM PUBLIC;
REVOKE ALL ON TABLE gene_product FROM unison;
GRANT ALL ON TABLE gene_product TO unison;


--
-- Name: gene_product_count; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE gene_product_count FROM PUBLIC;
REVOKE ALL ON TABLE gene_product_count FROM unison;
GRANT ALL ON TABLE gene_product_count TO unison;


--
-- Name: gene_product_property; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE gene_product_property FROM PUBLIC;
REVOKE ALL ON TABLE gene_product_property FROM unison;
GRANT ALL ON TABLE gene_product_property TO unison;


--
-- Name: gene_product_seq; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE gene_product_seq FROM PUBLIC;
REVOKE ALL ON TABLE gene_product_seq FROM unison;
GRANT ALL ON TABLE gene_product_seq TO unison;


--
-- Name: gene_product_synonym; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE gene_product_synonym FROM PUBLIC;
REVOKE ALL ON TABLE gene_product_synonym FROM unison;
GRANT ALL ON TABLE gene_product_synonym TO unison;


--
-- Name: graph_path; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE graph_path FROM PUBLIC;
REVOKE ALL ON TABLE graph_path FROM unison;
GRANT ALL ON TABLE graph_path TO unison;


--
-- Name: graph_path2term; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE graph_path2term FROM PUBLIC;
REVOKE ALL ON TABLE graph_path2term FROM unison;
GRANT ALL ON TABLE graph_path2term TO unison;


--
-- Name: instance_data; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE instance_data FROM PUBLIC;
REVOKE ALL ON TABLE instance_data FROM unison;
GRANT ALL ON TABLE instance_data TO unison;


--
-- Name: seq; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE seq FROM PUBLIC;
REVOKE ALL ON TABLE seq FROM unison;
GRANT ALL ON TABLE seq TO unison;


--
-- Name: seq_dbxref; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE seq_dbxref FROM PUBLIC;
REVOKE ALL ON TABLE seq_dbxref FROM unison;
GRANT ALL ON TABLE seq_dbxref TO unison;


--
-- Name: seq_property; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE seq_property FROM PUBLIC;
REVOKE ALL ON TABLE seq_property FROM unison;
GRANT ALL ON TABLE seq_property TO unison;


--
-- Name: source_audit; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE source_audit FROM PUBLIC;
REVOKE ALL ON TABLE source_audit FROM unison;
GRANT ALL ON TABLE source_audit TO unison;


--
-- Name: species; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE species FROM PUBLIC;
REVOKE ALL ON TABLE species FROM unison;
GRANT ALL ON TABLE species TO unison;


--
-- Name: term; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE term FROM PUBLIC;
REVOKE ALL ON TABLE term FROM unison;
GRANT ALL ON TABLE term TO unison;


--
-- Name: term2term; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE term2term FROM PUBLIC;
REVOKE ALL ON TABLE term2term FROM unison;
GRANT ALL ON TABLE term2term TO unison;


--
-- Name: term_audit; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE term_audit FROM PUBLIC;
REVOKE ALL ON TABLE term_audit FROM unison;
GRANT ALL ON TABLE term_audit TO unison;


--
-- Name: term_dbxref; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE term_dbxref FROM PUBLIC;
REVOKE ALL ON TABLE term_dbxref FROM unison;
GRANT ALL ON TABLE term_dbxref TO unison;


--
-- Name: term_definition; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE term_definition FROM PUBLIC;
REVOKE ALL ON TABLE term_definition FROM unison;
GRANT ALL ON TABLE term_definition TO unison;


--
-- Name: term_synonym; Type: ACL; Schema: go; Owner: unison
--

REVOKE ALL ON TABLE term_synonym FROM PUBLIC;
REVOKE ALL ON TABLE term_synonym FROM unison;
GRANT ALL ON TABLE term_synonym TO unison;


SET search_path = gong, pg_catalog;

--
-- Name: alias; Type: ACL; Schema: gong; Owner: unison
--

REVOKE ALL ON TABLE alias FROM PUBLIC;
REVOKE ALL ON TABLE alias FROM unison;
GRANT ALL ON TABLE alias TO unison;
GRANT SELECT ON TABLE alias TO PUBLIC;


--
-- Name: evidence_code; Type: ACL; Schema: gong; Owner: unison
--

REVOKE ALL ON TABLE evidence_code FROM PUBLIC;
REVOKE ALL ON TABLE evidence_code FROM unison;
GRANT ALL ON TABLE evidence_code TO unison;


--
-- Name: is_a; Type: ACL; Schema: gong; Owner: unison
--

REVOKE ALL ON TABLE is_a FROM PUBLIC;
REVOKE ALL ON TABLE is_a FROM unison;
GRANT ALL ON TABLE is_a TO unison;
GRANT SELECT ON TABLE is_a TO PUBLIC;


--
-- Name: node; Type: ACL; Schema: gong; Owner: unison
--

REVOKE ALL ON TABLE node FROM PUBLIC;
REVOKE ALL ON TABLE node FROM unison;
GRANT ALL ON TABLE node TO unison;
GRANT SELECT ON TABLE node TO PUBLIC;


--
-- Name: part_of; Type: ACL; Schema: gong; Owner: unison
--

REVOKE ALL ON TABLE part_of FROM PUBLIC;
REVOKE ALL ON TABLE part_of FROM unison;
GRANT ALL ON TABLE part_of TO unison;
GRANT SELECT ON TABLE part_of TO PUBLIC;


--
-- Name: term; Type: ACL; Schema: gong; Owner: unison
--

REVOKE ALL ON TABLE term FROM PUBLIC;
REVOKE ALL ON TABLE term FROM unison;
GRANT ALL ON TABLE term TO unison;
GRANT SELECT ON TABLE term TO PUBLIC;


SET search_path = marray, pg_catalog;

--
-- Name: chip; Type: ACL; Schema: marray; Owner: unison
--

REVOKE ALL ON TABLE chip FROM PUBLIC;
REVOKE ALL ON TABLE chip FROM unison;
GRANT ALL ON TABLE chip TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE chip TO loader;
GRANT SELECT ON TABLE chip TO PUBLIC;


--
-- Name: probe; Type: ACL; Schema: marray; Owner: unison
--

REVOKE ALL ON TABLE probe FROM PUBLIC;
REVOKE ALL ON TABLE probe FROM unison;
GRANT ALL ON TABLE probe TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE probe TO loader;
GRANT SELECT ON TABLE probe TO PUBLIC;


--
-- Name: chip_probe_v; Type: ACL; Schema: marray; Owner: unison
--

REVOKE ALL ON TABLE chip_probe_v FROM PUBLIC;
REVOKE ALL ON TABLE chip_probe_v FROM unison;
GRANT ALL ON TABLE chip_probe_v TO unison;
GRANT SELECT ON TABLE chip_probe_v TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: origin_id(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION origin_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION origin_id(text) FROM unison;
GRANT ALL ON FUNCTION origin_id(text) TO unison;
GRANT ALL ON FUNCTION origin_id(text) TO PUBLIC;


SET search_path = ncbi, pg_catalog;

--
-- Name: homologene; Type: ACL; Schema: ncbi; Owner: unison
--

REVOKE ALL ON TABLE homologene FROM PUBLIC;
REVOKE ALL ON TABLE homologene FROM unison;
GRANT ALL ON TABLE homologene TO unison;
GRANT SELECT ON TABLE homologene TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: homologene_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE homologene_v FROM PUBLIC;
REVOKE ALL ON TABLE homologene_v FROM unison;
GRANT ALL ON TABLE homologene_v TO unison;
GRANT SELECT ON TABLE homologene_v TO PUBLIC;


--
-- Name: homologene_pairs_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE homologene_pairs_v FROM PUBLIC;
REVOKE ALL ON TABLE homologene_pairs_v FROM unison;
GRANT ALL ON TABLE homologene_pairs_v TO unison;
GRANT SELECT ON TABLE homologene_pairs_v TO PUBLIC;


--
-- Name: homologene_orthologs_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE homologene_orthologs_v FROM PUBLIC;
REVOKE ALL ON TABLE homologene_orthologs_v FROM unison;
GRANT ALL ON TABLE homologene_orthologs_v TO unison;
GRANT SELECT ON TABLE homologene_orthologs_v TO PUBLIC;


--
-- Name: origin; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE origin FROM PUBLIC;
REVOKE ALL ON TABLE origin FROM unison;
GRANT ALL ON TABLE origin TO unison;
GRANT INSERT,UPDATE ON TABLE origin TO loader;
GRANT REFERENCES ON TABLE origin TO rkh;
GRANT SELECT ON TABLE origin TO PUBLIC;
GRANT REFERENCES ON TABLE origin TO mukhyala;


--
-- Name: pmodelset; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmodelset FROM PUBLIC;
REVOKE ALL ON TABLE pmodelset FROM unison;
GRANT ALL ON TABLE pmodelset TO unison;
GRANT INSERT,UPDATE ON TABLE pmodelset TO loader;
GRANT SELECT ON TABLE pmodelset TO PUBLIC;


--
-- Name: pmregexp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmregexp FROM PUBLIC;
REVOKE ALL ON TABLE pmregexp FROM unison;
GRANT ALL ON TABLE pmregexp TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pmregexp TO loader;
GRANT SELECT ON TABLE pmregexp TO PUBLIC;


--
-- Name: pmsm_pmhmm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmsm_pmhmm FROM PUBLIC;
REVOKE ALL ON TABLE pmsm_pmhmm FROM unison;
GRANT ALL ON TABLE pmsm_pmhmm TO unison;
GRANT SELECT ON TABLE pmsm_pmhmm TO PUBLIC;


--
-- Name: pmsm_pmregexp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmsm_pmregexp FROM PUBLIC;
REVOKE ALL ON TABLE pmsm_pmregexp FROM unison;
GRANT ALL ON TABLE pmsm_pmregexp TO unison;
GRANT SELECT ON TABLE pmsm_pmregexp TO PUBLIC;


SET search_path = scop, pg_catalog;

--
-- Name: cla; Type: ACL; Schema: scop; Owner: unison
--

REVOKE ALL ON TABLE cla FROM PUBLIC;
REVOKE ALL ON TABLE cla FROM unison;
GRANT ALL ON TABLE cla TO unison;
GRANT INSERT,UPDATE ON TABLE cla TO loader;
GRANT SELECT ON TABLE cla TO PUBLIC;


SET search_path = tax, pg_catalog;

--
-- Name: spspec; Type: ACL; Schema: tax; Owner: unison
--

REVOKE ALL ON TABLE spspec FROM PUBLIC;
REVOKE ALL ON TABLE spspec FROM unison;
GRANT ALL ON TABLE spspec TO unison;
GRANT REFERENCES ON TABLE spspec TO cavs;
GRANT INSERT,UPDATE ON TABLE spspec TO loader;
GRANT SELECT ON TABLE spspec TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: current_annotations_unsorted_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE current_annotations_unsorted_v FROM PUBLIC;
REVOKE ALL ON TABLE current_annotations_unsorted_v FROM unison;
GRANT ALL ON TABLE current_annotations_unsorted_v TO unison;
GRANT SELECT ON TABLE current_annotations_unsorted_v TO PUBLIC;


--
-- Name: pset_id(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pset_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pset_id(text) FROM unison;
GRANT ALL ON FUNCTION pset_id(text) TO unison;
GRANT ALL ON FUNCTION pset_id(text) TO PUBLIC;


--
-- Name: ensembl_unambiguous_overlaps_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ensembl_unambiguous_overlaps_mv FROM PUBLIC;
REVOKE ALL ON TABLE ensembl_unambiguous_overlaps_mv FROM unison;
GRANT ALL ON TABLE ensembl_unambiguous_overlaps_mv TO unison;
GRANT SELECT ON TABLE ensembl_unambiguous_overlaps_mv TO PUBLIC;


SET search_path = pdb, pg_catalog;

--
-- Name: descriptor_origin; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE descriptor_origin FROM PUBLIC;
REVOKE ALL ON TABLE descriptor_origin FROM unison;
GRANT ALL ON TABLE descriptor_origin TO unison;
GRANT SELECT ON TABLE descriptor_origin TO PUBLIC;


--
-- Name: ligand_descriptors; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_descriptors FROM PUBLIC;
REVOKE ALL ON TABLE ligand_descriptors FROM unison;
GRANT ALL ON TABLE ligand_descriptors TO unison;
GRANT SELECT ON TABLE ligand_descriptors TO PUBLIC;


--
-- Name: descriptor_origin_id(text, text); Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON FUNCTION descriptor_origin_id(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION descriptor_origin_id(text, text) FROM unison;
GRANT ALL ON FUNCTION descriptor_origin_id(text, text) TO unison;
GRANT ALL ON FUNCTION descriptor_origin_id(text, text) TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: pahmm_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pahmm_v FROM PUBLIC;
REVOKE ALL ON TABLE pahmm_v FROM unison;
GRANT ALL ON TABLE pahmm_v TO unison;
GRANT SELECT ON TABLE pahmm_v TO PUBLIC;


--
-- Name: papseq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE papseq FROM PUBLIC;
REVOKE ALL ON TABLE papseq FROM unison;
GRANT ALL ON TABLE papseq TO unison;
GRANT INSERT,UPDATE ON TABLE papseq TO loader;
GRANT SELECT ON TABLE papseq TO PUBLIC;


--
-- Name: pmpseq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmpseq FROM PUBLIC;
REVOKE ALL ON TABLE pmpseq FROM unison;
GRANT ALL ON TABLE pmpseq TO unison;
GRANT SELECT ON TABLE pmpseq TO PUBLIC;


--
-- Name: papseq_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE papseq_v FROM PUBLIC;
REVOKE ALL ON TABLE papseq_v FROM unison;
GRANT ALL ON TABLE papseq_v TO unison;
GRANT SELECT ON TABLE papseq_v TO PUBLIC;


SET search_path = scop, pg_catalog;

--
-- Name: dom; Type: ACL; Schema: scop; Owner: unison
--

REVOKE ALL ON TABLE dom FROM PUBLIC;
REVOKE ALL ON TABLE dom FROM unison;
GRANT ALL ON TABLE dom TO unison;
GRANT SELECT ON TABLE dom TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: papseq_pdbcs_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE papseq_pdbcs_mv FROM PUBLIC;
REVOKE ALL ON TABLE papseq_pdbcs_mv FROM unison;
GRANT ALL ON TABLE papseq_pdbcs_mv TO unison;
GRANT SELECT ON TABLE papseq_pdbcs_mv TO PUBLIC;


SET search_path = pdb, pg_catalog;

--
-- Name: chain; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE chain FROM PUBLIC;
REVOKE ALL ON TABLE chain FROM unison;
GRANT ALL ON TABLE chain TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE chain TO loader;
GRANT SELECT ON TABLE chain TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: domain_digest(integer, integer, text, text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text) FROM PUBLIC;
REVOKE ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text) FROM unison;
GRANT ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text) TO unison;
GRANT ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, note text, OUT digest text) TO PUBLIC;


--
-- Name: params; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE params FROM PUBLIC;
REVOKE ALL ON TABLE params FROM unison;
GRANT ALL ON TABLE params TO unison;
GRANT INSERT,UPDATE ON TABLE params TO loader;
GRANT SELECT ON TABLE params TO PUBLIC;


--
-- Name: pfsignalpnn; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfsignalpnn FROM PUBLIC;
REVOKE ALL ON TABLE pfsignalpnn FROM unison;
GRANT ALL ON TABLE pfsignalpnn TO unison;
GRANT INSERT,UPDATE ON TABLE pfsignalpnn TO loader;
GRANT SELECT ON TABLE pfsignalpnn TO PUBLIC;


--
-- Name: pftmhmm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pftmhmm FROM PUBLIC;
REVOKE ALL ON TABLE pftmhmm FROM unison;
GRANT ALL ON TABLE pftmhmm TO unison;
GRANT INSERT,UPDATE ON TABLE pftmhmm TO loader;
GRANT SELECT ON TABLE pftmhmm TO PUBLIC;


--
-- Name: pftype; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pftype FROM PUBLIC;
REVOKE ALL ON TABLE pftype FROM unison;
GRANT ALL ON TABLE pftype TO unison;
GRANT INSERT,UPDATE ON TABLE pftype TO loader;
GRANT SELECT ON TABLE pftype TO PUBLIC;


--
-- Name: run; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE run FROM PUBLIC;
REVOKE ALL ON TABLE run FROM unison;
GRANT ALL ON TABLE run TO unison;
GRANT SELECT ON TABLE run TO PUBLIC;


--
-- Name: pseq_features_signalpnn_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_signalpnn_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_signalpnn_v FROM unison;
GRANT ALL ON TABLE pseq_features_signalpnn_v TO unison;
GRANT ALL ON TABLE pseq_features_signalpnn_v TO rkh;
GRANT SELECT ON TABLE pseq_features_signalpnn_v TO PUBLIC;


--
-- Name: pseq_features_tmhmm_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_tmhmm_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_tmhmm_v FROM unison;
GRANT ALL ON TABLE pseq_features_tmhmm_v TO unison;
GRANT ALL ON TABLE pseq_features_tmhmm_v TO rkh;
GRANT SELECT ON TABLE pseq_features_tmhmm_v TO PUBLIC;


--
-- Name: pseq_features_tmhmm_excl_signal_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_tmhmm_excl_signal_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_tmhmm_excl_signal_v FROM unison;
GRANT ALL ON TABLE pseq_features_tmhmm_excl_signal_v TO unison;
GRANT ALL ON TABLE pseq_features_tmhmm_excl_signal_v TO rkh;
GRANT SELECT ON TABLE pseq_features_tmhmm_excl_signal_v TO PUBLIC;


--
-- Name: blasts_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE blasts_v FROM PUBLIC;
REVOKE ALL ON TABLE blasts_v FROM unison;
GRANT ALL ON TABLE blasts_v TO unison;
GRANT SELECT ON TABLE blasts_v TO PUBLIC;


--
-- Name: pmprospect; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmprospect FROM PUBLIC;
REVOKE ALL ON TABLE pmprospect FROM unison;
GRANT ALL ON TABLE pmprospect TO unison;
GRANT INSERT,UPDATE ON TABLE pmprospect TO loader;
GRANT REFERENCES ON TABLE pmprospect TO rkh;
GRANT SELECT ON TABLE pmprospect TO PUBLIC;


--
-- Name: pmprospect_scop_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmprospect_scop_v FROM PUBLIC;
REVOKE ALL ON TABLE pmprospect_scop_v FROM unison;
GRANT ALL ON TABLE pmprospect_scop_v TO unison;
GRANT SELECT ON TABLE pmprospect_scop_v TO PUBLIC;


--
-- Name: pmprospect_scop_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmprospect_scop_dv FROM PUBLIC;
REVOKE ALL ON TABLE pmprospect_scop_dv FROM unison;
GRANT ALL ON TABLE pmprospect_scop_dv TO unison;
GRANT SELECT ON TABLE pmprospect_scop_dv TO PUBLIC;


--
-- Name: paprospect_scop_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE paprospect_scop_v FROM PUBLIC;
REVOKE ALL ON TABLE paprospect_scop_v FROM unison;
GRANT ALL ON TABLE paprospect_scop_v TO unison;
GRANT SELECT ON TABLE paprospect_scop_v TO PUBLIC;


--
-- Name: _agg_as_set_finalfunc(anyarray); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _agg_as_set_finalfunc(anyarray) FROM PUBLIC;
REVOKE ALL ON FUNCTION _agg_as_set_finalfunc(anyarray) FROM unison;
GRANT ALL ON FUNCTION _agg_as_set_finalfunc(anyarray) TO unison;
GRANT ALL ON FUNCTION _agg_as_set_finalfunc(anyarray) TO PUBLIC;


--
-- Name: pmap_aln; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_aln FROM PUBLIC;
REVOKE ALL ON TABLE pmap_aln FROM unison;
GRANT ALL ON TABLE pmap_aln TO unison;
GRANT INSERT,DELETE,TRIGGER,UPDATE ON TABLE pmap_aln TO loader;
GRANT SELECT ON TABLE pmap_aln TO PUBLIC;


--
-- Name: pmap_alnhsp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_alnhsp FROM PUBLIC;
REVOKE ALL ON TABLE pmap_alnhsp FROM unison;
GRANT ALL ON TABLE pmap_alnhsp TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pmap_alnhsp TO loader;
GRANT SELECT ON TABLE pmap_alnhsp TO PUBLIC;


--
-- Name: pmap_hsp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_hsp FROM PUBLIC;
REVOKE ALL ON TABLE pmap_hsp FROM unison;
GRANT ALL ON TABLE pmap_hsp TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pmap_hsp TO loader;
GRANT SELECT ON TABLE pmap_hsp TO PUBLIC;


--
-- Name: pmodelset_id(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pmodelset_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pmodelset_id(text) FROM unison;
GRANT ALL ON FUNCTION pmodelset_id(text) TO unison;
GRANT ALL ON FUNCTION pmodelset_id(text) TO PUBLIC;


--
-- Name: current_annotations_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE current_annotations_v FROM PUBLIC;
REVOKE ALL ON TABLE current_annotations_v FROM unison;
GRANT ALL ON TABLE current_annotations_v TO unison;
GRANT SELECT ON TABLE current_annotations_v TO PUBLIC;


SET search_path = ncbi, pg_catalog;

--
-- Name: gene2accession; Type: ACL; Schema: ncbi; Owner: unison
--

REVOKE ALL ON TABLE gene2accession FROM PUBLIC;
REVOKE ALL ON TABLE gene2accession FROM unison;
GRANT ALL ON TABLE gene2accession TO unison;
GRANT SELECT ON TABLE gene2accession TO PUBLIC;


--
-- Name: gene2go; Type: ACL; Schema: ncbi; Owner: unison
--

REVOKE ALL ON TABLE gene2go FROM PUBLIC;
REVOKE ALL ON TABLE gene2go FROM unison;
GRANT ALL ON TABLE gene2go TO unison;
GRANT SELECT ON TABLE gene2go TO PUBLIC;


--
-- Name: gene2unigene; Type: ACL; Schema: ncbi; Owner: unison
--

REVOKE ALL ON TABLE gene2unigene FROM PUBLIC;
REVOKE ALL ON TABLE gene2unigene FROM unison;
GRANT ALL ON TABLE gene2unigene TO unison;
GRANT SELECT ON TABLE gene2unigene TO PUBLIC;


--
-- Name: gene_info; Type: ACL; Schema: ncbi; Owner: unison
--

REVOKE ALL ON TABLE gene_info FROM PUBLIC;
REVOKE ALL ON TABLE gene_info FROM unison;
GRANT ALL ON TABLE gene_info TO unison;
GRANT SELECT ON TABLE gene_info TO PUBLIC;


--
-- Name: generif; Type: ACL; Schema: ncbi; Owner: unison
--

REVOKE ALL ON TABLE generif FROM PUBLIC;
REVOKE ALL ON TABLE generif FROM unison;
GRANT ALL ON TABLE generif TO unison;
GRANT SELECT ON TABLE generif TO PUBLIC;


--
-- Name: mim2gene; Type: ACL; Schema: ncbi; Owner: unison
--

REVOKE ALL ON TABLE mim2gene FROM PUBLIC;
REVOKE ALL ON TABLE mim2gene FROM unison;
GRANT ALL ON TABLE mim2gene TO unison;
GRANT SELECT ON TABLE mim2gene TO PUBLIC;


SET search_path = pdb, pg_catalog;

--
-- Name: ligand; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand FROM PUBLIC;
REVOKE ALL ON TABLE ligand FROM unison;
GRANT ALL ON TABLE ligand TO unison;
GRANT SELECT ON TABLE ligand TO PUBLIC;


--
-- Name: ligand_atoms; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_atoms FROM PUBLIC;
REVOKE ALL ON TABLE ligand_atoms FROM unison;
GRANT ALL ON TABLE ligand_atoms TO unison;
GRANT SELECT ON TABLE ligand_atoms TO PUBLIC;


--
-- Name: ligand_bonds; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_bonds FROM PUBLIC;
REVOKE ALL ON TABLE ligand_bonds FROM unison;
GRANT ALL ON TABLE ligand_bonds TO unison;
GRANT SELECT ON TABLE ligand_bonds TO PUBLIC;


--
-- Name: ligand_descriptor_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_descriptor_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_descriptor_v FROM unison;
GRANT ALL ON TABLE ligand_descriptor_v TO unison;
GRANT SELECT ON TABLE ligand_descriptor_v TO PUBLIC;


--
-- Name: ligand_inchi_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_inchi_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_inchi_v FROM unison;
GRANT ALL ON TABLE ligand_inchi_v TO unison;
GRANT SELECT ON TABLE ligand_inchi_v TO PUBLIC;


--
-- Name: ligand_names_all_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_names_all_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_names_all_v FROM unison;
GRANT ALL ON TABLE ligand_names_all_v TO unison;
GRANT SELECT ON TABLE ligand_names_all_v TO PUBLIC;


--
-- Name: ligand_smiles_acdlabs_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_acdlabs_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_acdlabs_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_acdlabs_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_acdlabs_v TO PUBLIC;


--
-- Name: ligand_smiles_all_cactvs_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_all_cactvs_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_all_cactvs_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_all_cactvs_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_all_cactvs_v TO PUBLIC;


--
-- Name: ligand_smiles_all_oe_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_all_oe_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_all_oe_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_all_oe_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_all_oe_v TO PUBLIC;


--
-- Name: ligand_smiles_all_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_all_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_all_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_all_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_all_v TO PUBLIC;


--
-- Name: ligand_smiles_cactvs_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_cactvs_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_cactvs_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_cactvs_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_cactvs_v TO PUBLIC;


--
-- Name: ligand_smiles_canon_cactvs_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_canon_cactvs_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_canon_cactvs_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_canon_cactvs_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_canon_cactvs_v TO PUBLIC;


--
-- Name: ligand_smiles_canon_oe_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_canon_oe_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_canon_oe_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_canon_oe_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_canon_oe_v TO PUBLIC;


--
-- Name: ligand_smiles_canon_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_canon_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_canon_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_canon_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_canon_v TO PUBLIC;


--
-- Name: ligand_smiles_oe_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_oe_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_oe_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_oe_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_oe_v TO PUBLIC;


--
-- Name: ligand_smiles_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE ligand_smiles_v FROM PUBLIC;
REVOKE ALL ON TABLE ligand_smiles_v FROM unison;
GRANT ALL ON TABLE ligand_smiles_v TO unison;
GRANT SELECT ON TABLE ligand_smiles_v TO PUBLIC;


--
-- Name: pdb_ligand; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE pdb_ligand FROM PUBLIC;
REVOKE ALL ON TABLE pdb_ligand FROM unison;
GRANT ALL ON TABLE pdb_ligand TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pdb_ligand TO loader;
GRANT SELECT ON TABLE pdb_ligand TO PUBLIC;


--
-- Name: pdb_ligand_descriptors_v; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE pdb_ligand_descriptors_v FROM PUBLIC;
REVOKE ALL ON TABLE pdb_ligand_descriptors_v FROM unison;
GRANT ALL ON TABLE pdb_ligand_descriptors_v TO unison;
GRANT SELECT ON TABLE pdb_ligand_descriptors_v TO PUBLIC;


--
-- Name: residue; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE residue FROM PUBLIC;
REVOKE ALL ON TABLE residue FROM unison;
GRANT ALL ON TABLE residue TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE residue TO loader;
GRANT SELECT ON TABLE residue TO PUBLIC;


--
-- Name: summary; Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON TABLE summary FROM PUBLIC;
REVOKE ALL ON TABLE summary FROM unison;
GRANT ALL ON TABLE summary TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE summary TO loader;
GRANT SELECT ON TABLE summary TO PUBLIC;


SET search_path = pgutils, pg_catalog;

--
-- Name: column_descriptions; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE column_descriptions FROM PUBLIC;
REVOKE ALL ON TABLE column_descriptions FROM rkh;
GRANT ALL ON TABLE column_descriptions TO rkh;
GRANT SELECT ON TABLE column_descriptions TO PUBLIC;


--
-- Name: database_sizes; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE database_sizes FROM PUBLIC;
REVOKE ALL ON TABLE database_sizes FROM rkh;
GRANT ALL ON TABLE database_sizes TO rkh;
GRANT SELECT ON TABLE database_sizes TO PUBLIC;


--
-- Name: dependencies; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE dependencies FROM PUBLIC;
REVOKE ALL ON TABLE dependencies FROM rkh;
GRANT ALL ON TABLE dependencies TO rkh;
GRANT SELECT ON TABLE dependencies TO PUBLIC;


--
-- Name: foreign_keys; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE foreign_keys FROM PUBLIC;
REVOKE ALL ON TABLE foreign_keys FROM rkh;
GRANT ALL ON TABLE foreign_keys TO rkh;
GRANT SELECT ON TABLE foreign_keys TO PUBLIC;


--
-- Name: foreign_keys_missing_indexes; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE foreign_keys_missing_indexes FROM PUBLIC;
REVOKE ALL ON TABLE foreign_keys_missing_indexes FROM rkh;
GRANT ALL ON TABLE foreign_keys_missing_indexes TO rkh;
GRANT SELECT ON TABLE foreign_keys_missing_indexes TO PUBLIC;


--
-- Name: foreign_keys_pp; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE foreign_keys_pp FROM PUBLIC;
REVOKE ALL ON TABLE foreign_keys_pp FROM rkh;
GRANT ALL ON TABLE foreign_keys_pp TO rkh;
GRANT SELECT ON TABLE foreign_keys_pp TO PUBLIC;


--
-- Name: function_owner_mismatch; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE function_owner_mismatch FROM PUBLIC;
REVOKE ALL ON TABLE function_owner_mismatch FROM rkh;
GRANT ALL ON TABLE function_owner_mismatch TO rkh;
GRANT SELECT ON TABLE function_owner_mismatch TO PUBLIC;


--
-- Name: index_owner_is_not_table_owner; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE index_owner_is_not_table_owner FROM PUBLIC;
REVOKE ALL ON TABLE index_owner_is_not_table_owner FROM rkh;
GRANT ALL ON TABLE index_owner_is_not_table_owner TO rkh;
GRANT SELECT ON TABLE index_owner_is_not_table_owner TO PUBLIC;


--
-- Name: indexed_tables; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE indexed_tables FROM PUBLIC;
REVOKE ALL ON TABLE indexed_tables FROM rkh;
GRANT ALL ON TABLE indexed_tables TO rkh;
GRANT SELECT ON TABLE indexed_tables TO PUBLIC;


--
-- Name: indexed_tables_cluster; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE indexed_tables_cluster FROM PUBLIC;
REVOKE ALL ON TABLE indexed_tables_cluster FROM rkh;
GRANT ALL ON TABLE indexed_tables_cluster TO rkh;
GRANT SELECT ON TABLE indexed_tables_cluster TO PUBLIC;


--
-- Name: inherited_tables; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE inherited_tables FROM PUBLIC;
REVOKE ALL ON TABLE inherited_tables FROM rkh;
GRANT ALL ON TABLE inherited_tables TO rkh;
GRANT SELECT ON TABLE inherited_tables TO PUBLIC;


--
-- Name: oid_names; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE oid_names FROM PUBLIC;
REVOKE ALL ON TABLE oid_names FROM rkh;
GRANT ALL ON TABLE oid_names TO rkh;
GRANT SELECT ON TABLE oid_names TO PUBLIC;


--
-- Name: schema_not_owned_by_user; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE schema_not_owned_by_user FROM PUBLIC;
REVOKE ALL ON TABLE schema_not_owned_by_user FROM rkh;
GRANT ALL ON TABLE schema_not_owned_by_user TO rkh;
GRANT SELECT ON TABLE schema_not_owned_by_user TO PUBLIC;


--
-- Name: table_sizes; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE table_sizes FROM PUBLIC;
REVOKE ALL ON TABLE table_sizes FROM rkh;
GRANT ALL ON TABLE table_sizes TO rkh;
GRANT SELECT ON TABLE table_sizes TO PUBLIC;


--
-- Name: schema_sizes; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE schema_sizes FROM PUBLIC;
REVOKE ALL ON TABLE schema_sizes FROM rkh;
GRANT ALL ON TABLE schema_sizes TO rkh;
GRANT SELECT ON TABLE schema_sizes TO PUBLIC;


--
-- Name: table_cluster_index; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE table_cluster_index FROM PUBLIC;
REVOKE ALL ON TABLE table_cluster_index FROM rkh;
GRANT ALL ON TABLE table_cluster_index TO rkh;
GRANT SELECT ON TABLE table_cluster_index TO PUBLIC;


--
-- Name: table_columns; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE table_columns FROM PUBLIC;
REVOKE ALL ON TABLE table_columns FROM rkh;
GRANT ALL ON TABLE table_columns TO rkh;
GRANT SELECT ON TABLE table_columns TO PUBLIC;


--
-- Name: table_perms; Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON TABLE table_perms FROM PUBLIC;
REVOKE ALL ON TABLE table_perms FROM rkh;
GRANT ALL ON TABLE table_perms TO rkh;
GRANT SELECT ON TABLE table_perms TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: best_annotation_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE best_annotation_mv FROM PUBLIC;
REVOKE ALL ON TABLE best_annotation_mv FROM unison;
GRANT ALL ON TABLE best_annotation_mv TO unison;
GRANT SELECT ON TABLE best_annotation_mv TO PUBLIC;


--
-- Name: pseq_locus(integer, integer, integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pseq_locus(integer, integer, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION pseq_locus(integer, integer, integer) FROM unison;
GRANT ALL ON FUNCTION pseq_locus(integer, integer, integer) TO unison;
GRANT ALL ON FUNCTION pseq_locus(integer, integer, integer) TO PUBLIC;


--
-- Name: pmap_locus_representative_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_locus_representative_mv FROM PUBLIC;
REVOKE ALL ON TABLE pmap_locus_representative_mv FROM unison;
GRANT ALL ON TABLE pmap_locus_representative_mv TO unison;
GRANT SELECT ON TABLE pmap_locus_representative_mv TO PUBLIC;


SET search_path = sst, pg_catalog;

--
-- Name: v_trans; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE v_trans FROM PUBLIC;
REVOKE ALL ON TABLE v_trans FROM unison;
GRANT ALL ON TABLE v_trans TO unison;
GRANT SELECT ON TABLE v_trans TO PUBLIC;


--
-- Name: v_unq2dna; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE v_unq2dna FROM PUBLIC;
REVOKE ALL ON TABLE v_unq2dna FROM unison;
GRANT ALL ON TABLE v_unq2dna TO unison;
GRANT SELECT ON TABLE v_unq2dna TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: ncbi_pseq_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ncbi_pseq_mv FROM PUBLIC;
REVOKE ALL ON TABLE ncbi_pseq_mv FROM unison;
GRANT ALL ON TABLE ncbi_pseq_mv TO unison;
GRANT SELECT ON TABLE ncbi_pseq_mv TO PUBLIC;


--
-- Name: pmap_gg_representative_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_gg_representative_mv FROM PUBLIC;
REVOKE ALL ON TABLE pmap_gg_representative_mv FROM unison;
GRANT ALL ON TABLE pmap_gg_representative_mv TO unison;
GRANT SELECT ON TABLE pmap_gg_representative_mv TO PUBLIC;


--
-- Name: all_annotations_unsorted_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE all_annotations_unsorted_v FROM PUBLIC;
REVOKE ALL ON TABLE all_annotations_unsorted_v FROM unison;
GRANT ALL ON TABLE all_annotations_unsorted_v TO unison;
GRANT SELECT ON TABLE all_annotations_unsorted_v TO PUBLIC;


--
-- Name: papseq_pdbcs_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE papseq_pdbcs_v FROM PUBLIC;
REVOKE ALL ON TABLE papseq_pdbcs_v FROM unison;
GRANT ALL ON TABLE papseq_pdbcs_v TO unison;
GRANT SELECT ON TABLE papseq_pdbcs_v TO PUBLIC;


SET search_path = tax, pg_catalog;

--
-- Name: gs2tax_id(text); Type: ACL; Schema: tax; Owner: unison
--

REVOKE ALL ON FUNCTION gs2tax_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION gs2tax_id(text) FROM unison;
GRANT ALL ON FUNCTION gs2tax_id(text) TO unison;
GRANT ALL ON FUNCTION gs2tax_id(text) TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: domain_digest(integer, integer, text, integer, double precision); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text) FROM PUBLIC;
REVOKE ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text) FROM unison;
GRANT ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text) TO unison;
GRANT ALL ON FUNCTION domain_digest(pstart integer, pstop integer, name text, score integer, eval double precision, OUT digest text) TO PUBLIC;


--
-- Name: link_url(integer, text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION link_url(integer, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION link_url(integer, text) FROM unison;
GRANT ALL ON FUNCTION link_url(integer, text) TO unison;
GRANT ALL ON FUNCTION link_url(integer, text) TO PUBLIC;


--
-- Name: pseq_features_hmm_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_hmm_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_hmm_v FROM unison;
GRANT ALL ON TABLE pseq_features_hmm_v TO unison;
GRANT ALL ON TABLE pseq_features_hmm_v TO rkh;
GRANT SELECT ON TABLE pseq_features_hmm_v TO PUBLIC;


--
-- Name: palias_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE palias_v FROM PUBLIC;
REVOKE ALL ON TABLE palias_v FROM unison;
GRANT ALL ON TABLE palias_v TO unison;
GRANT SELECT ON TABLE palias_v TO PUBLIC;


--
-- Name: run_history; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE run_history FROM PUBLIC;
REVOKE ALL ON TABLE run_history FROM unison;
GRANT ALL ON TABLE run_history TO unison;
GRANT ALL ON TABLE run_history TO loader;
GRANT SELECT ON TABLE run_history TO PUBLIC;


--
-- Name: pftmhmm_tm_count_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pftmhmm_tm_count_v FROM PUBLIC;
REVOKE ALL ON TABLE pftmhmm_tm_count_v FROM unison;
GRANT ALL ON TABLE pftmhmm_tm_count_v TO unison;
GRANT SELECT ON TABLE pftmhmm_tm_count_v TO PUBLIC;


--
-- Name: psdisorder; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE psdisorder FROM PUBLIC;
REVOKE ALL ON TABLE psdisorder FROM unison;
GRANT ALL ON TABLE psdisorder TO unison;
GRANT INSERT ON TABLE psdisorder TO loader;
GRANT SELECT ON TABLE psdisorder TO PUBLIC;


SET search_path = scop, pg_catalog;

--
-- Name: hie; Type: ACL; Schema: scop; Owner: unison
--

REVOKE ALL ON TABLE hie FROM PUBLIC;
REVOKE ALL ON TABLE hie FROM unison;
GRANT ALL ON TABLE hie TO unison;
GRANT INSERT,UPDATE ON TABLE hie TO loader;
GRANT SELECT ON TABLE hie TO PUBLIC;


SET search_path = sst, pg_catalog;

--
-- Name: dna; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE dna FROM PUBLIC;
REVOKE ALL ON TABLE dna FROM unison;
GRANT ALL ON TABLE dna TO unison;
GRANT SELECT ON TABLE dna TO PUBLIC;


--
-- Name: fam; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE fam FROM PUBLIC;
REVOKE ALL ON TABLE fam FROM unison;
GRANT ALL ON TABLE fam TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE fam TO loader;
GRANT SELECT ON TABLE fam TO PUBLIC;


--
-- Name: pro; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE pro FROM PUBLIC;
REVOKE ALL ON TABLE pro FROM unison;
GRANT ALL ON TABLE pro TO unison;
GRANT SELECT ON TABLE pro TO PUBLIC;


--
-- Name: prodna; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE prodna FROM PUBLIC;
REVOKE ALL ON TABLE prodna FROM unison;
GRANT ALL ON TABLE prodna TO unison;
GRANT SELECT ON TABLE prodna TO PUBLIC;


--
-- Name: unq; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE unq FROM PUBLIC;
REVOKE ALL ON TABLE unq FROM unison;
GRANT ALL ON TABLE unq TO unison;
GRANT SELECT ON TABLE unq TO PUBLIC;


--
-- Name: unqfamily; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE unqfamily FROM PUBLIC;
REVOKE ALL ON TABLE unqfamily FROM unison;
GRANT ALL ON TABLE unqfamily TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE unqfamily TO loader;
GRANT SELECT ON TABLE unqfamily TO PUBLIC;


--
-- Name: unqproform; Type: ACL; Schema: sst; Owner: unison
--

REVOKE ALL ON TABLE unqproform FROM PUBLIC;
REVOKE ALL ON TABLE unqproform FROM unison;
GRANT ALL ON TABLE unqproform TO unison;
GRANT SELECT ON TABLE unqproform TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: _deprecated_pseq_gene_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _deprecated_pseq_gene_v FROM PUBLIC;
REVOKE ALL ON TABLE _deprecated_pseq_gene_v FROM unison;
GRANT ALL ON TABLE _deprecated_pseq_gene_v TO unison;
GRANT SELECT ON TABLE _deprecated_pseq_gene_v TO PUBLIC;


--
-- Name: _infer_tax_id_ensembl_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _infer_tax_id_ensembl_v FROM PUBLIC;
REVOKE ALL ON TABLE _infer_tax_id_ensembl_v FROM unison;
GRANT ALL ON TABLE _infer_tax_id_ensembl_v TO unison;
GRANT SELECT ON TABLE _infer_tax_id_ensembl_v TO loader;


--
-- Name: _infer_tax_id_genengenes_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _infer_tax_id_genengenes_v FROM PUBLIC;
REVOKE ALL ON TABLE _infer_tax_id_genengenes_v FROM unison;
GRANT ALL ON TABLE _infer_tax_id_genengenes_v TO unison;
GRANT SELECT ON TABLE _infer_tax_id_genengenes_v TO loader;


--
-- Name: _infer_tax_id_geneseq_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _infer_tax_id_geneseq_v FROM PUBLIC;
REVOKE ALL ON TABLE _infer_tax_id_geneseq_v FROM unison;
GRANT ALL ON TABLE _infer_tax_id_geneseq_v TO unison;
GRANT SELECT ON TABLE _infer_tax_id_geneseq_v TO loader;


--
-- Name: _infer_tax_id_refseq_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _infer_tax_id_refseq_v FROM PUBLIC;
REVOKE ALL ON TABLE _infer_tax_id_refseq_v FROM unison;
GRANT ALL ON TABLE _infer_tax_id_refseq_v TO unison;
GRANT SELECT ON TABLE _infer_tax_id_refseq_v TO loader;


--
-- Name: _infer_tax_id_uniprot_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _infer_tax_id_uniprot_v FROM PUBLIC;
REVOKE ALL ON TABLE _infer_tax_id_uniprot_v FROM unison;
GRANT ALL ON TABLE _infer_tax_id_uniprot_v TO unison;
GRANT SELECT ON TABLE _infer_tax_id_uniprot_v TO loader;


--
-- Name: _infer_tax_id_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _infer_tax_id_v FROM PUBLIC;
REVOKE ALL ON TABLE _infer_tax_id_v FROM unison;
GRANT ALL ON TABLE _infer_tax_id_v TO unison;
GRANT SELECT ON TABLE _infer_tax_id_v TO loader;


--
-- Name: _infer_tax_id_changed_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _infer_tax_id_changed_v FROM PUBLIC;
REVOKE ALL ON TABLE _infer_tax_id_changed_v FROM unison;
GRANT ALL ON TABLE _infer_tax_id_changed_v TO unison;
GRANT SELECT ON TABLE _infer_tax_id_changed_v TO loader;


--
-- Name: _missing_fk_indexes; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _missing_fk_indexes FROM PUBLIC;
REVOKE ALL ON TABLE _missing_fk_indexes FROM unison;
GRANT ALL ON TABLE _missing_fk_indexes TO unison;
GRANT SELECT ON TABLE _missing_fk_indexes TO PUBLIC;


--
-- Name: _pmsm_pmhmm_expand_by_pfam_name; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _pmsm_pmhmm_expand_by_pfam_name FROM PUBLIC;
REVOKE ALL ON TABLE _pmsm_pmhmm_expand_by_pfam_name FROM unison;
GRANT ALL ON TABLE _pmsm_pmhmm_expand_by_pfam_name TO unison;
GRANT SELECT ON TABLE _pmsm_pmhmm_expand_by_pfam_name TO PUBLIC;


--
-- Name: _pmsm_pmhmm_pfam_upgrade; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _pmsm_pmhmm_pfam_upgrade FROM PUBLIC;
REVOKE ALL ON TABLE _pmsm_pmhmm_pfam_upgrade FROM unison;
GRANT ALL ON TABLE _pmsm_pmhmm_pfam_upgrade TO unison;
GRANT SELECT ON TABLE _pmsm_pmhmm_pfam_upgrade TO PUBLIC;


--
-- Name: _readme; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE _readme FROM PUBLIC;
REVOKE ALL ON TABLE _readme FROM unison;
GRANT ALL ON TABLE _readme TO unison;
GRANT SELECT ON TABLE _readme TO PUBLIC;


--
-- Name: alias_pdbcs_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE alias_pdbcs_v FROM PUBLIC;
REVOKE ALL ON TABLE alias_pdbcs_v FROM unison;
GRANT ALL ON TABLE alias_pdbcs_v TO unison;
GRANT SELECT ON TABLE alias_pdbcs_v TO PUBLIC;


--
-- Name: aliases_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE aliases_v FROM PUBLIC;
REVOKE ALL ON TABLE aliases_v FROM unison;
GRANT ALL ON TABLE aliases_v TO unison;
GRANT SELECT ON TABLE aliases_v TO PUBLIC;


--
-- Name: aliasset_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE aliasset_v FROM PUBLIC;
REVOKE ALL ON TABLE aliasset_v FROM unison;
GRANT ALL ON TABLE aliasset_v TO unison;
GRANT SELECT ON TABLE aliasset_v TO PUBLIC;


--
-- Name: aliasset_alias_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE aliasset_alias_v FROM PUBLIC;
REVOKE ALL ON TABLE aliasset_alias_v FROM unison;
GRANT ALL ON TABLE aliasset_alias_v TO unison;
GRANT SELECT ON TABLE aliasset_alias_v TO PUBLIC;


--
-- Name: all_annotations_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE all_annotations_v FROM PUBLIC;
REVOKE ALL ON TABLE all_annotations_v FROM unison;
GRANT ALL ON TABLE all_annotations_v TO unison;
GRANT SELECT ON TABLE all_annotations_v TO PUBLIC;


--
-- Name: known_bcl2_overlaps_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE known_bcl2_overlaps_mv FROM PUBLIC;
REVOKE ALL ON TABLE known_bcl2_overlaps_mv FROM unison;
GRANT ALL ON TABLE known_bcl2_overlaps_mv TO unison;
GRANT SELECT ON TABLE known_bcl2_overlaps_mv TO PUBLIC;


--
-- Name: bcl2_zebrafish_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE bcl2_zebrafish_v FROM PUBLIC;
REVOKE ALL ON TABLE bcl2_zebrafish_v FROM unison;
GRANT ALL ON TABLE bcl2_zebrafish_v TO unison;
GRANT SELECT ON TABLE bcl2_zebrafish_v TO PUBLIC;


--
-- Name: bcl2_zebrafish_domains_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE bcl2_zebrafish_domains_v FROM PUBLIC;
REVOKE ALL ON TABLE bcl2_zebrafish_domains_v FROM unison;
GRANT ALL ON TABLE bcl2_zebrafish_domains_v TO unison;
GRANT SELECT ON TABLE bcl2_zebrafish_domains_v TO PUBLIC;


--
-- Name: best_annotation_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE best_annotation_v FROM PUBLIC;
REVOKE ALL ON TABLE best_annotation_v FROM unison;
GRANT ALL ON TABLE best_annotation_v TO unison;
GRANT SELECT ON TABLE best_annotation_v TO PUBLIC;


--
-- Name: better_annotations_unsorted_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE better_annotations_unsorted_v FROM PUBLIC;
REVOKE ALL ON TABLE better_annotations_unsorted_v FROM unison;
GRANT ALL ON TABLE better_annotations_unsorted_v TO unison;
GRANT SELECT ON TABLE better_annotations_unsorted_v TO PUBLIC;


--
-- Name: better_annotations_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE better_annotations_v FROM PUBLIC;
REVOKE ALL ON TABLE better_annotations_v FROM unison;
GRANT ALL ON TABLE better_annotations_v TO unison;
GRANT SELECT ON TABLE better_annotations_v TO PUBLIC;


--
-- Name: blatloci; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE blatloci FROM PUBLIC;
REVOKE ALL ON TABLE blatloci FROM unison;
GRANT ALL ON TABLE blatloci TO unison;
GRANT SELECT ON TABLE blatloci TO PUBLIC;


--
-- Name: canned_views; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE canned_views FROM PUBLIC;
REVOKE ALL ON TABLE canned_views FROM unison;
GRANT ALL ON TABLE canned_views TO unison;
GRANT SELECT,INSERT,DELETE ON TABLE canned_views TO cavs;
GRANT SELECT ON TABLE canned_views TO PUBLIC;


--
-- Name: e3_and_bh3_cv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE e3_and_bh3_cv FROM PUBLIC;
REVOKE ALL ON TABLE e3_and_bh3_cv FROM unison;
GRANT ALL ON TABLE e3_and_bh3_cv TO unison;
GRANT SELECT ON TABLE e3_and_bh3_cv TO PUBLIC;


--
-- Name: ensembl_coordinates_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ensembl_coordinates_mv FROM PUBLIC;
REVOKE ALL ON TABLE ensembl_coordinates_mv FROM unison;
GRANT ALL ON TABLE ensembl_coordinates_mv TO unison;
GRANT SELECT ON TABLE ensembl_coordinates_mv TO PUBLIC;


--
-- Name: ensembl_coordinates_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ensembl_coordinates_v FROM PUBLIC;
REVOKE ALL ON TABLE ensembl_coordinates_v FROM unison;
GRANT ALL ON TABLE ensembl_coordinates_v TO unison;
GRANT SELECT ON TABLE ensembl_coordinates_v TO PUBLIC;


--
-- Name: ensembl_unambiguous_coordinates_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ensembl_unambiguous_coordinates_mv FROM PUBLIC;
REVOKE ALL ON TABLE ensembl_unambiguous_coordinates_mv FROM unison;
GRANT ALL ON TABLE ensembl_unambiguous_coordinates_mv TO unison;
GRANT SELECT ON TABLE ensembl_unambiguous_coordinates_mv TO PUBLIC;


--
-- Name: ensembl_unambiguous_coordinates_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ensembl_unambiguous_coordinates_v FROM PUBLIC;
REVOKE ALL ON TABLE ensembl_unambiguous_coordinates_v FROM unison;
GRANT ALL ON TABLE ensembl_unambiguous_coordinates_v TO unison;
GRANT SELECT ON TABLE ensembl_unambiguous_coordinates_v TO PUBLIC;


--
-- Name: ensembl_unambiguous_overlaps_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ensembl_unambiguous_overlaps_v FROM PUBLIC;
REVOKE ALL ON TABLE ensembl_unambiguous_overlaps_v FROM unison;
GRANT ALL ON TABLE ensembl_unambiguous_overlaps_v TO unison;
GRANT SELECT ON TABLE ensembl_unambiguous_overlaps_v TO PUBLIC;


--
-- Name: sequence_ends(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION sequence_ends(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION sequence_ends(text) FROM unison;
GRANT ALL ON FUNCTION sequence_ends(text) TO unison;
GRANT ALL ON FUNCTION sequence_ends(text) TO PUBLIC;


--
-- Name: extended_annotation_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE extended_annotation_v FROM PUBLIC;
REVOKE ALL ON TABLE extended_annotation_v FROM unison;
GRANT ALL ON TABLE extended_annotation_v TO unison;
GRANT SELECT ON TABLE extended_annotation_v TO PUBLIC;


--
-- Name: fn3_prospect_pmodelset_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE fn3_prospect_pmodelset_dv FROM PUBLIC;
REVOKE ALL ON TABLE fn3_prospect_pmodelset_dv FROM unison;
GRANT ALL ON TABLE fn3_prospect_pmodelset_dv TO unison;
GRANT SELECT ON TABLE fn3_prospect_pmodelset_dv TO PUBLIC;


--
-- Name: genasm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE genasm FROM PUBLIC;
REVOKE ALL ON TABLE genasm FROM unison;
GRANT ALL ON TABLE genasm TO unison;
GRANT INSERT,UPDATE ON TABLE genasm TO loader;
GRANT SELECT,REFERENCES ON TABLE genasm TO PUBLIC;


--
-- Name: gg_famid_pseq_id_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE gg_famid_pseq_id_mv FROM PUBLIC;
REVOKE ALL ON TABLE gg_famid_pseq_id_mv FROM unison;
GRANT ALL ON TABLE gg_famid_pseq_id_mv TO unison;
GRANT SELECT ON TABLE gg_famid_pseq_id_mv TO PUBLIC;


--
-- Name: gg_famid_pseq_id_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE gg_famid_pseq_id_v FROM PUBLIC;
REVOKE ALL ON TABLE gg_famid_pseq_id_v FROM unison;
GRANT ALL ON TABLE gg_famid_pseq_id_v TO unison;
GRANT SELECT ON TABLE gg_famid_pseq_id_v TO PUBLIC;


--
-- Name: homologene_paralogs_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE homologene_paralogs_v FROM PUBLIC;
REVOKE ALL ON TABLE homologene_paralogs_v FROM unison;
GRANT ALL ON TABLE homologene_paralogs_v TO unison;
GRANT SELECT ON TABLE homologene_paralogs_v TO PUBLIC;


--
-- Name: hmm_pmodel_id(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION hmm_pmodel_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION hmm_pmodel_id(text) FROM unison;
GRANT ALL ON FUNCTION hmm_pmodel_id(text) TO unison;
GRANT ALL ON FUNCTION hmm_pmodel_id(text) TO PUBLIC;


--
-- Name: ig_tm_itim_cv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ig_tm_itim_cv FROM PUBLIC;
REVOKE ALL ON TABLE ig_tm_itim_cv FROM unison;
GRANT ALL ON TABLE ig_tm_itim_cv TO unison;
GRANT SELECT ON TABLE ig_tm_itim_cv TO PUBLIC;


--
-- Name: pseq_sst_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_sst_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_sst_v FROM unison;
GRANT ALL ON TABLE pseq_sst_v TO unison;
GRANT SELECT ON TABLE pseq_sst_v TO PUBLIC;


--
-- Name: human_itims_w_unqs_cv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE human_itims_w_unqs_cv FROM PUBLIC;
REVOKE ALL ON TABLE human_itims_w_unqs_cv FROM unison;
GRANT ALL ON TABLE human_itims_w_unqs_cv TO unison;
GRANT SELECT ON TABLE human_itims_w_unqs_cv TO PUBLIC;


--
-- Name: ig_prospect_pmodelset_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ig_prospect_pmodelset_dv FROM PUBLIC;
REVOKE ALL ON TABLE ig_prospect_pmodelset_dv FROM unison;
GRANT ALL ON TABLE ig_prospect_pmodelset_dv TO unison;
GRANT SELECT ON TABLE ig_prospect_pmodelset_dv TO PUBLIC;


--
-- Name: ig_tm_itim2_cv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ig_tm_itim2_cv FROM PUBLIC;
REVOKE ALL ON TABLE ig_tm_itim2_cv FROM unison;
GRANT ALL ON TABLE ig_tm_itim2_cv TO unison;
GRANT SELECT ON TABLE ig_tm_itim2_cv TO PUBLIC;


--
-- Name: itxm_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE itxm_v FROM PUBLIC;
REVOKE ALL ON TABLE itxm_v FROM unison;
GRANT ALL ON TABLE itxm_v TO unison;
GRANT SELECT ON TABLE itxm_v TO PUBLIC;


--
-- Name: itxm_w_unq_fam_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE itxm_w_unq_fam_v FROM PUBLIC;
REVOKE ALL ON TABLE itxm_w_unq_fam_v FROM unison;
GRANT ALL ON TABLE itxm_w_unq_fam_v TO unison;
GRANT SELECT ON TABLE itxm_w_unq_fam_v TO PUBLIC;


--
-- Name: known_bcl2_overlaps_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE known_bcl2_overlaps_v FROM PUBLIC;
REVOKE ALL ON TABLE known_bcl2_overlaps_v FROM unison;
GRANT ALL ON TABLE known_bcl2_overlaps_v TO unison;
GRANT SELECT ON TABLE known_bcl2_overlaps_v TO PUBLIC;


--
-- Name: meta; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE meta FROM PUBLIC;
REVOKE ALL ON TABLE meta FROM unison;
GRANT ALL ON TABLE meta TO unison;
GRANT INSERT,UPDATE ON TABLE meta TO loader;
GRANT SELECT ON TABLE meta TO PUBLIC;


--
-- Name: mint; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE mint FROM PUBLIC;
REVOKE ALL ON TABLE mint FROM unison;
GRANT ALL ON TABLE mint TO unison;
GRANT INSERT ON TABLE mint TO loader;
GRANT SELECT ON TABLE mint TO PUBLIC;


--
-- Name: mint_one_way_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE mint_one_way_v FROM PUBLIC;
REVOKE ALL ON TABLE mint_one_way_v FROM unison;
GRANT ALL ON TABLE mint_one_way_v TO unison;
GRANT SELECT ON TABLE mint_one_way_v TO PUBLIC;


--
-- Name: mint_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE mint_v FROM PUBLIC;
REVOKE ALL ON TABLE mint_v FROM unison;
GRANT ALL ON TABLE mint_v TO unison;
GRANT SELECT ON TABLE mint_v TO PUBLIC;


--
-- Name: ncbi_pseq_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE ncbi_pseq_v FROM PUBLIC;
REVOKE ALL ON TABLE ncbi_pseq_v FROM unison;
GRANT ALL ON TABLE ncbi_pseq_v TO unison;
GRANT SELECT ON TABLE ncbi_pseq_v TO PUBLIC;


--
-- Name: nearby_sequences_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE nearby_sequences_v FROM PUBLIC;
REVOKE ALL ON TABLE nearby_sequences_v FROM unison;
GRANT ALL ON TABLE nearby_sequences_v TO unison;
GRANT SELECT ON TABLE nearby_sequences_v TO PUBLIC;


--
-- Name: orphaned_sequences_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE orphaned_sequences_v FROM PUBLIC;
REVOKE ALL ON TABLE orphaned_sequences_v FROM unison;
GRANT ALL ON TABLE orphaned_sequences_v TO unison;
GRANT SELECT ON TABLE orphaned_sequences_v TO PUBLIC;


--
-- Name: p2gblataln_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE p2gblataln_v FROM PUBLIC;
REVOKE ALL ON TABLE p2gblataln_v FROM unison;
GRANT ALL ON TABLE p2gblataln_v TO unison;
GRANT SELECT ON TABLE p2gblataln_v TO PUBLIC;


--
-- Name: paprospect_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE paprospect_v FROM PUBLIC;
REVOKE ALL ON TABLE paprospect_v FROM unison;
GRANT ALL ON TABLE paprospect_v TO unison;
GRANT SELECT ON TABLE paprospect_v TO PUBLIC;


--
-- Name: papssm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE papssm FROM PUBLIC;
REVOKE ALL ON TABLE papssm FROM unison;
GRANT ALL ON TABLE papssm TO unison;
GRANT INSERT ON TABLE papssm TO loader;
GRANT SELECT ON TABLE papssm TO PUBLIC;


--
-- Name: params_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE params_v FROM PUBLIC;
REVOKE ALL ON TABLE params_v FROM unison;
GRANT ALL ON TABLE params_v TO unison;
GRANT SELECT ON TABLE params_v TO PUBLIC;


--
-- Name: pataa_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pataa_v FROM PUBLIC;
REVOKE ALL ON TABLE pataa_v FROM unison;
GRANT ALL ON TABLE pataa_v TO unison;
GRANT SELECT ON TABLE pataa_v TO PUBLIC;


--
-- Name: patents_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE patents_v FROM PUBLIC;
REVOKE ALL ON TABLE patents_v FROM unison;
GRANT ALL ON TABLE patents_v TO unison;
GRANT SELECT ON TABLE patents_v TO PUBLIC;


--
-- Name: patent_count_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE patent_count_v FROM PUBLIC;
REVOKE ALL ON TABLE patent_count_v FROM unison;
GRANT ALL ON TABLE patent_count_v TO unison;
GRANT SELECT ON TABLE patent_count_v TO PUBLIC;


--
-- Name: patents_unsorted_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE patents_unsorted_v FROM PUBLIC;
REVOKE ALL ON TABLE patents_unsorted_v FROM unison;
GRANT ALL ON TABLE patents_unsorted_v TO unison;
GRANT SELECT ON TABLE patents_unsorted_v TO PUBLIC;


--
-- Name: pcluster; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pcluster FROM PUBLIC;
REVOKE ALL ON TABLE pcluster FROM unison;
GRANT ALL ON TABLE pcluster TO unison;
GRANT SELECT,INSERT,UPDATE ON TABLE pcluster TO loader;
GRANT SELECT,INSERT ON TABLE pcluster TO cavs;
GRANT SELECT,REFERENCES ON TABLE pcluster TO PUBLIC;


--
-- Name: pcluster_member; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pcluster_member FROM PUBLIC;
REVOKE ALL ON TABLE pcluster_member FROM unison;
GRANT ALL ON TABLE pcluster_member TO unison;
GRANT SELECT,INSERT,UPDATE ON TABLE pcluster_member TO loader;
GRANT SELECT,INSERT ON TABLE pcluster_member TO cavs;
GRANT SELECT,REFERENCES ON TABLE pcluster_member TO PUBLIC;


--
-- Name: perftest_def; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE perftest_def FROM PUBLIC;
REVOKE ALL ON TABLE perftest_def FROM unison;
GRANT ALL ON TABLE perftest_def TO unison;
GRANT SELECT ON TABLE perftest_def TO PUBLIC;


--
-- Name: perftest_platform; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE perftest_platform FROM PUBLIC;
REVOKE ALL ON TABLE perftest_platform FROM unison;
GRANT ALL ON TABLE perftest_platform TO unison;
GRANT SELECT ON TABLE perftest_platform TO PUBLIC;


--
-- Name: perftest_result; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE perftest_result FROM PUBLIC;
REVOKE ALL ON TABLE perftest_result FROM unison;
GRANT ALL ON TABLE perftest_result TO unison;
GRANT SELECT ON TABLE perftest_result TO PUBLIC;


--
-- Name: perftest_run; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE perftest_run FROM PUBLIC;
REVOKE ALL ON TABLE perftest_run FROM unison;
GRANT ALL ON TABLE perftest_run TO unison;
GRANT SELECT ON TABLE perftest_run TO PUBLIC;


--
-- Name: pfantigenic; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfantigenic FROM PUBLIC;
REVOKE ALL ON TABLE pfantigenic FROM unison;
GRANT ALL ON TABLE pfantigenic TO unison;
GRANT INSERT ON TABLE pfantigenic TO loader;
GRANT SELECT ON TABLE pfantigenic TO PUBLIC;


--
-- Name: pfantigenic_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfantigenic_v FROM PUBLIC;
REVOKE ALL ON TABLE pfantigenic_v FROM unison;
GRANT ALL ON TABLE pfantigenic_v TO unison;
GRANT SELECT ON TABLE pfantigenic_v TO PUBLIC;


--
-- Name: pfbigpi; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfbigpi FROM PUBLIC;
REVOKE ALL ON TABLE pfbigpi FROM unison;
GRANT ALL ON TABLE pfbigpi TO unison;
GRANT INSERT ON TABLE pfbigpi TO loader;
GRANT SELECT ON TABLE pfbigpi TO PUBLIC;


--
-- Name: pfbigpi_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfbigpi_v FROM PUBLIC;
REVOKE ALL ON TABLE pfbigpi_v FROM unison;
GRANT ALL ON TABLE pfbigpi_v TO unison;
GRANT SELECT ON TABLE pfbigpi_v TO PUBLIC;


--
-- Name: pseq_id_sequence(integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pseq_id_sequence(pseq_id integer, OUT sequence text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pseq_id_sequence(pseq_id integer, OUT sequence text) FROM unison;
GRANT ALL ON FUNCTION pseq_id_sequence(pseq_id integer, OUT sequence text) TO unison;
GRANT ALL ON FUNCTION pseq_id_sequence(pseq_id integer, OUT sequence text) TO PUBLIC;


--
-- Name: pfnetphos; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfnetphos FROM PUBLIC;
REVOKE ALL ON TABLE pfnetphos FROM unison;
GRANT ALL ON TABLE pfnetphos TO unison;
GRANT SELECT ON TABLE pfnetphos TO PUBLIC;
GRANT INSERT ON TABLE pfnetphos TO loader;


--
-- Name: pfnetphos_site_predictions_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfnetphos_site_predictions_v FROM PUBLIC;
REVOKE ALL ON TABLE pfnetphos_site_predictions_v FROM unison;
GRANT ALL ON TABLE pfnetphos_site_predictions_v TO unison;
GRANT SELECT ON TABLE pfnetphos_site_predictions_v TO PUBLIC;


--
-- Name: pfpepcoil; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfpepcoil FROM PUBLIC;
REVOKE ALL ON TABLE pfpepcoil FROM unison;
GRANT ALL ON TABLE pfpepcoil TO unison;
GRANT SELECT ON TABLE pfpepcoil TO PUBLIC;
GRANT INSERT ON TABLE pfpepcoil TO loader;


--
-- Name: pfpsipred; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfpsipred FROM PUBLIC;
REVOKE ALL ON TABLE pfpsipred FROM unison;
GRANT ALL ON TABLE pfpsipred TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pfpsipred TO loader;
GRANT SELECT ON TABLE pfpsipred TO PUBLIC;


--
-- Name: pfregexp_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfregexp_v FROM PUBLIC;
REVOKE ALL ON TABLE pfregexp_v FROM unison;
GRANT ALL ON TABLE pfregexp_v TO unison;
GRANT SELECT ON TABLE pfregexp_v TO PUBLIC;


--
-- Name: pfseg; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfseg FROM PUBLIC;
REVOKE ALL ON TABLE pfseg FROM unison;
GRANT ALL ON TABLE pfseg TO unison;
GRANT SELECT ON TABLE pfseg TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE pfseg TO loader;


--
-- Name: pfsigcleave; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfsigcleave FROM PUBLIC;
REVOKE ALL ON TABLE pfsigcleave FROM unison;
GRANT ALL ON TABLE pfsigcleave TO unison;
GRANT INSERT,UPDATE ON TABLE pfsigcleave TO loader;
GRANT SELECT ON TABLE pfsigcleave TO PUBLIC;


--
-- Name: pfsignalphmm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfsignalphmm FROM PUBLIC;
REVOKE ALL ON TABLE pfsignalphmm FROM unison;
GRANT ALL ON TABLE pfsignalphmm TO unison;
GRANT INSERT,UPDATE ON TABLE pfsignalphmm TO loader;
GRANT SELECT ON TABLE pfsignalphmm TO PUBLIC;


--
-- Name: pfsignalphmm_pred; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfsignalphmm_pred FROM PUBLIC;
REVOKE ALL ON TABLE pfsignalphmm_pred FROM unison;
GRANT ALL ON TABLE pfsignalphmm_pred TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pfsignalphmm_pred TO loader;
GRANT SELECT ON TABLE pfsignalphmm_pred TO PUBLIC;


--
-- Name: pfsignalphmm_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pfsignalphmm_v FROM PUBLIC;
REVOKE ALL ON TABLE pfsignalphmm_v FROM unison;
GRANT ALL ON TABLE pfsignalphmm_v TO unison;
GRANT SELECT ON TABLE pfsignalphmm_v TO PUBLIC;


--
-- Name: pftmhmm_ecd_length_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pftmhmm_ecd_length_v FROM PUBLIC;
REVOKE ALL ON TABLE pftmhmm_ecd_length_v FROM unison;
GRANT ALL ON TABLE pftmhmm_ecd_length_v TO unison;
GRANT SELECT ON TABLE pftmhmm_ecd_length_v TO PUBLIC;


--
-- Name: pftmhmm_tms_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pftmhmm_tms_v FROM PUBLIC;
REVOKE ALL ON TABLE pftmhmm_tms_v FROM unison;
GRANT ALL ON TABLE pftmhmm_tms_v TO unison;
GRANT SELECT ON TABLE pftmhmm_tms_v TO PUBLIC;


--
-- Name: pftype_preferred_run_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pftype_preferred_run_v FROM PUBLIC;
REVOKE ALL ON TABLE pftype_preferred_run_v FROM unison;
GRANT ALL ON TABLE pftype_preferred_run_v TO unison;
GRANT SELECT ON TABLE pftype_preferred_run_v TO PUBLIC;


--
-- Name: pmap_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_v FROM unison;
GRANT ALL ON TABLE pmap_v TO unison;
GRANT SELECT ON TABLE pmap_v TO PUBLIC;


--
-- Name: pmap_best_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_best_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_best_v FROM unison;
GRANT ALL ON TABLE pmap_best_v TO unison;
GRANT SELECT ON TABLE pmap_best_v TO PUBLIC;


--
-- Name: pmap_ambiguous_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_ambiguous_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_ambiguous_v FROM unison;
GRANT ALL ON TABLE pmap_ambiguous_v TO unison;
GRANT SELECT ON TABLE pmap_ambiguous_v TO PUBLIC;


--
-- Name: pmap_unambiguous_overlaps_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_unambiguous_overlaps_mv FROM PUBLIC;
REVOKE ALL ON TABLE pmap_unambiguous_overlaps_mv FROM unison;
GRANT ALL ON TABLE pmap_unambiguous_overlaps_mv TO unison;
GRANT SELECT ON TABLE pmap_unambiguous_overlaps_mv TO PUBLIC;


--
-- Name: pmap_gg_representative_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_gg_representative_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_gg_representative_v FROM unison;
GRANT ALL ON TABLE pmap_gg_representative_v TO unison;
GRANT SELECT ON TABLE pmap_gg_representative_v TO PUBLIC;


--
-- Name: pmap_locus_representative_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_locus_representative_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_locus_representative_v FROM unison;
GRANT ALL ON TABLE pmap_locus_representative_v TO unison;
GRANT SELECT ON TABLE pmap_locus_representative_v TO PUBLIC;


--
-- Name: pmap_pfam_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_pfam_mv FROM PUBLIC;
REVOKE ALL ON TABLE pmap_pfam_mv FROM unison;
GRANT ALL ON TABLE pmap_pfam_mv TO unison;
GRANT SELECT ON TABLE pmap_pfam_mv TO PUBLIC;


--
-- Name: pmap_unambiguous_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_unambiguous_mv FROM PUBLIC;
REVOKE ALL ON TABLE pmap_unambiguous_mv FROM unison;
GRANT ALL ON TABLE pmap_unambiguous_mv TO unison;
GRANT SELECT ON TABLE pmap_unambiguous_mv TO PUBLIC;


--
-- Name: pseq_features_pfam_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_pfam_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_pfam_v FROM unison;
GRANT ALL ON TABLE pseq_features_pfam_v TO unison;
GRANT SELECT ON TABLE pseq_features_pfam_v TO PUBLIC;


--
-- Name: pmap_pfam_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_pfam_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_pfam_v FROM unison;
GRANT ALL ON TABLE pmap_pfam_v TO unison;
GRANT SELECT ON TABLE pmap_pfam_v TO PUBLIC;


--
-- Name: pmap_unambiguous_overlaps_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_unambiguous_overlaps_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_unambiguous_overlaps_v FROM unison;
GRANT ALL ON TABLE pmap_unambiguous_overlaps_v TO unison;
GRANT SELECT ON TABLE pmap_unambiguous_overlaps_v TO PUBLIC;


--
-- Name: pmap_unambiguous_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmap_unambiguous_v FROM PUBLIC;
REVOKE ALL ON TABLE pmap_unambiguous_v FROM unison;
GRANT ALL ON TABLE pmap_unambiguous_v TO unison;
GRANT SELECT ON TABLE pmap_unambiguous_v TO PUBLIC;


--
-- Name: pmodel2go; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmodel2go FROM PUBLIC;
REVOKE ALL ON TABLE pmodel2go FROM unison;
GRANT ALL ON TABLE pmodel2go TO unison;
GRANT SELECT ON TABLE pmodel2go TO PUBLIC;


--
-- Name: pmsm_pmpssm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmsm_pmpssm FROM PUBLIC;
REVOKE ALL ON TABLE pmsm_pmpssm FROM unison;
GRANT ALL ON TABLE pmsm_pmpssm TO unison;
GRANT SELECT ON TABLE pmsm_pmpssm TO PUBLIC;


--
-- Name: pmodelset_summary_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmodelset_summary_v FROM PUBLIC;
REVOKE ALL ON TABLE pmodelset_summary_v FROM unison;
GRANT ALL ON TABLE pmodelset_summary_v TO unison;
GRANT SELECT ON TABLE pmodelset_summary_v TO PUBLIC;


--
-- Name: pmodelsetsummary; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmodelsetsummary FROM PUBLIC;
REVOKE ALL ON TABLE pmodelsetsummary FROM unison;
GRANT ALL ON TABLE pmodelsetsummary TO unison;
GRANT INSERT,UPDATE ON TABLE pmodelsetsummary TO loader;
GRANT SELECT ON TABLE pmodelsetsummary TO PUBLIC;


--
-- Name: pmpssm; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmpssm FROM PUBLIC;
REVOKE ALL ON TABLE pmpssm FROM unison;
GRANT ALL ON TABLE pmpssm TO unison;
GRANT INSERT,UPDATE ON TABLE pmpssm TO loader;
GRANT SELECT ON TABLE pmpssm TO PUBLIC;


--
-- Name: pmsm_pmhmm_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pmsm_pmhmm_v FROM PUBLIC;
REVOKE ALL ON TABLE pmsm_pmhmm_v FROM unison;
GRANT ALL ON TABLE pmsm_pmhmm_v TO unison;
GRANT SELECT ON TABLE pmsm_pmhmm_v TO PUBLIC;


--
-- Name: pnote; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pnote FROM PUBLIC;
REVOKE ALL ON TABLE pnote FROM unison;
GRANT ALL ON TABLE pnote TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE pnote TO loader;
GRANT SELECT,INSERT ON TABLE pnote TO PUBLIC;


--
-- Name: porigin; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE porigin FROM PUBLIC;
REVOKE ALL ON TABLE porigin FROM unison;
GRANT ALL ON TABLE porigin TO unison;
GRANT SELECT ON TABLE porigin TO PUBLIC;


--
-- Name: pseq2go; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq2go FROM PUBLIC;
REVOKE ALL ON TABLE pseq2go FROM unison;
GRANT ALL ON TABLE pseq2go TO unison;
GRANT SELECT ON TABLE pseq2go TO PUBLIC;


SET search_path = unison_aux, pg_catalog;

--
-- Name: cytoband_hg18; Type: ACL; Schema: unison_aux; Owner: unison
--

REVOKE ALL ON TABLE cytoband_hg18 FROM PUBLIC;
REVOKE ALL ON TABLE cytoband_hg18 FROM unison;
GRANT ALL ON TABLE cytoband_hg18 TO unison;
GRANT SELECT ON TABLE cytoband_hg18 TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: pseq_cytoband_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_cytoband_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_cytoband_v FROM unison;
GRANT ALL ON TABLE pseq_cytoband_v TO unison;
GRANT SELECT ON TABLE pseq_cytoband_v TO PUBLIC;


--
-- Name: pseq_features_bigpi_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_bigpi_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_bigpi_v FROM unison;
GRANT ALL ON TABLE pseq_features_bigpi_v TO unison;
GRANT ALL ON TABLE pseq_features_bigpi_v TO rkh;
GRANT SELECT ON TABLE pseq_features_bigpi_v TO PUBLIC;


--
-- Name: aa_1_to_3(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION aa_1_to_3(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION aa_1_to_3(text) FROM unison;
GRANT ALL ON FUNCTION aa_1_to_3(text) TO unison;
GRANT ALL ON FUNCTION aa_1_to_3(text) TO PUBLIC;


--
-- Name: domain_digest(integer, text, text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION domain_digest(pstart integer, name text, note text, OUT digest text) FROM PUBLIC;
REVOKE ALL ON FUNCTION domain_digest(pstart integer, name text, note text, OUT digest text) FROM unison;
GRANT ALL ON FUNCTION domain_digest(pstart integer, name text, note text, OUT digest text) TO unison;
GRANT ALL ON FUNCTION domain_digest(pstart integer, name text, note text, OUT digest text) TO PUBLIC;


--
-- Name: pseq_features_netphos_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_netphos_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_netphos_v FROM unison;
GRANT ALL ON TABLE pseq_features_netphos_v TO unison;
GRANT SELECT ON TABLE pseq_features_netphos_v TO PUBLIC;


--
-- Name: pseq_features_prosite_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_prosite_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_prosite_v FROM unison;
GRANT ALL ON TABLE pseq_features_prosite_v TO unison;
GRANT SELECT ON TABLE pseq_features_prosite_v TO PUBLIC;


--
-- Name: pseq_features_regexp_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_regexp_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_regexp_v FROM unison;
GRANT ALL ON TABLE pseq_features_regexp_v TO unison;
GRANT ALL ON TABLE pseq_features_regexp_v TO rkh;
GRANT SELECT ON TABLE pseq_features_regexp_v TO PUBLIC;


--
-- Name: pdb_seq_pos(text, text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pdb_seq_pos(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pdb_seq_pos(text, text) FROM unison;
GRANT ALL ON FUNCTION pdb_seq_pos(text, text) TO unison;
GRANT ALL ON FUNCTION pdb_seq_pos(text, text) TO PUBLIC;


--
-- Name: scop_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE scop_v FROM PUBLIC;
REVOKE ALL ON TABLE scop_v FROM unison;
GRANT ALL ON TABLE scop_v TO unison;
GRANT SELECT ON TABLE scop_v TO PUBLIC;


--
-- Name: pseq_features_scop_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_scop_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_scop_v FROM unison;
GRANT ALL ON TABLE pseq_features_scop_v TO unison;
GRANT SELECT ON TABLE pseq_features_scop_v TO PUBLIC;


--
-- Name: pseq_features_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_features_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_v FROM unison;
GRANT ALL ON TABLE pseq_features_v TO unison;
GRANT ALL ON TABLE pseq_features_v TO rkh;
GRANT SELECT ON TABLE pseq_features_v TO PUBLIC;


--
-- Name: pseq_gene_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_gene_mv FROM PUBLIC;
REVOKE ALL ON TABLE pseq_gene_mv FROM unison;
GRANT ALL ON TABLE pseq_gene_mv TO unison;
GRANT SELECT ON TABLE pseq_gene_mv TO PUBLIC;


--
-- Name: pseq_gene_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_gene_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_gene_v FROM unison;
GRANT ALL ON TABLE pseq_gene_v TO unison;
GRANT SELECT ON TABLE pseq_gene_v TO PUBLIC;


--
-- Name: pseq_generif_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_generif_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_generif_v FROM unison;
GRANT ALL ON TABLE pseq_generif_v TO unison;
GRANT SELECT ON TABLE pseq_generif_v TO PUBLIC;


--
-- Name: pseq_id_sets_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_id_sets_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_id_sets_v FROM unison;
GRANT ALL ON TABLE pseq_id_sets_v TO unison;
GRANT SELECT ON TABLE pseq_id_sets_v TO PUBLIC;


--
-- Name: pseq_probe_mv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_probe_mv FROM PUBLIC;
REVOKE ALL ON TABLE pseq_probe_mv FROM unison;
GRANT ALL ON TABLE pseq_probe_mv TO unison;
GRANT SELECT ON TABLE pseq_probe_mv TO PUBLIC;


--
-- Name: pseq_probe_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_probe_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_probe_v FROM unison;
GRANT ALL ON TABLE pseq_probe_v TO unison;
GRANT SELECT ON TABLE pseq_probe_v TO PUBLIC;


--
-- Name: mol_wt(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION mol_wt(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION mol_wt(text) FROM unison;
GRANT ALL ON FUNCTION mol_wt(text) TO unison;
GRANT ALL ON FUNCTION mol_wt(text) TO PUBLIC;


--
-- Name: pi(text, text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pi(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pi(text, text) FROM unison;
GRANT ALL ON FUNCTION pi(text, text) TO unison;
GRANT ALL ON FUNCTION pi(text, text) TO PUBLIC;


--
-- Name: pseq_prop_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_prop_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_prop_v FROM unison;
GRANT ALL ON TABLE pseq_prop_v TO unison;
GRANT SELECT ON TABLE pseq_prop_v TO PUBLIC;


--
-- Name: pseq_set_membership; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_set_membership FROM PUBLIC;
REVOKE ALL ON TABLE pseq_set_membership FROM unison;
GRANT ALL ON TABLE pseq_set_membership TO unison;
GRANT SELECT ON TABLE pseq_set_membership TO PUBLIC;


--
-- Name: sp_var; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE sp_var FROM PUBLIC;
REVOKE ALL ON TABLE sp_var FROM unison;
GRANT ALL ON TABLE sp_var TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE sp_var TO loader;
GRANT SELECT ON TABLE sp_var TO PUBLIC;


--
-- Name: pseq_sp_var_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_sp_var_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_sp_var_v FROM unison;
GRANT ALL ON TABLE pseq_sp_var_v TO unison;
GRANT SELECT ON TABLE pseq_sp_var_v TO PUBLIC;


--
-- Name: pseq_template_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseq_template_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_template_v FROM unison;
GRANT ALL ON TABLE pseq_template_v TO unison;
GRANT SELECT ON TABLE pseq_template_v TO PUBLIC;


--
-- Name: pseqsummary_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pseqsummary_v FROM PUBLIC;
REVOKE ALL ON TABLE pseqsummary_v FROM unison;
GRANT ALL ON TABLE pseqsummary_v TO unison;
GRANT SELECT ON TABLE pseqsummary_v TO PUBLIC;


--
-- Name: pset_bacterial_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_bacterial_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_bacterial_dv FROM unison;
GRANT ALL ON TABLE pset_bacterial_dv TO unison;
GRANT SELECT ON TABLE pset_bacterial_dv TO PUBLIC;


--
-- Name: pset_blast_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_blast_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_blast_dv FROM unison;
GRANT ALL ON TABLE pset_blast_dv TO unison;
GRANT SELECT ON TABLE pset_blast_dv TO PUBLIC;


--
-- Name: pset_counts_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_counts_v FROM PUBLIC;
REVOKE ALL ON TABLE pset_counts_v FROM unison;
GRANT ALL ON TABLE pset_counts_v TO unison;
GRANT SELECT ON TABLE pset_counts_v TO PUBLIC;


--
-- Name: pset_criteria_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_criteria_v FROM PUBLIC;
REVOKE ALL ON TABLE pset_criteria_v FROM unison;
GRANT ALL ON TABLE pset_criteria_v TO unison;
GRANT SELECT ON TABLE pset_criteria_v TO PUBLIC;


--
-- Name: pset_patented_98_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_patented_98_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_patented_98_dv FROM unison;
GRANT ALL ON TABLE pset_patented_98_dv TO unison;
GRANT SELECT ON TABLE pset_patented_98_dv TO PUBLIC;


--
-- Name: pset_patented_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_patented_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_patented_dv FROM unison;
GRANT ALL ON TABLE pset_patented_dv TO unison;
GRANT SELECT ON TABLE pset_patented_dv TO PUBLIC;


--
-- Name: pset_unia_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_unia_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_unia_dv FROM unison;
GRANT ALL ON TABLE pset_unia_dv TO unison;
GRANT SELECT ON TABLE pset_unia_dv TO PUBLIC;


--
-- Name: pset_unib_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_unib_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_unib_dv FROM unison;
GRANT ALL ON TABLE pset_unib_dv TO unison;
GRANT SELECT ON TABLE pset_unib_dv TO PUBLIC;


--
-- Name: pset_unic_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_unic_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_unic_dv FROM unison;
GRANT ALL ON TABLE pset_unic_dv TO unison;
GRANT SELECT ON TABLE pset_unic_dv TO PUBLIC;


--
-- Name: pset_rungga_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_rungga_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_rungga_dv FROM unison;
GRANT ALL ON TABLE pset_rungga_dv TO unison;
GRANT SELECT ON TABLE pset_rungga_dv TO PUBLIC;


--
-- Name: pset_uptodate_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_uptodate_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_uptodate_dv FROM unison;
GRANT ALL ON TABLE pset_uptodate_dv TO unison;
GRANT SELECT ON TABLE pset_uptodate_dv TO PUBLIC;


--
-- Name: pset_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_v FROM PUBLIC;
REVOKE ALL ON TABLE pset_v FROM unison;
GRANT ALL ON TABLE pset_v TO unison;
GRANT SELECT ON TABLE pset_v TO PUBLIC;


--
-- Name: pset_viral_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE pset_viral_dv FROM PUBLIC;
REVOKE ALL ON TABLE pset_viral_dv FROM unison;
GRANT ALL ON TABLE pset_viral_dv TO unison;
GRANT SELECT ON TABLE pset_viral_dv TO PUBLIC;


--
-- Name: psetsummary; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE psetsummary FROM PUBLIC;
REVOKE ALL ON TABLE psetsummary FROM unison;
GRANT ALL ON TABLE psetsummary TO unison;
GRANT INSERT,UPDATE ON TABLE psetsummary TO loader;
GRANT SELECT ON TABLE psetsummary TO PUBLIC;


--
-- Name: psipred; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE psipred FROM PUBLIC;
REVOKE ALL ON TABLE psipred FROM unison;
GRANT ALL ON TABLE psipred TO unison;
GRANT INSERT,DELETE,UPDATE ON TABLE psipred TO loader;
GRANT SELECT ON TABLE psipred TO PUBLIC;


--
-- Name: psprotcomp; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE psprotcomp FROM PUBLIC;
REVOKE ALL ON TABLE psprotcomp FROM unison;
GRANT ALL ON TABLE psprotcomp TO unison;
GRANT INSERT ON TABLE psprotcomp TO loader;
GRANT SELECT ON TABLE psprotcomp TO PUBLIC;


--
-- Name: psprotcomp_location; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE psprotcomp_location FROM PUBLIC;
REVOKE ALL ON TABLE psprotcomp_location FROM unison;
GRANT ALL ON TABLE psprotcomp_location TO unison;
GRANT SELECT ON TABLE psprotcomp_location TO PUBLIC;


--
-- Name: psprotcomp_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE psprotcomp_v FROM PUBLIC;
REVOKE ALL ON TABLE psprotcomp_v FROM unison;
GRANT ALL ON TABLE psprotcomp_v TO unison;
GRANT SELECT ON TABLE psprotcomp_v TO PUBLIC;


--
-- Name: psprotcomp_reliable_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE psprotcomp_reliable_v FROM PUBLIC;
REVOKE ALL ON TABLE psprotcomp_reliable_v FROM unison;
GRANT ALL ON TABLE psprotcomp_reliable_v TO unison;
GRANT SELECT ON TABLE psprotcomp_reliable_v TO PUBLIC;


--
-- Name: public_pseq_ids_dv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE public_pseq_ids_dv FROM PUBLIC;
REVOKE ALL ON TABLE public_pseq_ids_dv FROM unison;
GRANT ALL ON TABLE public_pseq_ids_dv TO unison;
GRANT SELECT ON TABLE public_pseq_ids_dv TO PUBLIC;


--
-- Name: run_history_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE run_history_v FROM PUBLIC;
REVOKE ALL ON TABLE run_history_v FROM unison;
GRANT ALL ON TABLE run_history_v TO unison;
GRANT SELECT ON TABLE run_history_v TO PUBLIC;


--
-- Name: run_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE run_v FROM PUBLIC;
REVOKE ALL ON TABLE run_v FROM unison;
GRANT ALL ON TABLE run_v TO unison;
GRANT SELECT ON TABLE run_v TO PUBLIC;


--
-- Name: scop_pmodel_v; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE scop_pmodel_v FROM PUBLIC;
REVOKE ALL ON TABLE scop_pmodel_v FROM unison;
GRANT ALL ON TABLE scop_pmodel_v TO unison;
GRANT SELECT ON TABLE scop_pmodel_v TO PUBLIC;


--
-- Name: tm_kunitz_cv; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE tm_kunitz_cv FROM PUBLIC;
REVOKE ALL ON TABLE tm_kunitz_cv FROM unison;
GRANT ALL ON TABLE tm_kunitz_cv TO unison;
GRANT SELECT ON TABLE tm_kunitz_cv TO PUBLIC;


--
-- Name: userprefs; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON TABLE userprefs FROM PUBLIC;
REVOKE ALL ON TABLE userprefs FROM unison;
GRANT ALL ON TABLE userprefs TO unison;
GRANT SELECT ON TABLE userprefs TO PUBLIC;


SET search_path = unison_aux, pg_catalog;

--
-- Name: hugo; Type: ACL; Schema: unison_aux; Owner: unison
--

REVOKE ALL ON TABLE hugo FROM PUBLIC;
REVOKE ALL ON TABLE hugo FROM unison;
GRANT ALL ON TABLE hugo TO unison;
GRANT SELECT ON TABLE hugo TO PUBLIC;


SET search_path = pdb, pg_catalog;

--
-- Name: descriptor_origin_id(text, text, text); Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON FUNCTION descriptor_origin_id(text, text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION descriptor_origin_id(text, text, text) FROM unison;
GRANT ALL ON FUNCTION descriptor_origin_id(text, text, text) TO unison;
GRANT ALL ON FUNCTION descriptor_origin_id(text, text, text) TO PUBLIC;


--
-- Name: descriptor_origin_id(text); Type: ACL; Schema: pdb; Owner: unison
--

REVOKE ALL ON FUNCTION descriptor_origin_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION descriptor_origin_id(text) FROM unison;
GRANT ALL ON FUNCTION descriptor_origin_id(text) TO unison;
GRANT ALL ON FUNCTION descriptor_origin_id(text) TO PUBLIC;


SET search_path = pgutils, pg_catalog;

--
-- Name: pk_references(text, text, text, text); Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON FUNCTION pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text) FROM rkh;
GRANT ALL ON FUNCTION pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text) TO rkh;
GRANT ALL ON FUNCTION pk_references(nsp text, rel text, col text, expr text, OUT n integer, OUT fk_referent text) TO PUBLIC;


--
-- Name: pk_references(text, text); Type: ACL; Schema: pgutils; Owner: rkh
--

REVOKE ALL ON FUNCTION pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text) FROM rkh;
GRANT ALL ON FUNCTION pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text) TO rkh;
GRANT ALL ON FUNCTION pk_references(nrc text, expr text, OUT n integer, OUT fk_referent text) TO PUBLIC;


SET search_path = unison, pg_catalog;

--
-- Name: _dblast_species(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _dblast_species(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION _dblast_species(text) FROM unison;
GRANT ALL ON FUNCTION _dblast_species(text) TO unison;
GRANT ALL ON FUNCTION _dblast_species(text) TO PUBLIC;


--
-- Name: _defline_agg_finalfunc(anyarray); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _defline_agg_finalfunc(anyarray) FROM PUBLIC;
REVOKE ALL ON FUNCTION _defline_agg_finalfunc(anyarray) FROM unison;
GRANT ALL ON FUNCTION _defline_agg_finalfunc(anyarray) TO unison;
GRANT ALL ON FUNCTION _defline_agg_finalfunc(anyarray) TO PUBLIC;


--
-- Name: _expand_aa_sets(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _expand_aa_sets(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION _expand_aa_sets(text) FROM unison;
GRANT ALL ON FUNCTION _expand_aa_sets(text) TO unison;
GRANT ALL ON FUNCTION _expand_aa_sets(text) TO PUBLIC;


--
-- Name: _geneseq_species(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _geneseq_species(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION _geneseq_species(text) FROM unison;
GRANT ALL ON FUNCTION _geneseq_species(text) TO unison;
GRANT ALL ON FUNCTION _geneseq_species(text) TO PUBLIC;


--
-- Name: _nr_species(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _nr_species(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION _nr_species(text) FROM unison;
GRANT ALL ON FUNCTION _nr_species(text) TO unison;
GRANT ALL ON FUNCTION _nr_species(text) TO PUBLIC;


--
-- Name: _refseq_species(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _refseq_species(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION _refseq_species(text) FROM unison;
GRANT ALL ON FUNCTION _refseq_species(text) TO unison;
GRANT ALL ON FUNCTION _refseq_species(text) TO PUBLIC;


--
-- Name: _seqhash_no_cleaning(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION _seqhash_no_cleaning(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION _seqhash_no_cleaning(text) FROM unison;
GRANT ALL ON FUNCTION _seqhash_no_cleaning(text) TO unison;
GRANT ALL ON FUNCTION _seqhash_no_cleaning(text) TO PUBLIC;


--
-- Name: a280(text, text, boolean); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION a280(text, text, boolean) FROM PUBLIC;
REVOKE ALL ON FUNCTION a280(text, text, boolean) FROM unison;
GRANT ALL ON FUNCTION a280(text, text, boolean) TO unison;
GRANT ALL ON FUNCTION a280(text, text, boolean) TO PUBLIC;


--
-- Name: aa_3_to_1(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION aa_3_to_1(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION aa_3_to_1(text) FROM unison;
GRANT ALL ON FUNCTION aa_3_to_1(text) TO unison;
GRANT ALL ON FUNCTION aa_3_to_1(text) TO PUBLIC;


--
-- Name: current_params_id_by_pftype_id(integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION current_params_id_by_pftype_id(integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION current_params_id_by_pftype_id(integer) FROM unison;
GRANT ALL ON FUNCTION current_params_id_by_pftype_id(integer) TO unison;
GRANT ALL ON FUNCTION current_params_id_by_pftype_id(integer) TO PUBLIC;


--
-- Name: domain_digests(integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION domain_digests(integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION domain_digests(integer) FROM unison;
GRANT ALL ON FUNCTION domain_digests(integer) TO unison;
GRANT ALL ON FUNCTION domain_digests(integer) TO PUBLIC;


--
-- Name: expand_aa_sets(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION expand_aa_sets(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION expand_aa_sets(text) FROM unison;
GRANT ALL ON FUNCTION expand_aa_sets(text) TO unison;
GRANT ALL ON FUNCTION expand_aa_sets(text) TO PUBLIC;


--
-- Name: has_iupac_ambiguity_aa(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION has_iupac_ambiguity_aa(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION has_iupac_ambiguity_aa(text) FROM unison;
GRANT ALL ON FUNCTION has_iupac_ambiguity_aa(text) TO unison;
GRANT ALL ON FUNCTION has_iupac_ambiguity_aa(text) TO PUBLIC;


--
-- Name: has_iupac_gap_aa(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION has_iupac_gap_aa(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION has_iupac_gap_aa(text) FROM unison;
GRANT ALL ON FUNCTION has_iupac_gap_aa(text) TO unison;
GRANT ALL ON FUNCTION has_iupac_gap_aa(text) TO PUBLIC;


--
-- Name: has_iupac_stop_aa(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION has_iupac_stop_aa(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION has_iupac_stop_aa(text) FROM unison;
GRANT ALL ON FUNCTION has_iupac_stop_aa(text) TO unison;
GRANT ALL ON FUNCTION has_iupac_stop_aa(text) TO PUBLIC;


--
-- Name: has_non_iupac_aa(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION has_non_iupac_aa(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION has_non_iupac_aa(text) FROM unison;
GRANT ALL ON FUNCTION has_non_iupac_aa(text) TO unison;
GRANT ALL ON FUNCTION has_non_iupac_aa(text) TO PUBLIC;


--
-- Name: has_only_iupac_aa_ungapped(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION has_only_iupac_aa_ungapped(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION has_only_iupac_aa_ungapped(text) FROM unison;
GRANT ALL ON FUNCTION has_only_iupac_aa_ungapped(text) TO unison;
GRANT ALL ON FUNCTION has_only_iupac_aa_ungapped(text) TO PUBLIC;


--
-- Name: has_only_iupac_std_aa_ungapped(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION has_only_iupac_std_aa_ungapped(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION has_only_iupac_std_aa_ungapped(text) FROM unison;
GRANT ALL ON FUNCTION has_only_iupac_std_aa_ungapped(text) TO unison;
GRANT ALL ON FUNCTION has_only_iupac_std_aa_ungapped(text) TO PUBLIC;


--
-- Name: link_url(text, text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION link_url(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION link_url(text, text) FROM unison;
GRANT ALL ON FUNCTION link_url(text, text) TO unison;
GRANT ALL ON FUNCTION link_url(text, text) TO PUBLIC;


--
-- Name: locus_fmt(text, text, integer, integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION locus_fmt(chr text, str text, gstart integer, gstop integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION locus_fmt(chr text, str text, gstart integer, gstop integer) FROM unison;
GRANT ALL ON FUNCTION locus_fmt(chr text, str text, gstart integer, gstop integer) TO unison;
GRANT ALL ON FUNCTION locus_fmt(chr text, str text, gstart integer, gstop integer) TO PUBLIC;


--
-- Name: pfsignalphmm_pred(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pfsignalphmm_pred(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pfsignalphmm_pred(text) FROM unison;
GRANT ALL ON FUNCTION pfsignalphmm_pred(text) TO unison;
GRANT ALL ON FUNCTION pfsignalphmm_pred(text) TO PUBLIC;


--
-- Name: porigin_id(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION porigin_id(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION porigin_id(text) FROM unison;
GRANT ALL ON FUNCTION porigin_id(text) TO unison;
GRANT ALL ON FUNCTION porigin_id(text) TO PUBLIC;


--
-- Name: pseq_id_from_sequence(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION pseq_id_from_sequence(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION pseq_id_from_sequence(text) FROM unison;
GRANT ALL ON FUNCTION pseq_id_from_sequence(text) TO unison;
GRANT ALL ON FUNCTION pseq_id_from_sequence(text) TO PUBLIC;


--
-- Name: representative_pseq_id(integer, integer, integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer) FROM unison;
GRANT ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer) TO unison;
GRANT ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, genasm_id integer, params_id integer, OUT pseq_id integer) TO PUBLIC;


--
-- Name: representative_pseq_id(integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, OUT pseq_id integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, OUT pseq_id integer) FROM unison;
GRANT ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, OUT pseq_id integer) TO unison;
GRANT ALL ON FUNCTION representative_pseq_id(q_pseq_id integer, OUT pseq_id integer) TO PUBLIC;


--
-- Name: seqhash(text); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION seqhash(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION seqhash(text) FROM unison;
GRANT ALL ON FUNCTION seqhash(text) TO unison;
GRANT ALL ON FUNCTION seqhash(text) TO PUBLIC;


--
-- Name: sequence_ends(text, integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION sequence_ends(text, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION sequence_ends(text, integer) FROM unison;
GRANT ALL ON FUNCTION sequence_ends(text, integer) TO unison;
GRANT ALL ON FUNCTION sequence_ends(text, integer) TO PUBLIC;


--
-- Name: update_pmodelset(integer); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION update_pmodelset(integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION update_pmodelset(integer) FROM unison;
GRANT ALL ON FUNCTION update_pmodelset(integer) TO unison;
GRANT ALL ON FUNCTION update_pmodelset(integer) TO PUBLIC;


--
-- Name: array_accum(anyelement); Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON FUNCTION array_accum(anyelement) FROM PUBLIC;
REVOKE ALL ON FUNCTION array_accum(anyelement) FROM unison;
GRANT ALL ON FUNCTION array_accum(anyelement) TO unison;
GRANT ALL ON FUNCTION array_accum(anyelement) TO PUBLIC;


SET search_path = gong, pg_catalog;

--
-- Name: alias_alias_id_seq; Type: ACL; Schema: gong; Owner: unison
--

REVOKE ALL ON SEQUENCE alias_alias_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE alias_alias_id_seq FROM unison;
GRANT ALL ON SEQUENCE alias_alias_id_seq TO unison;
GRANT UPDATE ON SEQUENCE alias_alias_id_seq TO loader;


SET search_path = marray, pg_catalog;

--
-- Name: chip_chip_id_seq; Type: ACL; Schema: marray; Owner: unison
--

REVOKE ALL ON SEQUENCE chip_chip_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE chip_chip_id_seq FROM unison;
GRANT ALL ON SEQUENCE chip_chip_id_seq TO unison;
GRANT UPDATE ON SEQUENCE chip_chip_id_seq TO loader;


SET search_path = unison, pg_catalog;

--
-- Name: canned_views_cv_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE canned_views_cv_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE canned_views_cv_id_seq FROM unison;
GRANT ALL ON SEQUENCE canned_views_cv_id_seq TO unison;
GRANT UPDATE ON SEQUENCE canned_views_cv_id_seq TO loader;


--
-- Name: genasm_genasm_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE genasm_genasm_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE genasm_genasm_id_seq FROM unison;
GRANT ALL ON SEQUENCE genasm_genasm_id_seq TO unison;
GRANT UPDATE ON SEQUENCE genasm_genasm_id_seq TO loader;


--
-- Name: origin_origin_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE origin_origin_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE origin_origin_id_seq FROM unison;
GRANT ALL ON SEQUENCE origin_origin_id_seq TO unison;
GRANT UPDATE ON SEQUENCE origin_origin_id_seq TO loader;


--
-- Name: p2gblataln_p2gblataln_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE p2gblataln_p2gblataln_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE p2gblataln_p2gblataln_id_seq FROM unison;
GRANT ALL ON SEQUENCE p2gblataln_p2gblataln_id_seq TO unison;
GRANT UPDATE ON SEQUENCE p2gblataln_p2gblataln_id_seq TO loader;


--
-- Name: p2gblathsp_p2gblathsp_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE p2gblathsp_p2gblathsp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE p2gblathsp_p2gblathsp_id_seq FROM unison;
GRANT ALL ON SEQUENCE p2gblathsp_p2gblathsp_id_seq TO unison;
GRANT UPDATE ON SEQUENCE p2gblathsp_p2gblathsp_id_seq TO loader;


--
-- Name: paliasorigin_palias_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE paliasorigin_palias_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE paliasorigin_palias_id_seq FROM unison;
GRANT ALL ON SEQUENCE paliasorigin_palias_id_seq TO unison;
GRANT UPDATE ON SEQUENCE paliasorigin_palias_id_seq TO loader;
GRANT UPDATE ON SEQUENCE paliasorigin_palias_id_seq TO genengenes;


--
-- Name: params_params_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE params_params_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE params_params_id_seq FROM unison;
GRANT ALL ON SEQUENCE params_params_id_seq TO unison;
GRANT UPDATE ON SEQUENCE params_params_id_seq TO loader;


--
-- Name: pcluster_pcluster_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pcluster_pcluster_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pcluster_pcluster_id_seq FROM unison;
GRANT ALL ON SEQUENCE pcluster_pcluster_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pcluster_pcluster_id_seq TO loader;


--
-- Name: pftype_pftype_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pftype_pftype_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pftype_pftype_id_seq FROM unison;
GRANT ALL ON SEQUENCE pftype_pftype_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pftype_pftype_id_seq TO loader;


--
-- Name: pmap_aln_aln_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pmap_aln_aln_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pmap_aln_aln_id_seq FROM unison;
GRANT ALL ON SEQUENCE pmap_aln_aln_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pmap_aln_aln_id_seq TO loader;


--
-- Name: pmap_hsp_hsp_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pmap_hsp_hsp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pmap_hsp_hsp_id_seq FROM unison;
GRANT ALL ON SEQUENCE pmap_hsp_hsp_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pmap_hsp_hsp_id_seq TO loader;


--
-- Name: pmodelset_pmodelset_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pmodelset_pmodelset_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pmodelset_pmodelset_id_seq FROM unison;
GRANT ALL ON SEQUENCE pmodelset_pmodelset_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pmodelset_pmodelset_id_seq TO loader;


--
-- Name: pseq_pseq_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pseq_pseq_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pseq_pseq_id_seq FROM unison;
GRANT ALL ON SEQUENCE pseq_pseq_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pseq_pseq_id_seq TO loader;
GRANT UPDATE ON SEQUENCE pseq_pseq_id_seq TO genengenes;


--
-- Name: pset_pset_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE pset_pset_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pset_pset_id_seq FROM unison;
GRANT ALL ON SEQUENCE pset_pset_id_seq TO unison;
GRANT UPDATE ON SEQUENCE pset_pset_id_seq TO loader;


--
-- Name: psprotcomp_location_psloc_id_seq; Type: ACL; Schema: unison; Owner: unison
--

REVOKE ALL ON SEQUENCE psprotcomp_location_psloc_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE psprotcomp_location_psloc_id_seq FROM unison;
GRANT ALL ON SEQUENCE psprotcomp_location_psloc_id_seq TO unison;
GRANT UPDATE ON SEQUENCE psprotcomp_location_psloc_id_seq TO loader;


--
-- PostgreSQL database dump complete
--

