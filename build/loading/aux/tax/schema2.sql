-- taxonomic schema part II
-- $Id: schema.sql,v 1.2 2003/04/16 19:03:02 rkh Exp $

-- This files provides auxiliary functionality to the schema in
-- schema.sql.  Obviously, it must be loaded after that file.


create or replace function tax_level_id(text)
returns integer 
language plpgsql as '
DECLARE
	v_level alias for $1;
	rv integer;
BEGIN
	select into rv level_id from level where upper(level)=upper(v_level);
	return rv;
END;';


create or replace function node_iu_trigger()
returns trigger
language plpgsql as '
DECLARE
	v_parent_level_id integer;
BEGIN
	-- ensure that this isn''t a species node
	if new.level == tax_level_id(''species'') then
		raise exception ''species nodes must be inserted into the species table'';
	end if;

	-- ensure that this node is at a lower tax level that its parent
	if new.parent_id not null then
		select into v_parent_level_id level_id from node where node_id=new.parent_id;
		if v_parent_level_id not null and level_id<v_parent_level_id then
			raise exception ''parent must be in a higher taxonomic level (lower level_id)'';
		end if;
	end if;
END;';


create or replace function specie_iu_trigger()
returns trigger
language plpgsql as '
BEGIN
	if new.level != tax_level_id(''species'') then
		raise notice ''species level reset to species (use default next time)'';
		new.level = tax_level_id(''species'');
	end if;
END;';




alter table specie alter column level_id set default tax_level_id('species');

drop trigger specie_iu on specie;
create trigger specie_iu before insert or update on specie
for each row execute procedure specie_iu_trigger();
