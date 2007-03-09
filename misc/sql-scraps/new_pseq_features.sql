CREATE OR REPLACE VIEW new_pseq_features_bigpi_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, f.score, (f.pvalue)::double precision AS eval, NULL::integer AS pmodel_id, 'GPI Anchor'::text AS feature, NULL::text AS acc, NULL::text AS descr, ((('site='::text || (f.site_no)::text) || '; quality='::text) || (f.quality)::text) AS details, start||'-'||stop||':'||'GPI' as digest, NULL::text AS link_url FROM ((pfbigpi f JOIN params p ON ((f.params_id = p.params_id))) JOIN pftype ft ON ((p.pftype_id = ft.pftype_id))) WHERE ((f.params_id = preferred_params_id_by_pftype('BIG-PI'::text)) AND ((((f.quality = 'A'::bpchar) OR (f.quality = 'B'::bpchar)) OR (f.quality = 'C'::bpchar)) OR (f.quality = 'D'::bpchar)));
CREATE OR REPLACE VIEW new_pseq_features_hmm_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, f.score, f.eval, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, start||'-'||stop||':'||m.name || '('||score||','||eval||')' as digest, link_url(m.origin_id, m.acc) AS link_url FROM (((pahmm f JOIN pmhmm m ON ((f.pmodel_id = m.pmodel_id))) JOIN params p ON ((f.params_id = p.params_id))) JOIN pftype ft ON ((p.pftype_id = ft.pftype_id))) WHERE ((f.params_id = preferred_params_id_by_pftype('HMM'::text)) AND (f.eval < (1)::double precision));
CREATE OR REPLACE VIEW new_pseq_features_regexp_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, NULL::smallint AS score, NULL::double precision AS eval, f.pmodel_id, m.name AS feature, m.acc, m.descr, NULL::text AS details, start||'-'||stop||':'||m.name as digest, link_url(m.origin_id, m.acc) AS link_url FROM (((pfregexp f JOIN pmregexp m ON ((f.pmodel_id = m.pmodel_id))) JOIN params p ON ((f.params_id = p.params_id))) JOIN pftype ft ON ((p.pftype_id = ft.pftype_id))) WHERE (f.params_id = preferred_params_id_by_pftype('regexp'::text));
CREATE OR REPLACE VIEW new_pseq_features_signalpnn_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, f.d_score AS score, NULL::double precision AS eval, NULL::integer AS pmodel_id, 'SS'::text AS feature, NULL::text AS acc, 'signal sequence'::text AS descr, NULL::text AS details, start||'-'||stop||':'||'SS('||d_score||')' as digest, NULL::text AS link_url FROM ((pfsignalpnn f JOIN params p ON ((f.params_id = p.params_id))) JOIN pftype ft ON ((p.pftype_id = ft.pftype_id))) WHERE ((f.params_id = preferred_params_id_by_pftype('SignalP'::text)) AND (f.signal_peptide = true));
CREATE OR REPLACE VIEW new_pseq_features_tmhmm_v AS
    SELECT ft.name AS feature_type, f.params_id, p.name AS params_name, f.pseq_id, f."start", f.stop, NULL::smallint AS score, NULL::double precision AS eval, NULL::integer AS pmodel_id, 'TM'::text AS feature, NULL::text AS acc, 'transmembrane domain'::text AS descr, NULL::text AS details, start||'-'||stop||':'||'TM' as digest, NULL::text AS link_url FROM ((pftmhmm f JOIN params p ON ((f.params_id = p.params_id))) JOIN pftype ft ON ((p.pftype_id = ft.pftype_id))) WHERE ((f.params_id = preferred_params_id_by_pftype('TMHMM'::text)) AND ((f."type" = 'M'::bpchar) OR (f."type" = 'N'::bpchar)));
CREATE OR REPLACE VIEW new_pseq_features_tmhmm_excl_signal_v AS
    SELECT tm.feature_type, tm.params_id, tm.params_name, tm.pseq_id, tm."start", tm.stop, tm.score, tm.eval, tm.pmodel_id, tm.feature, tm.acc, tm.descr, tm.details, tm.digest, tm.link_url FROM new_pseq_features_tmhmm_v tm WHERE ((tm.params_id = preferred_params_id_by_pftype('TMHMM'::text)) AND (NOT (EXISTS (SELECT ss.pfeature_id, ss.pseq_id, ss.pftype_id, ss."start", ss.stop, ss.params_id, ss.d_score, ss.signal_peptide FROM pfsignalpnn ss WHERE (((((ss.pseq_id = tm.pseq_id) AND (ss.params_id = preferred_params_id_by_pftype('SignalP'::text))) AND (ss.signal_peptide = true)) AND (ss.stop >= tm."start")) AND (ss."start" <= tm.stop))))));

