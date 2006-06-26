\echo =======================================================================
\echo $Id: init.sql,v 1.1 2003/04/12 00:36:40 rkh Exp $
-- initialize database with some defaults


-- =======================================================================
insert into meta (key,value) values ('schema_Id','$Id: init.sql,v 1.1 2003/04/12 00:36:40 rkh Exp $');
insert into meta (key,value) values ('schema_Revision','$Revision: 1.1 $');
--insert into meta (key,value) values ('schema_version','0.0.0');
--insert into meta (key,value) values ('schema_min_version','0.0');


-- =======================================================================
-- 1..10 is for special origins
select setval('origin_origin_id_seq',1,FALSE);
insert into origin (origin) values ('Unison');
insert into origin (origin) values ('manual');

-- 11..1000 is for well-known origins
select setval('origin_origin_id_seq',11,FALSE);
insert into origin (origin) values ('PDB');
insert into origin (origin) values ('Swiss-Prot');
insert into origin (origin) values ('TrEMBL');
insert into origin (origin) values ('Ensembl');
insert into origin (origin) values ('SPDI');
insert into origin (origin) values ('Celera/Genscan');
insert into origin (origin) values ('NHGD30/Genscan');
insert into origin (origin) values ('IPI');
insert into origin (origin) values ('Proteome');
insert into origin (origin) values ('Refseq');
insert into origin (origin) values ('Prospect2');

-- 1001..10000 (I hope it never gets there) is reserved for methods
select setval('origin_origin_id_seq',1001,FALSE);
insert into origin (origin) values ('EMBOSS/sigcleave');

-- 10001.. is for newly-added sources
select setval('origin_origin_id_seq',10001,FALSE);


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
