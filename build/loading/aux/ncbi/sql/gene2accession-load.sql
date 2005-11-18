BEGIN;
TRUNCATE ncbi.gene2accession;
\copy ncbi.gene2accession FROM STDIN WITH NULL AS '-'
COMMIT;
ANALYZE ncbi.gene2accession;

SELECT COUNT(*) FROM ncbi.gene2accession;
