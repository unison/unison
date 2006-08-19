BEGIN;
TRUNCATE hugo.hugo;
\copy hugo.hugo FROM PSTDIN WITH NULL AS ''
COMMIT;
ANALYZE hugo.hugo;

SELECT COUNT(*) FROM hugo.hugo;
