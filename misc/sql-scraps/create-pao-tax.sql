drop table paotax;

create table paotax (palias_id integer not null,
	tax_id integer, infer_tax_id integer) without oids;

insert into paotax select
AO.palias_id,AO.tax_id,infer_tax_id(O.origin,AO.alias,AO.descr) from
paliasorigin AO join (select * from pseqalias where added>=now()-'12 weeks'::interval)
SA on SA.palias_id=AO.palias_id join origin O on
O.origin_id=AO.origin_id;
