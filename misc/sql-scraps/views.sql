\echo =======================================================================
\echo $Id: views.sql,v 1.3 2002/12/10 19:48:12 rkh Exp $

-- views

/*	to-do
	pseqsummary		for each seq: # aliases, # sets, # features
	poriginsummary	for each origin: # aliases
	psetsummary		for each set: # seqs
*/


/* drop view pseqsummary; */
create view pseqsummary as
	select q.pseq_id,q.len,q.md5,o.origin,a.alias,q.seq
	from pseq as q  
	full join palias as a on q.pseq_id=a.pseq_id
	left join porigin as o on a.porigin_id=o.porigin_id
	order by q.pseq_id,o.origin,a.alias;


create view redundant_spdi as
	select distinct pseq_id,porigin_id,count(porigin_id)
	from palias group by pseq_id,porigin_id
	having count(porigin_id)>3 order by count(porigin_id);
