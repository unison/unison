-- set search_path = 'rkh';

create table node
	(
	node_id  integer primary key,
	name	text not null,
	level	smallint,
	parent_node_id integer references node(node_id) on update cascade on delete cascade
	) without oids;
create index node_name_idx on node(name);
create index node_parent_node_id_idx on node(parent_node_id);
comment on column node.node_id	is 'unique, stable taxonomy node identifier';
comment on column node.name		is 'latin name of this node';
comment on column node.level		is 'tree level; 0=root, 10=kingdom..80=species';
comment on column node.parent_node_id is 'id of higher level';
insert into node values (0,'root',0,NULL);


create table specie
	(
	kingdom_id		integer references node(node_id) on update cascade on delete cascade,
	phylum_id		integer references node(node_id) on update cascade on delete cascade,
	class_id		integer references node(node_id) on update cascade on delete cascade,
	order_id		integer references node(node_id) on update cascade on delete cascade,
	superfamily_id	integer references node(node_id) on update cascade on delete cascade,
	family_id		integer references node(node_id) on update cascade on delete cascade,
	genus_id		integer references node(node_id) on update cascade on delete cascade,
	species_id		integer references node(node_id) on update cascade on delete cascade,

	swissprot_id	integer,
	swissprot_GS	char(5)
	) inherits (node) without oids;
create index specie_name_idx on specie(name);
create index specie_parent_node_id_idx on specie(parent_node_id);
comment on column specie.kingdom_id	is 'node_id of kingdom node';
comment on column specie.phylum_id		is 'node_id of phylum node';
comment on column specie.class_id		is 'node_id of class node';
comment on column specie.order_id		is 'node_id of order node';
comment on column specie.superfamily_id is 'node_id of superfamily node';	
comment on column specie.family_id		is 'node_id of family node';
comment on column specie.genus_id		is 'node_id of genus node';
comment on column specie.species_id	is 'node_id of species node';	
comment on column specie.swissprot_id	is 'swissprot node cross-reference';
comment on column specie.swissprot_GS	is 'swissprot 5 char designation';


create table synonym
	(
	node_id		integer references node(node_id) on update cascade on delete cascade,
	synonym		text
	) without oids;
create index synonym_node_id_idx on synonym(node_id);
create index synonym_synonym_idx on synonym(synonym);
comment on column synonym.node_id		is 'node_id to which synonym is attached';
comment on column synonym.synonym		is 'synonym for node';

