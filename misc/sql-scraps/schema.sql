CREATE SCHEMA scop;
CREATE SCHEMA unison;

SET search_path = public;

CREATE FUNCTION plpgsql_call_handler () RETURNS language_handler
    AS 'plpgsql', 'plpgsql_call_handler'
    LANGUAGE c;
CREATE TRUSTED PROCEDURAL LANGUAGE plpgsql HANDLER plpgsql_call_handler;
CREATE FUNCTION plperl_call_handler () RETURNS language_handler
    AS 'plperl', 'plperl_call_handler'
    LANGUAGE c;
CREATE TRUSTED PROCEDURAL LANGUAGE plperl HANDLER plperl_call_handler;
CREATE FUNCTION digest (text, text) RETURNS bytea
    AS 'pgcrypto', 'pg_digest'
    LANGUAGE c;

CREATE FUNCTION clean_sequence (text) RETURNS text
    AS 'unison', 'pg_clean_sequence'
    LANGUAGE c;
CREATE FUNCTION md5 (text) RETURNS text
    AS 'BEGIN return ( encode( digest( $1, ''md5'' ), ''hex'' ) ); END'
    LANGUAGE plpgsql IMMUTABLE;
CREATE FUNCTION seqhash (text) RETURNS text
    AS 'DECLARE S text; BEGIN S:=seqrefmt($1); return ( md5(S) || length(S) ); END'
    LANGUAGE plpgsql IMMUTABLE;
CREATE FUNCTION seqrefmt (text) RETURNS text
    AS 'BEGIN return clean_sequence( $1 ); END;'
    LANGUAGE plpgsql IMMUTABLE;
CREATE FUNCTION pl_clean_sequence (text) RETURNS text
    AS '$_[0]=~s/[^-A-Za-z*?]//g; $_[0]=uc($_[0]); return $_[0]'
    LANGUAGE plperl;
CREATE FUNCTION randseq () RETURNS text
    AS '$s=""; $s .= chr(65+rand(26)) for 0..(50+rand(500)); return $s;'
    LANGUAGE plperl;


CREATE TABLE unison.pseq (
    pseq_id serial NOT NULL,
    palias_id integer,
    seq text NOT NULL,
    len smallint NOT NULL,
    md5 character(32) NOT NULL,
    added timestamp without time zone DEFAULT now() NOT NULL
) WITHOUT OIDS;
REVOKE ALL ON TABLE pseq FROM PUBLIC;
GRANT SELECT ON TABLE pseq TO PUBLIC;
CREATE FUNCTION pseq_iu_trigger () RETURNS "trigger"
    AS '
	declare
		oldmd5 text;
	begin
		oldmd5 := md5(new.seq);
		new.seq := clean_sequence(new.seq);
		new.md5 := md5(new.seq);
		if oldmd5 != new.md5 then
			raise notice ''pseq_id % modified during insert.'',new.pseq_id;
		end if;
		new.len := length(new.seq);
		return new;
	end; '
    LANGUAGE plpgsql;
CREATE FUNCTION pseq_i_pseq_id (text) RETURNS integer
    AS '
DECLARE
	S alias for $1;
	rv integer;
BEGIN
	select into rv nextval(''pseq_pseq_id_seq'');
	insert into pseq (pseq_id,seq) values (rv,S);
	return rv;
END;'
    LANGUAGE plpgsql;
CREATE FUNCTION pseq_si_pseq_id (text) RETURNS integer
    AS '
DECLARE
	S text;
	rv integer;
	Smd5 text;
BEGIN
	S := clean_sequence($1);
	Smd5 := md5(S);
	select into rv pseq_id from pseq where md5=Smd5;
	if not found then
		select into rv pseq_i_pseq_id( S );
	end if;
	return rv;
END;'
    LANGUAGE plpgsql;
CREATE TABLE unison.porigin (
    porigin_id serial NOT NULL,
    origin text NOT NULL,
    url text,
    descr text
) WITHOUT OIDS;
REVOKE ALL ON TABLE porigin FROM PUBLIC;
GRANT SELECT ON TABLE porigin TO PUBLIC;
CREATE FUNCTION porigin_si_porigin_id (text) RETURNS integer
    AS '