CREATE OR REPLACE VIEW new_pseq_features_v AS
    (((SELECT feature_type, params_id, params_name, pseq_id, "start", stop, score, eval, pmodel_id, feature, acc, descr, details, digest, link_url FROM new_pseq_features_bigpi_v UNION ALL SELECT feature_type, params_id, params_name, pseq_id, "start", stop, score, eval, pmodel_id, feature, acc, descr, details, digest, link_url FROM new_pseq_features_hmm_v) UNION ALL SELECT feature_type, params_id, params_name, pseq_id, "start", stop, score, eval, pmodel_id, feature, acc, descr, details, digest, link_url FROM new_pseq_features_regexp_v) UNION ALL SELECT feature_type, params_id, params_name, pseq_id, "start", stop, score, eval, pmodel_id, feature, acc, descr, details, digest, link_url FROM new_pseq_features_signalpnn_v) UNION ALL SELECT feature_type, params_id, params_name, pseq_id, "start", stop, score, eval, pmodel_id, feature, acc, descr, details, digest, link_url FROM new_pseq_features_tmhmm_excl_signal_v ORDER BY 4, 5, 6;




COMMENT ON VIEW new_pseq_features_bigpi_v IS 'current Big-PI neural net features';
COMMENT ON COLUMN new_pseq_features_bigpi_v.feature_type IS 'type of features (always ''BIG-PI'')';
COMMENT ON COLUMN new_pseq_features_bigpi_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN new_pseq_features_bigpi_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN new_pseq_features_bigpi_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN new_pseq_features_bigpi_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_bigpi_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_bigpi_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN new_pseq_features_bigpi_v.eval IS 'expectation value';
COMMENT ON COLUMN new_pseq_features_bigpi_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN new_pseq_features_bigpi_v.feature IS 'name of feature (always ''GPI Anchor'')';
COMMENT ON COLUMN new_pseq_features_bigpi_v.descr IS 'unused';
COMMENT ON COLUMN new_pseq_features_bigpi_v.details IS 'prediction details';
COMMENT ON COLUMN new_pseq_features_bigpi_v.link_url IS 'URL to source data';
COMMENT ON VIEW new_pseq_features_hmm_v IS 'current HMM features';
COMMENT ON COLUMN new_pseq_features_hmm_v.feature_type IS 'type of features (always ''HMM'')';
COMMENT ON COLUMN new_pseq_features_hmm_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN new_pseq_features_hmm_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN new_pseq_features_hmm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN new_pseq_features_hmm_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_hmm_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_hmm_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN new_pseq_features_hmm_v.eval IS 'expectation value';
COMMENT ON COLUMN new_pseq_features_hmm_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN new_pseq_features_hmm_v.feature IS 'name of feature (Pfam name)';
COMMENT ON COLUMN new_pseq_features_hmm_v.descr IS 'HMM description';
COMMENT ON COLUMN new_pseq_features_hmm_v.details IS 'prediction details';
COMMENT ON COLUMN new_pseq_features_hmm_v.link_url IS 'URL to source data';
COMMENT ON VIEW new_pseq_features_regexp_v IS 'current regular expression features';
COMMENT ON COLUMN new_pseq_features_regexp_v.feature_type IS 'type of features (always ''regexp'')';
COMMENT ON COLUMN new_pseq_features_regexp_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN new_pseq_features_regexp_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN new_pseq_features_regexp_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN new_pseq_features_regexp_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_regexp_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_regexp_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN new_pseq_features_regexp_v.eval IS 'expectation value';
COMMENT ON COLUMN new_pseq_features_regexp_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN new_pseq_features_regexp_v.feature IS 'name of feature (motif name)';
COMMENT ON COLUMN new_pseq_features_regexp_v.descr IS 'motif description';
COMMENT ON COLUMN new_pseq_features_regexp_v.details IS 'prediction details';
COMMENT ON COLUMN new_pseq_features_regexp_v.link_url IS 'URL to source data';
COMMENT ON VIEW new_pseq_features_signalpnn_v IS 'current SignalP neural net features';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.feature_type IS 'type of features (always ''SignalP'')';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN new_pseq_features_signalpnn_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.eval IS 'expectation value';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.feature IS 'name of feature (always ''SS'')';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.descr IS 'unused';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.details IS 'prediction details';
COMMENT ON COLUMN new_pseq_features_signalpnn_v.link_url IS 'URL to source data';
COMMENT ON VIEW new_pseq_features_tmhmm_v IS 'current TMHMM features';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.feature_type IS 'type of features (always ''TMHMM'')';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.params_id IS 'parameter set identifier -- see params(params_id)';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.params_name IS 'parameter set name -- see params(name)';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN new_pseq_features_tmhmm_v."start" IS 'start of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.stop IS 'stop of prediction in protein sequence';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.score IS 'algorithm-specific score';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.eval IS 'expectation value';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.pmodel_id IS 'unique protein model identifier';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.feature IS 'name of feature (always ''TM'')';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.descr IS 'unused';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.details IS 'prediction details';
COMMENT ON COLUMN new_pseq_features_tmhmm_v.link_url IS 'URL to source data';
COMMENT ON VIEW new_pseq_features_tmhmm_excl_signal_v IS 'current TMHMM features that do not overlap a SignalP NN prediction';
COMMENT ON VIEW new_pseq_features_v IS 'most current features';
COMMENT ON COLUMN new_pseq_features_v.feature_type IS 'type of prediction feature';
COMMENT ON COLUMN new_pseq_features_v.params_id IS 'Unison parameter set';
COMMENT ON COLUMN new_pseq_features_v.params_name IS 'parameter set name';
COMMENT ON COLUMN new_pseq_features_v.pseq_id IS 'Unison pseq_id';
COMMENT ON COLUMN new_pseq_features_v."start" IS 'starting residue of feature';
COMMENT ON COLUMN new_pseq_features_v.stop IS 'starting residue of feature';
COMMENT ON COLUMN new_pseq_features_v.score IS 'raw score of prediction, where available';
COMMENT ON COLUMN new_pseq_features_v.eval IS 'evalue or pvalue of prediction, where available';
COMMENT ON COLUMN new_pseq_features_v.pmodel_id IS 'Unison unique protein model id';
COMMENT ON COLUMN new_pseq_features_v.feature IS 'feature name';
COMMENT ON COLUMN new_pseq_features_v.acc IS 'model accession in external database';
COMMENT ON COLUMN new_pseq_features_v.descr IS 'model description';
COMMENT ON COLUMN new_pseq_features_v.details IS 'additional prediction details';
COMMENT ON COLUMN new_pseq_features_v.link_url IS 'link to model in external database';

