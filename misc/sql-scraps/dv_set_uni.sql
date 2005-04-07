-- see docs/uni-psets for a description of unison sequence sets

CREATE OR REPLACE VIEW v_uni_originA as 
SELECT DISTINCT pseq_id FROM palias WHERE porigin_id in (porigin_id('GenenGenes'),porigin_id('UniProt'));

CREATE OR REPLACE VIEW v_uni_originB as 
SELECT pseq_id FROM v_uni_originA
UNION SELECT pseq_id FROM palias WHERE porigin_id in (porigin_id('RefSeq'));

CREATE OR REPLACE VIEW v_uni_originC as 
SELECT pseq_id FROM v_uni_originB
UNION SELECT pseq_id FROM palias WHERE porigin_id in (porigin_id('Swiss-Prot'));

CREATE OR REPLACE VIEW v_uni_originD as 
SELECT pseq_id FROM v_uni_originC
UNION SELECT pseq_id FROM palias WHERE porigin_id in (porigin_id('Geneseq'));

grant select on v_uni_originA,v_uni_originB,v_uni_originC,v_uni_originD to PUBLIC;


CREATE OR REPLACE VIEW v_uni_speciesA as
SELECT pseq_id FROM palias WHERE tax_id=gs2tax_id('HUMAN');

CREATE OR REPLACE VIEW v_uni_speciesB as
SELECT pseq_id FROM v_uni_speciesA 
UNION SELECT pseq_id FROM palias WHERE tax_id=gs2tax_id('MOUSE');

CREATE OR REPLACE VIEW v_uni_speciesC as
SELECT pseq_id FROM v_uni_speciesB
UNION SELECT pseq_id FROM palias WHERE tax_id=gs2tax_id('RAT');

CREATE OR REPLACE VIEW v_uni_speciesD as
SELECT pseq_id FROM v_uni_speciesC
UNION SELECT pseq_id FROM palias WHERE tax_id=gs2tax_id('YEAST') or tax_id=gs2tax_id('BRARE');

grant select on v_uni_speciesA,v_uni_speciesB,v_uni_speciesC,v_uni_speciesD to PUBLIC;


CREATE OR REPLACE VIEW v_uni_lengthA as
SELECT pseq_id FROM pseq WHERE len>=125 AND len<=1000;

CREATE OR REPLACE VIEW v_uni_lengthB as
SELECT pseq_id FROM pseq WHERE len>=125 AND len<=1000;

CREATE OR REPLACE VIEW v_uni_lengthC as
SELECT pseq_id FROM pseq WHERE len>=50 AND len<=1500;

CREATE OR REPLACE VIEW v_uni_lengthD as
SELECT pseq_id FROM pseq WHERE len>=50 AND len<=2000;

grant select on v_uni_lengthA,v_uni_lengthB,v_uni_lengthC,v_uni_lengthD to PUBLIC;



CREATE OR REPLACE VIEW dv_set_uniA as
			SELECT pseq_id from v_uni_originA
INTERSECT	SELECT pseq_id from v_uni_speciesA
INTERSECT	SELECT pseq_id from v_uni_lengthA;

CREATE OR REPLACE VIEW dv_set_uniB as
			SELECT pseq_id from v_uni_originB
INTERSECT	SELECT pseq_id from v_uni_speciesB
INTERSECT	SELECT pseq_id from v_uni_lengthB;

CREATE OR REPLACE VIEW dv_set_uniC as
			SELECT pseq_id from v_uni_originC
INTERSECT	SELECT pseq_id from v_uni_speciesC
INTERSECT	SELECT pseq_id from v_uni_lengthC;

CREATE OR REPLACE VIEW dv_set_uniD as
			SELECT pseq_id from v_uni_originD
INTERSECT	SELECT pseq_id from v_uni_speciesD
INTERSECT	SELECT pseq_id from v_uni_lengthD;

grant select on dv_set_uniA,dv_set_uniB,dv_set_uniC,dv_set_uniD to PUBLIC;

comment on view dv_set_uniA is 'defining view for pseq uniA';
comment on view dv_set_uniB is 'defining view for pseq uniB';
comment on view dv_set_uniC is 'defining view for pseq uniC';
comment on view dv_set_uniD is 'defining view for pseq uniD';


-- TESTING
-- ======================
-- drop table uniA;
-- drop table uniB;
-- drop table uniC;
-- drop table uniD;
-- 
-- create table uniA as select * from dv_set_uniA;
-- create table uniB as select * from dv_set_uniB;
-- create table uniC as select * from dv_set_uniC;
-- create table uniD as select * from dv_set_uniD;
-- 
-- select count(*) from uniA;
-- select count(*) from uniB;
-- select count(*) from uniC;
-- select count(*) from uniD;
