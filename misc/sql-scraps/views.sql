\echo =======================================================================
\echo $Id: views.sql,v 1.2 2002/11/27 00:42:01 rkh Exp $

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