REVOKE ALL ON TABLE new_pseq_features_bigpi_v FROM PUBLIC;
REVOKE ALL ON TABLE new_pseq_features_bigpi_v FROM unison;
REVOKE ALL ON TABLE new_pseq_features_hmm_v FROM PUBLIC;
REVOKE ALL ON TABLE new_pseq_features_hmm_v FROM unison;
REVOKE ALL ON TABLE new_pseq_features_regexp_v FROM PUBLIC;
REVOKE ALL ON TABLE new_pseq_features_regexp_v FROM unison;
REVOKE ALL ON TABLE new_pseq_features_signalpnn_v FROM PUBLIC;
REVOKE ALL ON TABLE new_pseq_features_signalpnn_v FROM unison;
REVOKE ALL ON TABLE new_pseq_features_tmhmm_excl_signal_v FROM PUBLIC;
REVOKE ALL ON TABLE new_pseq_features_tmhmm_excl_signal_v FROM unison;
REVOKE ALL ON TABLE new_pseq_features_tmhmm_v FROM PUBLIC;
REVOKE ALL ON TABLE new_pseq_features_tmhmm_v FROM unison;
REVOKE ALL ON TABLE new_pseq_features_v FROM PUBLIC;
REVOKE ALL ON TABLE new_pseq_features_v FROM unison;

GRANT SELECT ON TABLE new_pseq_features_bigpi_v TO PUBLIC;
GRANT SELECT ON TABLE new_pseq_features_hmm_v TO PUBLIC;
GRANT SELECT ON TABLE new_pseq_features_regexp_v TO PUBLIC;
GRANT SELECT ON TABLE new_pseq_features_signalpnn_v TO PUBLIC;
GRANT SELECT ON TABLE new_pseq_features_tmhmm_excl_signal_v TO PUBLIC;
GRANT SELECT ON TABLE new_pseq_features_tmhmm_v TO PUBLIC;
GRANT SELECT ON TABLE new_pseq_features_v TO PUBLIC;

GRANT ALL ON TABLE new_pseq_features_bigpi_v TO unison;
GRANT ALL ON TABLE new_pseq_features_hmm_v TO unison;
GRANT ALL ON TABLE new_pseq_features_regexp_v TO unison;
GRANT ALL ON TABLE new_pseq_features_signalpnn_v TO unison;
GRANT ALL ON TABLE new_pseq_features_tmhmm_excl_signal_v TO unison;
GRANT ALL ON TABLE new_pseq_features_tmhmm_v TO unison;
GRANT ALL ON TABLE new_pseq_features_v TO unison;

ALTER TABLE new_pseq_features_bigpi_v OWNER TO unison;
ALTER TABLE new_pseq_features_hmm_v OWNER TO unison;
ALTER TABLE new_pseq_features_regexp_v OWNER TO unison;
ALTER TABLE new_pseq_features_signalpnn_v OWNER TO unison;
ALTER TABLE new_pseq_features_tmhmm_v OWNER TO unison;
ALTER TABLE new_pseq_features_tmhmm_excl_signal_v OWNER TO unison;
ALTER TABLE new_pseq_features_v OWNER TO unison;
