-- new paprospect views
-- updated for name change (from p2thread) and rename of p2params_id->run_id


SET search_path = unison;

CREATE VIEW v_paprospect2_sf AS
    SELECT t.pseq_id, t.run_id, b.name, t.raw, t.svm, t.mutation, t.pairwise,
t.singleton, t.gap, des.descr AS "SCOP superfamily" FROM (((paprospect2 t
JOIN p2template b ON ((t.pmodel_id = b.pmodel_id))) LEFT JOIN scop.cla ON
((b.sunid = cla.sunid))) LEFT JOIN scop.des ON ((des.sunid = cla.sf)))
ORDER BY t.svm DESC;

REVOKE ALL ON TABLE v_paprospect2_sf FROM PUBLIC;
GRANT SELECT ON TABLE v_paprospect2_sf TO PUBLIC;


CREATE VIEW v_paprospect2_fa AS
    SELECT t.pseq_id, t.run_id, b.name, t.raw, t.svm, t.mutation, t.pairwise,
t.singleton, t.gap, des.descr AS "SCOP family" FROM (((paprospect2 t JOIN
p2template b ON ((t.pmodel_id = b.pmodel_id))) LEFT JOIN scop.cla ON
((b.sunid = cla.sunid))) LEFT JOIN scop.des ON ((des.sunid = cla.fa)))
ORDER BY t.svm DESC;

REVOKE ALL ON TABLE v_paprospect2_fa FROM PUBLIC;
GRANT SELECT ON TABLE v_paprospect2_fa TO PUBLIC;


CREATE VIEW v_paprospect2_cf AS
    SELECT t.pseq_id, t.run_id, b.name, t.raw, t.svm, t.mutation, t.pairwise,
t.singleton, t.gap, des.descr AS "SCOP fold" FROM (((paprospect2 t JOIN
p2template b ON ((t.pmodel_id = b.pmodel_id))) LEFT JOIN scop.cla ON
((b.sunid = cla.sunid))) LEFT JOIN scop.des ON ((des.sunid = cla.cf)))
ORDER BY t.svm DESC;

REVOKE ALL ON TABLE v_paprospect2_cf FROM PUBLIC;
GRANT SELECT ON TABLE v_paprospect2_cf TO PUBLIC;


CREATE VIEW v_paprospect2_scop AS
SELECT t.pseq_id, t.run_id, b.name, t.raw, t.svm, t.mutation,
t.pairwise, t.singleton, t.gap, ((((cfdes.descr || ' / '::text) ||
sfdes.descr) || ' / '::text) || fades.descr) AS "SCOP fold class /
superfamily / family" FROM (((((paprospect2 t JOIN p2template b ON
((t.pmodel_id = b.pmodel_id))) LEFT JOIN scop.cla ON ((b.sunid =
cla.sunid))) LEFT JOIN scop.des cfdes ON ((cfdes.sunid = cla.cf))) LEFT
JOIN scop.des sfdes ON ((sfdes.sunid = cla.sf))) LEFT JOIN scop.des fades
ON ((fades.sunid = cla.fa))) ORDER BY t.svm DESC;

REVOKE ALL ON TABLE v_paprospect2_scop FROM PUBLIC;
GRANT SELECT ON TABLE v_paprospect2_scop TO PUBLIC;
