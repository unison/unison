BEGIN;
TRUNCATE ncbi.mim2gene;
\copy ncbi.mim2gene FROM PSTDIN WITH NULL AS '-'
COMMIT;
ANALYZE ncbi.mim2gene;

SELECT COUNT(*) FROM ncbi.mim2gene;
