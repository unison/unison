\set ON_ERROR_STOP

BEGIN;
TRUNCATE ncbi.generif;
\copy ncbi.generif FROM PSTDIN WITH NULL AS '-'
UPDATE origin SET last_updated = NOW() WHERE origin='NCBI GeneRIF';
COMMIT;
ANALYZE ncbi.generif;

SELECT COUNT(*) FROM ncbi.generif;
