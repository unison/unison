BEGIN;
TRUNCATE ncbi.gene2go;
\copy ncbi.gene2go FROM PSTDIN WITH NULL AS '-'
COMMIT;
ANALYZE ncbi.gene2go;

SELECT COUNT(*) FROM ncbi.gene2go;
