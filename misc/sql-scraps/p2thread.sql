\echo =======================================================================
\echo $Id: p2thread.sql,v 1.1 2002/12/10 19:48:11 rkh Exp $
-- p2thread -- one sequence-structure threading result

create table p2thread (
	p2params_id		integer			not null default null,
	p2template_id	integer			not null default null,

	raw				float			not null default null,
	mutation		float			not null default null,
	singleton		float			not null default null,
	pairwise		float			not null default null,
	gap				float			not null default null,
	ssfit			float			not null default null,
	zscore			float					 default null,
	svm				float					 default null,
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

	) inherits (pfeature);		-- non-standard

create index p2thread_p2params_id on p2thread (p2params_id);
create index p2thread_p2template_id on p2thread (p2template_id);
create index p2thread_raw on p2thread (raw);
create index p2thread_mutation on p2thread (mutation);
create index p2thread_singleton on p2thread (singleton);
create index p2thread_pairwise on p2thread (pairwise);
create index p2thread_gap on p2thread (gap);
create index p2thread_ssfit on p2thread (ssfit);
create index p2thread_zscore on p2thread (zscore);
create index p2thread_svm on p2thread (svm);
create index p2thread_rgyr on p2thread (rgyr);

create function p2thread_i_trigger () returns trigger as 
	'BEGIN NEW.pftype_id=pftype_id_lookup(prospect2); return new; END;' language 'plpgsql';
create trigger p2thread_i_trigger 
	BEFORE insert on p2thread for each row
	execute procedure p2thread_i_trigger ();
