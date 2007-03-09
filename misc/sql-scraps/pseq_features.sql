create or replace function domain_digest(
	pstart integer,
	pstop integer,
	name text,
	note text,
	out digest text)
immutable language plpgsql as
$_$
BEGIN
	-- 12-23:Ig(56,1e-5)
	-- SELECT INTO digest pstart || '-' || pstop || ':' || name || COALESCE('('||NULLIF(note,'')||')','');

	SELECT INTO digest name || '(' || pstart || '-' || pstop || COALESCE(';'||NULLIF(note,''),'') || ')';
END;
$_$;


create or replace function domain_digest(
	pstart integer,
	pstop integer,
	name text,
	score integer,
	eval double precision,
	out digest text)
immutable language plpgsql as
$_$
BEGIN
	select into digest domain_digest(pstart,pstop,name,score||';'||eval);
END;
$_$;

drop view pseq_features_v;
drop view pseq_features_tmhmm_excl_signal_v;
drop view pseq_features_bigpi_v ;
drop view pseq_features_hmm_v;
drop view pseq_features_regexp_v ;
drop view pseq_features_signalpnn_v ;
drop view pseq_features_tmhmm_v ;


create or replace view pseq_features_bigpi_v as
 SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, f.score, f.pvalue::double precision AS eval, NULL::integer as origin_id, NULL::text as origin, NULL::integer AS pmodel_id, 'GPI Anchor'::text AS feature, NULL::text AS acc, NULL::text AS descr, (('site='::text || f.site_no::text) || '; quality='::text) || f.quality::text AS details, domain_digest(f.start,f.stop,'GPI',f.quality) as digest, NULL::text AS link_url
   FROM pfbigpi f
   JOIN params p ON f.params_id = p.params_id
   JOIN pftype ft ON p.pftype_id = ft.pftype_id
  WHERE f.params_id = preferred_params_id_by_pftype('BIG-PI'::text) AND (f.quality = 'A'::bpchar OR f.quality = 'B'::bpchar OR f.quality = 'C'::bpchar OR f.quality = 'D'::bpchar);

create or replace view pseq_features_hmm_v as
 SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, f.score, f.eval, m.origin_id, o.origin, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, domain_digest(f.start,f.stop,m.name,f.score,f.eval) AS digest, link_url(m.origin_id, m.acc) AS link_url
   FROM pahmm f
   JOIN pmhmm m ON f.pmodel_id = m.pmodel_id
   JOIN origin o ON m.origin_id=o.origin_id
   JOIN params p ON f.params_id = p.params_id
   JOIN pftype ft ON p.pftype_id = ft.pftype_id
  WHERE f.params_id = preferred_params_id_by_pftype('HMM'::text) AND f.eval < 1::double precision;

create or replace view pseq_features_regexp_v as
 SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, NULL::smallint AS score, NULL::double precision AS eval, m.origin_id, o.origin, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, domain_digest(f.start,f.stop,m.name,NULL) AS digest, link_url(m.origin_id, m.acc) AS link_url
   FROM pfregexp f
   JOIN pmregexp m ON f.pmodel_id = m.pmodel_id
   JOIN origin o ON m.origin_id=o.origin_id
   JOIN params p ON f.params_id = p.params_id
   JOIN pftype ft ON p.pftype_id = ft.pftype_id
  WHERE f.params_id = preferred_params_id_by_pftype('regexp'::text);

create or replace view pseq_features_signalpnn_v as
 SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, f.d_score AS score, NULL::double precision AS eval, NULL::integer as origin_id, NULL::text as origin, NULL::integer AS pmodel_id, 'SS'::text AS feature, NULL::text AS acc, 'signal sequence'::text AS descr, NULL::text AS details, domain_digest(f.start,f.stop,'SS',f.d_score) AS digest, NULL::text AS link_url
   FROM pfsignalpnn f
   JOIN params p ON f.params_id = p.params_id
   JOIN pftype ft ON p.pftype_id = ft.pftype_id
  WHERE f.params_id = preferred_params_id_by_pftype('SignalP'::text) AND f.signal_peptide = true;

create or replace view pseq_features_tmhmm_v as
 SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, NULL::smallint AS score, NULL::double precision AS eval, NULL::integer as origin_id, NULL::text as origin, NULL::integer AS pmodel_id, 'TM'::text AS feature, NULL::text AS acc, 'transmembrane domain'::text AS descr, NULL::text AS details, domain_digest(f.start,f.stop,'TM',NULL) AS digest, NULL::text AS link_url
   FROM pftmhmm f
   JOIN params p ON f.params_id = p.params_id
   JOIN pftype ft ON p.pftype_id = ft.pftype_id
  WHERE f.params_id = preferred_params_id_by_pftype('TMHMM'::text) AND (f."type" = 'M'::bpchar OR f."type" = 'N'::bpchar);

