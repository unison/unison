create or replace view nearby_sequences_unsorted_v as
 SELECT pseq.pseq_id AS q_pseq_id, pseq.pseq_id AS t_pseq_id, pseq.len, 100::double precision AS pct_ident, 100::double precision AS pct_coverage
   FROM pseq
UNION ALL 
 SELECT v_papseq.q_pseq_id, v_papseq.t_pseq_id, v_papseq.len, v_papseq.pct_ident, v_papseq.pct_coverage
   FROM papseq_v v_papseq
  WHERE v_papseq.pct_ident > 90::double precision AND v_papseq.pct_coverage > 90::double precision
;

create or replace view nearby_sequences_v as
SELECT * FROM nearby_sequences_unsorted_v
ORDER BY pct_coverage DESC, pct_ident DESC, t_pseq_id;

grant select on nearby_sequences_unsorted_v to public;
grant select on nearby_sequences_v to public;

comment on view nearby_sequences_unsorted_v is 'sequeneces within 90% coverage and 90% identity, unsorted';
comment on view nearby_sequences_v is 'sequeneces within 90% coverage and 90% identity';
