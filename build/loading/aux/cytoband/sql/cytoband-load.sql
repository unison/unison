BEGIN;
TRUNCATE "unison_aux".cytoband_hg18;
\copy "unison_aux".cytoband_hg18 (chr,gstart,gstop,band,stain) FROM PSTDIN WITH NULL AS ''
UPDATE "unison_aux".cytoband_hg18 SET genasm_id=(select genasm_id from genasm where name='hg18');
UPDATE origin SET last_updated = NOW() WHERE origin='UCSC hg18';
COMMIT;
ANALYZE "unison_aux".cytoband_hg18;

SELECT COUNT(*) FROM "unison_aux".cytoband_hg18;