DECLARE
	O alias for $1;				-- origin
	rv integer;
BEGIN
	select into rv porigin_id from porigin where upper(origin) = upper(O);
	if found then return rv; end if;
	insert into porigin (origin) values (O);
	select into rv porigin_id from porigin where origin = O;
	return rv;
END;'
    LANGUAGE plpgsql;
CREATE TABLE unison.palias (
    palias_id serial NOT NULL,
    pseq_id integer NOT NULL,
    porigin_id integer NOT NULL,
    alias text NOT NULL,
    descr text,
    ref_pseq_id integer,
    added timestamp without time zone DEFAULT now() NOT NULL
) WITHOUT OIDS;
REVOKE ALL ON TABLE palias FROM PUBLIC;
GRANT SELECT ON TABLE palias TO PUBLIC;
CREATE TABLE unison.pset (
    pset_id serial NOT NULL,
    name text NOT NULL,
    descr text
) WITHOUT OIDS;
REVOKE ALL ON TABLE pset FROM PUBLIC;
GRANT SELECT ON TABLE pset TO PUBLIC;
CREATE TABLE unison.pseqset (
    pset_id integer,
    pseq_id integer
) WITHOUT OIDS;
REVOKE ALL ON TABLE pseqset FROM PUBLIC;
GRANT SELECT ON TABLE pseqset TO PUBLIC;
CREATE TABLE unison.pftype (
    pftype_id serial NOT NULL,
    name text
) WITHOUT OIDS;
REVOKE ALL ON TABLE pftype FROM PUBLIC;
GRANT SELECT ON TABLE pftype TO PUBLIC;
CREATE TABLE unison.pfeature (
    pfeature_id serial NOT NULL,
    pseq_id integer NOT NULL,
    pftype_id integer NOT NULL,
    "start" integer,
    stop integer,
    "comment" text,
    quality real
) WITHOUT OIDS;
REVOKE ALL ON TABLE pfeature FROM PUBLIC;
GRANT SELECT ON TABLE pfeature TO PUBLIC;
CREATE TABLE unison.p2template (
    p2template_id serial NOT NULL,
    pseq_id integer NOT NULL,
    name text NOT NULL,
    len integer NOT NULL,
    ncores integer NOT NULL
) WITHOUT OIDS;
REVOKE ALL ON TABLE p2template FROM PUBLIC;
GRANT SELECT ON TABLE p2template TO PUBLIC;
CREATE TABLE unison.p2params (
    p2params_id serial NOT NULL,
    name text NOT NULL,
    commandline text,
    pairwise boolean,
    ss boolean,
    profile boolean,
    "global" boolean
) WITHOUT OIDS;
REVOKE ALL ON TABLE p2params FROM PUBLIC;
GRANT SELECT ON TABLE p2params TO PUBLIC;
CREATE TABLE unison.p2thread (
    p2params_id integer NOT NULL,
    p2template_id integer NOT NULL,
    nident integer NOT NULL,
    nalign integer NOT NULL,
    raw real NOT NULL,
    mutation real NOT NULL,
    singleton real NOT NULL,
    pairwise real NOT NULL,
    gap real NOT NULL,
    ssfit real NOT NULL,
    zscore real,
    svm real,
    rgyr real NOT NULL
)
INHERITS (pfeature) WITHOUT OIDS;
REVOKE ALL ON TABLE p2thread FROM PUBLIC;
GRANT SELECT ON TABLE p2thread TO PUBLIC;
CREATE FUNCTION p2thread_i_trigger () RETURNS "trigger"
    AS 'BEGIN NEW.pftype_id=pftype_id_lookup(''p2thread''); return new; END;'
    LANGUAGE plpgsql;
CREATE TABLE unison.meta (
    "key" text NOT NULL,
    value text
) WITHOUT OIDS;
REVOKE ALL ON TABLE meta FROM PUBLIC;
GRANT SELECT ON TABLE meta TO PUBLIC;
CREATE FUNCTION add_soa (text, text, text) RETURNS integer
    AS '
