-- $Id$
-- GOng -- next generation GO tables
-- This sql creates new tables based on the GO term data.  I find these
-- tables to be easier to navigate than the distributed tables, but YMMV.
-- This code is intended to be run after loading the (converted) GO mysql
-- data.  THIS CODE CONVERTS ONLY THE TERM DATA.


set search_path = go;

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
	

drop table is_a;
drop table part_of;
drop table node cascade;
drop table alias;

create table node (
	go_id integer  primary key,	
	is_obsolete boolean default FALSE,
	alias_id integer )
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


insert into node (go_id,is_obsolete) select acc2id(acc),is_obsolete=1 from term where acc~'^GO:[0-9]';
insert into alias(go_id,alias) select acc2id(acc),name from term where acc~'^GO:[0-9]';
update node set alias_id=(select alias_id from alias where alias.go_id=node.go_id);
insert into is_a select acc2id(T2.acc),acc2id(T1.acc) from term2term  join term T1 on T1.id=term1_id  join term T2 on T2.id=term2_id  where relationship_type_id=5;
insert into part_of select acc2id(T2.acc),acc2id(T1.acc) from term2term  join term T1 on T1.id=term1_id  join term T2 on T2.id=term2_id  where relationship_type_id=3;
insert into alias (go_id,alias) select acc2id(acc),term_synonym as "alias" from term_synonym join term on term.id=term_synonym.term_id;
