BEGIN;
TRUNCATE ncbi.mim2gene;
\copy ncbi.mim2gene FROM PSTDIN WITH NULL AS '-'
UPDATE origin SET last_updated = NOW() WHERE origin='NCBI mim2gene';
COMMIT;
ANALYZE ncbi.mim2gene;

SELECT COUNT(*) FROM ncbi.mim2gene;
