-- prospect2 -- prospect v2 threading results


-- p2params -- prospect 2 runtime parameters and parameter set names
create table p2params (
	p2params_id		serial,
	name			text			not null default null,
	secstr			boolean			not null default null,
	useprofile		boolean			not null default null,
	global			boolean			not null default null
	);


-- p2template -- templates (presumably fssp or scop ids)
create table p2template (
	p2template_id	serial,
	pstr_id			integer,
	name			text			unique,
	len				integer			not null default null,

	constraint pstr_exists
		foreign key (pstr_id)
		references pstr (pstr_id)
		on delete cascade
		on update cascade
	);


-- p2thread -- one sequence-structure threading result
create table p2thread (
	p2thread_id		serial,
	p2params_id		integer			not null default null,
	p2template_id	integer			not null default null,

	raw				float			not null default null,
	mutation		float			not null default null,
	singleton		float			not null default null,
	pairwise		float			not null default null,
	gap				float			not null default null,
	ssfit			float			not null default null,
	zscore			float					 default null,
	rgyr			float					 default null,

	nident			integer			not null default null,
	nalign			integer			not null default null,
	
	alignment		text					 default null,

	constraint p2params_exists
		foreign key (p2params_id)
		references p2params (p2params_id)
		on delete cascade
		on update cascade,

	constraint p2template_exists
		foreign key (p2template_id)
		references p2template (p2template_id)
		on delete cascade
		on update cascade

	) inherits (pfeature);

create function p2thread_i_trigger () returns opaque as 
	'BEGIN NEW.pftype_id=pftype_id_lookup(prospect2); return new; END;' language 'plpgsql';
create trigger p2thread_i_trigger 
	BEFORE insert on p2thread for each row
	execute procedure p2thread_i_trigger ();
