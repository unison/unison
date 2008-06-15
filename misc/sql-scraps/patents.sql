CREATE OR REPLACE VIEW patents_pataa_v AS
    SELECT sa.pseq_id, origin, alias, NULL::text AS species, NULL::date as patent_date, NULL::text AS patent_authority, ao.descr FROM 
	pseqalias sa 
	JOIN paliasorigin ao ON sa.palias_id = ao.palias_id
    JOIN origin o ON ao.origin_id = o.origin_id
   	  WHERE ao.origin_id = origin_id('pataa') AND sa.is_current
;
comment on view patents_pataa_v is 'Patents from NCBI''s pataa database';
COMMENT ON COLUMN patents_pataa_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN patents_pataa_v.alias   IS 'pataa concatentated alias for the sequence';
COMMENT ON COLUMN patents_pataa_v.species IS 'patent species (NULL in pataa)';
COMMENT ON COLUMN patents_pataa_v.patent_date IS 'patent date (NULL in pataa)';
COMMENT ON COLUMN patents_pataa_v.patent_authority IS 'patent authority (NULL in pataa)';
COMMENT ON COLUMN patents_pataa_v.descr   IS 'patent and sequence numbers from pataa sequence description';
GRANT SELECT ON TABLE patents_pataa_v TO PUBLIC;



CREATE OR REPLACE VIEW patents_geneseq_v AS
    SELECT sa.pseq_id, origin, alias, t.latin AS species, ("substring"(ao.descr, '\[DT: (\S+)'::text))::date AS patent_date, "substring"(ao.descr, '\[PA:\s+\([^\)]+\)\s+([^\]]+)'::text) AS patent_authority, ao.descr FROM (((pseqalias sa JOIN paliasorigin ao ON ((sa.palias_id = ao.palias_id))) JOIN origin o ON ((ao.origin_id = o.origin_id))) LEFT JOIN tax.spspec t ON ((ao.tax_id = t.tax_id))) WHERE ((ao.origin_id = origin_id('Geneseq'::text)) AND sa.is_current) 
-- DON'T ORDER: ORDER BY ("substring"(ao.descr, '\[DT: (\S+)'::text))::date DESC
;
comment on view patents_geneseq_v is 'Patents from Derwent Geneseq (proprietary; http://scientific.thomsonreuters.com/pharma/geneseq/)';
COMMENT ON COLUMN patents_geneseq_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN patents_geneseq_v.alias   IS 'pataa concatentated alias for the sequence';
COMMENT ON COLUMN patents_geneseq_v.species IS 'patent species';
COMMENT ON COLUMN patents_geneseq_v.patent_date IS 'patent date';
COMMENT ON COLUMN patents_geneseq_v.patent_authority IS 'patent authority';
COMMENT ON COLUMN patents_geneseq_v.descr   IS 'patent application id, title, and sequence info';
GRANT SELECT ON TABLE patents_geneseq_v TO PUBLIC;


create or replace view patents_unsorted_v as
SELECT * FROM patents_pataa_v
UNION ALL
SELECT * FROM patents_geneseq_v
;
comment on view patents_unsorted_v is 'Patents from pataa database and Geneseq, if available';
COMMENT ON COLUMN patents_unsorted_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN patents_unsorted_v.alias   IS 'authority''s alias for the sequence';
COMMENT ON COLUMN patents_unsorted_v.species IS 'patent species (not available in pataa)';
COMMENT ON COLUMN patents_unsorted_v.patent_date IS 'patent date (NULL in pataa)';
COMMENT ON COLUMN patents_unsorted_v.patent_authority IS 'patent authority (NULL in pataa)';
COMMENT ON COLUMN patents_unsorted_v.descr   IS 'descriptions from patents_pataa_v and patents_genseq_v, which see';
GRANT SELECT ON TABLE patents_unsorted_v TO PUBLIC;


create or replace view patents_v as
SELECT * FROM patents_unsorted_v
ORDER by origin = 'pataa'   -- sort pataa after geneseq
;
comment on view patents_v is 'Patents from pataa database and Geneseq, if available';
COMMENT ON COLUMN patents_v.pseq_id IS 'unique protein sequence identifier -- see pseq(pseq_id)';
COMMENT ON COLUMN patents_v.alias   IS 'authority''s alias for the sequence';
COMMENT ON COLUMN patents_v.species IS 'patent species (not available in pataa)';
COMMENT ON COLUMN patents_v.patent_date IS 'patent date (NULL in pataa)';
COMMENT ON COLUMN patents_v.patent_authority IS 'patent authority (NULL in pataa)';
COMMENT ON COLUMN patents_v.descr   IS 'descriptions from patents_pataa_v and patents_genseq_v, which see';
GRANT SELECT ON TABLE patents_v TO PUBLIC;

