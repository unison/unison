CREATE VIEW dv_ig_prospect_pmodelset AS SELECT DISTINCT
    pmprospect2_scop.pmodel_id FROM pmprospect_scop pmprospect2_scop WHERE
    (pmprospect2_scop.sunid IN (SELECT des.sunid FROM scop.des WHERE
    ((des."level" = 'px'::text) AND (des.sccs ~ 'b[.]1[.]1[.]'::text))))
    ORDER BY pmprospect2_scop.pmodel_id;





CREATE VIEW rkh.prospect_ig_fn3_in_top_10 AS SELECT q.pseq_id, (SELECT
    count(DISTINCT x.pmodel_id) AS count FROM ((SELECT a.pmodel_id FROM
    paprospect a WHERE ((a.pseq_id = q.pseq_id) AND (a.params_id = 1))
    ORDER BY a.raw LIMIT 10) INTERSECT SELECT pmsm_prospect.pmodel_id FROM
    pmsm_prospect pmsm_prospect WHERE ((pmsm_prospect.pmodelset_id = 13)
    OR (pmsm_prospect.pmodelset_id = 14))) x) AS cnt FROM pseq q;
