BEGIN;
TRUNCATE ncbi.gene2unigene;
\copy ncbi.gene2unigene FROM PSTDIN
COMMIT;
ANALYZE ncbi.gene2unigene;

SELECT COUNT(*) FROM ncbi.gene2unigene;
