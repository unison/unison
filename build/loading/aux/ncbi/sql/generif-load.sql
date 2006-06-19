\set ON_ERROR_STOP

BEGIN;
TRUNCATE ncbi.generif;
\copy ncbi.generif FROM PSTDIN WITH NULL AS '-'
COMMIT;
ANALYZE ncbi.generif;

SELECT COUNT(*) FROM ncbi.generif;
