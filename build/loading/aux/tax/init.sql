-- META DATA INITIALIZATIONS
-- ========================================================================

-- these are the levels I've chosen to represent for now
-- gaps exist for intermediate levels
insert into level (level_id,level) values ( 0,'root');
insert into level (level_id,level) values (10,'kingdom');
insert into level (level_id,level) values (20,'phylum');
insert into level (level_id,level) values (30,'class');
insert into level (level_id,level) values (40,'order');
insert into level (level_id,level) values (50,'superfamily');
insert into level (level_id,level) values (60,'family');
insert into level (level_id,level) values (70,'genus');
insert into level (level_id,level) values (80,'species');

-- everything will reside under `root'
-- for root only: node_id=0, name_id=0, level=0
insert into node (node_id,parent_id,level_id) values (0,0,0);
insert into name (name_id,name) values (0,'root');
update node set latin_name_id=0,common_name_id=0 where node_id=0;
