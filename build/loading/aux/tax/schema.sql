-- taxonomic schema
-- $Id$
-- this schema is not intended to represent all nuances of taxonomy it's a
-- middle ground between NCBI's exhaustive tax and Swiss-Prot's
-- species-only tax.  It is intended to be populated with data from both
-- sources.
-- * 2003/04/16 (Wed) 11:59 Reece Hart <reece@in-machina.com, rkh@gene.com>

-- for debugging:
-- set search_path = 'rkh';

create table level
	(
	level			smallint 	primary key,
	name			text		not null
	) without oids;
comment on table level is 'enumeration of taxonomy levels';


create table node
	(
	node_id		  	integer		primary key,
	parent_id		integer 	references node(node_id) on update cascade on delete cascade,
	level			smallint	references level(level)  on update cascade,
	latin_name_id	integer,
	common_name_id	integer
	) without oids;
-- node(node_id) is automatically indexed
create index node_parent_id_idx on node(parent_id);
create index node_latin_name_id_idx	on node(latin_name_id);
create index node_common_name_id_idx on node(common_name_id);
comment on table node 				is 'nodes in a taxonomic hierarchy';
comment on column node.node_id		is 'unique, stable taxonomy node identifier';
comment on column node.parent_id	is 'node_id of parent';
comment on column node.level		is 'taxonomic level';
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
alter table specie add constraint level_exists foreign key (level) references level(level) on update cascade;
alter table specie add constraint node_exists foreign key (parent_id) references node(node_id) on update cascade on delete cascade;
-- indicies for inherited fields:
-- create index specie_node_id_idx 	on specie(node_id);
create index specie_parent_id_idx 	on specie(parent_id);
create index specie_latin_name_id_idx on specie(latin_name_id);
create index specie_common_name_id_idx on specie(common_name_id);
-- indicies for subclass fields:
create index specie_kingdom_idx		on specie(kingdom_id);
create index specie_phylum_idx		on specie(phylum_id);
create index specie_class_idx		on specie(class_id);
create index specie_order_idx		on specie(order_id);
create index specie_superfamily_idx	on specie(superfamily_id);
create index specie_family_idx		on specie(family_id);
create index specie_genus_idx		on specie(genus_id);
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
create index name_name_idx 	on name(name);
comment on column name.name_id		is 'unique id for this taxonomic name';
comment on column name.node_id		is 'node_id for this taxonomic name';
comment on column name.name			is 'name for node';


-- these are the levels I've chosen to represent for now
-- gaps exist for intermediate levels
insert into level (level,name) values ( 0,'root');
insert into level (level,name) values (10,'kingdom');
insert into level (level,name) values (20,'phylum');
insert into level (level,name) values (30,'class');
insert into level (level,name) values (40,'order');
insert into level (level,name) values (50,'superfamily');
insert into level (level,name) values (60,'family');
insert into level (level,name) values (70,'genus');
insert into level (level,name) values (80,'species');

-- everything will reside under `root'
-- for root only: node_id=0, name_id=0, level=0
insert into node (node_id,parent_id,level) values (0,NULL,0);
insert into name (name_id,name) values (0,'root');
update node set latin_name_id=0,common_name_id=0 where node_id=0;


-- TODO
-- species trigger: level=<species level>
-- node trigger: level=!<species level>
