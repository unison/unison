-- -----------------------------------------------------------------------------
-- NAME: itim_mining.sql
-- PURPOSE: sql code for mining Unison for ITIMS
-- 
-- $Id: itim_mining.sql,v 1.5 2004/06/10 18:04:58 cavs Exp $
-- -----------------------------------------------------------------------------

-- define views for mining --

CREATE OR REPLACE VIEW cavs.canonical_itim AS
  SELECT r.pseq_id, h.start as "Pfam_start",h.stop as "Pfam_stop",
    t.start as "tm_start",t.stop as "tm_stop",
    r.start as "ITIM_start", r.stop as "ITIM_stop"
  FROM pahmm h
    JOIN pftmdetect t ON h.pseq_id = t.pseq_id
    JOIN pfregexp r ON h.pseq_id = r.pseq_id
  WHERE
    h.pmodel_id IN (11356269,10283) AND h.eval <= 0.05 AND
    t.pftype_id IN (5,6) AND t.start > h.stop AND
    r.pmodel_id=11368857 AND r.start > t.stop;

DROP VIEW cavs.pfam_tm_itim;
CREATE OR REPLACE VIEW cavs.pfam_tm_itim AS
  SELECT r.pseq_id, h.eval, h.start as "Pfam_start",h.stop as "Pfam_stop",
    t.start as "tm_start",t.stop as "tm_stop",
    r.start as "ITIM_start", r.stop as "ITIM_stop"
  FROM pahmm h
    JOIN pftmdetect t ON h.pseq_id = t.pseq_id
    JOIN pfregexp r ON h.pseq_id = r.pseq_id
  WHERE
    h.pmodel_id IN (11356269,10283) AND h.eval <= 0.05 AND
    t.pftype_id IN (5,6) AND t.start > h.stop AND
    r.pmodel_id=11368857 AND r.start > t.stop;

DROP VIEW prospect_ig_fn3_in_top_10;
CREATE OR REPLACE VIEW prospect_ig_fn3_in_top_10 AS
  SELECT Q.pseq_id,(SELECT count(DISTINCT pmodel_id) FROM 
  ((SELECT pmodel_id FROM paprospect2 A WHERE A.pseq_id=Q.pseq_id AND A.params_id=1 
  ORDER BY raw ASC LIMIT 10)   INTERSECT   
  (SELECT pmodel_id FROM pmsm_prospect2 WHERE pmodelset_id IN (13,14))) X) AS cnt FROM pseq Q;

CREATE OR REPLACE VIEW cavs.prospect_tm_itim AS
  SELECT DISTINCT r.pseq_id, 
    h.cnt AS "# of top 10 ig/fn3 threads", 
    t."start" AS tm_start, t.stop AS tm_stop, 
    r."start" AS itim_start, r.stop AS itim_stop
  FROM prospect_ig_fn3_in_top_10 h
    JOIN pftmdetect t ON h.pseq_id = t.pseq_id
    JOIN pfregexp r ON h.pseq_id = r.pseq_id
    WHERE h.cnt >= 2 AND 
      t.pftype_id IN (5,6) AND
      r.pmodel_id = 11368857 AND r."start" > t.stop;


-- build sets of known ITIMs for comparison --

-- build a set of pclusters based on known SPDI ITIM seqs
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=1;
INSERT INTO cavs.pclusterset SELECT DISTINCT 1,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=40);

-- get a list of pcluster siblings for known SPDI ITIM seqs
DELETE FROM pseqset WHERE pset_id=41;
INSERT INTO pseqset SELECT DISTINCT 41,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=1);

-- build a set of pclusters based on known staub ITIM seqs
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=2;
INSERT INTO cavs.pclusterset SELECT DISTINCT 2,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=45);

-- get a list of pcluster siblings for known staub ITIM seqs
DELETE FROM pseqset WHERE pset_id=46;
INSERT INTO pseqset SELECT DISTINCT 46,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=2);


-- mine uni_h --

