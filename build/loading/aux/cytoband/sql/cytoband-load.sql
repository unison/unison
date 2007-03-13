BEGIN;
TRUNCATE "unison_aux".cytoband_hg18;
\copy "unison_aux".cytoband_hg18 FROM PSTDIN WITH NULL AS ''
COMMIT;
ANALYZE "unison_aux".cytoband_hg18;

SELECT COUNT(*) FROM "unison_aux".cytoband_hg18;