DECLARE
	S alias for $1;				-- sequence
	O alias for $2;				-- origin
	A alias for $3;				-- alias
	si	integer;				-- pseq_id
	oi	integer;				-- porigin_id
BEGIN
	si := si_pseq_id(S);
	oi := si_porigin_id(O);
	insert into palias (pseq_id,porigin_id,alias) values (si,oi,A);
	return si;
END;'
    LANGUAGE plpgsql;
CREATE FUNCTION pstr_get_pstr_id (text) RETURNS integer
    AS '
DECLARE
	rv integer;
BEGIN
	select into rv pstr_id from pstr where pdbc = upper($1);
	return rv;
END;'
    LANGUAGE plpgsql;
CREATE FUNCTION pftype_id_lookup (text) RETURNS integer
    AS 'select pftype_id from pftype where name = $1'
    LANGUAGE sql;
CREATE TABLE unison.pseqprop (
    pseq_id integer,
    sigpredict real,
    sigsensor real,
    sighmm real
) WITHOUT OIDS;
REVOKE ALL ON TABLE pseqprop FROM PUBLIC;
GRANT SELECT ON TABLE pseqprop TO PUBLIC;
CREATE VIEW v_p2thread2 AS
    SELECT t.pseq_id, b.name, t.raw, t.svm, t.mutation, t.pairwise, t.singleton, t.gap, ((((o.origin || ':'::text) || a.alias) || ':'::text) || a.descr) AS oralde FROM (((p2thread t JOIN p2template b ON ((t.p2template_id = b.p2template_id))) JOIN palias a ON ((a.pseq_id = b.pseq_id))) JOIN porigin o ON ((a.porigin_id = o.porigin_id))) ORDER BY t.svm DESC;
REVOKE ALL ON TABLE v_p2thread2 FROM PUBLIC;
GRANT SELECT ON TABLE v_p2thread2 TO PUBLIC;
CREATE VIEW v_p2thread AS
    SELECT t.pseq_id, b.name, t.raw, t.svm, t.mutation, t.pairwise, t.singleton, t.gap FROM (p2thread t JOIN p2template b ON ((t.p2template_id = b.p2template_id))) ORDER BY t.svm DESC;
REVOKE ALL ON TABLE v_p2thread FROM PUBLIC;
GRANT SELECT ON TABLE v_p2thread TO PUBLIC;
CREATE VIEW v_pseqsummary AS
    SELECT q.pseq_id, o.origin, a.alias, a.descr, q.len, q.seq FROM ((pseq q FULL JOIN palias a ON ((q.pseq_id = a.pseq_id))) LEFT JOIN porigin o ON ((a.porigin_id = o.porigin_id))) ORDER BY q.pseq_id, o.origin, a.alias;
REVOKE ALL ON TABLE v_pseqsummary FROM PUBLIC;
GRANT SELECT ON TABLE v_pseqsummary TO PUBLIC;
CREATE VIEW v_pset AS
    SELECT pseq_id, pset.name FROM (pseqset JOIN pset ON ((pset.pset_id = pseqset.pset_id))) ORDER BY pset.name;
REVOKE ALL ON TABLE v_pset FROM PUBLIC;
GRANT SELECT ON TABLE v_pset TO PUBLIC;
CREATE TABLE unison.hmm (
    hmm_id serial NOT NULL,
    porigin_id integer,
    name text,
    hmm text
) WITHOUT OIDS;
REVOKE ALL ON TABLE hmm FROM PUBLIC;
GRANT SELECT ON TABLE hmm TO PUBLIC;
CREATE TABLE unison.pfhmm (
    hmm_id integer,
    score real,
    eval real
)
INHERITS (pfeature) WITHOUT OIDS;
CREATE FUNCTION si (text) RETURNS integer
    AS '
DECLARE
	S text;
	rv integer;
BEGIN
	S := clean_sequence($1);
	select into rv pseq_id from pseq where len=length(S) and md5=md5(S);
	if not found then
		select into rv pseq_i_pseq_id( S );
	end if;
	return rv;
