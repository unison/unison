BEGIN;
TRUNCATE ncbi.gene2unigene;
\copy ncbi.gene2unigene FROM STDIN
COMMIT;
ANALYZE ncbi.gene2unigene;

SELECT COUNT(*) FROM ncbi.gene2unigene;
