\set ON_ERROR_STOP

BEGIN;
TRUNCATE ncbi.gene_info;
\copy ncbi.gene_info FROM PSTDIN WITH NULL AS '-'
UPDATE origin SET last_updated = NOW() WHERE origin='NCBI gene info';
COMMIT;
ANALYZE ncbi.gene_info;

SELECT COUNT(*) FROM ncbi.gene_info;
