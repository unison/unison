-- -----------------------------------------------------------------------------
-- NAME: itim_mining.sql
-- PURPOSE: sql code for mining Unison for ITIMS
-- 
-- $Id: itim_mining.sql,v 1.2 2004/05/05 22:57:21 cavs Exp $
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW cavs.canonical_itim AS
  SELECT r.pseq_id, h.start as "Ig_start",h.stop as "Ig_stop",
    t.start as "tm_start",t.stop as "tm_stop",
    r.start as "ITIM_start", r.stop as "ITIM_stop"
  FROM pahmm h
    JOIN pftmdetect t ON h.pseq_id = t.pseq_id
    JOIN pfregexp r ON h.pseq_id = r.pseq_id
  WHERE
    h.pmodel_id=11356269 AND h.eval <= 0.02 AND
    t.pftype_id IN (5,6) AND t.start > h.stop AND
    r.pmodel_id=11368857 AND r.start > t.stop;

CREATE OR REPLACE VIEW cavs.pfam_tm_itim AS
  SELECT r.pseq_id, h.start as "Pfam_start",h.stop as "Pfam_stop",
    t.start as "tm_start",t.stop as "tm_stop",
    r.start as "ITIM_start", r.stop as "ITIM_stop"
  FROM pahmm h
    JOIN pftmdetect t ON h.pseq_id = t.pseq_id
    JOIN pfregexp r ON h.pseq_id = r.pseq_id
  WHERE
    h.pmodel_id IN (11356269,10283) AND h.eval <= 0.02 AND
    t.pftype_id IN (5,6) AND t.start > h.stop AND
    r.pmodel_id=11368857 AND r.start > t.stop;


CREATE OR REPLACE VIEW cavs.prospect_ig_fn3_IN_top10 AS
 SELECT x.pseq_id, ( SELECT count(*)
  FROM ( SELECT DISTINCT pmsm_prospect2.pmodel_id
    FROM pmsm_prospect2
      WHERE (pmsm_prospect2.pmodelset_id = 13 OR pmsm_prospect2.pmodelset_id = 14) AND 
          (pmsm_prospect2.pmodel_id IN ( SELECT paprospect2.pmodel_id
        FROM paprospect2
        WHERE paprospect2.params_id = 1 AND paprospect2.pseq_id = x.pseq_id
        ORDER BY paprospect2.raw LIMIT 10))
      ORDER BY pmsm_prospect2.pmodel_id) cnt) AS cnt
  FROM pseq x;


CREATE OR REPLACE VIEW cavs.prospect_tm_itim AS
  SELECT DISTINCT r.pseq_id, 
    h.cnt AS "# of top 10 ig/fn3 threads", 
    t."start" AS tm_start, t.stop AS tm_stop, 
    r."start" AS itim_start, r.stop AS itim_stop
  FROM prospect_ig_fn3_IN_top10 h
    JOIN pftmdetect t ON h.pseq_id = t.pseq_id
    JOIN pfregexp r ON h.pseq_id = r.pseq_id
    WHERE h.cnt >= 3 AND 
			t.pftype_id IN (5,6) AND
      r.pmodel_id = 11368857 AND r."start" > t.stop;

DELETE FROM pseqset WHERE pset_id=-30;
INSERT INTO pseqset SELECT DISTINCT -30,pseq_id
FROM cavs.pfam_tm_itim
WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);
 

--DELETE FROM pseqset WHERE pset_id=-35;
--INSERT INTO pseqset SELECT DISTINCT -35,pseq_id
--FROM cavs.prospect_tm_itim
--WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);
                                                                                                                                                                            
-- build a set of pclusters based on known SPDI ITIM seqs
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=1;
INSERT INTO cavs.pclusterset SELECT DISTINCT 1,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=40);

-- build a set of pclusters based on known staub ITIM seqs
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=2;
INSERT INTO cavs.pclusterset SELECT DISTINCT 2,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=45);

-- build a set of pclusters based on putative ITIMS from prospect
-- DELETE FROM cavs.pclusterset WHERE pclustersetname_id=3;
-- INSERT INTO cavs.pclusterset SELECT DISTINCT 3,pcluster_id FROM unison.pcluster_member 
-- WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-35);

