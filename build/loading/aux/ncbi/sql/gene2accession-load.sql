BEGIN;
TRUNCATE ncbi.gene2accession;
\copy ncbi.gene2accession FROM PSTDIN WITH NULL AS '-'
UPDATE origin SET last_updated = NOW() WHERE origin='NCBI gene2accession';
COMMIT;
ANALYZE ncbi.gene2accession;

SELECT COUNT(*) FROM ncbi.gene2accession;
