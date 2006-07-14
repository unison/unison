-- $Id: gong.sql,v 1.3 2003/07/01 18:59:55 rkh Exp $
-- GOng -- next generation GO tables

-- This sql creates new tables based on the GO term data.  I find these
-- tables to be easier to navigate than the distributed tables, but YMMV.
-- This code is intended to be run after loading the (converted) GO mysql
-- data.  THIS CODE CONVERTS ONLY THE TERM DATA.

-- (The name GOng is not intended in any way to indicate that the current
-- schema is broken. It supposed to be almost funny, which, like many of
-- my jokes, is probably all that it is.)



drop schema gong cascade;
create schema gong;

set search_path = gong;

create or replace function acc2id (text) returns integer
language plpgsql as '
DECLARE
	acc alias for $1;
	pos integer;
BEGIN
	pos := strpos($1,'':'');
	if pos is null then
		raise exception ''oops.. doesn''''t look like a GO Accession (GO:12345)'';
		return null;
	end if;
	return substr(acc,pos+1)::integer;
END';
	
create or replace function id2acc (integer) returns text
language plperl as 'return sprintf("GO:%06d",$_[0])';
--language plpgsql as 'BEGIN return ''GO:'' || to_char($1,''0000''); END';



create table node (
	go_id integer  primary key,	
	is_obsolete boolean default FALSE,
	alias_id integer,
	definition text,
	comment text )
	without oids;

create table is_a (
	go_id1 integer not null references node(go_id) on delete cascade on update cascade,
	go_id2 integer not null references node(go_id) on delete cascade on update cascade
	) without oids;
create unique index is_a_nonredundant_idx on is_a(go_id1,go_id2);
create index is_a_go_id2_idx on is_a(go_id2);

create table part_of (
	go_id1 integer not null references node(go_id) on delete cascade on update cascade,
	go_id2 integer not null references node(go_id) on delete cascade on update cascade
	) without oids;
create unique index part_of_nonredundant_idx on part_of(go_id1,go_id2);
create index part_of_go_id2_idx on part_of(go_id2);

create table alias (
	alias_id serial primary key,
	alias text not null,
	go_id integer not null references node(go_id) on delete cascade on update cascade )
	without oids;
create index alias_alias_idx on alias(upper(alias));
alter table node add constraint alias_id_exists 
	foreign key (alias_id) references alias(alias_id);


-- populate nodes: pkey is go id; the term name is just another alias
insert into node (go_id,is_obsolete,definition,comment)
	select acc2id(acc),is_obsolete=1,D.term_definition,D.term_comment from go.term T
	left join go.term_definition D on D.term_id=T.id
	where acc~'^GO:[0-9]';
-- insert aliases 
insert into alias(go_id,alias)
	select acc2id(acc),name from go.term where acc~'^GO:[0-9]';
-- make the just-loaded term names the primary alias (node.alias_id)
update node set alias_id=(select alias_id from alias
							 where alias.go_id=node.go_id);
-- load the remaining synonyms
insert into alias (go_id,alias) 
	select acc2id(acc),term_synonym as "alias" from go.term_synonym S
	join go.term T on T.id=S.term_id;

-- extract the is_a links
insert into is_a select acc2id(T2.acc),acc2id(T1.acc) from go.term2term 
	join go.term T1 on T1.id=term1_id  
	join go.term T2 on T2.id=term2_id
	where relationship_type_id=5;
-- extract the part_of links
insert into part_of select acc2id(T2.acc),acc2id(T1.acc) from go.term2term
	join go.term T1 on T1.id=term1_id
	join go.term T2 on T2.id=term2_id
	where relationship_type_id=3;


create view term as select N.go_id,A.alias,N.definition,is_obsolete from node N
	left join alias A on A.alias_id=N.alias_id
	order by is_obsolete,N.go_id;


grant usage on schema GOng to public;
comment on schema gong is 'Gene Ontology next generation -- simplified GO access';

grant select on node to public;
grant select on is_a to public;
grant select on part_of to public;
grant select on alias to public;
grant select on term to public;

comment on table node is 'GO nodes, indexed by their GO id (integer, wo/''GO:'')';
comment on table alias is 'GO names and synonyms';
comment on table is_a is 'GO is_a relationships';
comment on table part_of is 'GO part_of relationships';
comment on view term is 'simple view of GO nodes';