-- build a set of pclusters based on putative ITIMS from pfam
-- DELETE FROM cavs.pclusterset WHERE pclustersetname_id=4;
-- INSERT INTO cavs.pclusterset SELECT DISTINCT 4,pcluster_id FROM unison.pcluster_member 
-- WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-30);

-- build a set of pclusters based on novel ITIMS from prospect (take putative AND substract known staub)
-- DELETE FROM cavs.pclusterset WHERE pclustersetname_id=5;
-- INSERT INTO cavs.pclusterset SELECT DISTINCT 5,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=3 EXCEPT
-- SELECT 5,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=2;

-- build a set of pclusters based on novel ITIMS from pfam (take putative AND substract known staub)
-- DELETE FROM cavs.pclusterset WHERE pclustersetname_id=6;
-- INSERT INTO cavs.pclusterset SELECT DISTINCT 6,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=4 EXCEPT
-- SELECT 6,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=2;

-- get a list of pcluster siblings for known SPDI ITIM seqs
DELETE FROM pseqset WHERE pset_id=41;
INSERT INTO pseqset SELECT DISTINCT 41,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=1);

-- get a list of pcluster siblings for known staub ITIM seqs
DELETE FROM pseqset WHERE pset_id=46;
INSERT INTO pseqset SELECT DISTINCT 46,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=2);

-- build list of novel pfam itim seqs by subtract known ITIMs (and pcluster siblings) from set of pfam mined ITIMS
DELETE FROM pseqset WHERE pset_id=-31;
INSERT INTO pseqset SELECT -31,pseq_id FROM pseqset WHERE pset_id=-30 EXCEPT 
  SELECT -31,pseq_id FROM pseqset WHERE pset_id in (41,46);

-- build list of novel prospect ITIM seqs by subtract known ITIMs (AND pcluster siblings) from set of prospect mINed ITIMS
DELETE FROM pseqset WHERE pset_id=-36;
INSERT INTO pseqset SELECT -36,pseq_id FROM pseqset WHERE pset_id=-35 EXCEPT 
  SELECT -36,pseq_id FROM pseqset WHERE pset_id in (41,46);


-- new as of may 10th
delete from pseqset where pset_id=40;
insert into pseqset select distinct 40,pseq_id from palias where alias in (select 'PRO'||proid from spdi);

delete from pseqset where pset_id=-37;
insert into pseqset select distinct -37,pseq_id from pseqset where pset_id in (-31,-36);

DELETE FROM pfam_w_ortholog;
INSERT INTO pfam_w_ortholog SELECT DISTINCT pseq_id1,pseq_id2 
  FROM v_homologene_orthologs
  WHERE tax_id1=9606 AND tax_id2=10090 AND pseq_id1 IN
    (SELECT DISTINCT pseq_id FROM pseqset WHERE pset_id=-37)
  AND pseq_id2 IN (SELECT pseq_id FROM pfam_tm_itim);

delete from pseqset where pset_id=-38;
insert into pseqset select -38,pseq_id1 from pfam_w_ortholog;

DELETE FROM prospect_mouse_orthologs;
INSERT INTO prospect_mouse_orthologs SELECT pseq_id1,pseq_id2 FROM v_homologene_orthologs
    WHERE tax_id1=9606 AND tax_id2=10090 AND pseq_id1 IN
		      (SELECT DISTINCT pseq_id FROM pseqset WHERE pset_id =-37);

INSERT INTO pseqset SELECT -38,pseq_id1 FROM prospect_mouse_orthologs WHERE pseq_id2 IN
(SELECT DISTINCT pseq_id FROM prospect_tm_itim WHERE pseq_id IN
(
45698,58623,1547385,40626,876381,1113721,890337,1240855,
1238118,1416465,1223292,3193254,45686,1243797,1243798,
57960,3190380,1115403,63234,58969,1372210,1229017,2948943,
1379252,1002930,1105058,1237398,1387158,1202325,3198082
))
EXCEPT SELECT * FROM pseqset WHERE pset_id=-38;


-- SELECT pseq_id FROM prospect_tm_itim WHERE pseq_id IN
-- (SELECT DISTINCT pseq_id2 
-- FROM v_homologene_orthologs 
-- WHERE tax_id1=9606 AND tax_id2=10090 AND pseq_id1 IN 
-- (SELECT DISTINCT pseq_id FROM pseqset WHERE pset_id=-36));
		 
