begin;
truncate ncbi.homologene;
\copy ncbi.homologene from stdin
update porigin set last_updated = now() where origin='HomoloGene';
commit;
analyze ncbi.homologene;

select count(*) from ncbi.homologene;
select origin,last_updated from porigin where origin='HomoloGene';
