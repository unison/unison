create table pmprofile
	(
	md5		char(32)
	) inherits (pmodel) without oids;
create unique index pmprofile_pmodel_id_idx on pmprofile(pmodel_id);
create unique index pmprofile_md5_idx on pmprofile(md5);
create index pmprofile_name_idx on pmprofile(name);

create table pfprofile
	(
	pmodel_id integer   references pmprofile(pmodel_id)
							on update cascade on delete cascade,
	eval	double precision,
	len		smallint	
	) inherits (pfeature) without oids;
create index pfprofile_pmodel_id_idx on pfprofile(pmodel_id);
create index pfprofile_eval_idx on pfprofile(eval);
