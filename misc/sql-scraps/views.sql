\echo =======================================================================
\echo $Id$

-- views

/*	to-do
	pseqsummary		for each seq: # aliases, # sets, # features
	poriginsummary	for each origin: # aliases
	psetsummary		for each set: # seqs
*/


/* drop view pseqsummary;
create view pseqsummary as
	select q.pseq_id,q.len,q.seq,o.origin,a.alias
	from  pseq as q  
	right join palias as a on q.pseq_id=a.pseq_id
	left join porigin as o on a.porigin_id=o.porigin_id
	order by q.pseq_id,o.origin,a.alias;
*/