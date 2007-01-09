BEGIN;
TRUNCATE "unison-aux".cytoband_hg18;
\copy "unison-aux".cytoband_hg18 FROM PSTDIN WITH NULL AS ''
COMMIT;
ANALYZE "unison-aux".cytoband_hg18;

SELECT COUNT(*) FROM "unison-aux".cytoband_hg18;
