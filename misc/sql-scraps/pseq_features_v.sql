drop view pseq_features_v ;
drop view pseq_features_bigpi_v ;
drop view pseq_features_hmm_v ;
drop view pseq_features_regexp_v ;
drop view pseq_features_signalpnn_v ;
drop view pseq_features_tmhmm_v ;


CREATE OR REPLACE VIEW pseq_features_bigpi_v AS
  SELECT 	FT.name as feature_type,
			F.params_id,
			P.name as params_name,
			F.pseq_id,
			F.start, F.stop,
            F.score, 
			pvalue::double precision as "eval",
			NULL::integer as "pmodel_id",
			'GPI Anchor'::text as feature,
			NULL::text as "acc",
			NULL::text as "descr",
            'site='||site_no||'; quality='||quality as "details",
			NULL::text as link_url
    FROM pfbigpi F
    JOIN params P ON F.params_id=P.params_id
	JOIN pftype FT on P.pftype_id=FT.pftype_id
   WHERE F.params_id=preferred_params_id_by_pftype('BIG-PI')
         AND F.quality in ('A','B','C','D');
GRANT SELECT ON pseq_features_bigpi_v TO public;
COMMENT ON VIEW pseq_features_bigpi_v IS 'current Big-PI neural net features';


CREATE OR REPLACE VIEW pseq_features_hmm_v AS
  SELECT 	FT.name as feature_type,
			F.params_id,
			P.name as params_name,
			F.pseq_id,
			F.start, F.stop,
			F.score,
			F.eval,
			F.pmodel_id,
			M.name as feature,
			M.acc, 
			M.descr,
			NULL::text as "details",
			link_url(M.origin_id,M.acc)
    FROM pahmm F
    JOIN pmhmm M ON F.pmodel_id=M.pmodel_id 
    JOIN params P ON F.params_id=P.params_id
	JOIN pftype FT on P.pftype_id=FT.pftype_id
   WHERE F.params_id=preferred_params_id_by_pftype('HMM')
     AND F.eval<1;
GRANT SELECT ON pseq_features_hmm_v TO public;
COMMENT ON VIEW pseq_features_hmm_v IS 'current HMM features';


CREATE OR REPLACE VIEW pseq_features_regexp_v AS
  SELECT 	FT.name as feature_type,
			F.params_id,
			P.name as params_name,
			F.pseq_id,
			F.start, F.stop,
			NULL::smallint as "score",
			NULL::double precision as "eval",
			F.pmodel_id,
			M.name as feature,
			M.acc,
			M.descr,
			NULL::text as "details",
			link_url(M.origin_id,M.acc)
    FROM pfregexp F
    JOIN pmregexp M ON F.pmodel_id=M.pmodel_id 
    JOIN params P ON F.params_id=P.params_id
	JOIN pftype FT on P.pftype_id=FT.pftype_id
   WHERE F.params_id=preferred_params_id_by_pftype('regexp');
GRANT SELECT ON pseq_features_regexp_v TO public;
COMMENT ON VIEW pseq_features_regexp_v IS 'current regular expression features';


CREATE OR REPLACE VIEW pseq_features_signalpnn_v AS
  SELECT 	FT.name as feature_type,
			F.params_id,
			P.name as params_name,
			F.pseq_id,
			F.start, F.stop,
            F.d_score as "score",
			NULL::double precision as "eval",
			NULL::integer as pmodel_id,
			'SS'::text as feature,
			NULL::text as acc,
			'signal sequence'::text as "descr",
            NULL::text as "details",
			NULL::text as link_url
    FROM pfsignalpnn F
    JOIN params P ON F.params_id=P.params_id
	JOIN pftype FT on P.pftype_id=FT.pftype_id
   WHERE F.params_id=preferred_params_id_by_pftype('SignalP')
         AND F.signal_peptide=true;
GRANT SELECT ON pseq_features_signalpnn_v TO public;
COMMENT ON VIEW pseq_features_signalpnn_v IS 'current SignalP neural net features';


CREATE OR REPLACE VIEW pseq_features_tmhmm_v AS
  SELECT 	FT.name as feature_type,
			F.params_id,
			P.name as params_name,
			F.pseq_id,
			F.start,F.stop,
			NULL::smallint as "score",
			NULL::double precision as "eval",
			NULL::integer as pmodel_id,
			NULL::text as acc,
			'TM'::text as feature,
			'transmembrane domain'::text as "descr",
			NULL::text as "details",
			NULL::text as link_url
    FROM pftmhmm F
    JOIN params P ON F.params_id=P.params_id
	JOIN pftype FT on P.pftype_id=FT.pftype_id
   WHERE F.params_id=preferred_params_id_by_pftype('TMHMM')
         AND F.type in ('M','N');
GRANT SELECT ON pseq_features_tmhmm_v TO public;
COMMENT ON VIEW pseq_features_tmhmm_v IS 'current TMHMM features';

CREATE OR REPLACE VIEW pseq_features_scop_v as 
	SELECT  'SCOP' AS feature_type, 
		NULL::integer as params_id, 
		NULL:;text as params_name,
		a.q_pseq_id as pseq_id,
		(select CASE WHEN b.start is not null THEN a.q_start+int4larger(0,(pdb_seq_pos(a.pdbc,b.start)-a.t_start)) ELSE q_start END as "case") as start,
		select CASE WHEN b.stop is not null THEN a.q_start+((int4smaller(a.t_stop,pdb_seq_pos(a.pdbc,b\.stop)))-a.t_start) ELSE q_stop END as "case") as stop,
		a.score,
		a.eval,
		NULL::integer as pmodel_id,
		b.scop_id as acc,
		b.family as feature,
		'Classification='||b.class||', '||b.fold||', '||b.superfamily as descr,
		b.sid||', '||b.domain||', '||b.species as "details",
		NULL::text as link_url
		FROM papseq_pdbcs_mv a JOIN scop_v b ON a.pdbc=b.pdb||b.chain 
		WHERE (b.start is not null 
			AND pdb_seq_pos(a.pdbc,b.stop) >= a.t_start and pdb_seq_pos(a.pdbc,b.start) <= a.t_stop) 
			OR b.start is null;




CREATE OR REPLACE VIEW pseq_features_v AS
  SELECT * FROM pseq_features_bigpi_v
 UNION
  SELECT * FROM pseq_features_pfam_v
 UNION
  SELECT * FROM pseq_features_prosite_v
 UNION
  SELECT * FROM pseq_features_signalpnn_v
 UNION
  SELECT * FROM pseq_features_tmhmm_v
ORDER BY pseq_id,start,stop;

GRANT SELECT ON pseq_features_v TO public;
COMMENT ON VIEW pseq_features_v IS 'most current features';

comment on column pseq_features_v.acc is 'model accession in external database';
comment on column pseq_features_v.descr is 'model description';
comment on column pseq_features_v.details is 'additional prediction details';
comment on column pseq_features_v.eval is 'evalue or pvalue of prediction, where available';
comment on column pseq_features_v.feature is 'feature name';
comment on column pseq_features_v.feature_type is 'type of prediction feature';
comment on column pseq_features_v.link_url is 'link to model in external database';
comment on column pseq_features_v.params_id is 'Unison parameter set';
comment on column pseq_features_v.params_name is 'parameter set name';
comment on column pseq_features_v.pmodel_id is 'Unison unique protein model id';
comment on column pseq_features_v.pseq_id is 'Unison pseq_id';
comment on column pseq_features_v.score is 'raw score of prediction, where available';
comment on column pseq_features_v.start is 'starting residue of feature';
comment on column pseq_features_v.stop is 'starting residue of feature';

