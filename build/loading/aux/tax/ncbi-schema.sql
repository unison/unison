set search_path = 'taxonomy';

create table division
	(
	division_id	integer primary key,
	code	char(3),
	name	text,
	comments text	
	) without oids;

create table node
	(
	tax_id	integer primary key,
	parent_tax_id integer,
	rank	text,
	embl	text,
	division_id integer references division(division_id) 
							on update cascade on delete cascade,
	divinh	boolean,
	gbhidden  boolean,
	hidden  boolean,
	comments text
	) without oids;
create index node_parent_tax_id_idx on node(parent_tax_id);

create table name
	(
	tax_id	integer references node(tax_id)
							on update cascade on delete cascade,
	name	text,
	uname	text,
	class	text
	) without oids;
create index name_tax_id_idx on name(tax_id);
create index name_name_idx on name(name);
create index name_uname_idx on name(uname);
