-- -----------------------------------------------------------------------------
-- NAME: itim_mining.sql
-- PURPOSE: sql code for mining Unison for ITIMS
-- 
-- $Id: itim_mining.sql,v 1.1 2004/05/05 21:47:42 cavs Exp $
-- -----------------------------------------------------------------------------


DROP VIEW cavs.pfam_tm_itim;
CREATE OR REPLACE VIEW cavs.pfam_tm_itim AS
  SELECT DISTINCT r.pseq_id,best_alias(r.pseq_id,true),
                m.name as "Pfam_name",
                h.eval,h.start as "Pfam_start",h.stop as "Pfam_stop",
                t.start as "tm_start",t.stop as "tm_stop",
                r.start as "itim_start",r.stop as "itim_stop"
  FROM pahmm h, pmhmm m, pfregexp r, pftmdetect t
  WHERE h.pmodel_id IN (11356269,10283,11045) AND
                h.eval <= 0.02::double precision AND h.params_id=13 AND
    t.pseq_id = h.pseq_id AND (t.pftype_id=6 or t.pftype_id=5) AND t.start > h.stop AND
    r.pseq_id = t.pseq_id AND r.pmodel_id=11368857 AND r.start > t.stop AND
                m.pmodel_id=h.pmodel_id
  ORDER BY r.pseq_id;

DROP VIEW cavs.tm_itim;
CREATE OR REPLACE VIEW cavs.tm_itim AS
  SELECT DISTINCT r.pseq_id,best_alias(r.pseq_id,true),
                t.start as "tm_start",t.stop as "tm_stop",
                r.start as "itim_start",r.stop as "itim_stop"
  FROM pfregexp r, pftmdetect t
  WHERE 
    (t.pftype_id=6 or t.pftype_id=5) AND
    r.pseq_id = t.pseq_id AND r.pmodel_id=11368857 AND r.start > t.stop
  ORDER BY r.pseq_id;


DROP VIEW cavs.prospect_ig_fn3_IN_top10;
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


DROP VIEW cavs.prospect_tm_itim;
  CREATE OR REPLACE VIEW cavs.prospect_tm_itim AS
  SELECT DISTINCT r.pseq_id, best_alias(r.pseq_id, true) AS best_alias, 
    h.cnt AS "# of top 10 ig/fn3 threads", 
    t."start" AS tm_start, t.stop AS tm_stop, 
    r."start" AS itim_start, r.stop AS itim_stop
    FROM prospect_ig_fn3_IN_top10 h, pfregexp r, pftmdetect t
    WHERE h.cnt >= 3 AND t.pseq_id = h.pseq_id AND (t.pftype_id = 6 OR t.pftype_id = 5) AND 
      r.pseq_id = t.pseq_id AND r.pmodel_id = 11368857 AND r."start" > t.stop
    ORDER BY r.pseq_id, best_alias(r.pseq_id, true), h.cnt, t."start", t.stop, r."start", r.stop;


DELETE FROM pseqset WHERE pset_id=-30;
INSERT INTO pseqset SELECT DISTINCT -30,pseq_id
        FROM cavs.pfam_tm_itim
        WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);
 

DELETE FROM pseqset WHERE pset_id=-35;
INSERT INTO pseqset SELECT DISTINCT -35,pseq_id
        FROM cavs.prospect_tm_itim
        WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);
                                                                                                                                                                            
DROP VIEW cavs.tm_itam;
CREATE OR REPLACE VIEW cavs.tm_itam AS
  SELECT DISTINCT r.pseq_id,best_alias(r.pseq_id,true),
                t.start as "tm_start",t.stop as "tm_stop",
                r.start as "itam_start",r.stop as "itam_stop"
  FROM pfregexp r, pftmdetect t
  WHERE
    (t.pftype_id=6 or t.pftype_id=5) AND
    r.pseq_id = t.pseq_id AND r.pmodel_id=11368858 AND r.start > t.stop
  ORDER BY r.pseq_id;


-- build a set of pclusters based on known SPDI ITIM seqs
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=1;
INSERT INTO cavs.pclusterset SELECT DISTINCT 1,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=40);

-- build a set of pclusters based on known staub ITIM seqs
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=2;
INSERT INTO cavs.pclusterset SELECT DISTINCT 2,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=45);

-- build a set of pclusters based on putative ITIMS from prospect
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=3;
INSERT INTO cavs.pclusterset SELECT DISTINCT 3,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-35);

-- build a set of pclusters based on putative ITIMS from pfam
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=4;
INSERT INTO cavs.pclusterset SELECT DISTINCT 4,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=-30);

-- build a set of pclusters based on novel ITIMS from prospect (take putative AND substract known staub)
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=5;
INSERT INTO cavs.pclusterset SELECT DISTINCT 5,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=3 EXCEPT
  SELECT 5,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=2;

-- build a set of pclusters based on novel ITIMS from pfam (take putative AND substract known staub)
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=6;
INSERT INTO cavs.pclusterset SELECT DISTINCT 6,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=4 EXCEPT
  SELECT 6,pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=2;

-- get a list of pcluster siblings for known SPDI ITIM seqs
DELETE FROM pseqset WHERE pset_id=41;
INSERT INTO pseqset SELECT DISTINCT 41,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=1);

-- get a list of pcluster siblings for known staub ITIM seqs
DELETE FROM pseqset WHERE pset_id=46;
INSERT INTO pseqset SELECT DISTINCT 46,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=2);

-- build list of novel pfam itim seqs by subtract known staub ITIMs (and pcluster siblings) from set of pfam mined ITIMS
DELETE FROM pseqset WHERE pset_id=-31;
INSERT INTO pseqset SELECT -31,pseq_id FROM pseqset WHERE pset_id=-30 EXCEPT 
  SELECT -31,pseq_id FROM pseqset WHERE pset_id=46;

-- build list of novel prospect ITIM seqs by subtract known staub ITIMs (AND pcluster siblings) from set of prospect mINed ITIMS
DELETE FROM pseqset WHERE pset_id=-36;
INSERT INTO pseqset SELECT -36,pseq_id FROM pseqset WHERE pset_id=-35 EXCEPT 
  SELECT -36,pseq_id FROM pseqset WHERE pset_id=46;

