-- -----------------------------------------------------------------------------
-- NAME: v_paprospect_scop.sql
-- PURPOSE: build v_paprospect2_scop view
-- 
-- $Id: v_paprospect.sql,v 1.2 2004/03/31 17:56:01 cavs Exp $
-- -----------------------------------------------------------------------------

SET search_path = unison;

DROP VIEW v_paprospect2_scop;
CREATE VIEW v_paprospect2_scop AS
 SELECT t.pseq_id, t.params_id, m.acc, t."start", t.stop, t.nident, round(t.nident::numeric / (t.stop - t."start" + 1)::numeric * 100.0, 0) AS "pct_ident", t.raw::integer AS raw, round(t.svm::numeric, 1) AS svm, round(t.mutation::numeric, 0) AS mutation, round(t.pairwise::numeric, 0) AS pairwise, round(t.singleton::numeric, 0) AS singleton, round(t.gap::numeric, 0) AS gap, cla.cl AS clid, des1.descr AS clname, cla.sf AS sfid, des2.descr AS sfname, cla.dm AS dmid, des3.descr as dmname
   FROM paprospect2 t
   JOIN unison.pmprospect2_scop b ON t.pmodel_id = b.pmodel_id
   JOIN unison.pmprospect2 m ON t.pmodel_id = m.pmodel_id
   LEFT JOIN scop.cla ON b.sunid = cla.sunid
   LEFT JOIN scop.des des1 ON cla.cl = des1.sunid
   LEFT JOIN scop.des des2 ON cla.sf = des2.sunid
   LEFT JOIN scop.des des3 ON cla.dm = des3.sunid
  ORDER BY t.pseq_id ASC,t.svm DESC;

REVOKE ALL ON TABLE v_paprospect2_scop FROM PUBLIC;
GRANT SELECT ON TABLE v_paprospect2_scop TO PUBLIC;
