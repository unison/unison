BEGIN;
TRUNCATE ncbi.homologene;
\copy ncbi.homologene FROM PSTDIN
UPDATE origin SET last_updated = NOW() WHERE origin='NCBI HomoloGene';
COMMIT;
ANALYZE ncbi.homologene;

SELECT COUNT(*) FROM ncbi.homologene;
SELECT origin,last_updated FROM origin WHERE origin='NCBI HomoloGene';
