BEGIN;
TRUNCATE "unison-aux".hugo;
\copy "unison-aux".hugo FROM PSTDIN WITH NULL AS ''
COMMIT;
ANALYZE "unison-aux".hugo;

SELECT COUNT(*) FROM "unison-aux".hugo;
