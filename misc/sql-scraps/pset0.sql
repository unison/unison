-- pset0.sql
-- $Id$
-- differential update of pset 0.

drop table pset0;

create temp table pset0 as select distinct pseq_id
	from palias where porigin_id=porigin_id('kabat');

create index pset0_pseq_id on pset0(pseq_id);
analyze pset0;

delete from pseqset where pset_id=0 and pseq_id not in (select * from pset0);

insert into pseqset select 0,pseq_id 
	from (select pseq_id from pset0 
		  except
		  select pseq_id from pseqset where pset_id=0) X;
