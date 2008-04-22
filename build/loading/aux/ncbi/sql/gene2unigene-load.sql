BEGIN;
TRUNCATE ncbi.gene2unigene;
\copy ncbi.gene2unigene FROM PSTDIN
UPDATE origin SET last_updated = NOW() WHERE origin='NCBI gene2unigene';
COMMIT;
ANALYZE ncbi.gene2unigene;

SELECT COUNT(*) FROM ncbi.gene2unigene;
