-- $Id: sp-schema.sql,v 1.2 2003/07/09 19:36:58 rkh Exp $
-- schema for swissprot species codes

create table tax.spspec
	(
	tax_id	integer primary key,
	K		char(1),
	gs		text,
	name	text
	) without oids;
create index spspec_K_idx on tax.spspec(K);
create unique index spspec_gs_idx on tax.spspec(gs);
create unique index spspec_name_idx on tax.spspec(name);


create or replace function tax.gs2tax_id(text)
returns integer
language plpgsql as '
DECLARE
	v_gs alias for $1;
	rv integer;
BEGIN
	select into rv tax_id from tax.spspec where gs=v_gs;
	return rv;
END;';

create or replace function tax.tax_id2name(integer)
returns text
language plpgsql as '
DECLARE
	v_id alias for $1;
	rv text;
BEGIN
	select into rv name from tax.spspec where tax_id=v_id;
	return rv;
END;';

create or replace function tax.tax_id2gs(integer)
returns text
language plpgsql as '
DECLARE
	v_id alias for $1;
	rv text;
BEGIN
	select into rv gs from tax.spspec where tax_id=v_id;
	return rv;
END;';
