-- pstr -- protein structure reference

create table pstr (
	pstr_id			serial,
	pseq_id			integer not null default null,
	pdbc			varchar(5),

	constraint pseq_id_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade
	);

create index pstr_pdbc_idx on pstr (pdbc);