create or replace view pseq_features_tmhmm_excl_signal_v as
 SELECT tm.feature_type, tm.params_id, tm.params_name, tm.pseq_id, tm."start", tm.stop, tm.score, tm.eval, NULL::integer as origin_id, NULL::text as origin, tm.pmodel_id, tm.feature, tm.acc, tm.descr, tm.details, tm.digest, tm.link_url
   FROM pseq_features_tmhmm_v tm
  WHERE tm.params_id = preferred_params_id_by_pftype('TMHMM'::text) AND NOT (EXISTS ( SELECT ss.pfeature_id, ss.pseq_id, ss.pftype_id, ss."start", ss.stop, ss.params_id, ss.d_score, ss.signal_peptide
           FROM pfsignalpnn ss
          WHERE ss.pseq_id = tm.pseq_id AND ss.params_id = preferred_params_id_by_pftype('SignalP'::text) AND ss.signal_peptide = true AND ss.stop >=
tm."start" AND ss."start" <= tm.stop));


create or replace view pseq_features_v as
select * from pseq_features_bigpi_v
UNION ALL
select * from pseq_features_hmm_v
UNION ALL
select * from pseq_features_regexp_v
UNION ALL
select * from pseq_features_signalpnn_v
UNION ALL
select * from pseq_features_tmhmm_excl_signal_v
;


create or replace function domain_digests(integer)
returns text
language sql
strict volatile
as $_$ select as_set(digest) as domain_digests from (select * from pseq_features_v where pseq_id=$1 order by start,stop) X $_$;





comment on function domain_digest(integer,integer,text,text) 				is 'formatted domain summary, like start-stop:domain(note)';
comment on function domain_digest(integer,integer,text,integer,double precision) is 'formatted domain summary, like start-stop:domain(score,eval)';

grant execute on function domain_digest(integer,integer,text,text) to PUBLIC;
grant execute on function domain_digest(integer,integer,text,integer,double precision) to PUBLIC;


comment on function domain_digests(integer) is 'domain digests in N-to-C terminus order';
grant execute on function domain_digests(integer) to public;



