-- v_pmprospect_scop -- associate prospect pmodelids with scop sunids

-- There are several cases:
-- case S1:  prospect model acc == scop.cla sid
-- case 

create or replace view _v_pmprospect_scop as

-- 1) SCOP models which correspond exactly to SCOP domains
-- Join "misses" result from Prospect being out sync with SCOP (e.g., a
-- contiguous domain is split in a subsequent version of SCOP).  These
-- cases are ignored, but we could punt with a join on pdbids.
SELECT m.porigin_id,m.pmodel_id,m.acc,c.sunid,c.sid,c.pdb,1 as case
FROM pmprospect m
JOIN scop.cla c on m.acc=c.sid
WHERE m.porigin_id=porigin_id('Prospect/SCOP')

UNION

-- 2) FSSP domains which correspond to full-chain SCOP sids
-- The hallmark for this is a terminal '_'. 
-- Because FSSP and SCOP treat the case of missing chain names differently,
-- we get cases like 153l ~~ d153l__ and 1riba ~~ d1riba_, which can be
-- collapsed into one join criterion using padding (or trimming)
SELECT m.porigin_id,m.pmodel_id,m.acc,c.sunid,c.sid,c.pdb,2 as case
FROM pmprospect m
JOIN scop.cla c on rpad('d'||m.acc,7,'_')=c.sid
WHERE m.porigin_id=porigin_id('Prospect/FSSP')
  AND c.sid~'_$'

UNION

-- 3) Ambiguous matches of a single FSSP to multiple SCOP domains (same pdbc). 
-- The hallmark for this is a terminal \d. We'll generate the 1:N
-- FSSP:SCOP mapping by joining on pdbid.  The prudence of this is in
-- doubt... typically, only one of the N is correct and the rest are
-- misleading.  The cost of not doing this is that we'd miss the 1/N.
SELECT m.porigin_id,m.pmodel_id,m.acc,c.sunid,c.sid,c.pdb,3 as case
FROM pmprospect m
JOIN scop.cla c ON substr(m.acc,1,4) = c.pdb
WHERE m.porigin_id=porigin_id('Prospect/FSSP')
	AND c.sid ~ '\\d$'

SELECT m.porigin_id,m.pmodel_id,m.acc,c.sunid,c.sid,c.pdb,4 as case
FROM pmprospect m
JOIN scop.cla c ON substr(m.acc,1,4) = c.pdb
WHERE m.porigin_id=porigin_id('Prospect/FSSP')
	AND c.sid ~ '\\d$'

;


create or replace view dv_pmprospect_scop as
select pmodel_id,sunid from _v_pmprospect_scop;
