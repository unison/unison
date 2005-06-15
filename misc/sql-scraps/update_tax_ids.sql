create or replace view _v_infer_tax_id_GenenGenes as 
SELECT	A.palias_id,A.tax_id,T.tax_id as inferred_tax_id
  FROM	paliasorigin A
  JOIN	tax.spspec T on upper(substring(descr from '/species=''([^\\'']+)''' ))=T.gs
 WHERE	A.porigin_id=porigin_id('GenenGenes');

create or replace view _v_infer_tax_id_Geneseq as 
SELECT	A.palias_id,A.tax_id,T.tax_id as inferred_tax_id
  FROM	paliasorigin A
  JOIN	tax.spspec T on substring(descr from '\\[OS: ([^\\]]+)' )=T.latin
 WHERE	A.porigin_id=porigin_id('Geneseq');

create or replace view _v_infer_tax_id_Refseq as 
SELECT	A.palias_id,A.tax_id,T.tax_id as inferred_tax_id
  FROM	paliasorigin A
  JOIN	tax.spspec T on substring(descr from '\\[([^\\]]+)\\]$' )=T.latin
 WHERE	A.porigin_id=porigin_id('Refseq');

create or replace view _v_infer_tax_id_UniProt as 
SELECT	A.palias_id,A.tax_id,T.tax_id as inferred_tax_id
  FROM	paliasorigin A
  JOIN	tax.spspec T on substr(A.alias,strpos(A.alias,'_')+1)=T.gs
 WHERE	A.porigin_id=porigin_id('UniProt') AND A.alias ~ '_';

create or replace view _v_infer_tax_id as
select porigin_id('GenenGenes'),* from _v_infer_tax_id_GenenGenes
UNION
select porigin_id('Geneseq'),* from _v_infer_tax_id_Geneseq
UNION
select porigin_id('Refseq'),* from _v_infer_tax_id_Refseq
UNION
select porigin_id('UniProt'),* from _v_infer_tax_id_UniProt
;

create or replace view _v_infer_tax_id_changed as
SELECT * from _v_infer_tax_id
 WHERE (tax_id is NULL and inferred_tax_id is not null)
		OR (tax_id is not NULL and inferred_tax_id is null)
        OR (tax_id != inferred_tax_id) ;

create or replace function update_tax_ids () returns void
language sql as 'update paliasorigin set tax_id=inferred_tax_id from _v_infer_tax_id_changed where paliasorigin.palias_id=_v_infer_tax_id_changed.palias_id;';

comment on function update_tax_ids() is 'update paliasorigin.tax_id as necessary based on tax_ids inferred from origin, alias, and description';
