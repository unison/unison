\set ON_ERROR_STOP

BEGIN;
TRUNCATE ncbi.gene_info;
\copy ncbi.gene_info FROM STDIN WITH NULL AS '-'
COMMIT;
ANALYZE ncbi.gene_info;

SELECT COUNT(*) FROM ncbi.gene_info;