-- mine uni_h for ITIMs using pfam model
DELETE FROM pseqset WHERE pset_id=-30;
INSERT INTO pseqset SELECT DISTINCT -30,pseq_id
FROM cavs.pfam_tm_itim
WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);

-- build list of novel pfam itim seqs by subtract known ITIMs (and pcluster siblings) from set of pfam mined ITIMS
DELETE FROM pseqset WHERE pset_id=-31;
INSERT INTO pseqset SELECT -31,pseq_id FROM pseqset WHERE pset_id=-30 EXCEPT 
  SELECT -31,pseq_id FROM pseqset WHERE pset_id in (41,46);

-- build a set of pclusters based on novel pfam hits
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=3;
INSERT INTO cavs.pclusterset SELECT DISTINCT 3,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-31);

-- mine uni_h for ITIMs using prospect model
DELETE FROM pseqset WHERE pset_id=-35;
  INSERT INTO pseqset SELECT DISTINCT -35,pseq_id
  FROM cavs.prospect_tm_itim
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);

-- build list of novel prospect ITIM seqs by subtract known ITIMs (AND pcluster siblings) from set of prospect mINed ITIMS
DELETE FROM pseqset WHERE pset_id=-36;
INSERT INTO pseqset SELECT -36,pseq_id FROM pseqset WHERE pset_id=-35 EXCEPT 
  SELECT -36,pseq_id FROM pseqset WHERE pset_id in (41,46);

-- build a set of pclusters based on novel prospect hits
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=4;
INSERT INTO cavs.pclusterset SELECT DISTINCT 4,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-36);

-- push the novel hits to a bonafide pset
DELETE FROM pseqset WHERE pset_id=47;
INSERT INTO pseqset SELECT DISTINCT 47,pseq_id FROM pseqset WHERE pset_id IN (-31,-36);

-- get a list of pcluster siblings for already mined ITIM seqs
DELETE FROM pseqset WHERE pset_id=48;
INSERT INTO pseqset SELECT DISTINCT 48,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=3);


-- mine GGI --

-- get a list of GGI ITIMs from pfam
DELETE FROM pseqset WHERE pset_id=-39;
INSERT INTO pseqset SELECT DISTINCT -39,pseq_id FROM 
  pfam_tm_itim WHERE pseq_id IN 
  (SELECT pseq_id FROM palias WHERE porigin_id=10047);

-- subtract known staub, known SPDI, already mined, and their genomic siblings from the
-- GGI ITIMs to get a novel GGI set
DELETE FROM pseqset WHERE pset_id=-40;
INSERT INTO pseqset 
  SELECT DISTINCT -40,pseq_id FROM pseqset WHERE pset_id=-39 EXCEPT
  SELECT -40,pseq_id FROM pseqset WHERE pset_id in (41,46,48);

-- build a set of pclusters based on novel prospect hits
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=5;
INSERT INTO cavs.pclusterset SELECT DISTINCT 5,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-40);

-- get a list of GGI ITIMs from prospect
DELETE FROM pseqset WHERE pset_id=-41;
INSERT INTO pseqset SELECT -41,* FROM 
  (SELECT 
    (SELECT DISTINCT pti.pseq_id FROM cavs.prospect_tm_itim pti 
    WHERE pti.pseq_id=S.pseq_id) AS sq FROM palias S WHERE S.porigin_id=10047) 
  X WHERE X.sq IS NOT NULL;

-- subtract known staub, known SPDI, already mined, and their genomic siblings from the
-- GGI ITIMs to get a novel GGI set
DELETE FROM pseqset WHERE pset_id=-42;
INSERT INTO pseqset 
  SELECT DISTINCT -42,pseq_id FROM pseqset WHERE pset_id=-41 EXCEPT
  SELECT -42,pseq_id FROM pseqset WHERE pset_id in (41,46,48);

-- build a set of pclusters based on novel pfam hits
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=6;
INSERT INTO cavs.pclusterset SELECT DISTINCT 6,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-42);

