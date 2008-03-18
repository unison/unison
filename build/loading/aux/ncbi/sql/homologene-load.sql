BEGIN;
TRUNCATE ncbi.homologene;
\copy ncbi.homologene FROM PSTDIN
UPDATE origin SET last_updated = NOW() WHERE origin='HomoloGene';
COMMIT;
ANALYZE ncbi.homologene;

SELECT COUNT(*) FROM ncbi.homologene;
SELECT origin,last_updated FROM origin WHERE origin='HomoloGene';
