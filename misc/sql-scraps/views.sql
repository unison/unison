\echo =======================================================================
\echo $Id: views.sql,v 1.5 2002/12/13 23:27:02 rkh Exp $

-- views

/*	to-do
	pseqsummary		for each seq: # aliases, # sets, # features
	poriginsummary	for each origin: # aliases
	psetsummary		for each set: # seqs
*/


/* drop view pseqsummary; */
create view pseqsummary as
	select q.pseq_id,o.origin,a.alias,a.descr,q.len,q.seq
	from pseq as q  
	full join palias as a on q.pseq_id=a.pseq_id
	left join porigin as o on a.porigin_id=o.porigin_id
	order by q.pseq_id,o.origin,a.alias;


-- create view redundant_spdi as
-- 	select distinct a.pseq_id,o.origin,count(a.porigin_id)
-- 	from palias as a
-- 	join porigin as o on 
-- 	where o.origin='SPDI'
-- 	group by pseq_id,porigin_id
-- 	having count(porigin_id)>3 order by count(porigin_id);
