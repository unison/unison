-- taxonomic schema
-- $Id: schema.sql,v 1.2 2003/04/16 19:03:02 rkh Exp $
-- This schema is NOT intended to represent all nuances of taxonomy it's a
-- middle ground between NCBI's exhaustive tax and Swiss-Prot's
-- species-only tax.  It is intended to be populated with data from both
-- sources.
-- Intended for PostgreSQL (probably required)

-- see also ./schema2.sql and ./init.sql

-- TODO
-- auto ancestor population/calculation


-- for debugging:
-- set search_path = 'rkh';
-- set search_path = 'tax';


create table level
	(
	level_id		smallint 	primary key,
	level			text		not null
	) without oids;
-- level(level_id) is automatically indexed
create unique index level_level_idx on level(upper(level));
-- comments:
comment on table level				is 'enumeration of taxonomy levels';
comment on column level.level_id	is 'unique id for taxonomic level';
comment on column level.level		is 'name of taxonomic level';


create table node
	(
	node_id		  	integer		primary key,
	parent_id		integer 	not null references node(node_id) on update cascade on delete cascade,
	level_id		smallint	references level(level_id) on update cascade,
	latin_name_id	integer,
	common_name_id	integer
	) without oids;
-- node(node_id) is automatically indexed
create index node_parent_id_idx on node(parent_id);
create index node_latin_name_id_idx	on node(latin_name_id);
create index node_common_name_id_idx on node(common_name_id);
-- comments:
comment on table node 				is 'nodes in a taxonomic hierarchy';
comment on column node.node_id		is 'unique, stable taxonomy node identifier';
comment on column node.parent_id	is 'node_id of parent';
comment on column node.level_id		is 'taxonomic level_id';
comment on column node.latin_name_id is 'name_id of Latin name';
comment on column node.common_name_id is 'name_id of common name';


create table specie
	(
	kingdom_id		integer 	references node(node_id) on update cascade on delete cascade,
	phylum_id		integer 	references node(node_id) on update cascade on delete cascade,
	class_id		integer 	references node(node_id) on update cascade on delete cascade,
	order_id		integer 	references node(node_id) on update cascade on delete cascade,
	superfamily_id	integer 	references node(node_id) on update cascade on delete cascade,
	family_id		integer 	references node(node_id) on update cascade on delete cascade,
	genus_id		integer 	references node(node_id) on update cascade on delete cascade,

	swissprot_id	integer,
	swissprot_gs	char(5)
	) inherits (node) without oids;
-- inherited columns:
alter table specie add constraint level_id_exists foreign key (level_id) references level(level_id) on update cascade;
alter table specie add constraint node_exists foreign key (parent_id) references node(node_id) on update cascade on delete cascade;
create unique index specie_node_id_idx 	on specie(node_id);
create index specie_parent_id_idx 	on specie(parent_id);
create index specie_latin_name_id_idx on specie(latin_name_id);
create index specie_common_name_id_idx on specie(common_name_id);
-- indicies for subclass columns:
create index specie_kingdom_idx		on specie(kingdom_id);
create index specie_phylum_idx		on specie(phylum_id);
create index specie_class_idx		on specie(class_id);
create index specie_order_idx		on specie(order_id);
create index specie_superfamily_idx	on specie(superfamily_id);
create index specie_family_idx		on specie(family_id);
create index specie_genus_idx		on specie(genus_id);
-- comments:
comment on table specie				is 'subclass of node table for specie nodes only';
comment on column specie.kingdom_id	is 'node_id of kingdom node';
comment on column specie.phylum_id	is 'node_id of phylum node';
comment on column specie.class_id	is 'node_id of class node';
comment on column specie.order_id	is 'node_id of order node';
comment on column specie.superfamily_id is 'node_id of superfamily node';	
comment on column specie.family_id	is 'node_id of family node';
comment on column specie.genus_id	is 'node_id of genus node';
comment on column specie.swissprot_id is 'swissprot node cross-reference';
comment on column specie.swissprot_gs is 'swissprot 5 char designation';


create table name
	(
	name_id			serial 		primary key,
	node_id			integer		references node(node_id) on update cascade on delete cascade,
	name			text		not null
	) without oids;
create unique index name_name_idx 	on name(upper(name));
comment on column name.name_id		is 'unique id for this taxonomic name';
comment on column name.node_id		is 'node_id for this taxonomic name';
comment on column name.name			is 'name for node';