END;'
    LANGUAGE plpgsql;
CREATE VIEW v_palias AS
    SELECT palias.pseq_id, porigin.origin, palias.alias, palias.descr FROM palias, porigin WHERE (palias.porigin_id = porigin.porigin_id) ORDER BY palias.pseq_id;
REVOKE ALL ON TABLE v_palias FROM PUBLIC;
GRANT SELECT ON TABLE v_palias TO PUBLIC;
CREATE TABLE unison.pmodelset (
    pmodelset_id serial NOT NULL,
    name text
) WITHOUT OIDS;
REVOKE ALL ON TABLE pmodelset FROM PUBLIC;
GRANT SELECT ON TABLE pmodelset TO PUBLIC;
CREATE TABLE unison.pmsm (
    pmodelset_id integer NOT NULL,
    p2template_id integer NOT NULL
) WITHOUT OIDS;
REVOKE ALL ON TABLE pmsm FROM PUBLIC;
GRANT SELECT ON TABLE pmsm TO PUBLIC;
SET search_path = scop, pg_catalog;
CREATE TABLE scop.des (
    sunid integer NOT NULL,
    "level" text NOT NULL,
    sccs text NOT NULL,
    sname text,
    descr text NOT NULL
) WITHOUT OIDS;
CREATE TABLE scop.cla (
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
) WITHOUT OIDS;
CREATE TABLE scop.hie (
    sunid integer NOT NULL,
    psunid integer,
    children integer[]
) WITHOUT OIDS;
SET search_path = unison, pg_catalog;
CREATE VIEW v_pmodelset AS
    SELECT pmodelset_id, count(p2template_id) AS count, name FROM (pmodelset NATURAL JOIN pmsm) GROUP BY pmodelset_id, name;
CREATE VIEW v_pmsm AS
    SELECT m.name AS modelset, t.name AS model FROM ((pmodelset m JOIN pmsm i ON ((m.pmodelset_id = i.pmodelset_id))) JOIN p2template t ON ((i.p2template_id = t.p2template_id)));
CREATE VIEW tnf_best_hits AS
    SELECT DISTINCT q.pseq_id FROM p2thread q WHERE ((SELECT p2thread.p2template_id FROM p2thread WHERE (p2thread.pseq_id = q.pseq_id) ORDER BY p2thread.svm DESC LIMIT 25) = ANY (SELECT pmsm.p2template_id FROM pmsm WHERE (pmsm.pmodelset_id = 2))) ORDER BY q.pseq_id;