COMMENT ON VIEW pseq_features_bigpi_v IS 'current Big-PI neural net features';
COMMENT ON COLUMN pseq_features_bigpi_v.feature_type IS 'type of features (always ''BIG-PI'')';
COMMENT ON COLUMN pseq_features_bigpi_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN pseq_features_bigpi_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN pseq_features_bigpi_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN pseq_features_bigpi_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_bigpi_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_bigpi_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN pseq_features_bigpi_v.eval IS 'expectation value';
COMMENT ON COLUMN pseq_features_bigpi_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN pseq_features_bigpi_v.feature IS 'name of feature (always ''GPI Anchor'')';
COMMENT ON COLUMN pseq_features_bigpi_v.descr IS 'unused';
COMMENT ON COLUMN pseq_features_bigpi_v.details IS 'prediction details';
COMMENT ON COLUMN pseq_features_bigpi_v.link_url IS 'URL to source data';
COMMENT ON VIEW pseq_features_hmm_v IS 'current HMM features';
COMMENT ON COLUMN pseq_features_hmm_v.feature_type IS 'type of features (always ''HMM'')';
COMMENT ON COLUMN pseq_features_hmm_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN pseq_features_hmm_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN pseq_features_hmm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN pseq_features_hmm_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_hmm_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_hmm_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN pseq_features_hmm_v.eval IS 'expectation value';
COMMENT ON COLUMN pseq_features_hmm_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN pseq_features_hmm_v.feature IS 'name of feature (Pfam name)';
COMMENT ON COLUMN pseq_features_hmm_v.descr IS 'HMM description';
COMMENT ON COLUMN pseq_features_hmm_v.details IS 'prediction details';
COMMENT ON COLUMN pseq_features_hmm_v.link_url IS 'URL to source data';
COMMENT ON VIEW pseq_features_regexp_v IS 'current regular expression features';
COMMENT ON COLUMN pseq_features_regexp_v.feature_type IS 'type of features (always ''regexp'')';
COMMENT ON COLUMN pseq_features_regexp_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN pseq_features_regexp_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN pseq_features_regexp_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN pseq_features_regexp_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_regexp_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_regexp_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN pseq_features_regexp_v.eval IS 'expectation value';
COMMENT ON COLUMN pseq_features_regexp_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN pseq_features_regexp_v.feature IS 'name of feature (motif name)';
COMMENT ON COLUMN pseq_features_regexp_v.descr IS 'motif description';
COMMENT ON COLUMN pseq_features_regexp_v.details IS 'prediction details';
COMMENT ON COLUMN pseq_features_regexp_v.link_url IS 'URL to source data';
COMMENT ON VIEW pseq_features_signalpnn_v IS 'current SignalP neural net features';
COMMENT ON COLUMN pseq_features_signalpnn_v.feature_type IS 'type of features (always ''SignalP'')';
COMMENT ON COLUMN pseq_features_signalpnn_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN pseq_features_signalpnn_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN pseq_features_signalpnn_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN pseq_features_signalpnn_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_signalpnn_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_signalpnn_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN pseq_features_signalpnn_v.eval IS 'expectation value';
COMMENT ON COLUMN pseq_features_signalpnn_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN pseq_features_signalpnn_v.feature IS 'name of feature (always ''SS'')';
COMMENT ON COLUMN pseq_features_signalpnn_v.descr IS 'unused';
COMMENT ON COLUMN pseq_features_signalpnn_v.details IS 'prediction details';
COMMENT ON COLUMN pseq_features_signalpnn_v.link_url IS 'URL to source data';
COMMENT ON VIEW pseq_features_tmhmm_v IS 'current TMHMM features';
COMMENT ON COLUMN pseq_features_tmhmm_v.feature_type IS 'type of features (always ''TMHMM'')';
COMMENT ON COLUMN pseq_features_tmhmm_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN pseq_features_tmhmm_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN pseq_features_tmhmm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN pseq_features_tmhmm_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_tmhmm_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN pseq_features_tmhmm_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN pseq_features_tmhmm_v.eval IS 'expectation value';
COMMENT ON COLUMN pseq_features_tmhmm_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN pseq_features_tmhmm_v.feature IS 'name of feature (always ''TM'')';
COMMENT ON COLUMN pseq_features_tmhmm_v.descr IS 'unused';
COMMENT ON COLUMN pseq_features_tmhmm_v.details IS 'prediction details';
COMMENT ON COLUMN pseq_features_tmhmm_v.link_url IS 'URL to source data';
COMMENT ON VIEW pseq_features_tmhmm_excl_signal_v IS 'current TMHMM features that do not overlap a SignalP NN prediction';
COMMENT ON VIEW pseq_features_v IS 'most current features';
COMMENT ON COLUMN pseq_features_v.feature_type IS 'type of prediction feature';
COMMENT ON COLUMN pseq_features_v.params_id IS 'Unison parameter set';
COMMENT ON COLUMN pseq_features_v.params_name IS 'parameter set name';
COMMENT ON COLUMN pseq_features_v.pseq_id IS 'Unison pseq_id';
COMMENT ON COLUMN pseq_features_v."start" IS 'starting residue of feature';
COMMENT ON COLUMN pseq_features_v.stop IS 'starting residue of feature';
COMMENT ON COLUMN pseq_features_v.score IS 'raw score of prediction, where available';
COMMENT ON COLUMN pseq_features_v.eval IS 'evalue or pvalue of prediction, where available';
COMMENT ON COLUMN pseq_features_v.pmodel_id IS 'Unison unique protein model id';
COMMENT ON COLUMN pseq_features_v.feature IS 'feature name';
COMMENT ON COLUMN pseq_features_v.acc IS 'model accession in external database';
COMMENT ON COLUMN pseq_features_v.descr IS 'model description';
COMMENT ON COLUMN pseq_features_v.details IS 'additional prediction details';
COMMENT ON COLUMN pseq_features_v.link_url IS 'link to model in external database';
REVOKE ALL ON TABLE pseq_features_bigpi_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_bigpi_v FROM rkh;
GRANT ALL ON TABLE pseq_features_bigpi_v TO rkh;
GRANT ALL ON TABLE pseq_features_bigpi_v TO unison;
GRANT SELECT ON TABLE pseq_features_bigpi_v TO PUBLIC;
REVOKE ALL ON TABLE pseq_features_hmm_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_hmm_v FROM rkh;
GRANT ALL ON TABLE pseq_features_hmm_v TO rkh;
GRANT ALL ON TABLE pseq_features_hmm_v TO unison;
GRANT SELECT ON TABLE pseq_features_hmm_v TO PUBLIC;
REVOKE ALL ON TABLE pseq_features_regexp_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_regexp_v FROM rkh;
GRANT ALL ON TABLE pseq_features_regexp_v TO rkh;
GRANT ALL ON TABLE pseq_features_regexp_v TO unison;
GRANT SELECT ON TABLE pseq_features_regexp_v TO PUBLIC;
REVOKE ALL ON TABLE pseq_features_signalpnn_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_signalpnn_v FROM rkh;
GRANT ALL ON TABLE pseq_features_signalpnn_v TO rkh;
GRANT ALL ON TABLE pseq_features_signalpnn_v TO unison;
GRANT SELECT ON TABLE pseq_features_signalpnn_v TO PUBLIC;
REVOKE ALL ON TABLE pseq_features_tmhmm_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_tmhmm_v FROM rkh;
GRANT ALL ON TABLE pseq_features_tmhmm_v TO rkh;
GRANT ALL ON TABLE pseq_features_tmhmm_v TO unison;
GRANT SELECT ON TABLE pseq_features_tmhmm_v TO PUBLIC;
REVOKE ALL ON TABLE pseq_features_tmhmm_excl_signal_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_tmhmm_excl_signal_v FROM rkh;
GRANT ALL ON TABLE pseq_features_tmhmm_excl_signal_v TO rkh;
GRANT ALL ON TABLE pseq_features_tmhmm_excl_signal_v TO unison;
GRANT SELECT ON TABLE pseq_features_tmhmm_excl_signal_v TO PUBLIC;
REVOKE ALL ON TABLE pseq_features_v FROM PUBLIC;
REVOKE ALL ON TABLE pseq_features_v FROM rkh;
GRANT ALL ON TABLE pseq_features_v TO rkh;
GRANT ALL ON TABLE pseq_features_v TO unison;
GRANT SELECT ON TABLE pseq_features_v TO PUBLIC;
