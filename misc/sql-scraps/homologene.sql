create view v_homologene as
select H.*,sa.pseq_id from ncbi.homologene H
join paliasorigin oa on H.acc=oa.alias and oa.porigin_id=porigin_id('RefSeq')
join pseqalias sa on oa.palias_id=sa.palias_id;

create view v_homologene_pairs as 
SELECT q.hid, q.pseq_id AS q_pseq_id, q.acc as q_acc, q.tax_id AS q_tax_id, q.gene_symbol as q_gene_symbol,
	          t.pseq_id AS t_pseq_id, t.acc as t_acc, t.tax_id AS t_tax_id, t.gene_symbol as t_gene_symbol
FROM v_homologene q
JOIN v_homologene t ON q.hid = t.hid AND (q.pseq_id <> t.pseq_id OR q.tax_id <> t.tax_id);

create view v_homologene_orthologs as
SELECT *
FROM v_homologene_pairs
WHERE q_tax_id <> t_tax_id;

create view v_homologene_paralogs as
SELECT *
FROM v_homologene_pairs
WHERE q_tax_id = t_tax_id;
