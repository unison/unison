create or replace view nearby_patents_unsorted_v as
SELECT q_pseq_id,t_pseq_id,len,round(pct_coverage::numeric,1) as pct_coverage,round(pct_ident::numeric,1) as pct_ident,
	   origin,alias,species,patent_date,patent_authority,descr
FROM nearby_sequences_unsorted_v N
JOIN patents_unsorted_v P ON N.t_pseq_id=P.pseq_id
;
grant select on nearby_patents_unsorted_v to public;

create or replace view nearby_patents_v as
SELECT * from nearby_patents_unsorted_v
ORDER by pct_coverage desc,pct_ident desc,t_pseq_id,patent_date,patent_authority,origin = 'pataa',alias
;
grant select on nearby_patents_v to public;
