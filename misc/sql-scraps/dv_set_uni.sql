-- see docs/uni-psets for a description of unison sequence sets

CREATE OR REPLACE VIEW dv_pset_uniA as
SELECT distinct Q.pseq_id
  FROM pseq Q
  JOIN v_current_annotations A on A.pseq_id=Q.pseq_id
 WHERE A.origin_id in (origin_id('GenenGenes'),origin_id('RefSeq'),origin_id('UniProt'))
   AND A.tax_id=gs2tax_id('HUMAN')
   AND Q.len>=50 AND Q.len<=1500 AND Q.seq~'^M';

CREATE OR REPLACE VIEW dv_pset_uniB as
SELECT pseq_id FROM pseqset WHERE pset_id=pset_id('uniA')
UNION
SELECT Q.pseq_id
  FROM pseq Q
  JOIN v_current_annotations A on A.pseq_id=Q.pseq_id
 WHERE A.origin_id in (origin_id('GenenGenes'),origin_id('RefSeq'),origin_id('UniProt'))
   AND A.tax_id in (gs2tax_id('HUMAN'),gs2tax_id('MOUSE'),gs2tax_id('RAT'))
   AND Q.len>=50 AND Q.len<=1500;

CREATE OR REPLACE VIEW dv_pset_uniC as
SELECT pseq_id FROM pseqset WHERE pset_id=pset_id('uniB')
UNION
SELECT distinct Q.pseq_id
  FROM pseq Q
  JOIN v_current_annotations A on A.pseq_id=Q.pseq_id
 WHERE A.origin_id in (origin_id('GenenGenes'),origin_id('UniProt'),origin_id('RefSeq'))
   AND A.tax_id in (gs2tax_id('HUMAN'),gs2tax_id('MOUSE'),gs2tax_id('RAT'))
   AND Q.len>=50 AND Q.len<=1500;

CREATE OR REPLACE VIEW dv_pset_uniD as
SELECT pseq_id FROM pseqset WHERE pset_id=pset_id('uniD')
UNION
SELECT distinct Q.pseq_id
  FROM pseq Q
  JOIN v_current_annotations A on A.pseq_id=Q.pseq_id
 WHERE A.origin_id in (origin_id('GenenGenes'),origin_id('UniProt'),origin_id('RefSeq'),origin_id('Geneseq'))
   AND A.tax_id in (gs2tax_id('HUMAN'),gs2tax_id('MOUSE'),gs2tax_id('RAT'),gs2tax_id('YEAST'),gs2tax_id('BRARE'),gs2tax_id('MACMU'))
   AND Q.len>=50 AND Q.len<=2000;

grant select on dv_pset_uniA,dv_pset_uniB,dv_pset_uniC,dv_pset_uniD to PUBLIC;

comment on view dv_pset_uniA is 'defining view for pset uniA';
comment on view dv_pset_uniB is 'defining view for pset uniB';
comment on view dv_pset_uniC is 'defining view for pset uniC';
comment on view dv_pset_uniD is 'defining view for pset uniD';

