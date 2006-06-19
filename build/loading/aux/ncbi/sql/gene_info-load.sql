\set ON_ERROR_STOP

BEGIN;
TRUNCATE ncbi.gene_info;
\copy ncbi.gene_info FROM PSTDIN WITH NULL AS '-'
COMMIT;
ANALYZE ncbi.gene_info;

SELECT COUNT(*) FROM ncbi.gene_info;
