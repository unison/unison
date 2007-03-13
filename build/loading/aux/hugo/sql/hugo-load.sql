BEGIN;
TRUNCATE "unison_aux".hugo;
\copy "unison_aux".hugo FROM PSTDIN WITH NULL AS ''
COMMIT;
ANALYZE "unison_aux".hugo;

SELECT COUNT(*) FROM "unison_aux".hugo;
