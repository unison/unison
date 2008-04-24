drop table aliasset cascade;
drop table aliasset_alias cascade;
drop function aliasset_owner(integer);


create table aliasset (
	   aliasset_id serial primary key,
	    owner text not null default current_user,
		descr text,
		is_public boolean not null default false,
		created timestamp not null default now(),
		updated timestamp
		);
grant insert on aliasset to public;



create function aliasset_owner(integer)
returns text
strict immutable
language sql
as $_$select owner from aliasset where aliasset_id=$1$_$;

grant execute on aliasset_owner to public;


create table aliasset_alias (
	   aliasset_id integer not null
	   			   references aliasset(aliasset_id)
				   on delete cascade
				   on update cascade,
	   alias text not null,
	   pseq_id integer
	   		   references pseq(pseq_id)
			   on delete set null
			   on update cascade
);

grant insert on aliasset to public;
