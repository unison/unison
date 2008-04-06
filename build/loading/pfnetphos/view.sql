create or replace view pfnetphos_site_predictions_v as
select pseq_id,params_id,start,as_set(kinase||'('||prob||')')
from (select pseq_id,params_id,start,prob,kinase
	 from pfnetphos
	 where prob>=0.5
	 order by pseq_id,params_id,start,prob desc) X
group by pseq_id,params_id,start;

grant select on pfnetphos_site_predictions_v to public;
