BEGIN;
TRUNCATE ncbi.gene2go;
\copy ncbi.gene2go FROM PSTDIN WITH NULL AS '-'
UPDATE origin SET last_updated = NOW() WHERE origin='NCBI gene2go';
COMMIT;
ANALYZE ncbi.gene2go;

SELECT COUNT(*) FROM ncbi.gene2go;
