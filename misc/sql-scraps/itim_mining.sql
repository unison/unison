-- -----------------------------------------------------------------------------
-- NAME: itim_mining.sql
-- PURPOSE: sql code for mining Unison for ITIMS
-- 
-- $Id: itim_mining.sql,v 1.3 2004/05/12 23:11:40 cavs Exp $
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW cavs.canonical_itim AS
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

DROP VIEW cavs.pfam_tm_itim;
CREATE OR REPLACE VIEW cavs.pfam_tm_itim AS
  SELECT r.pseq_id, h.eval, h.start as "Pfam_start",h.stop as "Pfam_stop",
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

DROP VIEW prospect_ig_fn3_in_top_10;
CREATE OR REPLACE VIEW prospect_ig_fn3_in_top_10 AS
	SELECT Q.pseq_id,(SELECT count(DISTINCT pmodel_id) FROM 
	((select pmodel_id from paprospect2 A where A.pseq_id=Q.pseq_id and A.params_id=1 
	order by raw limit 10)   intersect   
	(select pmodel_id from pmsm_prospect2 where pmodelset_id in (13,14))) X) as cnt from pseq Q;

CREATE OR REPLACE VIEW cavs.prospect_tm_itim AS
  SELECT DISTINCT r.pseq_id, 
    h.cnt AS "# of top 10 ig/fn3 threads", 
    t."start" AS tm_start, t.stop AS tm_stop, 
    r."start" AS itim_start, r.stop AS itim_stop
  FROM prospect_ig_fn3_in_top_10 h
    JOIN pftmdetect t ON h.pseq_id = t.pseq_id
    JOIN pfregexp r ON h.pseq_id = r.pseq_id
    WHERE h.cnt >= 3 AND 
			t.pftype_id IN (5,6) AND
      r.pmodel_id = 11368857 AND r."start" > t.stop;

 

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

-- mine uni_h for ITIMs using pfam model
--DELETE FROM pseqset WHERE pset_id=-30;
--INSERT INTO pseqset SELECT DISTINCT -30,pseq_id
--FROM cavs.pfam_tm_itim
--WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);

-- build list of novel pfam itim seqs by subtract known ITIMs (and pcluster siblings) from set of pfam mined ITIMS
DELETE FROM pseqset WHERE pset_id=-31;
INSERT INTO pseqset SELECT -31,pseq_id FROM pseqset WHERE pset_id=-30 EXCEPT 
  SELECT -31,pseq_id FROM pseqset WHERE pset_id in (41,46);

-- mine uni_h for ITIMs using prospect model
--DELETE FROM pseqset WHERE pset_id=-35;
	--INSERT INTO pseqset SELECT DISTINCT -35,pseq_id
	--FROM cavs.prospect_tm_itim
	--WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=42);

-- build list of novel prospect ITIM seqs by subtract known ITIMs (AND pcluster siblings) from set of prospect mINed ITIMS
DELETE FROM pseqset WHERE pset_id=-36;
INSERT INTO pseqset SELECT -36,pseq_id FROM pseqset WHERE pset_id=-35 EXCEPT 
  SELECT -36,pseq_id FROM pseqset WHERE pset_id in (41,46);

-- push the novel hits to a bonafide pset
DELETE FROM pseqset WHERE pset_id=47;
INSERT INTO pseqset SELECT DISTINCT 47,pseq_id FROM pseqset WHERE pset_id IN (-31,-36);

-- build a set of pclusters based on already mined ITIMs
DELETE FROM cavs.pclusterset WHERE pclustersetname_id=3;
INSERT INTO cavs.pclusterset SELECT DISTINCT 3,pcluster_id FROM unison.pcluster_member 
  WHERE pseq_id IN (SELECT pseq_id FROM pseqset WHERE pset_id=47);

-- get a list of pcluster siblings for already mined ITIM seqs
DELETE FROM pseqset WHERE pset_id=48;
INSERT INTO pseqset SELECT DISTINCT 48,pseq_id FROM unison.pcluster_member WHERE pcluster_id IN 
  (SELECT pcluster_id FROM cavs.pclusterset WHERE pclustersetname_id=3);

-- get a list of GGI ITIMs from pfam
--DELETE FROM pseqset WHERE pset_id=-39;
--INSERT INTO pseqset SELECT DISTINCT -39,pseq_id FROM 
	--pfam_tm_itim WHERE pseq_id IN 
	--(SELECT pseq_id FROM palias WHERE porigin_id=10047);

-- subtract known staub, known SPDI, already mined, and their genomic siblings from the
-- GGI ITIMs to get a novel GGI set
DELETE FROM pseqset WHERE pset_id=-40;
INSERT INTO pseqset 
	SELECT DISTINCT -40,pseq_id FROM pseqset WHERE pset_id=-39 EXCEPT
	SELECT -40,pseq_id FROM pseqset WHERE pset_id in (41,46,48);

-- get a list of GGI ITIMs from prospect
--DELETE FROM pseqset WHERE pset_id=-41;
--INSERT INTO pseqset SELECT -41,* FROM 
	--(SELECT 
		--(SELECT DISTINCT pti.pseq_id FROM cavs.prospect_tm_itim pti 
		--WHERE pti.pseq_id=S.pseq_id) AS sq FROM palias S WHERE S.porigin_id=10047) 
	--X WHERE X.sq IS NOT NULL;

-- subtract known staub, known SPDI, already mined, and their genomic siblings from the
-- GGI ITIMs to get a novel GGI set
DELETE FROM pseqset WHERE pset_id=-42;
INSERT INTO pseqset 
	SELECT DISTINCT -42,pseq_id FROM pseqset WHERE pset_id=-41 EXCEPT
	SELECT -42,pseq_id FROM pseqset WHERE pset_id in (41,46,48);