COMMENT ON TABLE pseq IS 'table of unique protein sequences';
COMMENT ON COLUMN pseq.pseq_id IS 'unique id for sequence; default is serial number';
COMMENT ON COLUMN pseq.palias_id IS 'optional preferred palias to display for this sequence';
COMMENT ON COLUMN pseq.seq IS 'protein sequence';
COMMENT ON COLUMN pseq.len IS 'sequence length, computed automatically';
COMMENT ON COLUMN pseq.md5 IS 'md5 for sequence, computed automatically';
COMMENT ON COLUMN pseq.added IS 'timestamp at which sequence was added (automatic)';
COMMENT ON FUNCTION pseq_si_pseq_id (text) IS 'select/insert a pseq_id from sequence, returns pseq_id';
COMMENT ON TABLE porigin IS 'origin (database or algorithm) of protein alias (sequence)';
COMMENT ON COLUMN porigin.porigin_id IS 'unique id for origin; default is serial number';
COMMENT ON COLUMN porigin.origin IS 'origin name (freetext)';
COMMENT ON COLUMN porigin.url IS 'url for this origin; use %s as a placeholder for palias.alias';
COMMENT ON FUNCTION porigin_si_porigin_id (text) IS 'select/insert a porigin_id from origin text, returns porigin_id';
COMMENT ON TABLE palias IS 'alias (names) given to a sequence by a particular origin';
COMMENT ON COLUMN palias.pseq_id IS 'pseq.pseq_id for this alias';
COMMENT ON COLUMN palias.porigin_id IS 'porigin.porigin_id for this alias';
COMMENT ON COLUMN palias.alias IS 'alias text; this should be the unique identifier (may be more than 1) for this sequence from this origin';
COMMENT ON COLUMN palias.descr IS 'descriptive text, typically derived from the corresponding origin';
COMMENT ON COLUMN palias.ref_pseq_id IS 'reference to unison pseq_id for this derived sequence';
COMMENT ON TABLE pset IS 'set name and id for sets of sequences';
COMMENT ON COLUMN pset.pset_id IS 'unique identifer for set';
COMMENT ON COLUMN pset.name IS 'unique name for this sequence set';
COMMENT ON COLUMN pset.descr IS 'freetext description of this set';
COMMENT ON TABLE pseqset IS 'links pset and pseq instances (many-many)';
COMMENT ON COLUMN pseqset.pset_id IS 'pset.pset_id';
COMMENT ON COLUMN pseqset.pseq_id IS 'pseq.pseq_id';
COMMENT ON TABLE pftype IS 'enumeration of feature types';
COMMENT ON COLUMN pftype.pftype_id IS 'unique identifier for this feature type';
COMMENT ON COLUMN pftype.name IS 'short descriptive name of this feature type';
COMMENT ON TABLE pfeature IS 'parent table of all features; inherited by "subclass" feature tables';
COMMENT ON COLUMN pfeature.pfeature_id IS 'unique identifier for this feature';
COMMENT ON COLUMN pfeature.pseq_id IS 'pseq_id on which this feature applies';
COMMENT ON COLUMN pfeature.pftype_id IS 'type of feature, from pftype table';
COMMENT ON COLUMN pfeature."start" IS 'starting position (1-based) for feature';
COMMENT ON COLUMN pfeature.stop IS 'ending position (1-based) for feature';
COMMENT ON COLUMN pfeature."comment" IS 'freetext comment of feature (1 line summary, <CR>, then text is recommended)';
COMMENT ON COLUMN pfeature.quality IS 'reserved -- not currently used)';
COMMENT ON TABLE p2template IS 'Prospect2 templates (typically FSSP or SCOP substructures)';
COMMENT ON TABLE p2params IS 'Prospect2 threading parameters';
COMMENT ON COLUMN p2params.p2params_id IS 'unique serial number for this parameter set';
COMMENT ON COLUMN p2params.name IS 'short unique descriptive name of parameter set';
COMMENT ON COLUMN p2params.commandline IS 'commandline to prospect/threading; how to thread (NOT WHAT TO THREAD, e.g., -fssp)';
COMMENT ON COLUMN p2params.pairwise IS 'threaded with pairwise off? (from xml output)';
COMMENT ON COLUMN p2params.ss IS 'threaded with secondary structure? (from xml output)';
COMMENT ON COLUMN p2params.profile IS 'threaded with sequence profile? (from xml output)';
COMMENT ON COLUMN p2params."global" IS 'threaded globally? (from xml output)';
COMMENT ON TABLE p2thread IS 'single Prospect2 threading alignment (unique <pseq_id,p2params_id,p2template_id>)';
COMMENT ON TABLE meta IS 'key-value pairs of unison meta data';
COMMENT ON FUNCTION add_soa (text, text, text) IS 'add <sequnce,origin,alias> tuple, using existing ids when available, returns pseq_id';
COMMENT ON FUNCTION pstr_get_pstr_id (text) IS 'return pstr_id for pdbc (pdb + chain)';
COMMENT ON TABLE pseqprop IS 'miscellaneous sequence properties';
COMMENT ON COLUMN pseqprop.pseq_id IS 'referent pseq_id';
COMMENT ON COLUMN pseqprop.sigpredict IS 'sigpredict score';
COMMENT ON VIEW v_p2thread IS 'p2thread view with template names instead of ids';
COMMENT ON VIEW v_pset IS 'pset view with set names instead of ids';

grant usage on schema unison to public;
grant usage on schema scop to public;
