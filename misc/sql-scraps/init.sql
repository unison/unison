\echo =======================================================================
\echo $Id: init.sql,v 1.7 2003/01/06 23:07:23 rkh dead $
-- initialize database with some defaults


-- =======================================================================
insert into meta (key,value) values ('schema_Id','$Id: init.sql,v 1.7 2003/01/06 23:07:23 rkh dead $');
insert into meta (key,value) values ('schema_Revision','$Revision: 1.7 $');
--insert into meta (key,value) values ('schema_version','0.0.0');
--insert into meta (key,value) values ('schema_min_version','0.0');


-- =======================================================================
-- 1..10 is for special origins
select setval('porigin_porigin_id_seq',1,FALSE);
insert into porigin (origin) values ('Unison');
insert into porigin (origin) values ('manual');

-- 11..1000 is for well-known origins
select setval('porigin_porigin_id_seq',11,FALSE);
insert into porigin (origin) values ('PDB');
insert into porigin (origin) values ('Swiss-Prot');
insert into porigin (origin) values ('TrEMBL');
insert into porigin (origin) values ('Ensembl');
insert into porigin (origin) values ('SPDI');
insert into porigin (origin) values ('Celera/Genscan');
insert into porigin (origin) values ('NHGD30/Genscan');
insert into porigin (origin) values ('IPI');
insert into porigin (origin) values ('Proteome');
insert into porigin (origin) values ('Refseq');
insert into porigin (origin) values ('Prospect2');

-- 1001..10000 (I hope it never gets there) is reserved for methods
select setval('porigin_porigin_id_seq',1001,FALSE);
insert into porigin (origin) values ('EMBOSS/sigcleave');

-- 10001.. is for newly-added sources
select setval('porigin_porigin_id_seq',10001,FALSE);


-- =======================================================================
select setval('pftype_pftype_id_seq',1,FALSE);
insert into pftype (name) values ('manual');
insert into pftype (name) values ('p2thread');
insert into pftype (name) values ('EMBOSS/sigcleave');
insert into pftype (name) values ('tmdetect/signal');
insert into pftype (name) values ('tmdetect/tm');


-- =======================================================================
select setval('pset_pset_id_seq',1,FALSE);
insert into pset (name) values ('Human [Homo sapiens]');
insert into pset (name) values ('Mouse [Mus musculus]');
insert into pset (name) values ('Rat [Rattus norvegicus]');
