delete from pseqset;
delete from pseq;
delete from pset;

select setval('pseq_pseq_id_seq',1,false);
select setval('pset_pset_id_seq',1,false);


\echo =================================================================
\echo adding sequences
insert into pseq (seq) VALUES ('seqa');
insert into pseq (seq) VALUES ('seqb');
insert into pseq (seq) VALUES ('seqc');
insert into pseq (seq) VALUES ('seqd');
insert into pseq (seq) VALUES ('seqe');
\echo return to continue \!read z


\echo =================================================================
\echo adding 1 set; expect 1 failure
insert into pset (name) VALUES ('test set1');
insert into pset (name) VALUES ('test set2');
insert into pset (name) VALUES ('test set1'); -- duplicate name
\echo return to continue \!read z


\echo =================================================================
\echo adding sequences to sets
insert into pseqset (pseq_id,pset_id) values (1,1);
insert into pseqset (pseq_id,pset_id) values (2,1);
insert into pseqset (pseq_id,pset_id) values (3,2);
insert into pseqset (pseq_id,pset_id) values (4,2);
insert into pseqset (pseq_id,pset_id) values (5,1);
insert into pseqset (pseq_id,pset_id) values (5,2);
\echo return to continue \!read z


\echo =================================================================
\echo current sequences / sets
select q.pseq_id,q.seq,t.pset_id,t.name
	from pseq as q
	join pseqset as qt on q.pseq_id=qt.pseq_id
	join pset    as t  on qt.pset_id=t.pset_id
	order by q.pseq_id;
\echo return to continue \!read z


\echo =================================================================
\echo deleting sequence 1 should remove 1 pseqset entries too...
\echo before...
select count(*) from pseqset;
delete from pseq where pseq_id = 1;
\echo after...
select count(*) from pseqset;


\echo =================================================================
\echo deleting set 1 should remove 3 pseqset entries too...
\echo before...
select count(*) from pseqset;
delete from pset where pset_id = 1;
\echo after...
select count(*) from pseqset;


\echo =================================================================
\echo this leaves...
select q.pseq_id,q.seq,t.pset_id,t.name
	from pseq as q
	join pseqset as qt on q.pseq_id=qt.pseq_id
	join pset    as t  on qt.pset_id=t.pset_id
	order by q.pseq_id;
\echo return to continue \!read z
