BEGIN;
TRUNCATE unison.hugo;
\copy unison.hugo FROM PSTDIN WITH NULL AS '-'
COMMIT;
ANALYZE unison.hugo;

SELECT COUNT(*) FROM unison.hugo;
