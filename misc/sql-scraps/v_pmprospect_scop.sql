-- v_pmprospect_scop -- associate prospect pmodelids with scop sunids

-- There are several cases:
-- case S1:  prospect model acc == scop.cla sid
-- case 

create or replace view _v_pmprospect_scop as

-- 1) SCOP models which correspond exactly to SCOP domains
-- Join "misses" result from Prospect being out sync with SCOP (e.g., a
-- contiguous domain is split in a subsequent version of SCOP).  These
-- cases are ignored, but we could punt with a join on pdbids.
SELECT m.origin_id,m.pmodel_id,m.acc,c.sunid,c.sid,c.pdb,1 as case
FROM pmprospect m
JOIN scop.cla c on m.acc=c.sid
WHERE m.origin_id=origin_id('Prospect/SCOP')

UNION

-- 2) FSSP identifiers always correspond to full chains, while SCOP
-- domains may be full or partial chains.  Our choices are 1) map FSSP to
-- SCOP for full length chains only (1:1 map), or 2) map FSSP chains to
-- all SCOP domains with the same 'pdbc' (1:N map).  The former is more
-- specific, the latter more sensitive.  We opt for 2.

SELECT m.origin_id,m.pmodel_id,m.acc,c.sunid,c.sid,c.pdb,2 as case
FROM pmprospect M
JOIN scop.cla C on rpad(M.acc,5,'_')=substr(C.sid,2,5)
WHERE M.origin_id=origin_id('Prospect/FSSP');

;

grant select on _v_pmprospect_scop to public;
comment on view _v_pmprospect_scop is 'prospect pmodel_id-to-scop sunid mapping, with debugging info';



create or replace view dv_pmprospect_scop as
select pmodel_id,sunid from _v_pmprospect_scop;

grant select on dv_pmprospect_scop to public;
comment on view dv_pmprospect_scop is 'prospect pmodel_id-to-scop sunid mapping';
