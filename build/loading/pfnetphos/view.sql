create or replace view pfnetphos_site_predictions_v as
select pseq_id,params_id,start as pos,max(prob) as "max_prob",as_set(kinase||'('||prob||')') as kinases
from (select pseq_id,params_id,start,prob,kinase
	 from pfnetphos
	 where prob>=0.5
	 order by pseq_id,params_id,start,prob desc) X
group by pseq_id,params_id,start;

grant select on pfnetphos_site_predictions_v to public;


CREATE OR REPLACE VIEW pseq_features_netphos_v as
SELECT ft.name AS feature_type, f.params_id, p.name AS params_name,
	   f.pseq_id, f.pos as "start", f.pos as stop, max_prob AS score, 
	   NULL::double precision AS eval, 
	   NULL::integer AS origin_id, NULL::text AS origin, NULL::integer AS pmodel_id, 
	   'p'||aa_1_to_3(substr(seq,pos,1)) AS feature, 
	   NULL::text AS acc,
	   'predicted phospho-'||aa_1_to_3(substr(seq,pos,1))||'; '||kinases AS descr,
	   NULL::text AS details,
	   domain_digest(f.pos, 'p'||aa_1_to_3(substr(seq,pos,1)), max_prob) AS digest,
	   NULL::text AS link_url
   FROM pfnetphos_site_predictions_v f
   JOIN pseq q on f.pseq_id=q.pseq_id
   JOIN params p ON f.params_id = p.params_id
   JOIN run r ON r.params_id = p.params_id
   JOIN pftype ft ON ft.preferred_run_id = r.run_id
  WHERE ft.name = 'netphos'::text AND f.max_prob>=0.5;

